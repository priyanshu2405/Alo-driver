import 'package:alo_ride_driver_app/res/common/common_text_field.dart';
import 'package:alo_ride_driver_app/res/constant/app_images.dart';
import 'package:alo_ride_driver_app/screen/home/controller/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:alo_ride_driver_app/res/utils/app_responsive.dart';
import 'package:alo_ride_driver_app/res/common/app_button.dart';
import 'package:alo_ride_driver_app/res/common/app_text.dart';
import 'package:alo_ride_driver_app/res/constant/app_colors.dart';
import 'package:gap/gap.dart';
import 'package:alo_ride_driver_app/res/common/app_image.dart';
import 'package:get/get.dart';

class WelcomeDialog extends StatelessWidget {
  final HomeController controller;

  const WelcomeDialog({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Material( // ✅ REQUIRED for TextField
      color: Colors.transparent,
      child: Center(
        child: SingleChildScrollView( // ✅ Prevent overflow
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Container(
            width: 1.sw,
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Form(
              key: controller.formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Gap(20.h),
                  AppText(
                    text: "Welcome to Alo Drive!",
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),

                  Gap(6.h),

                  AppText(
                    text: "Please introduce yourself",
                    fontSize: 14,
                    color: AppColors.darkGrayColor,
                  ),

                  Gap(16.h),

                  /// 🔹 Name Input
                  CommonTextField(
                    controller: controller.nameController,
                    hintText: "Full Name",
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Full name is required";
                      }
                      if (value.length < 3) {
                        return "Name must be at least 3 characters";
                      }
                      return null;
                    },
                  ),


                  Gap(20.h),

                  /// 🔹 Submit Button
                  AppButton(
                    text: "SUBMIT",
                    onTap: () {
                      if (controller.formKey.currentState!.validate()) {
                        Navigator.pop(context);
                        showAdsPopup();

                        // save name / API
                      }
                    },
                  ),
                  Gap(20.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void showAdsPopup() {
    Get.dialog(
      AdsPopup(
        onClose: () => Get.back(), // ✅ SAFE
      ),
      barrierDismissible: false,
    );
  }

}




class AdsPopup extends StatelessWidget {
  final VoidCallback onClose;

  const AdsPopup({
    super.key,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.4), // 🔹 dark overlay
      child: Center(
        child: Container(
          width: 1.sw - 40.w,
          decoration: BoxDecoration(
            color: Color(0xffFAE5C2),
            borderRadius: BorderRadius.circular(6.r),
            border: Border.all(color: AppColors.black,width: 2)
          ),
          child: Stack(
            children: [
              /// 🔹 Content
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Gap(20),
                  /// Header / Logo Area
                  AppImage(
                    height: 122.h,
                    image: AppImages.bannerLogo,
                    imageType: ImageType.asset,
                  ),

                  Gap(10),
                  /// Offer Text
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AppText(
                            text: "10%",
                            fontSize: 35,
                            fontWeight: FontWeight.bold,
                            textAlign: TextAlign.center,
                          ),
                          AppText(
                            text: "10% OFF FOR CHRISTMAS",
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      AppText(
                        text: "137 McLaughlin Dr, Moncton.",
                        fontSize: 18,
                        textAlign: TextAlign.center,
                        fontWeight: FontWeight.w600,
                      ),
                    ],
                  ),

                  Gap(30),

                  /// Food Images
                  AppImage(
                    image: AppImages.banner,
                    imageType: ImageType.asset,
                  ),
                ],
              ),

              /// 🔹 Close Button
              Positioned(
                right: 6.w,
                top: 6.h,
                child: GestureDetector(
                  onTap: onClose,
                  child: Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: Colors.black),
                    ),
                    child: const Icon(Icons.close, size: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _foodImage(String image) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.r),
      child: AppImage(
        image: image,
        imageType: ImageType.asset,
        width: 90,
        height: 80,
        fit: BoxFit.cover,
      ),
    );
  }
}


