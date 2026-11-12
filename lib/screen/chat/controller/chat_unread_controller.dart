import 'dart:async';

import 'package:alo_ride_driver_app/screen/chat/model/chat_models.dart';
import 'package:alo_ride_driver_app/screen/chat/service/chat_api_service.dart';
import 'package:alo_ride_driver_app/services/token_store.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Drives the unread badge on the chat entry points.
///
/// A badge does not need to be live to the second, so this polls far slower
/// than the chat screen itself (20s vs 3s) and pauses in the background.
class ChatUnreadController extends GetxController with WidgetsBindingObserver {
  static const Duration pollInterval = Duration(seconds: 20);

  final Rx<ChatUnreadSummary> summary = const ChatUnreadSummary.empty().obs;

  Timer? _timer;
  bool _inFlight = false;

  /// The one shared instance. Widgets call this instead of `Get.put`, which
  /// would replace a live controller and orphan the widgets holding the old one.
  static ChatUnreadController get instance => Get.isRegistered<ChatUnreadController>()
      ? Get.find<ChatUnreadController>()
      : Get.put(ChatUnreadController(), permanent: true);

  int get total => summary.value.total;

  int unreadFor(int rideId) => summary.value.byRideId[rideId] ?? 0;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    start();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _timer = null;
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      start();
    } else {
      stop();
    }
  }

  void start() {
    if (_timer != null) return;
    refreshNow();
    _timer = Timer.periodic(pollInterval, (_) => refreshNow());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> refreshNow() async {
    if (_inFlight) return;

    final auth = Get.isRegistered<AuthController>() ? Get.find<AuthController>() : null;
    if (auth == null || !auth.isAuthenticated) return;

    _inFlight = true;
    try {
      summary.value = await ChatApiService.fetchUnreadCount();
    } on ChatFailure catch (e) {
      // A badge is never worth an error surface — the next tick retries.
      debugPrint('[CHAT] unread-count failed: ${e.message}');
    } finally {
      _inFlight = false;
    }
  }

  /// Zeroes one ride locally the moment its thread is opened, so the badge
  /// clears immediately instead of waiting up to 20s for the next poll.
  void clearRide(int rideId) {
    final current = summary.value;
    final removed = current.byRideId[rideId] ?? 0;
    if (removed == 0) return;

    final rooms = Map<int, int>.from(current.byRideId)..remove(rideId);
    summary.value = ChatUnreadSummary(
      total: (current.total - removed).clamp(0, 1 << 30),
      byRideId: rooms,
    );
  }
}
