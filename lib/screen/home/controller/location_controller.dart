import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;

class LocationController extends GetxController {
  // Controllers
  final Completer<GoogleMapController> mapController = Completer();
  final TextEditingController searchController = TextEditingController();

  // Observable variables
  RxDouble selectedDistance = 10.0.obs;
  RxBool isLoading = true.obs;
  RxBool showPredictions = false.obs;
  Rx<LatLng?> currentLatLng = Rx<LatLng?>(null);
  RxSet<Marker> markers = <Marker>{}.obs;
  RxList<dynamic> predictions = <dynamic>[].obs;
  RxString currentAddress = "Getting location...".obs;
  GoogleMapController? googleController;

  static const String _apiKey = "AIzaSyBDoZWzDdhnnXe0Kuaz0qcPZT_vsUltoxo";

  @override
  void onInit() {
    super.onInit();
    initLocation();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  /// Initialize map and permissions with retry logic
  Future<void> initLocation() async {
    try {
      isLoading.value = true;

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint("Location service disabled");
        await Geolocator.openLocationSettings().then((value) {
          retryLocationFetch();
        },);
        isLoading.value = false;
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      debugPrint("Current permission: $permission");

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        debugPrint("After requesting: $permission");

        if (permission == LocationPermission.denied) {
          Get.snackbar('Permission Denied', 'Location permission is required.');
          currentAddress.value = "Permission denied";
          isLoading.value = false;
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Get.snackbar(
          'Permission Denied Forever',
          'Please enable it in app settings.',
        );
        currentAddress.value = "Permission denied forever";
        isLoading.value = false;
        return;
      }

      // Permission granted - fetch location
      await _fetchLocation();
    } catch (e) {
      debugPrint("Location Error: $e");
      currentAddress.value = "Error getting location";
      isLoading.value = false;
    }
  }

  /// Fetch current position
  Future<void> _fetchLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      currentLatLng.value = LatLng(position.latitude, position.longitude);
      setMarker(currentLatLng.value!);

      // Get address for current location
      currentAddress.value = await getAddressFromLatLng(currentLatLng.value!);

      isLoading.value = false;
      debugPrint("Location fetched: ${position.latitude}, ${position.longitude}");
      debugPrint("Address: ${currentAddress.value}");
    } catch (e) {
      debugPrint("Error fetching location: $e");
      currentAddress.value = "Unable to get address";
      isLoading.value = false;
    }
  }

  /// Retry location fetch - call this after user grants permission
  Future<void> retryLocationFetch() async {
    isLoading.value = true;
    await Future.delayed(Duration(milliseconds: 500));
    await initLocation();
  }
  // BitmapDescriptor? driverIcon;
  //
  // Future<void> loadDriverIcon() async {
  //   driverIcon = await BitmapDescriptor.asset(
  //     const ImageConfiguration(size: Size(60, 60)),
  //     "assets/icons/car.png",
  //   );
  // }
  /// Set map marker
  void setMarker(LatLng position) {
    markers.value = {
      Marker(
        markerId: const MarkerId("selected"),
        position: position,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    };
    currentLatLng.value = position;
  }

  /// Move camera to position
  Future<void> moveCameraTo(LatLng position) async {
    if (mapController.isCompleted) {
      final controller = await mapController.future;
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: position, zoom: 14),
        ),
      );
    }
  }

  /// Get full address from LatLng coordinates
  Future<String> getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isEmpty) return "Unknown Location";

      Placemark place = placemarks.first;

      // Collect all possible address parts
      final rawParts = [
        place.name,
        place.street,
        place.subLocality,
        place.locality,
        place.subAdministrativeArea,
        place.administrativeArea,
        place.postalCode,
        place.country,
      ];

      // Remove null and empty strings
      final nonNullParts = rawParts
          .where((e) => e != null && e!.trim().isNotEmpty)
          .map((e) => e!.trim())
          .toList();

      // Remove duplicates (case-insensitive)
      final uniqueParts = <String>{};
      final cleaned = <String>[];

      for (var part in nonNullParts) {
        String lower = part.toLowerCase();
        if (!uniqueParts.contains(lower)) {
          cleaned.add(part);
          uniqueParts.add(lower);
        }
      }

      // Join all parts into final address
      return cleaned.join(", ");
    } catch (e) {
      debugPrint("Error getting address: $e");
      return "Unknown Location";
    }
  }

  void setCurrentLocationAndAddress(LatLng latLng, String address) {
    currentLatLng.value = latLng;

    markers.value = {
      Marker(
        markerId: const MarkerId("selected"),
        position: latLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    };

    searchController.text = address;
    currentAddress.value = address;

    update();
  }

  /// Get place predictions from Google Places API
  Future<void> getPlaces(String input) async {
    if (input.isEmpty) {
      predictions.clear();
      showPredictions.value = false;
      return;
    }

    // Restrict predictions to New Brunswick, Canada.
    // location/radius + strictbounds biases results to NB's bounding area;
    // components=country:ca limits to Canada.
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/autocomplete/json'
      '?input=${Uri.encodeComponent(input)}'
      '&components=country:ca'
      '&location=46.5653,-66.4619'
      '&radius=300000'
      '&strictbounds=true'
      '&key=$_apiKey',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        predictions.value = body['predictions'] ?? [];
        showPredictions.value = true;
      }
    } catch (e) {
      debugPrint("Error fetching places: $e");
    }
  }

  /// Get place details and update location
  Future<void> getPlaceDetails(String placeId) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$_apiKey',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        final result = body['result'];
        final geometry = result['geometry']['location'];
        final position = LatLng(geometry['lat'], geometry['lng']);
        final address = result['formatted_address'] ?? '';

        searchController.text = address;
        currentAddress.value = address;
        setMarker(position);
        moveCameraTo(position);
        showPredictions.value = false;
      }
    } catch (e) {
      debugPrint("Error fetching place details: $e");
    }
  }

  /// Handle map tap
  Future<void> onMapTap(LatLng position) async {
    setMarker(position);
    final address = await getAddressFromLatLng(position);
    searchController.text = address;
    currentAddress.value = address;
  }

  /// Clear search
  void clearSearch() {
    searchController.clear();
    predictions.clear();
    showPredictions.value = false;
  }

  /// Show results action
  void showResults() async {
    final lat = currentLatLng.value?.latitude;
    final lng = currentLatLng.value?.longitude;
    final dist = selectedDistance.value.toInt();
    final addr = searchController.text.trim();

    debugPrint("Passing to API ===>");
    debugPrint("Address: $addr");
    debugPrint("Latitude: $lat");
    debugPrint("Longitude: $lng");
    debugPrint("Distance: $dist");

    if (lat == null || lng == null) {
      Get.snackbar("Error", "Location not selected");
      return;
    }
  }

  /// Update distance
  void updateDistance(double value) {
    selectedDistance.value = value;
  }
}