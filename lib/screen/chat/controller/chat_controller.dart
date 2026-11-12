import 'dart:async';

import 'package:alo_ride_driver_app/screen/chat/controller/chat_unread_controller.dart';
import 'package:alo_ride_driver_app/screen/chat/model/chat_models.dart';
import 'package:alo_ride_driver_app/screen/chat/service/chat_api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// What the chat screen is allowed to do right now.
enum ChatAccess {
  /// First load hasn't answered yet.
  loading,

  /// Room is active — reading and sending both allowed.
  open,

  /// Ride completed or cancelled — history readable, input replaced by a banner.
  closed,

  /// 400: no driver on the ride. Should not normally be reachable from the
  /// driver app, but a re-assignment race can produce it.
  waitingForDriver,

  /// 403: the room belongs to the driver who cancelled. Leave the screen.
  notParticipant,

  /// Initial load failed for a reason worth retrying (network, 500, ...).
  error,
}

/// Polling chat for one ride.
///
/// Rules that keep this from getting buggy, all enforced here:
///  * one timer, cancelled in [onClose] and while backgrounded;
///  * `lastMessageId` only ever moves from SERVER ids, never optimistic ones;
///  * every incoming message is deduped by id before it is appended;
///  * a send in flight blocks the send button, so a double tap can't double post.
class ChatController extends GetxController with WidgetsBindingObserver {
  ChatController({
    required this.rideId,
    this.otherPartyName = '',
    this.otherPartyMobile = '',
    this.otherPartyPhoto = '',
  });

  final int rideId;
  final String otherPartyName;
  final String otherPartyMobile;
  final String otherPartyPhoto;

  static const Duration pollInterval = Duration(seconds: 3);
  static const int pageSize = 30;
  static const int maxMessageLength = 2000;

  /// A poll with `last_message_id` only returns NEW rows, so read receipts on
  /// messages already on screen would never flip. Every Nth tick re-reads the
  /// latest page instead, which refreshes `is_read` on our own bubbles.
  static const int _fullSyncEveryTicks = 5;

  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final Rx<ChatAccess> access = ChatAccess.loading.obs;
  final RxBool initialLoading = true.obs;
  final RxBool loadingOlder = false.obs;
  final RxBool sending = false.obs;
  final RxBool hasMoreOlder = false.obs;
  final RxBool showNewMessagePill = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool hasDraft = false.obs;

  final TextEditingController input = TextEditingController();
  final FocusNode inputFocus = FocusNode();

  /// `reverse: true`, so offset 0 is the BOTTOM (newest) of the thread.
  final ScrollController scroll = ScrollController();

  final Set<int> _seenIds = <int>{};
  Timer? _timer;
  bool _polling = false;
  int _tick = 0;
  int? _lastMessageId;

  bool get canSend => access.value == ChatAccess.open && !sending.value;

  /// NOT named `isClosed` — GetxController already owns that name for its own
  /// disposal flag.
  bool get isChatClosed => access.value == ChatAccess.closed;

  /// True while the thread has nothing but the empty state to show.
  bool get isEmpty => messages.isEmpty;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);

    scroll.addListener(_onScroll);
    input.addListener(() => hasDraft.value = input.text.trim().isNotEmpty);

    _loadInitial();
  }

  @override
  void onClose() {
    // A timer left alive here is the classic leak: it keeps firing after the
    // screen is gone and writes into a disposed controller.
    _stopPolling();
    WidgetsBinding.instance.removeObserver(this);
    scroll.removeListener(_onScroll);
    scroll.dispose();
    input.dispose();
    inputFocus.dispose();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Catch up immediately rather than waiting out a full interval.
      _pollNow();
      _startPolling();
    } else {
      _stopPolling();
    }
  }

  // ── Loading ────────────────────────────────────────────────────────────────

  Future<void> _loadInitial() async {
    initialLoading.value = true;
    errorMessage.value = '';
    try {
      final page = await ChatApiService.fetchMessages(
        rideId: rideId,
        perPage: pageSize,
      );
      _applyPage(page, incrementalPoll: false);
      access.value = page.isClosed ? ChatAccess.closed : ChatAccess.open;

      if (!page.isClosed) _startPolling();

      // Opening the thread clears its badge on both sides.
      unawaited(_markRead());
    } on ChatFailure catch (e) {
      _applyFailure(e, isInitial: true);
    } finally {
      initialLoading.value = false;
    }
  }

  /// Manual retry from the error state.
  Future<void> retryInitialLoad() => _loadInitial();

  Future<void> loadOlder() async {
    if (loadingOlder.value || !hasMoreOlder.value || messages.isEmpty) return;

    // Temp bubbles have no server id, so pagination anchors on the oldest real
    // message.
    ChatMessage? oldest;
    for (final message in messages) {
      if (!message.isTemp) {
        oldest = message;
        break;
      }
    }
    if (oldest == null) return;

    loadingOlder.value = true;
    try {
      final page = await ChatApiService.fetchMessages(
        rideId: rideId,
        beforeId: oldest.id,
        perPage: pageSize,
      );
      final fresh = page.messages.where((m) => _seenIds.add(m.id)).toList();
      if (fresh.isNotEmpty) messages.insertAll(0, fresh);
      hasMoreOlder.value = page.hasMoreOlder;
    } on ChatFailure catch (e) {
      debugPrint('[CHAT] loadOlder failed: ${e.message}');
    } finally {
      loadingOlder.value = false;
    }
  }

  // ── Polling ────────────────────────────────────────────────────────────────

  void _startPolling() {
    if (_timer != null) return;
    if (access.value == ChatAccess.closed) return;
    _timer = Timer.periodic(pollInterval, (_) => _pollNow());
  }

  void _stopPolling() {
    _timer?.cancel();
    _timer = null;
  }

  /// Public one-shot poll — used by the FCM handler when a chat push lands
  /// while this thread is already open, so the message appears at once.
  Future<void> pollOnce() => _pollNow();

  Future<void> _pollNow() async {
    if (_polling) return;
    if (access.value == ChatAccess.closed ||
        access.value == ChatAccess.notParticipant ||
        access.value == ChatAccess.waitingForDriver) {
      _stopPolling();
      return;
    }

    _polling = true;
    try {
      _tick++;
      final fullSync = _lastMessageId == null || _tick % _fullSyncEveryTicks == 0;

      final page = await ChatApiService.fetchMessages(
        rideId: rideId,
        lastMessageId: fullSync ? null : _lastMessageId,
        perPage: pageSize,
      );

      final incoming = _applyPage(page, incrementalPoll: !fullSync);

      if (page.isClosed) {
        access.value = ChatAccess.closed;
        _stopPolling();
      }

      if (incoming.any((m) => !m.isMine)) {
        unawaited(_markRead());
      }
    } on ChatFailure catch (e) {
      _applyFailure(e, isInitial: false);
    } finally {
      _polling = false;
    }
  }

  /// Merges a page into the thread and returns the messages that were new.
  ///
  /// [incrementalPoll] marks a `last_message_id` response: it only ever carries
  /// rows we have never seen, and it says nothing useful about older pages. A
  /// full read of the latest page (initial load / periodic full sync) instead
  /// updates rows already on screen — that is how read ticks flip — and is the
  /// only thing allowed to move `has_more_older`.
  List<ChatMessage> _applyPage(
    ChatThreadPage page, {
    required bool incrementalPoll,
  }) {
    final fresh = <ChatMessage>[];

    for (final message in page.messages) {
      if (_seenIds.contains(message.id)) {
        if (!incrementalPoll) {
          final index = messages.indexWhere((m) => m.id == message.id);
          if (index != -1 && messages[index].isRead != message.isRead) {
            messages[index] = message;
          }
        }
        continue;
      }
      _seenIds.add(message.id);
      fresh.add(message);
    }

    if (fresh.isNotEmpty) {
      final wasAtBottom = _isNearBottom;
      messages.addAll(fresh);
      // Only SERVER ids may advance the cursor — an optimistic negative id here
      // would make every later poll ask for messages "newer than -1770...".
      final highest = fresh.map((m) => m.id).reduce((a, b) => a > b ? a : b);
      if (_lastMessageId == null || highest > _lastMessageId!) {
        _lastMessageId = highest;
      }

      if (wasAtBottom) {
        _scrollToBottomSoon();
      } else if (fresh.any((m) => !m.isMine)) {
        // Don't yank a driver who scrolled up to read history.
        showNewMessagePill.value = true;
      }
    }

    if (!incrementalPoll) hasMoreOlder.value = page.hasMoreOlder;

    messages.refresh();
    return fresh;
  }

  void _applyFailure(ChatFailure failure, {required bool isInitial}) {
    switch (failure.kind) {
      case ChatErrorKind.noDriverAssigned:
        access.value = ChatAccess.waitingForDriver;
        errorMessage.value = failure.message;
        _stopPolling();
        break;
      case ChatErrorKind.notParticipant:
        access.value = ChatAccess.notParticipant;
        errorMessage.value = failure.message;
        _stopPolling();
        break;
      case ChatErrorKind.chatClosed:
        access.value = ChatAccess.closed;
        _stopPolling();
        break;
      case ChatErrorKind.rideNotFound:
        access.value = ChatAccess.error;
        errorMessage.value = failure.message;
        _stopPolling();
        break;
      default:
        // Transient: a dropped poll is not an error state, the next tick retries.
        if (isInitial) {
          access.value = ChatAccess.error;
          errorMessage.value = failure.message;
        } else {
          debugPrint('[CHAT] poll failed: ${failure.message}');
        }
    }
  }

  Future<void> _markRead() async {
    try {
      await ChatApiService.markRead(rideId: rideId);
      ChatUnreadController.instance.clearRide(rideId);
    } on ChatFailure catch (e) {
      debugPrint('[CHAT] markRead failed: ${e.message}');
    }
  }

  // ── Sending ────────────────────────────────────────────────────────────────

  Future<void> sendCurrentInput() async {
    final text = input.text.trim();
    if (text.isEmpty) return;
    input.clear();
    hasDraft.value = false;
    await sendText(text);
  }

  /// Also used by the quick-reply chips — they are plain text messages.
  Future<void> sendText(String rawText) async {
    final text = rawText.trim();
    if (text.isEmpty || !canSend) return;

    final safeText = text.length > maxMessageLength
        ? text.substring(0, maxMessageLength)
        : text;

    final temp = ChatMessage.optimistic(
      tempId: -DateTime.now().millisecondsSinceEpoch,
      text: safeText,
      now: DateTime.now(),
    );

    sending.value = true;
    messages.add(temp);
    _scrollToBottomSoon();

    try {
      final saved = await ChatApiService.sendMessage(
        rideId: rideId,
        message: safeText,
      );
      _replaceTemp(temp.id, saved);
    } on ChatFailure catch (e) {
      _markTempFailed(temp.id);
      if (e.kind == ChatErrorKind.chatClosed) {
        access.value = ChatAccess.closed;
        _stopPolling();
      } else if (e.kind == ChatErrorKind.notParticipant) {
        access.value = ChatAccess.notParticipant;
        _stopPolling();
      }
      Get.snackbar(
        'Message not sent',
        e.message,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(8),
        duration: const Duration(seconds: 3),
      );
    } finally {
      sending.value = false;
    }
  }

  /// Tap on a failed bubble: drop it and send the same text again.
  Future<void> retryFailed(ChatMessage failed) async {
    if (!failed.isTemp) return;
    messages.removeWhere((m) => m.id == failed.id);
    await sendText(failed.message);
  }

  void discardFailed(ChatMessage failed) {
    if (!failed.isTemp) return;
    messages.removeWhere((m) => m.id == failed.id);
  }

  void _replaceTemp(int tempId, ChatMessage saved) {
    final index = messages.indexWhere((m) => m.id == tempId);

    // The 3s poll can land between the POST and its response and already hold
    // the saved row — dropping the temp bubble is then the whole job.
    if (_seenIds.contains(saved.id)) {
      if (index != -1) messages.removeAt(index);
      return;
    }

    _seenIds.add(saved.id);
    if (index == -1) {
      messages.add(saved);
    } else {
      messages[index] = saved;
    }
    if (_lastMessageId == null || saved.id > _lastMessageId!) {
      _lastMessageId = saved.id;
    }
    messages.refresh();
    _scrollToBottomSoon();
  }

  void _markTempFailed(int tempId) {
    final index = messages.indexWhere((m) => m.id == tempId);
    if (index == -1) return;
    messages[index] = messages[index].copyWith(sendStatus: ChatSendStatus.failed);
    messages.refresh();
  }

  Future<void> deleteMessage(ChatMessage message) async {
    if (message.isTemp) {
      discardFailed(message);
      return;
    }
    try {
      await ChatApiService.deleteMessage(messageId: message.id);
      messages.removeWhere((m) => m.id == message.id);
      _seenIds.remove(message.id);
    } on ChatFailure catch (e) {
      Get.snackbar(
        'Could not delete',
        e.message,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(8),
      );
    }
  }

  // ── Scrolling ──────────────────────────────────────────────────────────────

  /// `reverse: true` puts the newest message at offset 0.
  bool get _isNearBottom {
    if (!scroll.hasClients) return true;
    return scroll.position.pixels <= 120;
  }

  void _onScroll() {
    if (!scroll.hasClients) return;

    if (_isNearBottom && showNewMessagePill.value) {
      showNewMessagePill.value = false;
    }

    // In a reversed list the OLDEST messages sit at the far end of the extent.
    final position = scroll.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      loadOlder();
    }
  }

  void jumpToLatest() {
    showNewMessagePill.value = false;
    if (!scroll.hasClients) return;
    scroll.animateTo(
      0,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  void _scrollToBottomSoon() {
    showNewMessagePill.value = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scroll.hasClients) return;
      scroll.jumpTo(0);
    });
  }
}
