import 'dart:async';
import 'package:alo_ride_driver_app/res/common/app_button.dart';
import 'package:alo_ride_driver_app/res/common/app_image.dart';
import 'package:alo_ride_driver_app/res/common/app_text.dart';
import 'package:alo_ride_driver_app/res/constant/app_colors.dart';
import 'package:alo_ride_driver_app/res/constant/app_images.dart';
import 'package:alo_ride_driver_app/screen/login/controller/verify_otp_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:alo_ride_driver_app/res/utils/app_responsive.dart';
import 'package:get/get.dart';
import 'package:gap/gap.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  final String countryCode;

  const OtpScreen({
    super.key,
    required this.phoneNumber,
    required this.countryCode,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> otpControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final VerifyOtpController verifyOtpController = Get.put(VerifyOtpController());
  int secondsRemaining = 30;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    timer?.cancel();
    secondsRemaining = 30;

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsRemaining == 0) {
        timer.cancel();
      } else {
        setState(() {
          secondsRemaining--;
        });
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    for (var c in otpControllers) {
      c.dispose();
    }
    super.dispose();
  }

  String getOtp() {
    return otpControllers.map((e) => e.text).join();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop(); // 🔴 CLOSE APP
        return false; // prevent navigation stack pop
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        // appBar: AppAppBar(),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Gap(MediaQuery.of(context).size.height * 0.08),
                AppText(
                  text: "OTP",
                  fontSize: 16,
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w500,
                ),
                Gap(5),

                /// 🔹 Illustration
                Center(
                  child: AppImage(
                    image: AppImages.loginLogo,
                    imageType: ImageType.svgAsset,
                    height: 210,
                    fit: BoxFit.contain,
                  ),
                ),

                Gap(10.h),

                /// 🔹 Title
                const AppText(
                  text: "Enter the code",
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),

                Gap(8.h),

                /// 🔹 Subtitle
                AppText(
                  text:
                      "OTP was sent to your registered mobile No\n${widget.phoneNumber}",
                  fontSize: 14,
                  color: AppColors.darkGrayColor,
                ),

                Gap(20.h),

                /// 🔹 OTP Fields
                Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(4, (index) => _otpBox(index)),
                ),

                Gap(20.h),

                /// 🔹 Resend
                Row(
                  children: [
                    const AppText(
                      text: "Didn't receive the code? ",
                      fontSize: 14,
                    ),
                    InkWell(
                      onTap: secondsRemaining == 0
                          ? () {
                              startTimer();
                              verifyOtpController.resendOtp(countryCode: widget.countryCode,mobile: widget.phoneNumber);
                            }
                          : null,
                      child: AppText(
                        text: "Resend code",
                        fontSize: 14,
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                Gap(6.h),

                /// 🔹 Timer
                AppText(
                  text: "Time Remaining ${secondsRemaining}s",
                  fontSize: 12,
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
          child: Obx(() {
            return AppButton(
              isLoading: verifyOtpController.isVerifyOtp.value,
              text: "CONFIRM",
              onTap: () {
                final otp = getOtp();
                if (otp.length == 4) {
                  debugPrint("OTP Entered: $otp");
                  verifyOtpController.verifyOtp(context,countryCode: widget.countryCode,mobile: widget.phoneNumber,otp: otp);
                  // loginController.verifyOtp(
                  //   mobile: widget.phoneNumber,
                  //   otp: otp,
                  //   countryCode: widget.countryCode,
                  // );
                  // call verify OTP API here
                } else {
                  Get.snackbar(
                    "Error",
                    "Please enter valid OTP",
                    backgroundColor: AppColors.secondary.withOpacity(0.5),
                  );
                }
              },
            );
          },),
        ),
      ),
    );
  }

  Widget _otpBox(int index) {
    return Padding(
      padding: EdgeInsets.only(right: 15.w),
      child: SizedBox(
        width: 48.w,
        height: 56.h, // ✅ increased height
        child: TextField(
          controller: otpControllers[index],
          keyboardType: TextInputType.number,
          textInputAction: index == 3
              ? TextInputAction.done
              : TextInputAction.next,
          textAlign: TextAlign.center,
          maxLength: 1,
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            counterText: "",
            isDense: true,

            // ✅ REQUIRED: fixes text not visible
            contentPadding: EdgeInsets.symmetric(vertical: 16.h),

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: AppColors.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: AppColors.borderColor),
            ),
          ),

          /// 🔹 AUTO MOVE + CLOSE KEYBOARD
          onChanged: (value) {
            if (value.isNotEmpty) {
              if (index < 3) {
                FocusScope.of(context).nextFocus();
              } else {
                FocusScope.of(context).unfocus();
              }
            }
          },

          /// 🔹 DONE BUTTON ACTION (iOS)
          onSubmitted: (_) {
            FocusScope.of(context).unfocus();
          },
        ),
      ),
    );
  }
}
