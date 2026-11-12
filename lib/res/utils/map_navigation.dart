import 'dart:io';

import 'package:alo_ride_driver_app/res/constant/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens Google Maps turn-by-turn navigation to a ride destination
/// (pickup, an intermediate stop, or the final drop-off).
///
/// Android : `google.navigation:` starts navigation inside the Google Maps app,
///           `geo:` is the fallback when navigation mode isn't available.
/// iOS     : `comgooglemaps://` opens the Google Maps app in directions mode,
///           `maps://` falls back to Apple Maps.
/// Last    : the universal `google.com/maps/dir` link, which opens the Google
///           Maps app when installed and the default browser when it isn't.
///
/// Both `google.navigation` and `geo` must be declared in the Android manifest
/// `<queries>` block, otherwise the launcher reports them as unavailable on
/// Android 11+ and navigation silently falls back to the browser.
/// One point of a trip route — the pickup, a stop, or the final drop-off.
class MapPoint {
  final double? latitude;
  final double? longitude;
  final String address;

  /// "Pickup", "Stop 1", "Drop Off" — used for logging and the map pin label.
  final String label;

  const MapPoint({
    this.latitude,
    this.longitude,
    this.address = '',
    this.label = '',
  });

  bool get hasCoordinates =>
      MapNavigation.areCoordinatesValid(latitude, longitude);

  bool get isNavigable => hasCoordinates || address.trim().isNotEmpty;

  /// What Google Maps receives. Coordinates from the booking are used whenever
  /// they're valid, so the pin lands on the exact booked location; the address
  /// is only used when the API sent no usable coordinates.
  String get query =>
      hasCoordinates ? "$latitude,$longitude" : address.trim();
}

class MapNavigation {
  const MapNavigation._();

  /// [latitude] / [longitude] come from the API and take priority.
  /// [address] is used as the destination when coordinates are missing or
  /// invalid, and as the map label when they are valid.
  static Future<void> openDirections({
    required double? latitude,
    required double? longitude,
    String? address,
    String? label,
  }) async {
    final hasCoordinates = areCoordinatesValid(latitude, longitude);
    final trimmedAddress = address?.trim() ?? '';

    if (!hasCoordinates && trimmedAddress.isEmpty) {
      _showError("Location not available for this ride");
      return;
    }

    /// `lat,lng` navigates to the exact point the backend returned; the address
    /// is only used when no usable coordinates came back.
    final destination = hasCoordinates ? "$latitude,$longitude" : trimmedAddress;

    final uris = _buildUris(
      destination: destination,
      hasCoordinates: hasCoordinates,
      label: (label ?? trimmedAddress).trim(),
    );

    for (final uri in uris) {
      if (await _tryLaunch(uri)) return;
    }

    _showError("Could not open Google Maps");
  }

  /// Opens the complete trip route in Google Maps:
  /// `Pickup → Stop 1 → … → Final Drop Off`.
  ///
  /// [destination] is always the final drop-off — stops are passed as
  /// waypoints only and can never take its place. Waypoints require the Maps
  /// URL API (`google.navigation:` supports a single destination only), so the
  /// universal link is used first; it opens the Google Maps app when installed
  /// and only falls back to a single-destination launch if that fails.
  static Future<void> openRoute({
    required MapPoint origin,
    required List<MapPoint> waypoints,
    required MapPoint destination,
  }) async {
    if (!destination.isNavigable) {
      _showError("Drop off location not available for this ride");
      return;
    }

    final routeUri = buildRouteUri(
      origin: origin,
      waypoints: waypoints,
      destination: destination,
    );

    if (await _tryLaunch(routeUri)) return;

    /// Couldn't open the multi-stop route — at least start navigation to the
    /// drop-off rather than leaving the driver with nothing.
    await openDirections(
      latitude: destination.latitude,
      longitude: destination.longitude,
      address: destination.address,
      label: destination.label,
    );
  }

  /// `https://www.google.com/maps/dir/?api=1&origin=…&waypoints=…&destination=…`
  @visibleForTesting
  static Uri buildRouteUri({
    required MapPoint origin,
    required List<MapPoint> waypoints,
    required MapPoint destination,
  }) {
    /// The Maps URL API accepts at most 9 waypoints.
    final usableWaypoints = waypoints
        .where((point) => point.isNavigable)
        .take(_maxWaypoints)
        .map((point) => point.query)
        .toList();

    final params = <String, String>{
      "api": "1",
      if (origin.isNavigable) "origin": origin.query,
      "destination": destination.query,
      if (usableWaypoints.isNotEmpty) "waypoints": usableWaypoints.join("|"),
      "travelmode": "driving",
      "dir_action": "navigate",
    };

    return Uri.https("www.google.com", "/maps/dir/", params);
  }

  static const int _maxWaypoints = 9;

  /// Rejects nulls, NaN/infinite values, out of range values and the `0,0`
  /// null-island the API sends when a location wasn't set.
  static bool areCoordinatesValid(double? latitude, double? longitude) {
    if (latitude == null || longitude == null) return false;
    if (!latitude.isFinite || !longitude.isFinite) return false;
    if (latitude.abs() > 90 || longitude.abs() > 180) return false;
    if (latitude == 0 && longitude == 0) return false;
    return true;
  }

  /// Parses the string coordinates the API returns, returning `null` when the
  /// value can't be used for navigation.
  static double? parseCoordinate(String? value) {
    final parsed = double.tryParse((value ?? '').trim());
    if (parsed == null || !parsed.isFinite) return null;
    return parsed;
  }

  /// Ordered launch candidates: navigation app first, web last.
  static List<Uri> _buildUris({
    required String destination,
    required bool hasCoordinates,
    required String label,
  }) {
    final encodedDestination = Uri.encodeComponent(destination);

    final webUri = Uri.parse(
      "https://www.google.com/maps/dir/?api=1"
      "&destination=$encodedDestination&travelmode=driving&dir_action=navigate",
    );

    if (Platform.isIOS) {
      return [
        Uri.parse(
          "comgooglemaps://?daddr=$encodedDestination&directionsmode=driving",
        ),
        webUri,
        Uri.parse("maps://?daddr=$encodedDestination&dirflg=d"),
      ];
    }

    return [
      Uri.parse("google.navigation:q=$encodedDestination&mode=d"),

      /// `geo:` keeps working when navigation mode is unavailable; the label in
      /// brackets is what Google Maps shows for the destination pin.
      Uri.parse(
        hasCoordinates
            ? "geo:$destination?q=$encodedDestination"
                  "${label.isEmpty ? '' : '(${Uri.encodeComponent(label)})'}"
            : "geo:0,0?q=$encodedDestination",
      ),
      webUri,
    ];
  }

  /// `canLaunchUrl` is only a hint — the launch is attempted regardless, because
  /// package visibility can hide an app that is actually installed.
  static Future<bool> _tryLaunch(Uri uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint("Map Navigation Error ($uri): $e");
      return false;
    }
  }

  static void _showError(String message) {
    Get.snackbar(
      "Navigation",
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.red.withOpacity(0.85),
      colorText: AppColors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(8),
      borderRadius: 8,
    );
  }
}
