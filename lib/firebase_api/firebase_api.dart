import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:alo_ride_driver_app/firebase_options.dart';
import 'package:alo_ride_driver_app/screen/chat/service/chat_push_router.dart';
import 'package:alo_ride_driver_app/screen/dashboard/controller/dashboard_conroller.dart';
import 'package:alo_ride_driver_app/screen/dashboard/screen/dashboard_screen.dart';
import 'package:alo_ride_driver_app/screen/home/controller/home_controller.dart';
import 'package:alo_ride_driver_app/services/token_store.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

/// ============================================================================
/// PUSH NOTIFICATIONS — NEW RIDE REQUEST
/// ============================================================================
///
/// Expected FCM payload from the backend when a customer requests a ride.
/// The `notification` block is what makes the alert appear while the app is in
/// the background or fully closed (iOS *requires* it), and the `data` block is
/// what the app uses to open the New Ride Request card:
///
/// {
///   "token": "DRIVER_FCM_TOKEN",
///   "notification": { "title": "New Ride Request", "body": "Pickup: ..." },
///   "data": {
///     "screen": "new_ride_request",
///     "click_action": "FLUTTER_NOTIFICATION_CLICK",
///     "ride_id": "131", "user_id": "7",
///     "trip_type": "...", "distance_km": "4.2", "total_fare": "120",
///     "pickup_address": "...", "drop_address": "...",
///     "pickup_datetime": "...", "type": "...",
///     "user_name": "...", "user_image": "..."
///   },
///   "android": { "priority": "high" },
///   "apns": { "headers": { "apns-priority": "10" } }
/// }
///
/// Every stage of the tap flow logs with the [_tag] prefix — filter the console
/// on `NOTIF` to see whether a tap was received and whether navigation ran.
/// ============================================================================

const String _tag = '[NOTIF]';

/// Single channel, using the device's default notification sound.
///
/// The id is VERSIONED on purpose. Android freezes a channel's importance and
/// sound the first time it is created and ignores every later change, so a
/// device that installed an older build keeps the old (possibly silent)
/// settings forever. Publishing a new id is the only way to hand out new ones —
/// bump the suffix whenever the sound or importance below changes, and keep the
/// old id in [kRetiredChannelIds] so the stale channel is removed.
const String kDefaultChannelId = 'alo_driver_alerts_v2';

/// Channels from earlier builds, deleted on startup so users don't end up with
/// duplicate entries in Android's notification settings.
const List<String> kRetiredChannelIds = ['high_importance_channel'];

/// Dashboard tab holding the New Ride Request screen (`MyRideView`), i.e. the
/// "New Request" item in [CommonBottomBar].
const int kNewRideRequestTab = 1;

final FlutterLocalNotificationsPlugin _localNotifications =
    FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel _defaultChannel = AndroidNotificationChannel(
  kDefaultChannelId,
  'Ride & message alerts',
  description: 'Ride requests, ride updates and chat messages.',
  // max, not high: heads-up over whatever is on screen, including our own app.
  importance: Importance.max,
  playSound: true,
  enableVibration: true,
  showBadge: true,
);

/// True when the message is a chat message from the customer.
///
/// Chat payloads carry `ride_id` too, so this has to be checked *before*
/// [isRideRequestPayload] or every message would open the New Ride Request tab.
bool isChatPayload(Map<String, dynamic> data) =>
    ChatPushRouter.isChatPayload(data);

/// True when the message describes an incoming ride request.
///
/// `screen == "home"` is kept for backwards compatibility with payloads the
/// backend already sends.
bool isRideRequestPayload(Map<String, dynamic> data) {
  if (isChatPayload(data)) return false;

  final marker = (data['screen'] ?? data['type'] ?? '').toString();
  if (marker == 'home' ||
      marker == 'new_ride' ||
      marker == 'new_ride_request' ||
      marker == 'ride_request' ||
      marker == 'new_ride_assigned') {
    return true;
  }

  // Every ride push carries `ride_id`, so it cannot be used as the marker on
  // its own — a completed/cancelled/paid ride would open the New Ride Request
  // tab. Those types are known and explicitly not ride requests.
  if (kNonRideRequestTypes.contains(marker)) return false;

  return data['ride_id'] != null;
}

/// Push types that share the channel with ride requests but must never open
/// the New Ride Request tab.
const Set<String> kNonRideRequestTypes = {
  'chat',
  'ride_update',
  'ride_completed',
  'ride_cancelled',
  'payment_received',
};

/// Uses the channel's (device default) notification sound on both platforms.
///
/// On Android the sound comes from the CHANNEL; these values only matter on
/// pre-Oreo devices, but they must agree with the channel or the notification
/// posts silently there.
NotificationDetails _notificationDetails() => const NotificationDetails(
  android: AndroidNotificationDetails(
    kDefaultChannelId,
    'Ride & message alerts',
    channelDescription: 'Ride requests, ride updates and chat messages.',
    importance: Importance.max,
    priority: Priority.high,
    playSound: true,
    enableVibration: true,
    icon: '@mipmap/ic_launcher',
  ),
  iOS: DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  ),
);

/// Creates the notification channel. Safe to call repeatedly and from the
/// background isolate.
Future<void> _createChannels() async {
  final android = _localNotifications
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();
  if (android == null) return;

  // Drop superseded channels first, so their frozen settings (and their row in
  // the system notification settings screen) go away.
  for (final retired in kRetiredChannelIds) {
    await android.deleteNotificationChannel(channelId: retired);
  }
  await android.createNotificationChannel(_defaultChannel);
}

/// Renders [m] as a local notification whose tap payload carries [m.data].
Future<void> _showLocalNotification(RemoteMessage m) async {
  final data = Map<String, dynamic>.from(m.data);
  final isRide = isRideRequestPayload(data);

  // The one case that must stay silent: a chat message for the thread the
  // driver is already reading. It lands in the open conversation instead.
  if (ChatPushRouter.suppressAlertFor(data)) return;

  debugPrint('$_tag showing local notification | isRide=$isRide | data=$data');

  await _localNotifications.show(
    id: m.messageId?.hashCode ?? m.hashCode,
    title: m.notification?.title ??
        data['title']?.toString() ??
        (isRide ? 'New Ride Request' : 'Alo Driver'),
    body:
        m.notification?.body ??
        data['body']?.toString() ??
        (isRide
            ? (data['pickup_address']?.toString().isNotEmpty == true
                  ? 'Pickup: ${data['pickup_address']}'
                  : 'You have a new ride request')
            : ''),
    notificationDetails: _notificationDetails(),
    payload: jsonEncode(data),
  );
}

/// Background / terminated isolate handler.
///
/// Messages that carry a `notification` block are drawn by the OS itself, so we
/// only render data-only messages here (Android). Doing both would show the
/// notification twice.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  debugPrint(
    '$_tag background message | id=${message.messageId} '
    '| hasNotificationBlock=${message.notification != null} '
    '| data=${message.data}',
  );

  if (message.notification != null) return;
  if (message.data.isEmpty) return;
  // Chat pushes always carry a notification block; a data-only one still must
  // not be drawn twice.
  if (isChatPayload(Map<String, dynamic>.from(message.data))) return;

  await NotificationService.initLocalNotifications();
  await _showLocalNotification(message);
}

class NotificationService {
  static final FirebaseMessaging _fm = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _ln = _localNotifications;
  final _box = GetStorage();

  static bool _initialized = false;
  static bool _localInitialized = false;

  /// Set once the app has finished its startup routing (see [notifyAppReady]).
  /// Until then a notification tap is parked in [_pendingData] — navigating
  /// before/while the splash screen routes would immediately be overwritten by
  /// `Get.offAll` in `SplashController`.
  static bool _appReady = false;
  static Map<String, dynamic>? _pendingData;
  static Timer? _readyFallback;

  Future<void> initialize() async {
    // `initialize()` is called from `main()` and again after OTP verification;
    // re-running it would register duplicate message listeners.
    if (_initialized) {
      debugPrint('$_tag initialize() already done — skipping');
      return;
    }
    _initialized = true;
    debugPrint('$_tag initialize() start');

    await _requestPermissions();
    await initLocalNotifications();

    // NOT awaited: fetching the FCM token hits the network (and on iOS waits on
    // APNs), which would delay `runApp` by seconds. A cold start triggered by a
    // notification tap must reach the first frame immediately.
    unawaited(_saveToken());

    _fm.onTokenRefresh.listen((newToken) async {
      await _box.write('fcm_token', newToken);
      debugPrint('$_tag FCM token refreshed: $newToken');
    });

    // Our own local notification is shown in the foreground, so iOS must not
    // also present the incoming push (it would alert twice).
    await _fm.setForegroundNotificationPresentationOptions(
      alert: false,
      badge: false,
      sound: false,
    );

    // FOREGROUND: draw the alert ourselves so it is visible and tappable.
    FirebaseMessaging.onMessage.listen((msg) {
      debugPrint('$_tag onMessage (foreground) | data=${msg.data}');
      _showLocalNotification(msg);
    });

    // BACKGROUND TAP: app was alive but backgrounded, FCM drew the notification.
    FirebaseMessaging.onMessageOpenedApp.listen((msg) {
      debugPrint('$_tag onMessageOpenedApp (background tap) | data=${msg.data}');
      _handleTap(Map<String, dynamic>.from(msg.data));
    });

    // TERMINATED TAP: the tap launched the process, FCM drew the notification.
    final initial = await _fm.getInitialMessage();
    debugPrint(
      '$_tag getInitialMessage -> ${initial == null ? 'null (normal launch)' : initial.data}',
    );
    if (initial != null) {
      _handleTap(Map<String, dynamic>.from(initial.data));
    }

    // TERMINATED TAP on a notification we drew ourselves from the background
    // isolate (data-only message). These never surface through
    // `getInitialMessage`, so they need their own cold-start check.
    final launch = await _ln.getNotificationAppLaunchDetails();
    final payload = launch?.notificationResponse?.payload;
    debugPrint(
      '$_tag notificationAppLaunchDetails -> '
      'didLaunch=${launch?.didNotificationLaunchApp} | payload=$payload',
    );
    if (launch?.didNotificationLaunchApp == true &&
        payload != null &&
        payload.isNotEmpty) {
      _handleTap(_decode(payload));
    }

    debugPrint('$_tag initialize() done');
  }

  /// Initialises flutter_local_notifications and the channels. Also called from
  /// the background isolate, which has its own copy of the plugin state.
  static Future<void> initLocalNotifications() async {
    if (_localInitialized) return;
    _localInitialized = true;

    const init = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      ),
    );

    await _localNotifications.initialize(
      settings: init,
      onDidReceiveNotificationResponse: (res) {
        // Tap on a notification drawn by flutter_local_notifications
        // (foreground, or a data-only message rendered in the background).
        debugPrint('$_tag local notification tapped | payload=${res.payload}');
        final payload = res.payload;
        if (payload == null || payload.isEmpty) return;
        _handleTap(_decode(payload));
      },
    );

    await _createChannels();
    debugPrint('$_tag local notifications initialised');
  }

  Future<void> _requestPermissions() async {
    // Also triggers the Android 13+ POST_NOTIFICATIONS runtime prompt.
    final settings = await _fm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('Notification permission: ${settings.authorizationStatus}');
  }

  Future<void> _saveToken() async {
    // On iOS the FCM token is only available once APNs has handed one over.
    if (Platform.isIOS) {
      for (int i = 0; i < 5; i++) {
        try {
          if (await _fm.getAPNSToken() != null) break;
        } catch (e) {
          debugPrint('APNS token attempt ${i + 1} failed: $e');
        }
        await Future.delayed(const Duration(seconds: 2));
      }
    }

    String? token;
    for (int i = 0; i < 5; i++) {
      try {
        token = await _fm.getToken();
        if (token != null) break;
      } catch (e) {
        debugPrint('FCM token attempt ${i + 1} failed: $e');
      }
      await Future.delayed(const Duration(seconds: 2));
    }

    if (token != null) {
      await _box.write('fcm_token', token);
      debugPrint('FCM Token saved: $token');
    } else {
      debugPrint('FCM token could not be retrieved.');
    }
  }

  static Map<String, dynamic> _decode(String payload) {
    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (e) {
      debugPrint('Notification payload decode failed: $e');
    }
    return <String, dynamic>{};
  }

  // ---------------- NAVIGATION CORE ----------------

  /// Called by `SplashController` once the app has routed past the splash
  /// screen, so a tap that launched the app from a terminated state can be
  /// replayed without being clobbered by the splash `Get.offAll`.
  static void notifyAppReady() {
    if (!_appReady) debugPrint('$_tag app ready — navigation unblocked');
    _appReady = true;
    _readyFallback?.cancel();
    _readyFallback = null;

    final pending = _pendingData;
    if (pending == null) return;
    _pendingData = null;
    debugPrint('$_tag replaying parked notification tap | data=$pending');
    _safeNavigate(() => _goToScreen(pending));
  }

  static void _handleTap(Map<String, dynamic> data) {
    debugPrint('$_tag TAP RECEIVED | appReady=$_appReady | data=$data');

    if (data.isEmpty) {
      debugPrint('$_tag tap ignored — empty data payload');
      return;
    }

    if (!_appReady) {
      // Parked: navigating now would be undone by `SplashController`'s
      // `Get.offAll`. `notifyAppReady()` replays it once routing is done.
      debugPrint('$_tag tap parked until app finishes startup routing');
      _pendingData = data;

      // Safety net: if the splash flow never reports ready (early error, an
      // unexpected launch path), release the tap anyway rather than losing it.
      _readyFallback?.cancel();
      _readyFallback = Timer(const Duration(seconds: 8), () {
        debugPrint('$_tag ready-callback never fired — releasing parked tap');
        notifyAppReady();
      });
      return;
    }
    _safeNavigate(() => _goToScreen(data));
  }

  /// Returns the registered instance of [T], creating it only when absent.
  ///
  /// Plain `Get.put` would *replace* a live controller, leaving the widgets
  /// that already hold the previous instance listening to a dead one.
  static T _findOrPut<T>(T Function() create) =>
      Get.isRegistered<T>() ? Get.find<T>() : Get.put<T>(create());

  static void _goToScreen(Map<String, dynamic> data) {
    // Chat first, and before the auth check: the router parks the tap itself
    // when the session isn't restored yet.
    if (ChatPushRouter.handlePushTap(data)) return;

    final auth = _findOrPut<AuthController>(() => AuthController());
    if (!auth.isAuthenticated) {
      debugPrint('$_tag navigation skipped — driver is not logged in');
      return;
    }

    final onDashboard = Get.currentRoute.contains('DashboardScreen');
    final isRide = isRideRequestPayload(data);
    debugPrint(
      '$_tag navigating | type=${data['type']} | isRideRequest=$isRide | '
      'currentRoute=${Get.currentRoute} | alreadyOnDashboard=$onDashboard',
    );

    if (!onDashboard) {
      // Only a ride REQUEST opens on the New Request tab. A ride_completed /
      // ride_cancelled / payment_received tap shares this channel and must land
      // on the dashboard's default tab instead.
      Get.offAll(
        () => DashboardScreen(
          initialIndex: isRide ? kNewRideRequestTab : null,
        ),
      );
    }

    if (!isRide) {
      debugPrint('$_tag not a ride-request payload — stopped at dashboard');
      return;
    }

    // Resolved *after* navigating: `DashboardScreen` / `HomeScreen` register
    // their own controllers as they build, and `HomeScreen.dispose()` hides the
    // ride card — so the request is applied once the transition has settled,
    // against whichever instance the visible screen is actually using.
    Future.delayed(Duration(milliseconds: onDashboard ? 0 : 500), () {
      try {
        _findOrPut<DashBoardController>(
          () => DashBoardController(),
        ).changeIndex(kNewRideRequestTab);

        // Keep the home ride card in sync with the pushed request (existing
        // behaviour), so both entry points show the same ride.
        _findOrPut<HomeController>(() => HomeController()).setRideRequest(data);

        debugPrint('$_tag opened New Ride Request (tab $kNewRideRequestTab)');
      } catch (e) {
        debugPrint('$_tag could not open ride request from notification: $e');
      }
    });
  }

  /// Runs [fn] once the widget tree has a frame, so `Get` has a live navigator.
  static void _safeNavigate(VoidCallback fn) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.key.currentState == null) {
        // Navigator not attached yet — retry on the following frame.
        debugPrint('$_tag navigator not ready, retrying next frame');
        WidgetsBinding.instance.addPostFrameCallback((_) => fn());
        return;
      }
      fn();
    });
  }

  static Future<String?> getToken() async {
    try {
      return await _fm.getToken();
    } catch (e) {
      debugPrint('FCM token error: $e');
      return null;
    }
  }
}
