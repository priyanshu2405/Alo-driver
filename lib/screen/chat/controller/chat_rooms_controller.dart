import 'dart:async';

import 'package:alo_ride_driver_app/screen/chat/model/chat_models.dart';
import 'package:alo_ride_driver_app/screen/chat/service/chat_api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Backs the "Messages" list. Deliberately slower than the thread poll (10s vs
/// 3s) — a conversation list does not need per-second freshness.
class ChatRoomsController extends GetxController with WidgetsBindingObserver {
  static const Duration pollInterval = Duration(seconds: 10);

  final RxList<ChatRoomSummary> rooms = <ChatRoomSummary>[].obs;
  final RxBool loading = true.obs;
  final RxString errorMessage = ''.obs;

  Timer? _timer;
  bool _inFlight = false;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    load(showSpinner: true);
    _start();
  }

  @override
  void onClose() {
    _stop();
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      load();
      _start();
    } else {
      _stop();
    }
  }

  void _start() {
    if (_timer != null) return;
    _timer = Timer.periodic(pollInterval, (_) => load());
  }

  void _stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> load({bool showSpinner = false}) async {
    if (_inFlight) return;
    _inFlight = true;
    if (showSpinner) loading.value = true;

    try {
      rooms.value = await ChatApiService.fetchRooms();
      errorMessage.value = '';
    } on ChatFailure catch (e) {
      // Keep whatever is already on screen; only an empty list is worth an error.
      if (rooms.isEmpty) errorMessage.value = e.message;
      debugPrint('[CHAT] rooms failed: ${e.message}');
    } finally {
      loading.value = false;
      _inFlight = false;
    }
  }
}
