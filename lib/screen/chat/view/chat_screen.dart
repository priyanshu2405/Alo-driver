import 'package:alo_ride_driver_app/res/common/app_text.dart';
import 'package:alo_ride_driver_app/res/constant/app_colors.dart';
import 'package:alo_ride_driver_app/res/utils/app_responsive.dart';
import 'package:alo_ride_driver_app/screen/chat/controller/chat_controller.dart';
import 'package:alo_ride_driver_app/screen/chat/model/chat_models.dart';
import 'package:alo_ride_driver_app/screen/chat/service/chat_push_router.dart';
import 'package:alo_ride_driver_app/screen/chat/view/chat_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

/// In-ride chat with the customer.
///
/// Polling only — the controller owns the 3s timer and stops it on dispose and
/// while the app is backgrounded.
class ChatScreen extends StatefulWidget {
  final int rideId;
  final String customerName;
  final String customerMobile;
  final String customerPhoto;

  const ChatScreen({
    super.key,
    required this.rideId,
    this.customerName = '',
    this.customerMobile = '',
    this.customerPhoto = '',
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  /// Uber/Rapido style canned replies, from the driver's side of the ride.
  static const List<String> _quickReplies = [
    "On my way",
    "I have arrived",
    "Waiting at pickup",
    "Please come out",
    "Running 5 min late",
  ];

  late final ChatController controller;
  late final Worker _accessWorker;
  bool _quickRepliesExpanded = false;

  @override
  void initState() {
    super.initState();
    // Marks this thread as the one on screen: a push for it shows no banner,
    // and a tap on it won't stack a second copy running a second poll timer.
    ChatPushRouter.currentChatRideId = widget.rideId;

    // Tagged per ride so opening a different thread never reuses this one's
    // timer, cursor or dedupe set.
    controller = Get.put(
      ChatController(
        rideId: widget.rideId,
        otherPartyName: widget.customerName,
        otherPartyMobile: widget.customerMobile,
        otherPartyPhoto: widget.customerPhoto,
      ),
      tag: 'chat_${widget.rideId}',
    );

    // 403 "not a participant" happens when the ride was re-assigned and the
    // room still belongs to the driver who left — leave quietly, never crash.
    _accessWorker = ever<ChatAccess>(controller.access, (state) {
      if (!mounted) return;
      if (state == ChatAccess.notParticipant) {
        Get.back();
        Get.snackbar(
          'Chat unavailable',
          'This conversation belongs to another driver.',
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(8),
        );
      }
    });
  }

  @override
  void dispose() {
    if (ChatPushRouter.currentChatRideId == widget.rideId) {
      ChatPushRouter.currentChatRideId = null;
    }
    _accessWorker.dispose();
    Get.delete<ChatController>(tag: 'chat_${widget.rideId}');
    super.dispose();
  }

  Future<void> _callCustomer() async {
    final number = widget.customerMobile.trim();
    if (number.isEmpty) {
      Get.snackbar(
        'No number',
        'This customer has no phone number on the ride.',
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(8),
      );
      return;
    }
    final uri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Obx(() {
          switch (controller.access.value) {
            case ChatAccess.loading:
              return const Center(child: CircularProgressIndicator());

            case ChatAccess.waitingForDriver:
              return _CenteredNotice(
                icon: Icons.hourglass_empty,
                title: 'Chat not available yet',
                subtitle: 'This ride does not have an assigned driver.',
              );

            case ChatAccess.notParticipant:
              // The worker above is already popping this screen.
              return const SizedBox.shrink();

            case ChatAccess.error:
              return _CenteredNotice(
                icon: Icons.wifi_off,
                title: 'Could not load messages',
                subtitle: controller.errorMessage.value,
                actionLabel: 'Try again',
                onAction: controller.retryInitialLoad,
              );

            case ChatAccess.open:
            case ChatAccess.closed:
              return _buildThread();
          }
        }),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0.5,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new, size: 18.sp, color: AppColors.black),
        onPressed: () => Get.back(),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          ChatAvatar(photo: widget.customerPhoto, size: 38.r),
          Gap(10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                AppText(
                  text: widget.customerName.isEmpty ? 'Customer' : widget.customerName,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                AppText(
                  text: 'Customer',
                  fontSize: 11,
                  color: AppColors.lightGrayText,
                ),
              ],
            ),
          ),
        ],
      ),
      // actions: [
      //   IconButton(
      //     tooltip: 'Call customer',
      //     onPressed: _callCustomer,
      //     icon: Icon(Icons.call, color: AppColors.greenColor, size: 22.r),
      //   ),
      //   Gap(4.w),
      // ],
    );
  }

  Widget _buildThread() {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              Obx(() {
                if (controller.initialLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.messages.isEmpty) {
                  return _CenteredNotice(
                    icon: Icons.chat_bubble_outline,
                    title: 'Message your customer',
                    subtitle: 'Let them know where you are or if you need a moment.',
                  );
                }
                return _buildMessageList();
              }),
              Obx(() {
                if (!controller.showNewMessagePill.value) {
                  return const SizedBox.shrink();
                }
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: _NewMessagesPill(onTap: controller.jumpToLatest),
                  ),
                );
              }),
            ],
          ),
        ),
        Obx(
          () => controller.isChatClosed ? const _ClosedBanner() : _buildComposer(),
        ),
      ],
    );
  }

  Widget _buildMessageList() {
    final items = controller.messages;

    return ListView.builder(
      controller: controller.scroll,
      reverse: true,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      itemCount: items.length + 1,
      itemBuilder: (context, index) {
        // Trailing slot in a reversed list = the very top of the thread.
        if (index == items.length) {
          return Obx(
            () => controller.loadingOlder.value
                ? Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    child: const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          );
        }

        final position = items.length - 1 - index;
        final message = items[position];
        final previous = position == 0 ? null : items[position - 1];

        return Column(
          children: [
            if (_needsDaySeparator(previous, message))
              _DaySeparator(label: _dayLabel(message.createdAt)),
            _MessageBubble(
              message: message,
              onRetry: () => controller.retryFailed(message),
              onLongPress: message.isMine && !message.isTemp
                  ? () => _confirmDelete(message)
                  : null,
            ),
          ],
        );
      },
    );
  }

  Widget _buildComposer() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.lightGray)),
      ),
      padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 8.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildQuickReplies(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Obx(() {
                // Chips stay out of the way once the conversation is going.
                if (controller.messages.isEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: EdgeInsets.only(right: 6.w, bottom: 2.h),
                  child: InkWell(
                    onTap: () => setState(
                      () => _quickRepliesExpanded = !_quickRepliesExpanded,
                    ),
                    borderRadius: BorderRadius.circular(20.r),
                    child: Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _quickRepliesExpanded ? Icons.close : Icons.add,
                        size: 20.r,
                        color: AppColors.lightGrayText,
                      ),
                    ),
                  ),
                );
              }),
              Expanded(
                child: Container(
                  constraints: BoxConstraints(maxHeight: 120.h),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(22.r),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
                  child: TextField(
                    controller: controller.input,
                    focusNode: controller.inputFocus,
                    minLines: 1,
                    maxLines: 5,
                    textCapitalization: TextCapitalization.sentences,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(
                        ChatController.maxMessageLength,
                      ),
                    ],
                    style: TextStyle(fontSize: 14.sp, color: AppColors.black),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      hintText: 'Message',
                      hintStyle: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.greyColor,
                      ),
                    ),
                    onSubmitted: (_) => controller.sendCurrentInput(),
                  ),
                ),
              ),
              Gap(8.w),
              Obx(() {
                // Disabled while a send is in flight — a double tap must not
                // post the same message twice.
                final enabled = controller.canSend && controller.hasDraft.value;
                return GestureDetector(
                  onTap: enabled ? controller.sendCurrentInput : null,
                  child: Container(
                    width: 42.r,
                    height: 42.r,
                    decoration: BoxDecoration(
                      color: enabled ? AppColors.secondary : AppColors.lightGray,
                      shape: BoxShape.circle,
                    ),
                    child: controller.sending.value
                        ? Padding(
                            padding: EdgeInsets.all(11.r),
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(AppColors.white),
                            ),
                          )
                        : Icon(
                            Icons.send_rounded,
                            size: 20.r,
                            color: enabled ? AppColors.white : AppColors.greyColor,
                          ),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickReplies() {
    return Obx(() {
      final show = controller.messages.isEmpty || _quickRepliesExpanded;
      if (!show) return const SizedBox.shrink();

      return Container(
        height: 40.h,
        margin: EdgeInsets.only(bottom: 8.h),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _quickReplies.length,
          separatorBuilder: (_, __) => Gap(8.w),
          itemBuilder: (context, index) {
            final reply = _quickReplies[index];
            return GestureDetector(
              onTap: controller.canSend
                  ? () {
                      controller.sendText(reply);
                      if (_quickRepliesExpanded) {
                        setState(() => _quickRepliesExpanded = false);
                      }
                    }
                  : null,
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: AppColors.lightGray),
                ),
                child: AppText(
                  text: reply,
                  fontSize: 12,
                  color: AppColors.textColor,
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Future<void> _confirmDelete(ChatMessage message) async {
    await Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
        ),
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.delete_outline, color: AppColors.red),
                title: AppText(text: 'Delete message', fontSize: 14),
                onTap: () {
                  Get.back();
                  controller.deleteMessage(message);
                },
              ),
              ListTile(
                leading: Icon(Icons.copy, color: AppColors.lightGrayText),
                title: AppText(text: 'Copy', fontSize: 14),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: message.message));
                  Get.back();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  static bool _needsDaySeparator(ChatMessage? previous, ChatMessage current) {
    final currentDate = current.createdAt;
    if (currentDate == null) return false;
    final previousDate = previous?.createdAt;
    if (previousDate == null) return true;
    return !_isSameDay(previousDate, currentDate);
  }

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static String _dayLabel(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    if (_isSameDay(date, now)) return 'Today';
    if (_isSameDay(date, now.subtract(const Duration(days: 1)))) return 'Yesterday';
    return DateFormat('dd MMM').format(date);
  }
}

// ── Pieces ───────────────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback onRetry;
  final VoidCallback? onLongPress;

  const _MessageBubble({
    required this.message,
    required this.onRetry,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    // Alignment comes from `is_mine` only — the server computed it from the
    // token, and sender ids are not comparable across user/driver tables.
    final mine = message.isMine;
    final failed = message.sendStatus == ChatSendStatus.failed;

    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: onLongPress,
        onTap: failed ? onRetry : null,
        child: Container(
          constraints: BoxConstraints(maxWidth: 0.75.sw),
          margin: EdgeInsets.only(bottom: 8.h),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: mine ? AppColors.secondary : AppColors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(14.r),
              topRight: Radius.circular(14.r),
              bottomLeft: Radius.circular(mine ? 14.r : 4.r),
              bottomRight: Radius.circular(mine ? 4.r : 14.r),
            ),
            border: mine ? null : Border.all(color: AppColors.lightGray),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              AppText(
                text: message.message,
                fontSize: 13.5,
                color: mine ? AppColors.white : AppColors.textColor,
                overflow: TextOverflow.visible,
                textAlign: TextAlign.start,
              ),
              Gap(2.h),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppText(
                    text: failed
                        ? 'Tap to retry'
                        : _time(message.createdAt),
                    fontSize: 10,
                    color: failed
                        ? (mine ? AppColors.white : AppColors.red)
                        : (mine
                            ? AppColors.white.withOpacity(0.85)
                            : AppColors.greyColor),
                  ),
                  if (mine && !failed) ...[
                    Gap(4.w),
                    _statusIcon(),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusIcon() {
    if (message.sendStatus == ChatSendStatus.sending) {
      return Icon(
        Icons.access_time,
        size: 12.r,
        color: AppColors.white.withOpacity(0.85),
      );
    }
    return Icon(
      message.isRead ? Icons.done_all : Icons.done,
      size: 13.r,
      color: message.isRead ? AppColors.white : AppColors.white.withOpacity(0.7),
    );
  }

  static String _time(DateTime? date) =>
      date == null ? '' : DateFormat('HH:mm').format(date);
}

class _DaySeparator extends StatelessWidget {
  final String label;

  const _DaySeparator({required this.label});

  @override
  Widget build(BuildContext context) {
    if (label.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: AppColors.lightGray,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: AppText(text: label, fontSize: 11, color: AppColors.lightGrayText),
      ),
    );
  }
}

class _NewMessagesPill extends StatelessWidget {
  final VoidCallback onTap;

  const _NewMessagesPill({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: AppColors.blueColor,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.arrow_downward, size: 14.r, color: AppColors.white),
            Gap(6.w),
            AppText(text: 'New messages', fontSize: 12, color: AppColors.white),
          ],
        ),
      ),
    );
  }
}

class _ClosedBanner extends StatelessWidget {
  const _ClosedBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.lightGray,
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
      child: AppText(
        text: 'This chat has ended',
        fontSize: 13,
        color: AppColors.lightGrayText,
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _CenteredNotice extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _CenteredNotice({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 46.r, color: AppColors.greyColor),
            Gap(12.h),
            AppText(
              text: title,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              textAlign: TextAlign.center,
              overflow: TextOverflow.visible,
            ),
            Gap(6.h),
            AppText(
              text: subtitle,
              fontSize: 12.5,
              color: AppColors.lightGrayText,
              textAlign: TextAlign.center,
              overflow: TextOverflow.visible,
            ),
            if (actionLabel != null) ...[
              Gap(16.h),
              TextButton(
                onPressed: onAction,
                child: AppText(
                  text: actionLabel!,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
