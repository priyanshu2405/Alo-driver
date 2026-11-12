import 'dart:async';
import 'package:alo_ride_driver_app/firebase_api/firebase_api.dart';
import 'package:alo_ride_driver_app/screen/chat/service/chat_push_router.dart';
import 'package:alo_ride_driver_app/screen/dashboard/screen/dashboard_screen.dart';
import 'package:alo_ride_driver_app/screen/login/view/login_screen.dart';
import 'package:alo_ride_driver_app/services/token_store.dart';
import 'package:get/get.dart';

class SplashController extends GetxController {

  final AuthController authController = Get.put(AuthController());
  @override
  void onInit() {
    super.onInit();
    checkTokenAndNavigate();
  }


  Future<void> checkTokenAndNavigate() async {
    try {
      // Add a small delay to ensure everything is initialized
      await Future.delayed(Duration(milliseconds: 200));

      final token = authController.getToken();
      print("token===>$token");
      print("isLoggedIn===> ${authController.isLoggedIn.value}");

      // Show splash for 3 seconds
      await Future.delayed(Duration(seconds: 3));

      if (authController.isAuthenticated) {
        Get.offAll(()=>DashboardScreen());
      } else {
        print("User is not authenticated, navigating to login");
        Get.offAll(() => LoginScreen());
      }

      /// Startup routing is done — replay a notification tap that launched the
      /// app from a terminated state (parked until now so `Get.offAll` above
      /// does not discard it).
      NotificationService.notifyAppReady();

      /// A chat push tapped from a terminated state may have been parked while
      /// the session was still loading — it is safe to open now. Called on BOTH
      /// branches: when logged out the router keeps the tap parked until the
      /// OTP screen calls back in, so it is never silently dropped.
      ChatPushRouter.flushPending();
    } catch (e) {
      print("Error in checkTokenAndNavigate: $e");
      Get.offAll(() => LoginScreen());
      NotificationService.notifyAppReady();
      ChatPushRouter.flushPending();
    }
  }

}