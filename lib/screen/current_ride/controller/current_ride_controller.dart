import 'dart:async';

import 'package:alo_ride_driver_app/screen/my_rides/model/ride_history_model.dart';
import 'package:alo_ride_driver_app/services/api_service.dart';
import 'package:alo_ride_driver_app/services/socket_services.dart';
import 'package:alo_ride_driver_app/services/token_store.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CurrentRideController extends GetxController {
  RxBool isLoading = false.obs;

  Rx<RideData> getCurrentRideModel = RideData().obs;
  final SocketIoService socketIoService = SocketIoService();
  final AuthController authController = Get.put(AuthController());
  StreamSubscription? locationSub;

  @override
  void onInit() {
    super.onInit();
    getCurrentRide();
  }

  Future<void> getCurrentRide() async {
    try {
      isLoading.value = true;

      final response = await ApiService.get(
        endpoint: 'rides/current',
        isShow: false,
      );

      if (response != null && response['success'] == true) {
       /* socketIoService.connect(
          driverId: authController.userId.value,
          token: authController.token.value,
        );*/

        getCurrentRideModel.value = RideData.fromJson(response['data']['ride']);
      } else {
        getCurrentRideModel.value = RideData();
      }
    } catch (e) {
      debugPrint("Current Ride Error: $e");
      getCurrentRideModel.value = RideData();
    } finally {
      isLoading.value = false;
    }
  }
  void startLocationUpdates({int? rideId}) async {

    // await Future.delayed(const Duration(seconds: 2)); // interval here

    /*socketIoService.connect(
      driverId: authController.userId.value,
      token: authController.token.value,
    );
    locationSub =  Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position pos) {
      socketIoService.sendLocation(lat: pos.latitude, lng: pos.longitude, rideId: rideId ?? 0);
    });*/
  }

}


