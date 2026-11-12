import 'package:alo_ride_driver_app/res/utils/ride_status_flow.dart';
import 'package:alo_ride_driver_app/screen/my_rides/model/ride_history_model.dart';
import 'package:alo_ride_driver_app/screen/ride/view/reached_destination_screen.dart';
import 'package:alo_ride_driver_app/screen/ride/view/ride_details_screen.dart';
import 'package:alo_ride_driver_app/screen/ride/view/start_pickup_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

/// Builds the stage screen that matches a ride's *current* status, so every
/// entry point (current ride tab, my rides list, accept flow, status update)
/// stays in sync with the backend instead of guessing the next screen.
///
///   accepted        → RideDetailsScreen        (START RIDE)
///   going_to_pickup → StartPickupScreen        (ARRIVED)
///   arrived         → StartPickupScreen        (PICK UP)
///   pickup_done     → ReachedDestinationScreen (DROP OFF)
class RideScreenRouter {
  const RideScreenRouter._();

  static Widget? screenFor(
    RideData ride, {
    bool? backScreen,
    bool? myRidesBack,
  }) {
    final status = ride.status;
    final pickupTime = formatRideDate(ride.pickupDatetime?.toIso8601String());

    switch (status) {
      case RideStatus.accepted:
        return RideDetailsScreen(
          riderId: ride.id ?? 0,
          riderName: ride.user?.name ?? '',
          status: RideStatus.accepted,
          bookingId: ride.bookingId ?? '',
          distance: ride.distanceKm ?? '',
          fare: ride.totalFare ?? '',
          pickupAddress: ride.pickupAddress ?? '',
          dropAddress: ride.dropAddress ?? '',
          pickupTime: pickupTime,
          profileImage: ride.user?.profilePhoto ?? '',
          backScreen: backScreen,
          myRidesBack: myRidesBack,
          ride: ride,
        );

      case RideStatus.goingToPickup:
      case RideStatus.arrived:
        return StartPickupScreen(
          riderName: ride.user?.name ?? '',
          bookingId: ride.bookingId ?? '',
          pickupAddress: ride.pickupAddress ?? '',
          dropAddress: ride.dropAddress ?? '',
          distance: ride.distanceKm ?? '0',
          fare: ride.totalFare ?? '0',
          profileImage: ride.user?.profilePhoto ?? '',
          pickupLat: double.tryParse(ride.pickupLatitude ?? '') ?? 0,
          pickupLng: double.tryParse(ride.pickupLongitude ?? '') ?? 0,
          dropLat: double.tryParse(ride.dropLatitude ?? '') ?? 0,
          dropLng: double.tryParse(ride.dropLongitude ?? '') ?? 0,
          pickupTime: pickupTime,
          riderId: ride.id ?? 0,
          status: status!,
          backScreen: backScreen,
          myRidesBack: myRidesBack,
          ride: ride,
        );

      case RideStatus.pickupDone:
        return ReachedDestinationScreen(
          riderName: ride.user?.name ?? '',
          bookingId: ride.bookingId ?? '',
          pickupAddress: ride.pickupAddress ?? '',
          dropAddress: ride.dropAddress ?? '',
          distance: ride.distanceKm ?? '0',
          fare: ride.totalFare ?? '0',
          profileImage: ride.user?.profilePhoto ?? '',
          pickupLat: double.tryParse(ride.pickupLatitude ?? '') ?? 0,
          pickupLng: double.tryParse(ride.pickupLongitude ?? '') ?? 0,
          dropLat: double.tryParse(ride.dropLatitude ?? '') ?? 0,
          dropLng: double.tryParse(ride.dropLongitude ?? '') ?? 0,
          riderId: ride.id ?? 0,
          status: RideStatus.pickupDone,
          pickupTime: pickupTime,
          backScreen: backScreen,
          myRidesBack: myRidesBack,
          ride: ride,
        );

      default:
        return null;
    }
  }

  /// Opens the screen for [ride]'s current status.
  /// [replace] swaps the current route so the driver can't walk back into a
  /// stage the backend has already moved past.
  static void open(
    RideData ride, {
    bool replace = false,
    bool? backScreen,
    bool? myRidesBack,
  }) {
    final screen = screenFor(
      ride,
      backScreen: backScreen,
      myRidesBack: myRidesBack,
    );
    if (screen == null) return;

    if (replace) {
      Get.off(() => screen);
    } else {
      Get.to(() => screen);
    }
  }

  static String formatRideDate(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return "";
    final parsed = DateTime.tryParse(isoDate);
    if (parsed == null) return isoDate;
    return DateFormat("dd MMM,yyyy  h:mm a").format(parsed.toLocal());
  }
}
