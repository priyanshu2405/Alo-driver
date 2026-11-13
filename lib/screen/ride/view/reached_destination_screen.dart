import 'dart:async';

import 'package:alo_ride_driver_app/res/common/app_appbar.dart';
import 'package:alo_ride_driver_app/res/common/app_button.dart';
import 'package:alo_ride_driver_app/res/common/app_image.dart';
import 'package:alo_ride_driver_app/res/common/app_text.dart';
import 'package:alo_ride_driver_app/res/constant/app_colors.dart';
import 'package:alo_ride_driver_app/res/constant/app_images.dart';
import 'package:alo_ride_driver_app/res/constant/app_map_keys.dart';
import 'package:alo_ride_driver_app/res/utils/map_navigation.dart';
import 'package:alo_ride_driver_app/res/utils/ride_status_flow.dart';
import 'package:alo_ride_driver_app/screen/chat/view/chat_entry_button.dart';
import 'package:alo_ride_driver_app/screen/dashboard/screen/dashboard_screen.dart';
import 'package:alo_ride_driver_app/screen/my_rides/model/ride_history_model.dart';
import 'package:alo_ride_driver_app/screen/ride/controller/ride_completed_controller.dart';
import 'package:alo_ride_driver_app/screen/ride/view/cancel_ride_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:alo_ride_driver_app/res/utils/app_responsive.dart';
import 'package:gap/gap.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Drop-off stage (`pickup_done`): guides the driver through every remaining
/// stop and finally to the drop-off location.
class ReachedDestinationScreen extends StatefulWidget {
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

  /// The ride's **current** status (`pickup_done`).
  final String status;
  final String pickupTime;
  final bool? backScreen;
  final bool? myRidesBack;
  final RideData ride;

  const ReachedDestinationScreen({
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
    this.backScreen,
    this.myRidesBack,
    required this.ride,
  });

  @override
  State<ReachedDestinationScreen> createState() =>
      _ReachedDestinationScreenState();
}

class _ReachedDestinationScreenState extends State<ReachedDestinationScreen> {
  final RideCompletedController controller = Get.put(RideCompletedController());

  late LatLng pickupLocation;

  /// Stop 1 → Stop 2 → … → Drop Off
  List<RideDestination> destinations = [];

  /// Rebuilt as a **new** set every time: GoogleMap diffs the set it is given
  /// against the previous one, so mutating a single instance in place makes it
  /// see no change and later markers/polylines never reach the map.
  Set<Marker> markers = {};
  Set<Polyline> polylines = {};

  /// Draw order, so a stop can never hide the final drop-off when two points
  /// share the same coordinates.
  static const double _zPickup = 1;
  static const double _zStop = 2;
  static const double _zDriver = 3;
  static const double _zDrop = 4;

  final PolylinePoints polylinePoints = PolylinePoints(
    apiKey: AppMapKeys.apiKey,
  );

  GoogleMapController? mapController;
  LatLng? driverLatLng;
  Timer? _locationTimer;

  @override
  void initState() {
    super.initState();

    pickupLocation = LatLng(widget.pickupLat, widget.pickupLng);
    destinations = _buildDestinations();

    _buildMarkers();
    _drawFullRoute();
    _refreshDriverLocation();
    _startLocationUpdates();
    _loadStopsFromApi();
  }

  /// The ride handed to this screen doesn't always carry `stops` (the list and
  /// current-ride payloads are lighter than the details one), which would leave
  /// the stop markers off the map. Pull the full ride once and redraw if it
  /// brings more destinations.
  Future<void> _loadStopsFromApi() async {
    final refreshed = await controller.fetchRideDetails(widget.riderId);
    if (!mounted || refreshed == null) return;

    final latest = refreshed.destinations;
    if (latest.isEmpty || latest.length <= destinations.length) return;

    setState(() => destinations = latest);

    _buildMarkers();
    _drawFullRoute();
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    mapController?.dispose();
    super.dispose();
  }

  /// Stops from the API; falls back to the legacy `drop_*` fields so a ride
  /// without stops still shows `Pickup → Drop Off`.
  List<RideDestination> _buildDestinations() {
    final fromApi = widget.ride.destinations;
    if (fromApi.isNotEmpty) return fromApi;

    return [
      RideDestination(
        index: 0,
        latitude: widget.dropLat,
        longitude: widget.dropLng,
        address: widget.dropAddress,
        isFinalDrop: true,
      ),
    ];
  }

  /// The stop the driver is heading to right now: the first pending one, and
  /// the drop-off once every stop has been covered. Recomputed on every read,
  /// so it stays correct after a stop is completed or the ride is refreshed.
  RideDestination? get _currentDestination {
    for (final destination in destinations) {
      if (!destination.isReached) return destination;
    }
    return destinations.isEmpty ? null : destinations.last;
  }

  /// Only destinations the map can actually plot.
  List<RideDestination> get _mappableDestinations =>
      destinations.where((d) => d.hasCoordinates).toList();

  /// The final drop-off — the last entry, which the model guarantees is the
  /// ride's `drop_*` location and never an intermediate stop.
  RideDestination? get _finalDropOff {
    for (final destination in destinations.reversed) {
      if (destination.isFinalDrop) return destination;
    }
    return destinations.isEmpty ? null : destinations.last;
  }

  /// Everything between the pickup and the drop-off, in `sequence` order.
  List<RideDestination> get _intermediateStops =>
      destinations.where((d) => !d.isFinalDrop).toList();

  List<RideDestination> get _pendingDestinations =>
      destinations.where((d) => !d.isReached).toList();

  // ================= MAP =================

  /// Pickup + every stop with valid coordinates + the final drop-off, each with
  /// its own marker id and InfoWindow.
  void _buildMarkers() {
    final current = _currentDestination;

    final updated = <Marker>{
      Marker(
        markerId: const MarkerId("pickup"),
        position: pickupLocation,
        zIndex: _zPickup,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: InfoWindow(
          title: "Pickup",
          snippet: widget.pickupAddress,
        ),
        onTap: () => _showAddress("Pickup", widget.pickupAddress),
      ),
    };

    for (final destination in _mappableDestinations) {
      final isCurrent = destination.index == current?.index;

      updated.add(
        Marker(
          /// Unique per destination, so no marker can overwrite another.
          markerId: MarkerId(
            destination.isFinalDrop
                ? "drop_off"
                : "stop_${destination.stopId ?? destination.index}",
          ),
          position: LatLng(destination.latitude!, destination.longitude!),

          /// The drop-off sits above the stops — when a stop shares its
          /// coordinates the drop-off stays the visible one.
          zIndex: destination.isFinalDrop ? _zDrop : _zStop,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            destination.isReached
                ? BitmapDescriptor.hueGreen
                : destination.isFinalDrop
                    ? BitmapDescriptor.hueRed
                    : isCurrent
                        ? BitmapDescriptor.hueOrange
                        : BitmapDescriptor.hueRose,
          ),
          infoWindow: InfoWindow(
            title: isCurrent ? "${destination.label} • NEXT" : destination.label,
            snippet: _addressOf(destination),
          ),
          onTap: () => _showAddress(destination.label, _addressOf(destination)),
        ),
      );
    }

    /// 🔴 The drop-off marker is never optional: if the destination list had no
    /// usable coordinates for it, fall back to the booking's `drop_*` values so
    /// the final drop pin is always on the map.
    final hasDropMarker =
        updated.any((m) => m.markerId.value == "drop_off");

    if (!hasDropMarker &&
        MapNavigation.areCoordinatesValid(widget.dropLat, widget.dropLng)) {
      updated.add(
        Marker(
          markerId: const MarkerId("drop_off"),
          position: LatLng(widget.dropLat, widget.dropLng),
          zIndex: _zDrop,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: "Drop Off",
            snippet: widget.dropAddress,
          ),
          onTap: () => _showAddress("Drop Off", widget.dropAddress),
        ),
      );
    }

    if (driverLatLng != null) {
      updated.add(
        Marker(
          markerId: const MarkerId("driver"),
          position: driverLatLng!,
          zIndex: _zDriver,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(title: "You"),
        ),
      );
    }

    debugPrint(
      "🗺 Drop-off map markers: ${updated.map((m) => m.markerId.value).join(', ')}",
    );

    if (!mounted) {
      markers = updated;
      return;
    }

    setState(() => markers = updated);
  }

  /// Complete route `Pickup → Stop 1 → … → Drop Off`, with the leg to the
  /// current destination highlighted on top of it.
  Future<void> _drawFullRoute() async {
    final plottable = _mappableDestinations;
    if (plottable.isEmpty) return;

    final finalDrop = plottable.last;

    final wayPoints = plottable
        .sublist(0, plottable.length - 1)
        .map((d) => PolylineWayPoint(location: "${d.latitude},${d.longitude}"))
        .toList();

    final points = await _fetchRoute(
      origin: pickupLocation,
      destination: LatLng(finalDrop.latitude!, finalDrop.longitude!),
      wayPoints: wayPoints,
    );

    if (points.isEmpty || !mounted) return;

    _replacePolyline(
      Polyline(
        polylineId: const PolylineId("full_route"),
        color: AppColors.blueColor.withOpacity(0.55),
        width: 6,
        geodesic: true,
        points: points,
      ),
    );

    _fitCameraBounds();
    _drawActiveLeg();
  }

  /// Driver → current destination, drawn in the accent colour.
  Future<void> _drawActiveLeg() async {
    final current = _currentDestination;
    final origin = driverLatLng;
    if (current == null || origin == null || !current.hasCoordinates) return;

    final points = await _fetchRoute(
      origin: origin,
      destination: LatLng(current.latitude!, current.longitude!),
    );

    if (points.isEmpty || !mounted) return;

    _replacePolyline(
      Polyline(
        polylineId: const PolylineId("active_leg"),
        color: AppColors.secondary,
        width: 7,
        geodesic: true,
        points: points,
      ),
    );
  }

  /// Swaps one polyline into a **new** set — same reason as the markers: the
  /// map ignores a set instance it has already been given.
  void _replacePolyline(Polyline polyline) {
    final updated = Set<Polyline>.from(polylines)
      ..removeWhere((p) => p.polylineId == polyline.polylineId)
      ..add(polyline);

    if (!mounted) {
      polylines = updated;
      return;
    }

    setState(() => polylines = updated);
  }

  Future<List<LatLng>> _fetchRoute({
    required LatLng origin,
    required LatLng destination,
    List<PolylineWayPoint> wayPoints = const [],
  }) async {
    try {
      final result = await polylinePoints.getRouteBetweenCoordinates(
        request: PolylineRequest(
          origin: PointLatLng(origin.latitude, origin.longitude),
          destination: PointLatLng(destination.latitude, destination.longitude),
          mode: TravelMode.driving,
          wayPoints: wayPoints,
        ),
      );

      return result.points
          .map((p) => LatLng(p.latitude, p.longitude))
          .toList();
    } catch (e) {
      debugPrint("Route Error: $e");
      return [];
    }
  }

  /// Keeps pickup, every stop, the drop-off and the driver in view.
  Future<void> _fitCameraBounds() async {
    final map = mapController;
    if (map == null) return;

    final points = <LatLng>[
      pickupLocation,
      ..._mappableDestinations.map((d) => LatLng(d.latitude!, d.longitude!)),
      if (driverLatLng != null) driverLatLng!,
    ];

    if (points.isEmpty) return;

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final point in points) {
      minLat = point.latitude < minLat ? point.latitude : minLat;
      maxLat = point.latitude > maxLat ? point.latitude : maxLat;
      minLng = point.longitude < minLng ? point.longitude : minLng;
      maxLng = point.longitude > maxLng ? point.longitude : maxLng;
    }

    /// A single point (or points almost on top of each other) collapses the
    /// bounds and Maps can't derive a zoom from it — pad it out slightly.
    const minSpan = 0.002;
    if (maxLat - minLat < minSpan) {
      final center = (maxLat + minLat) / 2;
      minLat = center - minSpan / 2;
      maxLat = center + minSpan / 2;
    }
    if (maxLng - minLng < minSpan) {
      final center = (maxLng + minLng) / 2;
      minLng = center - minSpan / 2;
      maxLng = center + minSpan / 2;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    try {
      await map.animateCamera(CameraUpdate.newLatLngBounds(bounds, 70));
    } catch (e) {
      /// Thrown when the map hasn't been laid out yet — retry once it has.
      debugPrint("Fit Camera Error: $e");
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      await map.animateCamera(CameraUpdate.newLatLngBounds(bounds, 70));
    }
  }

  // ================= LOCATION =================

  void _startLocationUpdates() {
    _locationTimer?.cancel();
    _locationTimer = Timer.periodic(
      const Duration(seconds: 7),
      (_) => _refreshDriverLocation(),
    );
  }

  Future<void> _refreshDriverLocation() async {
    final position = await _currentLatLng();
    if (position == null || !mounted) return;

    driverLatLng = position;
    _buildMarkers();
    _drawActiveLeg();
  }

  Future<LatLng?> _currentLatLng() async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      debugPrint("Driver Location Error: $e");
      return null;
    }
  }


  /// Address shown in the UI and on the marker: the stop's own address, the
  /// ride's `drop_address` for the final drop-off, then a plain placeholder.
  String _addressOf(RideDestination? destination) {
    final address = destination?.address.trim() ?? '';
    if (address.isNotEmpty) return address;

    if (destination?.isFinalDrop == true && widget.dropAddress.trim().isNotEmpty) {
      return widget.dropAddress;
    }
    return "Address not available";
  }

  void _showAddress(String label, String address) {
    Get.snackbar(
      label,
      address.isEmpty ? "Address not available" : address,
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.blueColor.withOpacity(0.9),
      colorText: AppColors.white,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(8),
      borderRadius: 8,
    );
  }

  /// Opens the complete trip route in Google Maps:
  /// `Pickup → Stop 1 → … → Final Drop Off`.
  ///
  /// The final drop-off is always the destination; intermediate stops are sent
  /// as waypoints only, so a stop can never end up as the destination.
  Future<void> _openGoogleMapsNavigation() async {
    final finalDrop = _finalDropOff;

    if (finalDrop == null || !finalDrop.isNavigable) {
      Get.snackbar(
        "Navigation",
        "Drop off location is not available for this ride",
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.red.withOpacity(0.85),
        colorText: AppColors.white,
      );
      return;
    }

    await MapNavigation.openRoute(
      origin: MapPoint(
        latitude: widget.pickupLat,
        longitude: widget.pickupLng,
        address: widget.pickupAddress,
        label: "Pickup",
      ),
      waypoints: _intermediateStops
          .map(
            (stop) => MapPoint(
              latitude: stop.latitude,
              longitude: stop.longitude,
              address: stop.address,
              label: stop.label,
            ),
          )
          .toList(),
      destination: MapPoint(
        latitude: finalDrop.latitude,
        longitude: finalDrop.longitude,
        address: _addressOf(finalDrop),
        label: finalDrop.label,
      ),
    );
  }

  // ================= ACTIONS =================

  /// DROP OFF completes the ride straight away (`pickup_done → completed`),
  /// regardless of how many stops the trip has.
  Future<void> _onPrimaryAction() async {
    await controller.advanceRideStatus(
      rideId: widget.riderId,
      currentStatus: widget.status,
      hostedInTab: widget.backScreen == true,
    );
  }

  String get _primaryActionLabel =>
      RideStatus.actionLabel(widget.status) ?? "DROP OFF";

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (widget.myRidesBack == true) {
          Get.back();
        } else {
          Get.offAll(() => const DashboardScreen());
        }
        return false; // ⛔ prevent default back
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppAppBar(
          title: RideStatus.screenTitle(widget.status),
          onBack: () {
            if (widget.myRidesBack == true) {
              Get.back();
            } else {
              Get.to(() => DashboardScreen());
            }
          },
          showBack: widget.backScreen == true ? false : true,
          actions: [
            /// 💬 Chat with the customer — hidden until the ride has a room.
            ChatEntryButton(
              rideId: widget.riderId,
              rideStatus: widget.status,
              customerName: widget.riderName,
              customerMobile: widget.ride.user?.mobile ?? '',
              customerPhoto: widget.profileImage,
            ),
            Gap(12.w),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Divider(color: AppColors.darkTextColor),
              Gap(15),

              /// 📍 PICKUP → STOPS → DROP OFF
              _buildLocationRow(
                icon: AppImage(
                  height: 20.h,
                  width: 20.w,
                  image: AppImages.recordCircleFill,
                  imageType: ImageType.svgAsset,
                ),
                label: "Pickup",
                title: widget.pickupAddress,
                subtitle: widget.pickupTime,
                showDivider: destinations.isNotEmpty,
                isReached: true,
              ),

              ...List.generate(destinations.length, (index) {
                final destination = destinations[index];
                final isNext = destination.index == _currentDestination?.index;
                return _buildLocationRow(
                  icon: Icon(
                    destination.isReached
                        ? Icons.check_circle
                        : Icons.location_on,
                    color: destination.isReached
                        ? AppColors.greenColor
                        : isNext
                            ? AppColors.secondary
                            : AppColors.pinkColor,
                    size: 20,
                  ),
                  label: destination.label,
                  title: _addressOf(destination),
                  subtitle: '',
                  showDivider: index != destinations.length - 1,
                  isNext: isNext,
                  isReached: destination.isReached,
                );
              }),

              Gap(15),
              Divider(color: AppColors.darkTextColor),
              Gap(10),

              /// 📄 BOOKING INFO
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        AppText(
                          text: "Booking ID: ${widget.bookingId}",
                          fontWeight: FontWeight.w600,
                          color: AppColors.blueColor,
                        ),
                        const Spacer(),
                        AppText(
                          text: RideStatus.stageLabel(widget.status),
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ],
                    ),
                    if (widget.ride.pickupAt != null) ...[
                      Gap(4),
                      AppText(
                        text: "Picked up at ${_formatTime(widget.ride.pickupAt!)}",
                        fontSize: 12,
                        color: AppColors.greenColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ],
                    if (widget.ride.isFlight == true) ...[
                      Gap(8),
                      Divider(color: AppColors.darkTextColor),
                      Gap(8),
                      AppText(
                        text: "Airport Pickup(${widget.ride.flightNumber})",
                        fontWeight: FontWeight.w600,
                        color: AppColors.red,
                      ),
                    ],
                  ],
                ),
              ),

              Gap(15),
              Container(height: 1, color: AppColors.darkTextColor),

              /// 🗺️ MAP — pickup, every stop and the drop-off
              SizedBox(
                height: 320.h,
                child: Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: pickupLocation,
                        zoom: 14,
                      ),
                      onMapCreated: (map) {
                        mapController = map;
                        _fitCameraBounds();
                      },
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      markers: markers,
                      polylines: polylines,
                      gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                        Factory<OneSequenceGestureRecognizer>(
                          () => EagerGestureRecognizer(),
                        ),
                      },
                    ),

                    /// 🧭 NAVIGATE TO THE CURRENT DESTINATION
                    Positioned(
                      left: 16.w,
                      bottom: 16.h,
                      child: FloatingActionButton.extended(
                        heroTag: "dropoff_navigation",
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

              /// 🚗 NEXT DESTINATION
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        text: "Next destination • ${_currentDestination?.label ?? 'Drop Off'}",
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.secondary,
                      ),
                      Gap(4),
                      AppText(
                        text: _addressOf(_currentDestination),
                        fontSize: 13,
                        maxLines: 2,
                      ),
                      if (_pendingDestinations.length > 1) ...[
                        Gap(4),
                        AppText(
                          text: "${_pendingDestinations.length - 1} more stop(s) before drop off",
                          fontSize: 11,
                          color: AppColors.lightBlackColor,
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              Container(height: 1, color: AppColors.darkTextColor),

              /// 🚗 TRAVEL INFO
              Container(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _infoBox("Rider", widget.riderName),
                    Gap(60.w),
                    Container(
                      width: 1,
                      height: 60,
                      color: AppColors.darkTextColor,
                    ),
                    Gap(60.w),
                    _infoBox("Distance", "${widget.distance} km"),
                  ],
                ),
              ),

              Container(height: 1, color: AppColors.darkTextColor),
              Gap(15),

              /// 💰 FARE
              _fareRow("Trip Fare", "\$${widget.fare}", fontSize: 16, bold: true),

              if (widget.ride.isPackageStatus == 1) ...[
                Gap(10),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.h),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: AppText(
                      text: "Package used - ${widget.ride.packageName}",
                      fontSize: 12,
                      maxLines: 2,
                      color: AppColors.red,
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
              ],

              Gap(20),

              /// ✅ DROP OFF — completes the ride directly
              if (RideStatus.actionLabel(widget.status) != null)
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Obx(() {
                    final isLoading = controller.isLoading.value;
                    return AppButton(
                      isLoading: isLoading,
                      text: _primaryActionLabel,
                      backgroundColor: AppColors.secondary,
                      onTap: isLoading ? null : _onPrimaryAction,
                    );
                  }),
                ),

              /// ❌ Only while the backend status allows cancelling.
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: CancelRideButton(
                  rideId: widget.riderId,
                  status: widget.ride.status ?? widget.status,
                ),
              ),
              Gap(20),
            ],
          ),
        ),
      ),
    );
  }

  /// ================= COMPONENTS =================

  String _formatTime(DateTime dateTime) {
    final local = dateTime.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    return "$hour:$minute ${local.hour >= 12 ? 'PM' : 'AM'}";
  }

  Widget _buildLocationRow({
    required Widget icon,
    required String title,
    required String subtitle,
    required bool showDivider,
    String? label,
    bool isNext = false,
    bool isReached = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              icon,
              if (showDivider)
                Column(
                  children: List.generate(
                    10,
                    (_) => Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Container(
                        height: 2,
                        width: 2,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (label != null)
                  Row(
                    children: [
                      AppText(
                        text: label,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isNext
                            ? AppColors.secondary
                            : AppColors.lightBlackColor,
                      ),
                      if (isNext) ...[
                        Gap(6.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: AppText(
                            text: "NEXT",
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                AppText(
                  text: title,
                  maxLines: 2,
                  fontWeight: isNext ? FontWeight.w600 : FontWeight.normal,
                  color: isReached && !isNext
                      ? AppColors.lightBlackColor
                      : AppColors.black,
                ),
                if (subtitle.isNotEmpty)
                  AppText(text: subtitle, fontSize: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoBox(String title, String value) {
    return Column(
      children: [
        AppText(text: title, fontSize: 12, color: AppColors.lightBlackColor),
        Gap(4.h),
        AppText(text: value, fontWeight: FontWeight.w600),
      ],
    );
  }

  Widget _fareRow(
    String title,
    String value, {
    bool bold = false,
    double fontSize = 14,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(
            text: title,
            fontSize: fontSize,
            fontWeight: bold ? FontWeight.w500 : FontWeight.normal,
          ),
          AppText(
            text: value,
            fontSize: fontSize,
            fontWeight: bold ? FontWeight.w500 : FontWeight.normal,
          ),
        ],
      ),
    );
  }
}
