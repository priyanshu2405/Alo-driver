import 'dart:async';
import 'dart:developer';

import 'package:alo_ride_driver_app/screen/my_rides/model/get_ride_details_model.dart';
import 'package:alo_ride_driver_app/screen/my_rides/model/ride_history_model.dart';
import 'package:alo_ride_driver_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MyRideRequestController extends GetxController{
  RxInt viewType = 0.obs;
  RxInt rideTab = 0.obs;
  RxBool isLoading = false.obs;

  /// 🔹 NEW: selected calendar date
  Rx<DateTime?> selectedDate = Rx<DateTime?>(null);

  Rx<PendingRideHistoryModel> rideHistoryModel = PendingRideHistoryModel().obs;
  RxList<RideData> filteredRides = <RideData>[].obs;
  RxBool isGetRideDetails = false.obs;

  Rx<GetRideDetailsModel> getRideDetailsModel = GetRideDetailsModel().obs;
  Rx<LatLng?> pickupLatLng = Rx<LatLng?>(null);
  Rx<LatLng?> dropLatLng = Rx<LatLng?>(null);
  Timer? _autoRefreshTimer;

  @override
  void onInit() {
    super.onInit();
    getRideHistory();
  }
  Future<void> getRideHistory({bool showLoader = false}) async {
    try {
      if (showLoader) {
        isLoading.value = true;
      }

      final response = await ApiService.get(
        endpoint: 'rides/pending',
        isShow: false,
      );

      rideHistoryModel.value = PendingRideHistoryModel.fromJson(response);
      log("response:: ${rideHistoryModel.value.toJson()}");
     // applyFilter();
    } catch (e) {
      debugPrint("Ride History Error: $e");
    } finally {
      if (showLoader) {
        isLoading.value = false;
      }
    }
  }

  void startAutoRefresh() {
    _autoRefreshTimer?.cancel();

    _autoRefreshTimer = Timer.periodic(
      const Duration(seconds: 5),
          (timer) {
        getRideHistory(showLoader: false); // ❌ no loader
      },
    );
  }
}