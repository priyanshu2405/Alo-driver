import 'package:alo_ride_driver_app/res/common/app_button.dart';
import 'package:alo_ride_driver_app/res/common/app_text.dart';
import 'package:alo_ride_driver_app/res/constant/app_colors.dart';
import 'package:alo_ride_driver_app/res/utils/app_responsive.dart';
import 'package:alo_ride_driver_app/res/utils/ride_status_flow.dart';
import 'package:alo_ride_driver_app/screen/dashboard/screen/dashboard_screen.dart';
import 'package:alo_ride_driver_app/screen/ride/controller/ride_completed_controller.dart';
import 'package:alo_ride_driver_app/screen/ride/model/no_show_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

/// "REPORT NO SHOW", shown only while the ride's **backend** status is
/// `arrived` — the driver is at the pickup point and the customer hasn't come.
/// See [RideStatus.canReportNoShow].
///
/// [status] is the status the hosting screen was built with (always API
/// sourced). Once [RideCompletedController] has a fresher copy of the same
/// ride, that one wins, so the button disappears the moment the status moves.
class NoShowButton extends StatelessWidget {
  final int rideId;
  final String? status;

  const NoShowButton({super.key, required this.rideId, this.status});

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
      /// after every status update and after a no-show / cancellation.
      final currentStatus = (liveRide != null && liveRide.id == rideId)
          ? liveRide.status
          : status;

      if (!RideStatus.canReportNoShow(currentStatus)) {
        return const SizedBox.shrink();
      }

      final isReporting = controller.isReportingNoShow.value;

      return AppButton(
        text: "NO SHOW",
        isLoading: isReporting,
        backgroundColor: AppColors.white,
        textColor: AppColors.darkGrayColor,
        borderColor: AppColors.darkGrayColor,
        onTap: isReporting ? null : () => _confirmNoShow(controller),
      );
    });
  }

  /// Confirmation + optional notes (the API caps them at 255 chars).
  void _confirmNoShow(RideCompletedController controller) {
    Get.dialog(
      _NoShowDialog(
        onConfirm: (notes) async {
          final result = await controller.reportNoShow(
            rideId: rideId,
            notes: notes,
          );

          /// `null` means the request failed — the error snackbar is already
          /// on screen, so the driver stays on the ride.
          if (result == null) return;

          _showResult(result);
        },
      ),
      barrierDismissible: true,
    );
  }

  /// Success sheet with the fee the backend actually charged, then back to the
  /// dashboard — the ride is finished either way.
  void _showResult(NoShowResult result) {
    Get.dialog(
      NoShowResultDialog(
        result: result,
        onDone: () {
          Get.back();
          Get.offAll(() => const DashboardScreen());
        },
      ),
      barrierDismissible: false,
    );
  }
}

/// Owns the notes field's [TextEditingController] so it lives exactly as long
/// as the dialog's element does — disposing it right after `Get.dialog(...)`
/// resolves is too early (the exit transition still rebuilds the [TextField]).
class _NoShowDialog extends StatefulWidget {
  final void Function(String notes) onConfirm;

  const _NoShowDialog({required this.onConfirm});

  @override
  State<_NoShowDialog> createState() => _NoShowDialogState();
}

class _NoShowDialogState extends State<_NoShowDialog> {
  final TextEditingController notesController = TextEditingController();

  @override
  void dispose() {
    notesController.dispose();
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
              text: "Report a no show?",
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            Gap(8.h),
            AppText(
              text:
                  "The ride will be cancelled and the customer will be charged "
                  "the no-show fee.",
              fontSize: 13,
              color: AppColors.lightGrayText,
              overflow: TextOverflow.visible,
            ),
            Gap(16.h),
            TextField(
              controller: notesController,
              maxLength: 255,
              maxLines: 3,
              minLines: 1,
              textCapitalization: TextCapitalization.sentences,
              inputFormatters: [LengthLimitingTextInputFormatter(255)],
              decoration: InputDecoration(
                hintText: "Notes (optional)",
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
                    text: "KEEP WAITING",
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
                    text: "NO SHOW",
                    height: 44.h,
                    fontSize: 14,
                    backgroundColor: AppColors.red,
                    textColor: AppColors.white,
                    onTap: () {
                      /// Read the notes *before* popping — the field's state
                      /// goes away with the route.
                      final notes = notesController.text;
                      Get.back();
                      widget.onConfirm(notes);
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

/// Shows what the backend did: the ride's new status and, when a fee was
/// charged, its amount / currency / card / payment reference — all read from
/// the response, never assumed.
class NoShowResultDialog extends StatelessWidget {
  final NoShowResult result;
  final VoidCallback onDone;

  const NoShowResultDialog({
    super.key,
    required this.result,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    final fee = result.fee;
    final feePaid = fee?.isPaid ?? false;
    final feeAmount = fee?.formattedAmount;

    return Dialog(
      backgroundColor: AppColors.white,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  feePaid ? Icons.check_circle : Icons.info_outline,
                  color: feePaid ? AppColors.greenColor : AppColors.secondary,
                  size: 22.r,
                ),
                Gap(8.w),
                Expanded(
                  child: AppText(
                    text: "No-show reported",
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    overflow: TextOverflow.visible,
                  ),
                ),
              ],
            ),
            Gap(12.h),

            if ((result.bookingId ?? '').isNotEmpty)
              _DetailRow(label: "Booking ID", value: result.bookingId!),
            if ((result.status ?? '').isNotEmpty)
              _DetailRow(
                label: "Ride status",
                value: RideStatus.stageLabel(result.status).isNotEmpty
                    ? RideStatus.stageLabel(result.status)
                    : result.status!,
              ),
            if (result.noShowAt != null)
              _DetailRow(
                label: "Reported at",
                value: DateFormat(
                  "dd MMM,yyyy  h:mm a",
                ).format(result.noShowAt!.toLocal()),
              ),

            /// 💳 FEE — only what the API sent.
            if (fee != null) ...[
              Gap(6.h),
              Divider(color: AppColors.lightGray, height: 16.h),
              if (feeAmount != null)
                _DetailRow(
                  label: "No-show fee",
                  value: feeAmount,
                  valueColor: feePaid
                      ? AppColors.greenColor
                      : AppColors.darkGrayColor,
                  bold: true,
                ),
              if ((fee.status ?? '').isNotEmpty)
                _DetailRow(label: "Payment", value: fee.status!),
              if (fee.card?.label != null)
                _DetailRow(label: "Card", value: fee.card!.label!),
              if ((fee.paymentIntentId ?? '').isNotEmpty)
                _DetailRow(
                  label: "Reference",
                  value: fee.paymentIntentId!,
                ),
              if ((fee.message ?? '').isNotEmpty) ...[
                Gap(8.h),
                AppText(
                  text: fee.message!,
                  fontSize: 12,
                  color: AppColors.lightGrayText,
                  overflow: TextOverflow.visible,
                ),
              ],
            ],

            Gap(16.h),
            AppButton(text: "DONE", height: 44.h, fontSize: 14, onTap: onDone),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool bold;

  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            text: label,
            fontSize: 13,
            color: AppColors.lightGrayText,
          ),
          Gap(12.w),
          Expanded(
            child: AppText(
              text: value,
              fontSize: 13,
              fontWeight: bold ? FontWeight.w600 : FontWeight.w500,
              color: valueColor ?? AppColors.darkGrayColor,
              textAlign: TextAlign.end,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
