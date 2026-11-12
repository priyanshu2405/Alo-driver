import 'package:alo_ride_driver_app/res/common/app_appbar.dart';
import 'package:alo_ride_driver_app/res/common/app_text.dart';
import 'package:alo_ride_driver_app/res/constant/app_colors.dart';
import 'package:alo_ride_driver_app/screen/payout/controller/weekly_payout_controller.dart';
import 'package:alo_ride_driver_app/screen/payout/model/weekly_payout_model.dart';
import 'package:flutter/material.dart';
import 'package:alo_ride_driver_app/res/utils/app_responsive.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class WeeklyPayoutScreen extends StatelessWidget {
  const WeeklyPayoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final WeeklyPayoutController controller = Get.put(WeeklyPayoutController());

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppAppBar(title: "Weekly Payout"),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final weeks = controller.weeks;

        return RefreshIndicator(
          onRefresh: () => controller.getWeeklyPayout(),
          color: AppColors.secondary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 💰 SUMMARY (total_paid / total_unpaid)
                _summaryCard(controller),
                Gap(24.h),

                AppText(
                  text: "Weekly Payouts",
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                Gap(12.h),

                if (weeks.isEmpty)
                  _emptyState(controller)
                else
                  ...weeks.map(_weekCard),

                Gap(20.h),
              ],
            ),
          ),
        );
      }),
    );
  }

  // ── Summary card: total_paid + total_unpaid ───────────────
  Widget _summaryCard(WeeklyPayoutController controller) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.secondary, Color(0xFFFFA640)],
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          _summaryStat("Total Paid", _amount(controller.totalPaid)),
          Container(
            width: 1,
            height: 42.h,
            color: AppColors.white.withOpacity(0.3),
          ),
          _summaryStat("Total Unpaid", _amount(controller.totalUnpaid)),
        ],
      ),
    );
  }

  Widget _summaryStat(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          AppText(
            text: value,
            color: AppColors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          Gap(4.h),
          AppText(text: label, color: AppColors.white, fontSize: 12),
        ],
      ),
    );
  }

  // ── One week from `weeks[]` ───────────────────────────────
  Widget _weekCard(Week week) {
    final bool isPaid = (week.status ?? '').toLowerCase() == "paid";

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.lightGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔹 label + status
          Row(
            children: [
              Expanded(
                child: AppText(
                  text: week.label ?? _weekRange(week),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if ((week.status ?? '').isNotEmpty) ...[
                Gap(8.w),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: (isPaid ? AppColors.greenColor : AppColors.secondary)
                        .withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: AppText(
                    text: _capitalize(week.status!),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isPaid ? AppColors.greenColor : AppColors.secondary,
                  ),
                ),
              ],
            ],
          ),

          /// 🔹 week_start - week_end (only when the label already shows something else)
          // if (week.label != null && _weekRange(week).isNotEmpty) ...[
          //   Gap(4.h),
          //   AppText(
          //     text: _weekRange(week),
          //     fontSize: 12,
          //     color: AppColors.lightGrayText,
          //   ),
          // ],

          Gap(12.h),
          Divider(color: AppColors.lightGray, height: 1),
          Gap(12.h),

          if (week.totalRides != null) ...[
            _infoRow("Total Rides", "${week.totalRides}"),
            Gap(10.h),
          ],
          if (week.grossFare != null) ...[
            _infoRow("Gross Fare", _amount(week.grossFare!)),
            Gap(10.h),
          ],

          if (week.payout != null) ...[
            Divider(color: AppColors.lightGray, height: 1),
            Gap(10.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText(text: "Payout", fontSize: 15, fontWeight: FontWeight.w600),
                AppText(
                  text: _amount(week.payout!),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.greenColor,
                ),
              ],
            ),
          ],

          /// 🔹 Payment details (only sent once the week is paid)
          if (week.amountPaid != null ||
              (week.transactionNumber ?? '').isNotEmpty ||
              (week.paidAt ?? '').isNotEmpty) ...[
            Gap(10.h),
            Divider(color: AppColors.lightGray, height: 1),
            Gap(10.h),
            if (week.amountPaid != null) ...[
              _infoRow("Amount Paid", _amount(week.amountPaid!)),
              Gap(10.h),
            ],
            if ((week.transactionNumber ?? '').isNotEmpty) ...[
              _infoRow("Transaction No.", week.transactionNumber!),
              Gap(10.h),
            ],
            if ((week.paidAt ?? '').isNotEmpty)
              _infoRow("Paid At", _formatPaidAt(week.paidAt!)),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, {Color? valueColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: AppText(
            text: label,
            fontSize: 14,
            color: AppColors.lightTextColor,
          ),
        ),
        Gap(12.w),
        Flexible(
          child: AppText(
            text: value,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textColor,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget _emptyState(WeeklyPayoutController controller) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: AppText(
        text: controller.errorMessage.value.isNotEmpty
            ? controller.errorMessage.value
            : "No payouts yet",
        fontSize: 14,
        color: AppColors.lightGrayText,
        textAlign: TextAlign.center,
      ),
    );
  }

  // ================= HELPERS =================
  String _amount(double value) => "\$${value.toStringAsFixed(2)}";

  String _capitalize(String value) =>
      value.isEmpty ? value : value[0].toUpperCase() + value.substring(1);

  /// "20 Jul - 26 Jul 2026"
  String _weekRange(Week week) {
    if (week.weekStart == null || week.weekEnd == null) return "";
    return "${DateFormat("dd MMM").format(week.weekStart!)} - "
        "${DateFormat("dd MMM yyyy").format(week.weekEnd!)}";
  }

  String _formatPaidAt(String paidAt) {
    final date = DateTime.tryParse(paidAt);
    if (date == null) return paidAt;
    return DateFormat("dd MMM, yyyy  h:mm a").format(date.toLocal());
  }
}
