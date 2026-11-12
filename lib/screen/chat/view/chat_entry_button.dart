import 'package:alo_ride_driver_app/res/common/app_text.dart';
import 'package:alo_ride_driver_app/res/constant/app_colors.dart';
import 'package:alo_ride_driver_app/res/utils/app_responsive.dart';
import 'package:alo_ride_driver_app/res/utils/ride_status_flow.dart';
import 'package:alo_ride_driver_app/screen/chat/controller/chat_unread_controller.dart';
import 'package:alo_ride_driver_app/screen/chat/view/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// When a ride has a live chat room.
///
/// The room is created server-side the moment the driver accepts, and closes
/// (read-only) on completion / cancellation. Before an accept there is no room
/// at all, which is why the button has to be hidden rather than disabled.
class ChatAvailability {
  const ChatAvailability._();

  static const Set<String> openStatuses = {
    RideStatus.accepted,
    RideStatus.goingToPickup,
    RideStatus.arrived,
    RideStatus.pickupDone,
  };

  static bool isOpen({required int? rideId, required String? status}) =>
      rideId != null && rideId > 0 && openStatuses.contains(status);
}

/// Chat icon with an unread badge, for the active-ride screens.
///
/// Renders nothing while the ride has no chat room, so callers can drop it into
/// a Row unconditionally.
class ChatEntryButton extends StatelessWidget {
  final int? rideId;
  final String? rideStatus;
  final String customerName;
  final String customerMobile;
  final String customerPhoto;

  const ChatEntryButton({
    super.key,
    required this.rideId,
    required this.rideStatus,
    this.customerName = '',
    this.customerMobile = '',
    this.customerPhoto = '',
  });

  @override
  Widget build(BuildContext context) {
    if (!ChatAvailability.isOpen(rideId: rideId, status: rideStatus)) {
      return const SizedBox.shrink();
    }

    final unread = ChatUnreadController.instance;

    return GestureDetector(
      onTap: () => openRideChat(
        rideId: rideId!,
        customerName: customerName,
        customerMobile: customerMobile,
        customerPhoto: customerPhoto,
      ),
      child: Container(
        width: 42.r,
        height: 42.r,
        decoration: BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.lightGray),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 20.r,
              color: AppColors.blueColor,
            ),
            Obx(() {
              final count = unread.unreadFor(rideId!);
              if (count == 0) return const SizedBox.shrink();
              return Positioned(
                top: 6.r,
                right: 6.r,
                child: UnreadDot(count: count),
              );
            }),
          ],
        ),
      ),
    );
  }
}

/// The red count bubble, shared by the ride screens and the rooms list.
class UnreadDot extends StatelessWidget {
  final int count;

  const UnreadDot({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minWidth: 16.r, minHeight: 16.r),
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.red,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: AppText(
        text: count > 99 ? '99+' : '$count',
        fontSize: 9,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
      ),
    );
  }
}

/// Single entry point into a thread — used by the ride screens, the rooms list
/// and the FCM deep link, so they can't drift apart.
void openRideChat({
  required int rideId,
  String customerName = '',
  String customerMobile = '',
  String customerPhoto = '',
}) {
  Get.to(
    () => ChatScreen(
      rideId: rideId,
      customerName: customerName,
      customerMobile: customerMobile,
      customerPhoto: customerPhoto,
    ),
  );
}
