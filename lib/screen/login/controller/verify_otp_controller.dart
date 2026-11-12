import 'dart:async';
import 'package:alo_ride_driver_app/firebase_api/firebase_api.dart';
import 'package:alo_ride_driver_app/res/constant/app_colors.dart';
import 'package:alo_ride_driver_app/screen/chat/service/chat_push_router.dart';
import 'package:alo_ride_driver_app/screen/dashboard/screen/dashboard_screen.dart';
import 'package:alo_ride_driver_app/screen/profile/controller/profile_controller.dart';
import 'package:alo_ride_driver_app/services/api_service.dart';
import 'package:alo_ride_driver_app/services/token_store.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VerifyOtpController extends GetxController {
  RxBool isVerifyOtp = false.obs;
  RxBool isResendLoading = false.obs;
  final AuthController authController = Get.put(AuthController());
  ProfileController profileController = Get.put(ProfileController());


  final List<TextEditingController> otpControllers = List.generate(4, (_) => TextEditingController());
  RxInt secondsRemaining = 30.obs;
  Timer? timer;

  Future<void> verifyOtp(BuildContext context,{String? countryCode,String? mobile,String? otp}) async {
    isVerifyOtp.value = true; // Start loading
    final notificationService = NotificationService();
    await notificationService.initialize();
    final token = await NotificationService.getToken();
    print("FCM TOKEN ON LOGIN → $token");
    try {

      // String otp = otpControllers.map((e) => e.text).join();

      debugPrint("otp : ${otp}");
      var body = {
        "mobile": mobile,
        "otp": otp,
        "country_code" :countryCode,
        "fcm_token" : token,
      };
      debugPrint("body : $body");
      final response = await ApiService.post(
        endpoint: 'verify-otp',
        body: body,
      );
      print("id: ${response['data']['driver']["id"]}");
      print("token: ${response["data"]["token"]}");
      if (response['success'] == true) {
        await authController.storeUserData(
          accessToken: response["data"]["token"],
          id: response['data']['driver']["id"].toString(),
        );
        Get.to(()=>DashboardScreen());

        /// A chat push tapped before login is replayed now that there is a
        /// session and a dashboard to come back to.
        ChatPushRouter.flushPending();


      } else {
        // Handle case when API doesn't return expected data
        Get.snackbar(
          "Error",
          "${response["message"]}",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
        );
      }

    } catch (e) {
      print("Error in createUser: $e");
      Get.snackbar(
        "Error",
        "$e",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } finally {
      isVerifyOtp.value = false; // Stop loading in all cases
    }
  }


  Future<void> resendOtp({String? countryCode,String? mobile}) async {
    isResendLoading.value = true; // Start loading

    var body = {
      "country_code": "+$countryCode",
      "mobile": mobile,
    };
    debugPrint("body : $body");

    try {
      final response = await ApiService.post(
        endpoint: 'send-otp',
        body: body,
      );
      print("id: ${response["otp"]}");

      debugPrint("otp verify =====>${response["otp"]}");
      if (response['success'] == true) {
        // Get.to(()=>OtpScreen(phoneNumber: phoneNumberCtrl.text));
        debugPrint("otp verify =====>${response["otp"]}");
      } else{
        Get.snackbar(
          "Error",
          "${response["errors"]["mobile"]}",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("Error in createUser: $e");
      Get.snackbar(
        "Error",
        "$e",
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.secondary.withOpacity(0.5),
        colorText: Colors.white,
      );
    } finally {
      isResendLoading.value = false; // Stop loading in all cases
    }
  }

}