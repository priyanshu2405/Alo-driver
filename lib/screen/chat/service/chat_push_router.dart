import 'dart:async';

import 'package:alo_ride_driver_app/screen/chat/controller/chat_controller.dart';
import 'package:alo_ride_driver_app/screen/chat/controller/chat_unread_controller.dart';
import 'package:alo_ride_driver_app/screen/chat/view/chat_entry_button.dart';
import 'package:alo_ride_driver_app/services/token_store.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Everything that turns a chat push into an open chat screen.
///
/// One place, because the three delivery paths must behave identically:
///
///   terminated / cold start -> FirebaseMessaging.getInitialMessage()
///   backgrounded tray tap   -> FirebaseMessaging.onMessageOpenedApp
///   foreground              -> FirebaseMessaging.onMessage (local notification)
///
/// Payload contract — `ride_id` is the ONLY id, and it arrives as a STRING:
///
///   notification.title : sender's name
///   notification.body  : message text (80 chars)
///   data.type          : "chat"
///   data.ride_id       : "480"
///
/// Every other data key on a chat push is an empty string, so nothing else is
/// read here. The chat screen fetches whatever it needs from `ride_id` alone.
class ChatPushRouter {
  const ChatPushRouter._();

  static const String _tag = '[CHAT-PUSH]';

  /// The ride whose chat screen is currently on top. Set by `ChatScreen` in
  /// initState, cleared in dispose.
  ///
  /// Two jobs: suppress the banner for a thread already being read, and stop a
  /// tap from stacking a second copy of the same screen — each copy would run
  /// its own 3s poll, doubling requests and duplicating bubbles.
  static int? currentChatRideId;

  /// A tap that landed before the session was restored. Replayed by
  /// [flushPending] once login is done — never push chat over a login screen.
  static int? _pendingChatRideId;

  /// False until startup routing has settled (splash -> dashboard) or a login
  /// has just completed. Pushing a chat screen before that point puts it under
  /// whatever the splash navigates to next, so the tap looks like it did
  /// nothing at all.
  static bool _appReady = false;

  /// Safety net for a parked tap. If startup routing never reports ready (an
  /// early exception, an unexpected launch path), the tap would sit in
  /// [_pendingChatRideId] forever and the user would see a tap that did
  /// nothing. Released after this delay instead.
  static Timer? _readyFallback;

  static bool isChatPayload(Map<String, dynamic> data) =>
      data['type']?.toString() == 'chat';

  /// `ride_id` is a String in an FCM data payload. `int.parse` on a null or
  /// empty value throws and kills the whole handler, so this is always
  /// `tryParse` + a null check at the call site.
  static int? rideIdOf(Map<String, dynamic> data) =>
      int.tryParse(data['ride_id']?.toString() ?? '');

  /// Exposed so the notification router can gate non-chat routes on a session
  /// too — pushing any screen over the login flow looks like a dead tap.
  static bool get isLoggedIn => _isLoggedIn;

  static bool get _isLoggedIn {
    if (!Get.isRegistered<AuthController>()) return false;
    return Get.find<AuthController>().isAuthenticated;
  }

  /// Handles a notification TAP (background tray, or cold start).
  ///
  /// Returns true when the payload was a chat push, so callers can fall
  /// through to their own handling otherwise.
  static bool handlePushTap(Map<String, dynamic> data) {
    if (!isChatPayload(data)) return false;

    final rideId = rideIdOf(data);
    if (rideId == null) {
      debugPrint('$_tag tap with no usable ride_id — ignored | data=$data');
      return true;
    }

    if (!_appReady || !_isLoggedIn) {
      debugPrint(
        '$_tag tap parked | ride=$rideId | appReady=$_appReady '
        '| loggedIn=$_isLoggedIn',
      );
      _pendingChatRideId = rideId;
      _armReadyFallback();
      return true;
    }

    openChat(rideId);
    return true;
  }

  /// Whether a FOREGROUND push must be delivered silently — no alert, no sound.
  ///
  /// Only one case qualifies: a chat message for the thread already on screen.
  /// Alerting there would talk over the conversation the user is reading, so
  /// the thread just pulls the message in instead.
  ///
  /// Everything else (including chat for another ride) returns false and gets
  /// the normal notification, so the foreground behaves like the tray does.
  static bool suppressAlertFor(Map<String, dynamic> data) {
    if (!isChatPayload(data)) return false;

    final rideId = rideIdOf(data);
    if (rideId == null) return false;

    if (currentChatRideId == rideId) {
      debugPrint('$_tag push for the open thread ($rideId) — silent, polling');
      pollOpenThread(rideId);
      return true;
    }

    // Alerting anyway, but keep the badge honest while we are at it.
    if (Get.isRegistered<ChatUnreadController>()) {
      unawaited(Get.find<ChatUnreadController>().refreshNow());
    }
    return false;
  }

  /// Nudges an open thread to fetch immediately instead of waiting out its
  /// 3s tick.
  static void pollOpenThread(int rideId) {
    final tag = 'chat_$rideId';
    if (Get.isRegistered<ChatController>(tag: tag)) {
      unawaited(Get.find<ChatController>(tag: tag).pollOnce());
    }
  }

  /// Opens a ride's thread, guarding against a duplicate on top of itself.
  static void openChat(int rideId) {
    if (currentChatRideId == rideId) {
      debugPrint('$_tag ride $rideId already open — not stacking');
      return;
    }

    _afterFrame(() {
      debugPrint('$_tag opening chat for ride $rideId');
      openRideChat(rideId: rideId);
    });
  }

  /// Called once the session is restored (splash routing / OTP verified), so a
  /// cold-start tap that arrived too early — or while logged out — still lands.
  static void flushPending() {
    if (!_appReady) debugPrint('$_tag app ready — chat navigation unblocked');
    _appReady = true;
    _readyFallback?.cancel();
    _readyFallback = null;

    final rideId = _pendingChatRideId;
    if (rideId == null) return;

    // Still logged out (splash routed to login): keep the tap parked so it
    // lands after the OTP screen calls back in, rather than being dropped.
    if (!_isLoggedIn) {
      debugPrint('$_tag ready but logged out — keeping ride=$rideId parked');
      return;
    }

    _pendingChatRideId = null;
    debugPrint('$_tag replaying parked tap | ride=$rideId');
    openChat(rideId);
  }

  /// Releases a parked tap even if nothing ever calls [flushPending].
  static void _armReadyFallback() {
    _readyFallback?.cancel();
    _readyFallback = Timer(const Duration(seconds: 8), () {
      debugPrint('$_tag ready callback never fired — releasing parked tap');
      flushPending();
    });
  }

  /// Runs [action] once the navigator is mounted.
  ///
  /// A cold start consumes `getInitialMessage()` before the first frame; a push
  /// issued then is silently dropped, which is close to impossible to debug.
  static void _afterFrame(VoidCallback action) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.key.currentState == null) {
        // Navigator still not attached — try again on the next frame.
        WidgetsBinding.instance.addPostFrameCallback((_) => action());
        return;
      }
      action();
    });
  }
}
