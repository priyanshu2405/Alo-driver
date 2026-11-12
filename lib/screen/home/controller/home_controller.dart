import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:alo_ride_driver_app/screen/home/model/request_model.dart';
import 'package:alo_ride_driver_app/screen/my_rides/model/ride_history_model.dart';
import 'package:alo_ride_driver_app/screen/ride/view/ride_screen_router.dart';
import 'package:alo_ride_driver_app/services/api_service.dart';
import 'package:alo_ride_driver_app/services/socket_services.dart';
import 'package:alo_ride_driver_app/services/token_store.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class HomeController extends GetxController{

  RxInt selectedVehicle = 0.obs;
  final formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();

  RxBool showBottomDialog = false.obs;

  void showRideCard() => showBottomDialog.value = true;
  void hideRideCard() => showBottomDialog.value = false;

  @override
  void onClose() {
    stopDriverLocationAutoSend();
    //socketIoService.disconnect();
    super.onClose();
  }

  RxBool isAcceptRide = false.obs;
  RxInt selectedVehicleIndex = 2.obs; // SUV selected by default

  final List<Map<String, dynamic>> vehicles = [
    {'name': 'Mini', 'capacity': 'Capacity: 1 - 4', 'icon': Icons.directions_car},
    {'name': 'Sedan', 'capacity': 'Capacity: 1 - 4', 'icon': Icons.directions_car},
    {'name': 'SUV', 'capacity': 'Capacity: 1 - 4', 'icon': Icons.directions_car},
    {'name': 'Luxury', 'capacity': 'Capacity: 1 - 4', 'icon': Icons.directions_car},
    {'name': 'Rentals', 'capacity': 'Capacity: 1 - 4', 'icon': Icons.directions_car},
  ];

  Rxn<RideRequestModel> rideRequest = Rxn<RideRequestModel>();

  void setRideRequest(Map<String, dynamic> data) {
    rideRequest.value = RideRequestModel.fromMap(data);
    showBottomDialog.value = true;
  }
  RxBool isOnline = false.obs;
  RxBool isLoading = false.obs;

  Future<void> updateOnlineStatus({
    required bool status,
    required double latitude,
    required double longitude,
  }) async {
    try {
      isLoading.value = true;

      final body = {
        "is_online": status,
        "latitude": latitude,
        "longitude": longitude,
      };

      debugPrint("📤 Online Status Body: $body");

      final response = await ApiService.post(
        endpoint: 'online-status',
        body: body,
      );

      if (response['success'] == true) {
        // backend may return updated value
        isOnline.value =
            response['data']['driver']['is_online'] ?? status;

        debugPrint("✅ Status Updated: ${isOnline.value}");
      } else {
        _showError(response['message'] ?? "Update failed");
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }




  Future<void> getOnlineStatus() async {
    try {
     // isLoading.value = true;

      final response = await ApiService.get(
        endpoint: 'online-status',
      );

      if (response['success'] == true) {
        // backend may return updated value
        isOnline.value = response['data']['is_online'] == 1 ? true : false;

        debugPrint("✅ Status Updated: ${isOnline.value}");
      } else {
        _showError(response['message'] ?? "Update failed");
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }


  final SocketIoService socketIoService = SocketIoService();
  StreamSubscription? locationSub;
  final AuthController authController = Get.put(AuthController());

  void startLocationUpdates({int? rideId}) async {

   // await Future.delayed(const Duration(seconds: 2)); // interval here

    // socketIoService.connect(
    //   driverId: authController.userId.value,
    //   token: authController.token.value,
    // );
    locationSub =  Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position pos) {
      socketIoService.sendLocation(lat: pos.latitude, lng: pos.longitude, rideId: rideId ?? 0);
    });
  }

  Future<void> acceptRide1({
    required int rideId,
  })
  async {
   // startLocationUpdates(rideId: rideId);
    isAcceptRide.value = true;
   //socketIoService.disconnect();
    try {
      final response = await ApiService.post(
        endpoint: 'rides/$rideId/accept',
        isShow: true,
        body: {},
      );

      // log("Accept Ride Response: $response");

      if (response['success'] == true) {
        final ride = response['ride'];
      //  log(ride);
      //   socketIoService.userAuth(userId: ride['driver_id']);
      //   socketIoService.acceptRide(rideId: rideId, userId: ride['user_id']);
      //   startLocationUpdates(rideId: rideId);

        /// ✅ SUCCESS MESSAGE
        Get.snackbar(
          "Success",
          response['message'] ?? "Ride accepted successfully",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green.withOpacity(0.9),
          colorText: Colors.white,
        );

        /// ✅ Navigate to pickup screen
        // Get.to(
        //       () => RideDetailsScreen(
        //     riderName: ride['user']?['name'] ?? '',
        //     bookingId: ride['booking_id'] ?? '',
        //     pickupAddress: ride['pickup_address'] ?? '',
        //     dropAddress: ride['drop_address'] ?? '',
        //     distance: ride['distance_km']?.toString() ?? '',
        //     fare: ride['total_fare']?.toString() ?? '',
        //     profileImage: ride['user']?['profile_photo'] ?? '',
        //     // pickupLat: double.tryParse(ride['pickup_latitude'].toString()) ?? 0,
        //     // pickupLng: double.tryParse(ride['pickup_longitude'].toString()) ?? 0,
        //     // dropLat: double.tryParse(ride['drop_latitude'].toString()) ?? 0,
        //     // dropLng: double.tryParse(ride['drop_longitude'].toString()) ?? 0,
        //     status: "going_to_pickup",
        //     riderId: ride['id'],
        //     pickupTime: formatRideDate(ride['pickup_datetime']),
        //         ride: ride,
        //   ),
        // );
      } else {
        _showError(response['message'] ?? "Failed to accept ride");
      }
    } catch (e) {
      debugPrint("Accept Ride Error: ${e}");
      _showError(e.toString());
    } finally {
      hideRideCard();
      isAcceptRide.value = false;
    }
  }
  Future<void> acceptRide({
    required int rideId,
  }) async {
    isAcceptRide.value = true;

    final endpoint = 'rides/$rideId/accept';

    // Print URL
    debugPrint("URL: ${ApiService.baseUrl}/$endpoint");
    // અથવા
    log("URL: ${ApiService.baseUrl}/$endpoint");

    try {
      final response = await ApiService.post(
        endpoint: 'rides/$rideId/accept',
        isShow: true,
        body: {},
      );

      log("Accept Ride Response: ${jsonEncode(response)}");

      if (response['success'] == true) {
        final Map<String, dynamic> ride =
        Map<String, dynamic>.from(response['ride']);

        log("Ride Data: ${jsonEncode(ride)}");

        Get.snackbar(
          "Success",
          response['message'] ?? "Ride accepted successfully",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green.withOpacity(0.9),
          colorText: Colors.white,
        );

        /// 🔹 Opens the stage matching the ride's current status (accepted).
        RideScreenRouter.open(RideData.fromJson(ride));
      } else {
        _showError(response['message'] ?? "Failed to accept ride");
      }
    } catch (e, stack) {
      debugPrint("Accept Ride Error: $e");
      debugPrintStack(stackTrace: stack);
      _showError(e.toString());
    } finally {
      hideRideCard();
      isAcceptRide.value = false;
    }
  }



  Timer? _locationTimer;
  bool _isSendingLocation = false;
  void stopDriverLocationAutoSend() {
    _locationTimer?.cancel();
    _locationTimer = null;
    debugPrint("🛑 Auto location sending stopped");
  }
  void startDriverLocationAutoSend() {
    // avoid duplicate timers
    _locationTimer?.cancel();

    _locationTimer = Timer.periodic(const Duration(seconds: 7), (_) async {
      if (_isSendingLocation) return; // avoid overlap
      _isSendingLocation = true;

      try {
        final position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 3,
            ),
        );

        await sentDriverLocation(
          latitude: position.latitude,
          longitude: position.longitude,
        );
      } catch (e) {
        debugPrint("❌ Auto send error: $e");
      } finally {
        _isSendingLocation = false;
      }
    });

    //debugPrint("🚕 Auto location sending started for ride $rideId");
  }


  Future<void> sentDriverLocation({
    required double latitude,
    required double longitude,
  }) async {
    try {
      // isLoading.value = true;

      final body = {
        "latitude": latitude,
        "longitude": longitude,
      };

      debugPrint("Location sent of driver: $body");

      final response = await ApiService.post(
        endpoint: 'location',
        body: body,
      );

      if (response['success'] == true) {
        debugPrint("✅ Status Updated: $response");
      } else {
        _showError(response['message'] ?? "Update failed");
      }
    } catch (e) {
      stopDriverLocationAutoSend();
     // _showError(e.toString());
    } finally {
      // isLoading.value = false;
    }
  }

  String formatRideDate(String? dateTime) {
    if (dateTime == null || dateTime.isEmpty) return "";

    try {
      final dt = DateTime.parse(dateTime).toLocal();
      return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
    } catch (e) {
      debugPrint("Date format error: $e");
      return "";
    }
  }


  void _showError(String message) {
    Get.snackbar(
      "Error",
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

}