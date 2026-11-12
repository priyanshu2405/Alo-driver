import 'dart:async';
import 'dart:developer';

import 'package:alo_ride_driver_app/screen/my_rides/model/get_ride_details_model.dart';
import 'package:alo_ride_driver_app/screen/my_rides/model/ride_history_model.dart';
import 'package:alo_ride_driver_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class MyRideController extends GetxController {
  RxInt viewType = 0.obs;
  RxInt rideTab = 0.obs;
  RxBool isLoading = false.obs;

  /// 🔹 NEW: selected calendar date
  Rx<DateTime?> selectedDate = Rx<DateTime?>(null);

  Rx<RideHistoryModel> rideHistoryModel = RideHistoryModel().obs;
  RxList<RideData> filteredRides = <RideData>[].obs;
  RxBool isGetRideDetails = false.obs;
  final List<String> onGoingStatuses = [
    'accepted',
    'going_to_pickup',
    'arrived',
    'pickup_done',
  ];
  Rx<GetRideDetailsModel> getRideDetailsModel = GetRideDetailsModel().obs;
  Rx<LatLng?> pickupLatLng = Rx<LatLng?>(null);
  Rx<LatLng?> dropLatLng = Rx<LatLng?>(null);
  Timer? _autoRefreshTimer;

  @override
  void onInit() {
    super.onInit();
    getRideHistory();
  }

  // ================= API CALL =================
  // Future<void> getRideHistory() async {
  //   try {
  //     isLoading.value = true;
  //
  //     final response = await ApiService.get(
  //       endpoint: 'rides/history',
  //       isShow: false,
  //     );
  //
  //     rideHistoryModel.value = RideHistoryModel.fromJson(response);
  //     applyFilter();
  //   } catch (e) {
  //     debugPrint("Ride History Error: $e");
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }
  Future<void> getRideHistory({bool showLoader = false}) async {
    try {
      if (showLoader) {
        isLoading.value = true;
      }

      final response = await ApiService.get(
        endpoint: 'rides/history',
        isShow: false,
      );

      rideHistoryModel.value = RideHistoryModel.fromJson(response);
      applyFilter();
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


  // ================= MAIN FILTER =================

  void resetCalendarAndReload() {
    selectedDate.value = null;
    getRideHistory(); // 🔥 API CALL AGAIN
  }

  void applyFilter() {
    final rides = rideHistoryModel.value.data?.data ?? [];

    Iterable<RideData> result = rides;

    /// 🔹 STATUS FILTER
    if (rideTab.value == 0) {
      result = result.where((r) => r.status == 'completed');
    } else if (rideTab.value == 1) {
      result = result.where((r) => onGoingStatuses.contains(r.status));
    } else {
      result = result.where((r) => r.status == 'cancelled');
    }

    /// 🔹 DATE FILTER
    if (selectedDate.value != null) {
      result = result.where((r) {
        if (r.createdAt == null) return false;

        final rideDate = DateTime.tryParse(r.pickupDatetime!.toString());
        if (rideDate == null) return false;

        return rideDate.year == selectedDate.value!.year &&
            rideDate.month == selectedDate.value!.month &&
            rideDate.day == selectedDate.value!.day;
      });
    }

    filteredRides.value = result.toList();
  }

  // ================= CALENDAR DATE CHANGE =================
  void changeSelectedDate(DateTime date) {
    selectedDate.value = date;
    applyFilter();
  }

  void changeRideTab(int index) {
    rideTab.value = index;
    applyFilter();
  }


  Future<void> getRideDetails({required int id}) async {
    try {
      isGetRideDetails.value = true;

      final response = await ApiService.get(
        endpoint: 'rides/$id',
        isShow: false,
      );

      getRideDetailsModel.value = GetRideDetailsModel.fromJson(response);
      log(getRideDetailsModel.value.toJson().toString());
      final ride = getRideDetailsModel.value.data?.ride;

      if (ride != null) {
        /// ✅ Convert String → double safely
        final pickupLat = double.tryParse(ride.pickupLatitude ?? '');
        final pickupLng = double.tryParse(ride.pickupLongitude ?? '');
        final dropLat = double.tryParse(ride.dropLatitude ?? '');
        final dropLng = double.tryParse(ride.dropLongitude ?? '');

        if (pickupLat != null && pickupLng != null) {
          pickupLatLng.value = LatLng(pickupLat, pickupLng);
        }

        if (dropLat != null && dropLng != null) {
          dropLatLng.value = LatLng(dropLat, dropLng);
        }
      }


    } catch (e) {
      debugPrint('Error fetching ride details: $e');
    } finally {
      isGetRideDetails.value = false;
    }
  }
}

