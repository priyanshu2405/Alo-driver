import 'package:alo_ride_driver_app/res/utils/ride_status_flow.dart';
import 'package:alo_ride_driver_app/screen/current_ride/controller/current_ride_controller.dart';
import 'package:alo_ride_driver_app/screen/dashboard/screen/dashboard_screen.dart';
import 'package:alo_ride_driver_app/screen/earnings/controller/earnings_controller.dart';
import 'package:alo_ride_driver_app/screen/my_rides/controller/my_ride_controller.dart';
import 'package:alo_ride_driver_app/screen/my_rides/model/ride_history_model.dart';
import 'package:alo_ride_driver_app/screen/ride/model/no_show_result.dart';
import 'package:alo_ride_driver_app/screen/ride/view/customer_paid_dialog.dart';
import 'package:alo_ride_driver_app/screen/ride/view/ride_screen_router.dart';
import 'package:alo_ride_driver_app/services/api_service.dart';
import 'package:alo_ride_driver_app/services/socket_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class RideCompletedController extends GetxController {
  RxBool isLoading = false.obs;

  /// Kept separate from [isLoading] so cancelling never puts the primary
  /// status button into its loading state (and vice versa).
  RxBool isCancelling = false.obs;

  /// Own flag for the no-show request, for the same reason as [isCancelling]:
  /// reporting a no-show must not spin the other buttons.
  RxBool isReportingNoShow = false.obs;

  /// Latest ride returned by the API, refreshed after every status update.
  Rx<RideData?> ride = Rx<RideData?>(null);

  /// Advances the ride one step: `accepted → going_to_pickup → arrived →
  /// pickup_done → completed`.
  ///
  /// [currentStatus] is the ride's status right now; the status that gets
  /// posted is always derived from it, so a step can never be skipped.
  /// Returns the refreshed ride, or `null` when the update failed.
  Future<RideData?> advanceRideStatus({
    required int rideId,
    required String? currentStatus,
    bool navigate = true,
    bool hostedInTab = false,
  }) async {
    final nextStatus = RideStatus.next(currentStatus);

    if (nextStatus == null) {
      _showError("This ride can't be updated any further");
      return null;
    }

    return updateRideStatus(
      rideId: rideId,
      status: nextStatus,
      currentStatus: currentStatus,
      notes: RideStatus.notesFor(nextStatus),
      navigate: navigate,
      hostedInTab: hostedInTab,
    );
  }

  /// Posts a status update and then re-fetches the ride so the UI always
  /// reflects the backend (status + `arrived_at` / `pickup_at` / `completed_at`).
  Future<RideData?> updateRideStatus({
    required int rideId,
    required String status,
    required String notes,
    String? currentStatus,
    bool navigate = true,

    /// The stage screen lives inside the dashboard's current-ride tab, so the
    /// tab is refreshed instead of pushing/replacing a route.
    bool hostedInTab = false,
  }) async {
    /// 🔒 Ignore taps while a request is already running.
    if (isLoading.value) return null;

    /// 🔒 Never post an out of sequence status (backend returns 400).
    if (currentStatus != null &&
        !RideStatus.canTransition(from: currentStatus, to: status)) {
      _showError("Invalid status transition");
      return null;
    }

    try {
      isLoading.value = true;

      final body = {"status": status, "notes": notes};
      debugPrint("Update Ride Status body : $body");

      final response = await ApiService.post(
        endpoint: 'rides/$rideId/status',
        isShow: true,
        body: body,
      );

      debugPrint("Update Status Response: $response");

      if (response['success'] != true) {
        _showError(response['message'] ?? "Status update failed");
        return null;
      }

      /// ✅ Always trust the freshly fetched ride over the POST payload.
      final updatedRide =
          await fetchRideDetails(rideId) ?? _rideFromResponse(response);

      if (updatedRide == null) {
        _showError("Could not load the updated ride");
        return null;
      }

      ride.value = updatedRide;

      /// A completed ride changes today's / this week's totals — pull them
      /// again so the earnings summary never shows a stale number.
      if (updatedRide.status == RideStatus.completed) {
        EarningsController.refreshIfRegistered();
      }

      if (navigate || updatedRide.status == RideStatus.completed) {
        _openStageFor(updatedRide, hostedInTab: hostedInTab);
      } else if (hostedInTab) {
        _refreshCurrentRideTab();
      }

      return updatedRide;
    } catch (e) {
      debugPrint("Update Ride Status Error: $e");

      /// ApiService already shows the backend message (e.g. "Invalid status
      /// transition"), so don't snackbar it twice.
      if (e is! ApiException) {
        _showError(e.toString());
      }
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// POST `rides/{id}/cancel` — the driver drops the ride.
  ///
  /// [reason] is optional and capped at 255 chars by the backend. On success
  /// the ride goes back to the pool (the API answers with its new status, e.g.
  /// `pending`), so the local ride is updated to that status — which is what
  /// hides the cancel button — and the driver is sent back to the dashboard.
  ///
  /// Returns `true` when the ride was cancelled.
  Future<bool> cancelRide({required int rideId, String? reason}) async {
    /// 🔒 Ignore taps while a request is already running.
    if (isCancelling.value) return false;

    try {
      isCancelling.value = true;

      final trimmedReason = reason?.trim() ?? '';

      final body = <String, dynamic>{
        if (trimmedReason.isNotEmpty)
          "reason": trimmedReason.length > 255
              ? trimmedReason.substring(0, 255)
              : trimmedReason,
      };

      debugPrint("Cancel Ride body : $body");

      final response = await ApiService.post(
        endpoint: 'rides/$rideId/cancel',
        isShow: true,
        body: body,
      );

      debugPrint("Cancel Ride Response: $response");

      if (response['success'] != true) {
        _showError(response['message'] ?? "Ride cancellation failed");
        return false;
      }

      /// ✅ Status comes from the response — never assumed locally.
      final cancelledStatus =
          response['data']?['status']?.toString() ?? RideStatus.cancelled;

      final current = ride.value;
      if (current != null && current.id == rideId) {
        current.status = cancelledStatus;
        ride.refresh();
      }

      /// The ride is no longer this driver's: stop streaming location for it,
      /// then reload the screens that show it. `rides/current` will now answer
      /// with no ride, which is what clears the driver's ride state.
      SocketIoService().releaseCurrentRide(rideId: rideId);
      _refreshCurrentRideTab();
      _refreshRideHistory();

      Get.offAll(() => const DashboardScreen());

      return true;
    } catch (e) {
      debugPrint("Cancel Ride Error: $e");

      /// ApiService already surfaces the backend message.
      if (e is! ApiException) {
        _showError(e.toString());
      }
      return false;
    } finally {
      isCancelling.value = false;
    }
  }

  /// POST `rides/{id}/no-show` — the driver arrived, waited, and the customer
  /// never showed up.
  ///
  /// [notes] is optional and capped at 255 chars by the backend. On success the
  /// ride is `cancelled` and the customer is charged the no-show fee the API
  /// decides on — the amount, currency and payment status all come back in the
  /// response and are handed to the caller untouched, so nothing about the fee
  /// is hard coded in the app.
  ///
  /// Returns the parsed result, or `null` when the report failed.
  Future<NoShowResult?> reportNoShow({
    required int rideId,
    String? notes,
  }) async {
    /// 🔒 Ignore taps while a request is already running.
    if (isReportingNoShow.value) return null;

    try {
      isReportingNoShow.value = true;

      final trimmedNotes = notes?.trim() ?? '';

      final body = <String, dynamic>{
        if (trimmedNotes.isNotEmpty)
          "notes": trimmedNotes.length > 255
              ? trimmedNotes.substring(0, 255)
              : trimmedNotes,
      };

      debugPrint("No Show body : $body");

      /// The backend message is shown by the success dialog instead, so the
      /// snackbar stays off here.
      final response = await ApiService.post(
        endpoint: 'rides/$rideId/no-show',
        isShow: false,
        body: body,
      );

      debugPrint("No Show Response: $response");

      if (response['success'] != true) {
        _showError(response['message'] ?? "Could not report the no-show");
        return null;
      }

      final data = response['data'];
      final result = data is Map
          ? NoShowResult.fromJson(Map<String, dynamic>.from(data))
          : const NoShowResult();

      /// ✅ Status comes from the response — never assumed locally.
      final newStatus = result.status ?? RideStatus.cancelled;

      final current = ride.value;
      if (current != null && current.id == rideId) {
        current.status = newStatus;
        ride.refresh();
      }

      /// The ride is over: stop streaming location for it, then reload the
      /// screens that show it (`rides/current` now answers with no ride).
      SocketIoService().releaseCurrentRide(rideId: rideId);
      _refreshCurrentRideTab();
      _refreshRideHistory();

      return result;
    } catch (e) {
      debugPrint("No Show Error: $e");

      /// ApiService already surfaces the backend message.
      if (e is! ApiException) {
        _showError(e.toString());
      }
      return null;
    } finally {
      isReportingNoShow.value = false;
    }
  }

  /// GET `rides/{id}` — the latest ride details, including stops & timestamps.
  Future<RideData?> fetchRideDetails(int rideId) async {
    try {
      final response = await ApiService.get(
        endpoint: 'rides/$rideId',
        isShow: false,
      );

      if (response['success'] == true && response['data']?['ride'] != null) {
        return RideData.fromJson(
          Map<String, dynamic>.from(response['data']['ride']),
        );
      }
    } catch (e) {
      debugPrint("Fetch Ride Details Error: $e");
    }
    return null;
  }

  RideData? _rideFromResponse(Map<String, dynamic> response) {
    final raw = response['data']?['ride'] ?? response['ride'];
    if (raw == null) return null;
    return RideData.fromJson(Map<String, dynamic>.from(raw));
  }

  /// Moves to the screen matching the ride's new status. The completed ride
  /// ends on the payment dialog instead of another stage screen.
  void _openStageFor(RideData updatedRide, {bool hostedInTab = false}) {
    if (updatedRide.status == RideStatus.completed) {
      Get.dialog(
        CustomerPaidDialog(
          date: formatRideDate(updatedRide.completedAt?.toIso8601String()),
          bookingID: updatedRide.bookingId ?? '',
          tripFare: updatedRide.totalFare ?? '',
          onGoHome: () {
            Get.back();
            Get.offAll(() => const DashboardScreen());
          },
        ),
        barrierDismissible: false,
      );
      return;
    }

    /// Inside the dashboard tab there is no stage route to replace — the tab
    /// rebuilds itself from the refreshed current ride.
    if (hostedInTab) {
      _refreshCurrentRideTab();
      return;
    }

    RideScreenRouter.open(updatedRide, replace: true);
  }

  void _refreshCurrentRideTab() {
    if (Get.isRegistered<CurrentRideController>()) {
      Get.find<CurrentRideController>().getCurrentRide();
    }
  }

  void _refreshRideHistory() {
    if (Get.isRegistered<MyRideController>()) {
      Get.find<MyRideController>().getRideHistory();
    }
  }

  String formatRideDate(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return "";

    final dateTime = DateTime.tryParse(isoDate);
    if (dateTime == null) return "";
    return DateFormat("dd MMM,yyyy  h:mm a").format(dateTime.toLocal());
  }

  void _showError(String message) {
    Get.snackbar(
      "Error",
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red.withOpacity(0.85),
      colorText: Colors.white,
    );
  }
}
