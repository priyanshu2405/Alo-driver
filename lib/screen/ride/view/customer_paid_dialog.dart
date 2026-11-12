import 'package:alo_ride_driver_app/res/common/app_button.dart';
import 'package:alo_ride_driver_app/res/common/app_text.dart';
import 'package:alo_ride_driver_app/res/constant/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:alo_ride_driver_app/res/utils/app_responsive.dart';
import 'package:gap/gap.dart';

class CustomerPaidDialog extends StatelessWidget {
  final String bookingID;
  final String date;
  final String tripFare;
  final VoidCallback onGoHome;

  const CustomerPaidDialog({
    super.key,
    required this.onGoHome, required this.bookingID, required this.date, required this.tripFare,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.4), // 🔹 dim background
      child: Center(
        child: Container(
          width: 1.sw - 40.w,
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// ✅ CHECK ICON
              Container(
                height: 48.r,
                width: 48.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.secondary,
                    width: 3,
                  ),
                ),
                child: const Icon(
                  Icons.check,
                  color: AppColors.secondary,
                  size: 32,
                ),
              ),

              Gap(16.h),

              /// TITLE
              // AppText(
              //   text: "Customer Paid",
              //   fontSize: 20,
              //   fontWeight: FontWeight.bold,
              // ),

              Gap(12.h),

              /// DETAILS
              _infoText("Booking ID: $bookingID"),
              _infoText("Date: $date"),
              _infoText("Trip Fare : \$$tripFare"),

              Gap(20.h),

              /// BUTTON
              AppButton(
                text: "GO TO HOME",
                onTap: onGoHome,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoText(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: AppText(
        text: text,
        fontSize: 14,
        color: AppColors.lightBlackColor,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
