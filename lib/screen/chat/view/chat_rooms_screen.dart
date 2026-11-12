import 'package:alo_ride_driver_app/res/common/app_appbar.dart';
import 'package:alo_ride_driver_app/res/common/app_text.dart';
import 'package:alo_ride_driver_app/res/constant/app_colors.dart';
import 'package:alo_ride_driver_app/res/utils/app_responsive.dart';
import 'package:alo_ride_driver_app/screen/chat/controller/chat_rooms_controller.dart';
import 'package:alo_ride_driver_app/screen/chat/model/chat_models.dart';
import 'package:alo_ride_driver_app/screen/chat/view/chat_avatar.dart';
import 'package:alo_ride_driver_app/screen/chat/view/chat_entry_button.dart';
import 'package:alo_ride_driver_app/screen/chat/view/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

/// All conversations, active and ended. Closed rooms stay readable.
class ChatRoomsScreen extends StatelessWidget {
  const ChatRoomsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChatRoomsController());

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const AppAppBar(title: 'Messages'),
      body: Obx(() {
        if (controller.loading.value && controller.rooms.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.rooms.isEmpty) {
          return RefreshIndicator(
            onRefresh: () => controller.load(),
            child: ListView(
              children: [
                Gap(120.h),
                Icon(
                  Icons.forum_outlined,
                  size: 46.r,
                  color: AppColors.greyColor,
                ),
                Gap(12.h),
                AppText(
                  text: controller.errorMessage.value.isEmpty
                      ? 'No conversations yet'
                      : controller.errorMessage.value,
                  fontSize: 13,
                  color: AppColors.lightGrayText,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.visible,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.load(),
          child: ListView.separated(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            itemCount: controller.rooms.length,
            separatorBuilder: (_, __) =>
                Divider(height: 1, color: AppColors.lightGray),
            itemBuilder: (context, index) =>
                _RoomTile(room: controller.rooms[index]),
          ),
        );
      }),
    );
  }
}

class _RoomTile extends StatelessWidget {
  final ChatRoomSummary room;

  const _RoomTile({required this.room});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChatRoomsController());
    final name = room.otherParty?.name.isNotEmpty == true
        ? room.otherParty!.name
        : 'Customer';

    final profilePhoto = room.otherParty?.profilePhoto ?? '';

    return ListTile(
      // onTap: () => openRideChat(
      //   rideId: room.rideId,
      //   customerName: name,
      //   customerMobile: room.otherParty?.mobile ?? '',
      // ),
      onTap: () {
        Get.to(
          () => ChatScreen(
            rideId: room.rideId,
            customerName: name,
            customerMobile: room.otherParty?.mobile ?? '',
            customerPhoto: profilePhoto,
          ),
        )?.then((value) {
          controller.load();
        });
      },
      leading: ChatAvatar(photo: profilePhoto, size: 44.r),
      title: Row(
        children: [
          Expanded(
            child: AppText(
              text: name,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          AppText(
            text: _stamp(room.lastMessageAt),
            fontSize: 11,
            color: AppColors.greyColor,
          ),
        ],
      ),
      subtitle: Padding(
        padding: EdgeInsets.only(top: 2.h),
        child: Row(
          children: [
            Expanded(
              child: AppText(
                text: room.lastMessage?.message ?? 'No messages yet',
                fontSize: 12.5,
                color: AppColors.lightGrayText,
                maxLines: 1,
              ),
            ),
            if (room.unreadCount > 0) ...[
              Gap(8.w),
              UnreadDot(count: room.unreadCount),
            ] else if (room.isClosed) ...[
              Gap(8.w),
              AppText(text: 'Ended', fontSize: 10, color: AppColors.greyColor),
            ],
          ],
        ),
      ),
    );
  }

  /// Time for today, weekday inside the last week, date beyond that.
  static String _stamp(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final sameDay =
        date.year == now.year && date.month == now.month && date.day == now.day;
    if (sameDay) return DateFormat('HH:mm').format(date);
    if (now.difference(date).inDays < 7) return DateFormat('EEE').format(date);
    return DateFormat('dd MMM').format(date);
  }
}
