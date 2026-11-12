import 'package:alo_ride_driver_app/res/common/app_appbar.dart';
import 'package:alo_ride_driver_app/res/common/app_button.dart';
import 'package:alo_ride_driver_app/res/constant/app_colors.dart';
import 'package:alo_ride_driver_app/res/constant/app_images.dart';
import 'package:alo_ride_driver_app/screen/login/controller/login_controller.dart';
import 'package:alo_ride_driver_app/screen/signup/view/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:alo_ride_driver_app/res/utils/app_responsive.dart';
import 'package:alo_ride_driver_app/res/common/app_text.dart';
import 'package:alo_ride_driver_app/res/common/app_image.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final LoginController loginController = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop(); // 🔴 CLOSE APP
        return false; // prevent navigation stack pop
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppAppBar(
          showBack: false,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: "Log in",
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
                AppText(
                  text: "Join us via Phone number",
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),

                Gap(8.h),

                /// 🔹 Subtitle
                AppText(
                  text: "We’ll text a code to verify your phone",
                  fontSize: 14,
                  color: AppColors.darkGrayColor,
                ),

                Gap(25.h),

                /// 🔹 Phone Input
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  height: 50.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: AppColors.borderColor),
                  ),
                  child: Row(
                    children: [
                      /// Country Code
                     InkWell(
                       onTap: loginController.pickCountry,
                       child: Row(
                         children: [
                           Obx(() {
                             return AppText(
                               text: "+${loginController.countryCode.value?.phoneCode ?? ""}",
                               fontSize: 16,
                               fontWeight: FontWeight.w500,
                             );
                           }),
                           Gap(8.w),
                           Icon(Icons.keyboard_arrow_down),
                           Gap(10.w),
                         ],
                       ),
                     ),

                      /// Divider
                      Container(
                        width: 1.w,
                        height: 30.h,
                        color: AppColors.black,
                      ),
                      Gap(10.w),

                      /// Phone TextField
                      // Expanded(
                      //   child: TextFormField(
                      //     keyboardType: TextInputType.phone,
                      //     controller: loginController.phoneNumberCtrl,
                      //     validator: (value) {
                      //       if (value == null || value.trim().isEmpty) {
                      //         return "Phone number is required";
                      //       } else if (value.length < 8 || value.length > 15) {
                      //         return "Enter a valid phone number";
                      //       }
                      //       return null;
                      //     },
                      //     decoration: const InputDecoration(
                      //
                      //       border: InputBorder.none,
                      //       hintText: "",
                      //     ),
                      //   ),
                      // ),
                      Expanded(
                        child: TextFormField(
                          controller: loginController.phoneNumberCtrl,
                          // keyboardType: TextInputType.phone,
                          textInputAction:TextInputAction.done,
                          maxLength: 13,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: (_) => loginController.validatePhone(),
                          decoration: const InputDecoration(
                            counterText: '',
                            border: InputBorder.none,
                            hintText: "Phone number",
                          ),
                        ),
                      ),

                    ],
                  ),
                ),

                Obx(() {
                  if (loginController.phoneError.value.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: EdgeInsets.only(top: 6.h),
                    child: AppText(
                      text: loginController.phoneError.value,
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  );
                }),
                Gap(50),
           Obx(() {
             return      AppButton(
               isLoading: loginController.isLoading.value,
               text: "NEXT",
               onTap: () {
                 loginController.validatePhone();

                 if (loginController.isPhoneValid.value) {
                   loginController.loginApi();
                 }
               },
             );
           },),
                Gap(50),
                Center(child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppText(text: "Don't Have an Account?"),
                    InkWell(onTap: () {
                      Get.to(SignupScreen());
                    },child: AppText(text: " Sign Up",color: AppColors.secondary,)),
                  ],
                )),


              ],
            ),
          ),
        ),
        // bottomNavigationBar: Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        //   child: AppButton(
        //     text: "NEXT",
        //     onTap: () {
        //       loginController.validatePhone();
        //
        //       if (loginController.isPhoneValid.value) {
        //         Get.to(() => OtpScreen(
        //             phoneNumber:
        //             "+${loginController.countryCode.value!.phoneCode} "
        //                 "${loginController.phoneNumberCtrl.text}",
        //           ),
        //         );
        //       }
        //     },
        //   ),
        // ),
      ),
    );
  }
}
