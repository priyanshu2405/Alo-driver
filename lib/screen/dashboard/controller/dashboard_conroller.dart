
import 'package:alo_ride_driver_app/screen/current_ride/controller/current_ride_controller.dart';
import 'package:alo_ride_driver_app/screen/current_ride/view/current_ride_screen.dart';
import 'package:alo_ride_driver_app/screen/home/view/home_screen.dart';
import 'package:alo_ride_driver_app/screen/my_ride/my_ride_view.dart';
import 'package:alo_ride_driver_app/screen/my_rides/view/my_rides_screen.dart';
import 'package:alo_ride_driver_app/screen/profile/view/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// class DashBoardController1 extends GetxController {
//   final RxInt selectedIndex = 0.obs;
//
//   void changeIndex(int index) {
//     if (selectedIndex.value != index) {
//       selectedIndex.value = index;
//     }
//   }
//
//   late List<Widget> pages;
//   @override
//   void onInit() {
//     super.onInit();
//     // pages = [
//     //   HomeScreen(),
//     //   CurrentRideScreen(),
//     //   MyRidesScreen(),
//     //   ProfileScreen(),
//     // ];
//
//     pages = [
//       HomeScreen(),
//       RideStatusWrapperScreen(), // ✅ dynamic screen
//       MyRidesScreen(),
//       ProfileScreen(),
//     ];
//
//   }
//
//
// }

class DashBoardController extends GetxController {
  final RxInt selectedIndex = 0.obs;

  /// ✅ SINGLE INSTANCE
  final CurrentRideController currentRideController =
  Get.put(CurrentRideController(), permanent: true);

  late List<Widget> pages;

  void changeIndex(int index) {
    if (selectedIndex.value != index) {
      selectedIndex.value = index;
    }
  }

  @override
  void onInit() {
    super.onInit();

    pages = [
      HomeScreen(),
      MyRideView(),
      RideStatusWrapperScreen(), // dynamic
      MyRidesScreen(),
      ProfileScreen(),
    ];
  }
}
