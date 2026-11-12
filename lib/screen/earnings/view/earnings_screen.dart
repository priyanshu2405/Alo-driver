import 'package:alo_ride_driver_app/res/common/app_appbar.dart';
import 'package:alo_ride_driver_app/res/common/app_text.dart';
import 'package:alo_ride_driver_app/res/constant/app_colors.dart';
import 'package:alo_ride_driver_app/res/utils/app_responsive.dart';
import 'package:alo_ride_driver_app/screen/earnings/controller/earnings_controller.dart';
import 'package:alo_ride_driver_app/screen/earnings/model/driver_earnings_model.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

/// Earnings summary — today, yesterday, this week (Mon–Sun) and last week.
/// All totals come straight from `GET driver/earnings`.
class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  final EarningsController controller = Get.put(EarningsController());

  @override
  void initState() {
    super.initState();

    /// Re-opening a screen whose controller is still alive skips `onInit`, so
    /// pull fresh totals — rides completed in the meantime show up right away.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.hasData) controller.getEarnings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppAppBar(title: "Earnings"),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!controller.hasData && controller.errorMessage.value.isNotEmpty) {
          return _errorState();
        }

        return RefreshIndicator(
          onRefresh: () => controller.getEarnings(),
          color: AppColors.secondary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 💰 TODAY
                _todayCard(controller.today),
                Gap(24.h),

                AppText(
                  text: "Summary",
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                Gap(12.h),

                _periodCard(controller.yesterday, fallbackTitle: "Yesterday"),
                _periodCard(controller.thisWeek, fallbackTitle: "This Week"),
                _periodCard(controller.lastWeek, fallbackTitle: "Last Week"),

                Gap(20.h),
              ],
            ),
          ),
        );
      }),
    );
  }

  // ── Today's total, front and centre ───────────────────────
  Widget _todayCard(EarningsPeriod period) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppText(
            text: period.label ?? "Today",
            color: AppColors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          if (period.subtitle != null) ...[
            Gap(2.h),
            AppText(
              text: period.subtitle!,
              color: AppColors.white.withOpacity(0.85),
              fontSize: 11,
            ),
          ],
          Gap(10.h),
          AppText(
            text: controller.amount(period.earningsValue),
            color: AppColors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
          Gap(4.h),
          AppText(
            text: controller.ridesText(period.ridesCount),
            color: AppColors.white,
            fontSize: 12,
          ),
        ],
      ),
    );
  }

  // ── Yesterday / this week / last week ─────────────────────
  Widget _periodCard(EarningsPeriod period, {required String fallbackTitle}) {
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
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      text: period.label ?? fallbackTitle,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    if (period.subtitle != null) ...[
                      Gap(2.h),
                      AppText(
                        text: period.subtitle!,
                        fontSize: 12,
                        color: AppColors.lightGrayText,
                      ),
                    ],
                  ],
                ),
              ),
              Gap(12.w),
              AppText(
                text: controller.amount(period.earningsValue),
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.greenColor,
              ),
            ],
          ),

          Gap(12.h),
          Divider(color: AppColors.lightGray, height: 1),
          Gap(12.h),

          _infoRow("Rides", "${period.ridesCount}"),
          if (period.grossFare != null) ...[
            Gap(10.h),
            _infoRow("Gross Fare", controller.amount(period.grossFare)),
          ],
          if (period.commission != null) ...[
            Gap(10.h),
            _infoRow("Commission", controller.amount(period.commission)),
          ],
          if (period.tips != null) ...[
            Gap(10.h),
            _infoRow("Tips", controller.amount(period.tips)),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
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
            color: AppColors.textColor,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget _errorState() {
    return RefreshIndicator(
      onRefresh: () => controller.getEarnings(),
      color: AppColors.secondary,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(16.w),
        children: [
          Gap(80.h),
          AppText(
            text: controller.errorMessage.value,
            fontSize: 14,
            color: AppColors.lightGrayText,
            textAlign: TextAlign.center,
            overflow: TextOverflow.visible,
          ),
          Gap(16.h),
          Center(
            child: TextButton(
              onPressed: () => controller.getEarnings(showLoader: true),
              child: AppText(
                text: "Retry",
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
