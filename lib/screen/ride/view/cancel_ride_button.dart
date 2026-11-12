import 'package:alo_ride_driver_app/res/common/app_button.dart';
import 'package:alo_ride_driver_app/res/common/app_text.dart';
import 'package:alo_ride_driver_app/res/constant/app_colors.dart';
import 'package:alo_ride_driver_app/res/utils/app_responsive.dart';
import 'package:alo_ride_driver_app/res/utils/ride_status_flow.dart';
import 'package:alo_ride_driver_app/screen/ride/controller/ride_completed_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

/// "CANCEL RIDE", shown only while the ride's **backend** status is one the
/// driver may cancel from (`accepted`, `going_to_pickup`, `arrived`,
/// `pickup_done`). Hidden for `pending`, `completed`, `cancelled` and any
/// status the app doesn't recognise — see [RideStatus.canCancel].
///
/// [status] is the status the hosting screen was built with (always API
/// sourced). Once [RideCompletedController] has a fresher copy of the same
/// ride, that one wins, so the button disappears the moment the status moves.
class CancelRideButton extends StatelessWidget {
  final int rideId;
  final String? status;

  const CancelRideButton({super.key, required this.rideId, this.status});

  RideCompletedController get _controller =>
      Get.isRegistered<RideCompletedController>()
      ? Get.find<RideCompletedController>()
      : Get.put(RideCompletedController());

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    return Obx(() {
      final liveRide = controller.ride.value;

      /// Prefer the controller's ride when it's this ride — it's refreshed
      /// after every status update and after a cancellation.
      final currentStatus = (liveRide != null && liveRide.id == rideId)
          ? liveRide.status
          : status;

      if (!RideStatus.canCancel(currentStatus)) {
        return const SizedBox.shrink();
      }

      return AppButton(
        text: "CANCEL RIDE",
        isLoading: controller.isCancelling.value,
        backgroundColor: AppColors.white,
        textColor: AppColors.red,
        borderColor: AppColors.red,
        onTap: controller.isCancelling.value
            ? null
            : () => _confirmCancel(controller),
      );
    });
  }

  /// Confirmation + optional reason (the API caps it at 255 chars).
  void _confirmCancel(RideCompletedController controller) {
    Get.dialog(
      _CancelRideDialog(
        onConfirm: (reason) =>
            controller.cancelRide(rideId: rideId, reason: reason),
      ),
      barrierDismissible: true,
    );
  }
}

/// Owns the reason field's [TextEditingController] so it lives exactly as long
/// as the dialog's element does.
///
/// Disposing it right after `Get.dialog(...)` resolves is too early: the route's
/// pop future completes when the dismissal *starts*, while the [TextField] is
/// still being rebuilt by the exit transition — which is what threw
/// "A TextEditingController was used after being disposed".
class _CancelRideDialog extends StatefulWidget {
  final void Function(String reason) onConfirm;

  const _CancelRideDialog({required this.onConfirm});

  @override
  State<_CancelRideDialog> createState() => _CancelRideDialogState();
}

class _CancelRideDialogState extends State<_CancelRideDialog> {
  final TextEditingController reasonController = TextEditingController();

  @override
  void dispose() {
    reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),

      /// The dialog hands its child a max height; the on-screen keyboard eats
      /// most of it, so the content scrolls instead of overflowing.
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              text: "Cancel this ride?",
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            Gap(8.h),
            AppText(
              text: "The ride will be released and offered to other drivers.",
              fontSize: 13,
              color: AppColors.lightGrayText,
              overflow: TextOverflow.visible,
            ),
            Gap(16.h),
            TextField(
              controller: reasonController,
              maxLength: 255,
              maxLines: 3,
              minLines: 1,
              textCapitalization: TextCapitalization.sentences,
              inputFormatters: [LengthLimitingTextInputFormatter(255)],
              decoration: InputDecoration(
                hintText: "Reason (optional)",
                hintStyle: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.lightGrayText,
                ),
                counterText: "",
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 12.h,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: const BorderSide(color: AppColors.lightGray),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: const BorderSide(color: AppColors.lightGray),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: const BorderSide(color: AppColors.secondary),
                ),
              ),
            ),
            Gap(12.h),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: "KEEP RIDE",
                    height: 44.h,
                    fontSize: 14,
                    backgroundColor: AppColors.white,
                    textColor: AppColors.darkGrayColor,
                    borderColor: AppColors.lightGray,
                    onTap: () => Get.back(),
                  ),
                ),
                Gap(12.w),
                Expanded(
                  child: AppButton(
                    text: "CANCEL RIDE",
                    height: 44.h,
                    fontSize: 14,
                    backgroundColor: AppColors.red,
                    textColor: AppColors.white,
                    onTap: () {
                      /// Read the reason *before* popping — the field's state
                      /// goes away with the route.
                      final reason = reasonController.text;
                      Get.back();
                      widget.onConfirm(reason);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
