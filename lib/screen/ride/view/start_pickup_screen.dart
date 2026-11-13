import 'dart:async';
import 'dart:math';

import 'package:alo_ride_driver_app/res/common/app_appbar.dart';
import 'package:alo_ride_driver_app/res/common/app_button.dart';
import 'package:alo_ride_driver_app/res/common/app_text.dart';
import 'package:alo_ride_driver_app/res/constant/app_colors.dart';
import 'package:alo_ride_driver_app/res/constant/app_map_keys.dart';
import 'package:alo_ride_driver_app/res/utils/map_navigation.dart';
import 'package:alo_ride_driver_app/res/utils/ride_status_flow.dart';
import 'package:alo_ride_driver_app/screen/chat/view/chat_entry_button.dart';
import 'package:alo_ride_driver_app/screen/dashboard/screen/dashboard_screen.dart';
import 'package:alo_ride_driver_app/screen/my_rides/model/ride_history_model.dart';
import 'package:alo_ride_driver_app/screen/ride/controller/ride_completed_controller.dart';
import 'package:alo_ride_driver_app/screen/ride/view/cancel_ride_button.dart';
import 'package:alo_ride_driver_app/screen/ride/view/no_show_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:alo_ride_driver_app/res/utils/app_responsive.dart';
import 'package:gap/gap.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// class StartPickupScreen extends StatefulWidget {
//   final String riderName;
//   final String bookingId;
//   final String pickupAddress;
//   final String dropAddress;
//   final String distance;
//   final String fare;
//   final String profileImage;
//   final double pickupLat;
//   final double pickupLng;
//   final double dropLat;
//   final double dropLng;
//   const StartPickupScreen({
//     super.key,
//     required this.riderName,
//     required this.bookingId,
//     required this.pickupAddress,
//     required this.dropAddress,
//     required this.distance,
//     required this.fare,
//     required this.profileImage,
//     required this.pickupLat,
//     required this.pickupLng,
//     required this.dropLat,
//     required this.dropLng,
//   });
//
//   @override
//   State<StartPickupScreen> createState() => _StartPickupScreenState();
// }
//
// class _StartPickupScreenState extends State<StartPickupScreen> {
//   late GoogleMapController mapController;
//
//   final LatLng pickupLocation = const LatLng(46.0878, -64.7782);
//   final LatLng dropLocation = const LatLng(46.0915, -64.7500);
//
//   final Set<Marker> markers = {};
//   final Set<Polyline> polylines = {};
//
//   @override
//   void initState() {
//     super.initState();
//
//     /// Pickup Marker
//     markers.add(
//       Marker(
//         markerId: const MarkerId("pickup"),
//         position: pickupLocation,
//         icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
//       ),
//     );
//
//     /// Drop Marker
//     markers.add(
//       Marker(
//         markerId: const MarkerId("drop"),
//         position: dropLocation,
//         icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
//       ),
//     );
//
//     /// Route Polyline (dummy example)
//     polylines.add(
//       Polyline(
//         polylineId: const PolylineId("route"),
//         points: [pickupLocation, const LatLng(46.0895, -64.7700), dropLocation],
//         color: Colors.blue,
//         width: 5,
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.white,
//       appBar: AppAppBar(title: "Start Pickup"),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             Divider(color: AppColors.darkTextColor),
//             Gap(10),
//             Container(
//               padding: EdgeInsets.symmetric(horizontal: 16.w),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Icon(Icons.location_on, color: Colors.red),
//                       Gap(8.w),
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           AppText(
//                             text: "241–205 Barrieau Rd, Moncton.",
//                             fontSize: 12,
//                             color: AppColors.textColor,
//                           ),
//                           Gap(3.h),
//                           AppText(text: "11 Dec,2025  7:20 PM", fontSize: 12),
//                         ],
//                       ),
//                       Spacer(),
//                       Column(
//                         children: [
//                           const Icon(Icons.navigation, color: AppColors.secondary),
//                           Gap(2.h),
//                           AppText(text: "Navigate", fontSize: 11),
//                           Gap(2.h),
//                           AppText(
//                             text: "1.2 Km",
//                             fontSize: 12,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             Gap(10),
//             Divider(color: AppColors.darkTextColor),
//             Gap(10),
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: 16),
//               child: Row(
//                 children: [
//                   AppText(
//                     text: "Booking ID: 23356",
//                     fontWeight: FontWeight.w600,
//                     color: AppColors.blueColor,
//                   ),
//                   Spacer(),
//                   AppText(
//                     text: "Date: 10/12/2025 10.30 AM",
//                     fontWeight: FontWeight.w500,
//                     fontSize: 12,
//                   ),
//                 ],
//               ),
//             ),
//             Gap(15),
//             Container(
//               width: double.infinity,
//               height: 1,
//               color: AppColors.darkTextColor,
//             ),
//
//             Container(
//               height: 425.h,
//               child: GoogleMap(
//                 initialCameraPosition: CameraPosition(
//                   target: pickupLocation,
//                   zoom: 14,
//                 ),
//                 onMapCreated: (controller) {
//                   mapController = controller;
//                 },
//                 markers: markers,
//                 polylines: polylines,
//                 myLocationEnabled: true,
//                 myLocationButtonEnabled: false,
//               ),
//             ),
//             Gap(10),
//             Gap(10),
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: 16.h),
//               child: Row(
//                 children: [
//                   CircleAvatar(
//                     radius: 30.r,
//                     backgroundImage: const NetworkImage(
//                       "https://i.pravatar.cc/150?img=47",
//                     ),
//                   ),
//                   Gap(12.w),
//                   Expanded(
//                     child: AppText(
//                       text: "Léonie",
//                       fontSize: 13,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.end,
//                       children: [
//                         AppText(
//                           text: "1.2 Km",
//                           fontSize: 13,
//                           fontWeight: FontWeight.w500,
//                         ),
//                         AppText(
//                           text: "Fare estimate: \$20",
//                           fontSize: 13,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Gap(10),
//             Padding(
//               padding: EdgeInsets.all(16.w),
//               child: AppButton(
//                 text: "CONFIRM YOU'VE ARRIVED",
//                 onTap: () {
//                   Get.to(() => ArrivedAtPickupPoint());
//                   // navigate to next step
//                 },
//               ),
//             ),
//             Gap(10),
//           ],
//         ),
//       ),
//     );
//   }
// }

class StartPickupScreen extends StatefulWidget {
  final String riderName;
  final String bookingId;
  final String pickupAddress;
  final String dropAddress;
  final String distance;
  final String fare;
  final String profileImage;
  final double pickupLat;
  final double pickupLng;
  final double dropLat;
  final double dropLng;
  final int riderId;

  /// The ride's **current** status: `going_to_pickup` or `arrived`.
  /// The posted status is derived from it, so no step can be skipped.
  final String status;
  final String pickupTime;
  final bool? backScreen;
  final bool? myRidesBack;
  final RideData? ride;

  const StartPickupScreen({
    super.key,
    required this.riderName,
    required this.bookingId,
    required this.pickupAddress,
    required this.dropAddress,
    required this.distance,
    required this.fare,
    required this.profileImage,
    required this.pickupLat,
    required this.pickupLng,
    required this.dropLat,
    required this.dropLng,
    required this.riderId,
    required this.status,
    required this.pickupTime,
    this.backScreen, this.myRidesBack,
    this.ride,
  });

  @override
  State<StartPickupScreen> createState() => _StartPickupScreenState();
}

class _StartPickupScreenState extends State<StartPickupScreen> {
  late GoogleMapController mapController;

  /// `mapController` is only assigned in `onMapCreated`; the timer driven
  /// camera moves can fire before that (and after dispose).
  bool _isMapReady = false;

  LatLng ?pickupLocation;
  LatLng ?dropLocation;

  final Set<Marker> markers = {};
  Set<Polyline> polylines = {};
  final PolylinePoints polylinePoints = PolylinePoints(
    apiKey: AppMapKeys.apiKey,
  );
  LatLng? currentDriverLatLng;
  LatLng? destinationLatLng;
  final RideCompletedController controller = Get.put(RideCompletedController());
  String buildProfileImage(String? path) {
    if (path == null || path.isEmpty) {
      return "";
    }
    if (path.startsWith("http")) return path;
    return "https://deliverymate.volive.me/alodrive/public/$path";
  }
  List<LatLng> routePoints = [];
  double currentBearing = 0.0;
  static const double routeDeviationThresholdMeters = 35;
  static const double minReRouteIntervalSeconds = 6;

  DateTime? lastReRouteTime;

  /// 🔹 Live ride status for this screen (`going_to_pickup` → `arrived`).
  /// Kept in state so the button label flips without leaving the map.
  late String _currentStatus;
  DateTime? _arrivedAt;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.ride?.status ?? widget.status;
    _arrivedAt = widget.ride?.arrivedAt;
    loadDriverIcon();
    pickupLocation = LatLng(widget.pickupLat, widget.pickupLng);
    dropLocation = LatLng(widget.dropLat, widget.dropLng);

    _init();
    // dropLocation = LatLng(widget.dropLat, widget.dropLng);
    //
    // markers.add(
    //   Marker(
    //     markerId: const MarkerId("pickup"),
    //     position: pickupLocation,
    //     icon: BitmapDescriptor.defaultMarker,
    //   ),
    // );
    //
    // markers.add(
    //   Marker(
    //     markerId: const MarkerId("drop"),
    //     position: dropLocation,
    //     icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
    //   ),
    // );
    // getRoutePolyline(/*source: pickupLocation,*/ destination: pickupLocation);
    // updateDriverMarker();
    // refreshRouteIfNeeded();
  }

  Future<void> _init() async {
    await getRoutePolyline(destination: pickupLocation ?? LatLng(0.0, 0.0));

    /// Every step here awaits location / directions, so the screen can be gone
    /// by the time it resumes — bail instead of touching a dead State.
    if (!mounted) return;

    await updateDriverMarker();
    if (!mounted) return;

    refreshRouteIfNeeded();
    _startAutoDriverLocationFetch();
  }

  Future<LatLng?> getCurrentLatLng() async {
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
    if (perm == LocationPermission.deniedForever) return null;

    final pos = await Geolocator.getCurrentPosition(
      //desiredAccuracy: LocationAccuracy.high,
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
      )
    );

    return LatLng(pos.latitude, pos.longitude);
  }
  void refreshRouteIfNeeded() async {
    if (!mounted) return;
    if (currentDriverLatLng == null || routePoints.isEmpty) return;

    // 1) nearest point on current route
    double minDistance = double.infinity;

    for (final p in routePoints) {
      final d = Geolocator.distanceBetween(
        currentDriverLatLng!.latitude,
        currentDriverLatLng!.longitude,
        p.latitude,
        p.longitude,
      );

      if (d < minDistance) minDistance = d;
    }

    debugPrint("🚗 deviation distance = $minDistance m");

    // 2) if within route — do nothing
    if (minDistance < routeDeviationThresholdMeters) return;

    // 3) debounce re-routing API calls
    if (lastReRouteTime != null) {
      if (DateTime.now().difference(lastReRouteTime!).inSeconds <
          minReRouteIntervalSeconds) return;
    }

    lastReRouteTime = DateTime.now();

    debugPrint("🧭 Driver deviated… recalculating route");

    await getRoutePolyline(destination: pickupLocation ?? LatLng(0.0, 0.0));
  }
  Future<void> getRoutePolyline({required LatLng destination}) async {
    final current = await getCurrentLatLng();
    if (current == null || !mounted) return;

    final result = await polylinePoints.getRouteBetweenCoordinates(
      request: PolylineRequest(
        origin: PointLatLng(current.latitude, current.longitude),
        destination: PointLatLng(destination.latitude, destination.longitude),
        mode: TravelMode.driving,
        alternatives: false,
      ),
    );

    /// The directions call is a network round trip — the driver may have left
    /// the screen while it was in flight.
    if (result.points.isEmpty || !mounted) return;

    routePoints = result.points
        .map((p) => LatLng(p.latitude, p.longitude))
        .toList();

    polylines.clear();

    polylines.add(
      Polyline(
        polylineId: const PolylineId("route"),
        width: 7,
        color: Colors.blue,
        geodesic: true,
        points: routePoints,
      ),
    );

    setState(() {});
    fitCameraBounds();
  }

  Future<void> updateDriverMarker() async {
    final current = await getCurrentLatLng();

    /// 🔒 `getCurrentLatLng` awaits the GPS fix, which routinely outlives the
    /// screen (leaving the ride, a status change swapping the stage screen).
    /// Without this the pending future came back to a disposed State and
    /// `setState()` below threw.
    if (current == null || !mounted) return;

    markers.removeWhere((m) => m.markerId.value == "driver");
    markers.removeWhere((m) => m.markerId.value == "pickup");

    // smooth bearing
    if (currentDriverLatLng != null) {
      currentBearing = Geolocator.bearingBetween(
        currentDriverLatLng!.latitude,
        currentDriverLatLng!.longitude,
        current.latitude,
        current.longitude,
      );
    }

    markers.add(
      Marker(
        markerId: const MarkerId("pickup"),
        position: pickupLocation!,
       // rotation: currentBearing,
        icon: BitmapDescriptor.defaultMarker,
        anchor: const Offset(.5, .5),
      ),
    );
    markers.add(
      Marker(
        markerId: const MarkerId("driver"),
        position: current,
        rotation: currentBearing,
        icon:driverIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        anchor: const Offset(.5, .5),
      ),
    );

    currentDriverLatLng = current;

    setState(() {});

    _moveCameraToDriver(current);
  }

  void fitCameraBounds() {
    /// `mapController` is `late` — it only exists once `onMapCreated` ran.
    if (currentDriverLatLng == null || !_isMapReady) return;

    final bounds = LatLngBounds(
      southwest: LatLng(
        min(currentDriverLatLng!.latitude, pickupLocation?.latitude ?? 0.0),
        min(currentDriverLatLng!.longitude, pickupLocation?.longitude ?? 0.0),
      ),
      northeast: LatLng(
        max(currentDriverLatLng!.latitude, pickupLocation?.latitude ?? 0.0),
        max(currentDriverLatLng!.longitude, pickupLocation?.longitude ?? 0.0),
      ),
    );

    mapController.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 80),
    );
  }
  Timer? locationTimer;

  void _startAutoDriverLocationFetch() {
    locationTimer?.cancel();

    locationTimer = Timer.periodic(const Duration(seconds: 7), (timer) async {
      /// Belt and braces: `dispose` cancels the timer, but a tick already in
      /// flight must not resume against a dead State.
      if (!mounted) {
        timer.cancel();
        return;
      }

      await updateDriverMarker();
      refreshRouteIfNeeded();
    });
  }
  Timer? _liveTimer;
  static const double _minZoom = 12.0;
  static const double _maxZoom = 18.5;
  static const double _tilt = 55.0;
  static const double _bearingSmoothing = 0.2;

  void startLiveTrackingToPickup() {
    _liveTimer?.cancel();

    _liveTimer = Timer.periodic(
      const Duration(seconds: 5),
          (timer) async {
        if (!mounted) {
          timer.cancel();
          return;
        }

        await updateDriverMarker();
        if (!mounted) return;

        await getRoutePolyline(destination: pickupLocation ?? LatLng(0, 0));
      },
    );
  }

  Future<void> _moveCameraToDriver(LatLng target) async {
    if (!_isMapReady) return;

    final zoom = await mapController.getZoomLevel();
    if (!mounted || !_isMapReady) return;

    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: target,
          zoom: zoom.clamp(_minZoom, _maxZoom),
          tilt: _tilt,
          bearing: currentBearing,
        ),
      ),
    );
  }

  void stopLiveTracking() {
    _liveTimer?.cancel();
  }

  @override
  void dispose() {
    /// Both timers hold a reference to this State — leaving either running
    /// keeps it alive and lands a `setState()` on a disposed screen.
    locationTimer?.cancel();
    locationTimer = null;
    _liveTimer?.cancel();
    _liveTimer = null;
    _isMapReady = false;
    super.dispose();
  }
  // void listenDriverLocationFromSocket() {
  //   socket.on("driver_location", (data) {
  //
  //     final lat = double.parse(data["lat"].toString());
  //     final lng = double.parse(data["lng"].toString());
  //
  //     updateDriverMarker(LatLng(lat, lng));
  //   });
  // }

  /// 🧭 Opens Google Maps navigation to the pickup coordinates of this booking.
  Future<void> _openGoogleMapsNavigation() async {
    await MapNavigation.openDirections(
      latitude: widget.pickupLat,
      longitude: widget.pickupLng,
      /// Falls back to the address when the API sent no usable coordinates.
      address: widget.pickupAddress,
      label: "Pickup",
    );
  }

  /// `going_to_pickup → arrived` keeps the driver on this screen (only the
  /// label / timestamp change); `arrived → pickup_done` moves to the drop-off
  /// screen, which the controller handles.
  Future<void> _onPrimaryAction() async {
    final nextStatus = RideStatus.next(_currentStatus);
    final staysOnThisScreen = nextStatus == RideStatus.arrived;

    final updatedRide = await controller.advanceRideStatus(
      rideId: widget.riderId,
      currentStatus: _currentStatus,
      navigate: !staysOnThisScreen,
      hostedInTab: widget.backScreen == true,
    );

    if (updatedRide == null || !mounted) return;

    setState(() {
      _currentStatus = updatedRide.status ?? nextStatus ?? _currentStatus;
      _arrivedAt = updatedRide.arrivedAt ?? _arrivedAt;
    });
  }

  String _formatTimestamp(DateTime dateTime) {
    final local = dateTime.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    return "$hour:$minute ${local.hour >= 12 ? 'PM' : 'AM'}";
  }

  BitmapDescriptor? driverIcon;

  Future<void> loadDriverIcon() async {
    driverIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(48, 48)),
      "assets/icons/car.png",
    );
  }



  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if(widget.myRidesBack == true){
          Get.back();
        }else{
          Get.offAll(() => const DashboardScreen());
        }
        return false; // ⛔ prevent default back
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppAppBar(
          title: RideStatus.screenTitle(_currentStatus),
          onBack: () {
            if(widget.myRidesBack == true){
              Get.back();
            }else{
              Get.to(()=>DashboardScreen());
            }
          },
          showBack: widget.backScreen == true ? false : true,
          actions: [
            /// 💬 Chat with the customer — hidden until the ride has a room.
            ChatEntryButton(
              rideId: widget.riderId,
              rideStatus: _currentStatus,
              customerName: widget.riderName,
              customerMobile: widget.ride?.user?.mobile ?? '',
              customerPhoto: widget.profileImage,
            ),
            Gap(12.w),
          ],
          /*actions: [
            ElevatedButton(
              onPressed: () {
                //  getRoutePolyline(destination: destinationLatLng ?? LatLng(, longitude));
              },
              child: Text("Hello"),
            ),
          ],*/
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            /// The fixed rows (addresses, rider, buttons) can be taller than the
            /// viewport on short screens, so the page scrolls and the map takes a
            /// share of the height instead of whatever is left over.
            final mapHeight = max(240.h, constraints.maxHeight * 0.35);
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
          children: [
            // ElevatedButton(onPressed: (){
            //
            // }, child: Text("dcd")),
            Divider(color: AppColors.darkTextColor),
            Gap(10),

            /// 📍 PICKUP ADDRESS
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on, color: Colors.red),
                  Gap(8.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          text: widget.pickupAddress,
                          fontSize: 12,
                          color: AppColors.textColor,
                        ),
                        Gap(3.h),
                        AppText(text: widget.pickupTime, fontSize: 12),
                      ],
                    ),
                  ),
                  /// 🧭 GOOGLE MAPS NAVIGATION
                  InkWell(
                    borderRadius: BorderRadius.circular(8.r),
                    onTap: _openGoogleMapsNavigation,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 4.h,
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.navigation,
                            color: AppColors.secondary,
                          ),
                          Gap(2.h),
                          AppText(text: "Navigate", fontSize: 11),
                          Gap(2.h),
                          AppText(
                            text: "${widget.distance} Km",
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Gap(10),
            Divider(color: AppColors.darkTextColor),
            Gap(10),

            /// 📄 BOOKING
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  AppText(
                    text: "Booking ID: ${widget.bookingId}",
                    fontWeight: FontWeight.w600,
                    color: AppColors.blueColor,
                  ),
                  Spacer(),
                  AppText(
                    text: RideStatus.stageLabel(_currentStatus),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ],
              ),
            ),

            /// ⏱ ARRIVAL TIME (backend `arrived_at`)
            if (_arrivedAt != null) ...[
              Gap(6),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: AppText(
                    text: "Arrived at ${_formatTimestamp(_arrivedAt!)}",
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.greenColor,
                  ),
                ),
              ),
            ],

            Gap(15),

            /// 🗺 MAP
            SizedBox(
              height: mapHeight,
              child: Stack(
                children: [
                  SizedBox.expand(
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: pickupLocation ?? LatLng(0, 0),
                        zoom: 20,
                      ),
                      onMapCreated: (controller) {
                        mapController = controller;
                        _isMapReady = true;
                      },
                      markers: markers,
                      polylines: polylines,
                      myLocationEnabled: false,
                      myLocationButtonEnabled: true,
                    ),
                  ),

                  /// 🧭 OPEN IN GOOGLE MAPS
                  Positioned(
                    left: 16.w,
                    bottom: 16.h,
                    child: FloatingActionButton.extended(
                      heroTag: "pickup_navigation",
                      backgroundColor: AppColors.secondary,
                      foregroundColor: AppColors.white,
                      onPressed: _openGoogleMapsNavigation,
                      icon: const Icon(Icons.directions),
                      label: AppText(
                        text: "Google Maps",
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Gap(10),

            /// 👤 RIDER
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.h),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30.r,
                    backgroundImage: NetworkImage(
                      buildProfileImage(widget.profileImage),
                    ),
                  ),
                  Gap(12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          text: widget.riderName,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        if(widget.ride?.isFlight == true)
                        AppText(
                          text:"Airport Pickup(${widget.ride?.flightNumber})",
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.red,
                          overflow: TextOverflow.visible,
                        ),
                      ],
                    ),
                  ),
                  Gap(8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        AppText(text: "${widget.distance} Km", fontSize: 13),
                        AppText(
                          text: "Fare estimate: \$${widget.fare}",
                          fontSize: 13,overflow: TextOverflow.visible,
                        ),
                      ],
                    ),
                  ),


                ],
              ),
            ),
            if(widget.ride?.isPackageStatus == 1)...[
              Gap(10),
              Padding(
                padding:  EdgeInsets.symmetric(horizontal: 16.h),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: AppText(
                    text:
                    "Package used - ${widget.ride?.packageName}",
                    fontSize: 12,
                    maxLines: 2,
                    color: AppColors.red,
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
            ],

            Gap(10),

            /// 🔘 ARRIVED → PICK UP, driven by the ride's current status.
            if (RideStatus.actionLabel(_currentStatus) != null)
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Obx(() {
                  final isLoading = controller.isLoading.value;
                  return AppButton(
                    isLoading: isLoading,
                    text: RideStatus.actionLabel(_currentStatus)!,
                    onTap: isLoading ? null : _onPrimaryAction,
                  );
                }),
              ),

            /// 🚫 Only once the backend confirmed `arrived` — customer never
            /// showed up, so the ride is cancelled and the fee is charged.
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: NoShowButton(
                rideId: widget.riderId,
                status: _currentStatus,
              ),
            ),
            if (RideStatus.canReportNoShow(_currentStatus)) Gap(10),

            /// ❌ Only while the backend status allows cancelling.
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: CancelRideButton(
                rideId: widget.riderId,
                status: _currentStatus,
              ),
            ),
            Gap(10),
          ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
