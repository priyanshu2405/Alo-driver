import 'package:alo_ride_driver_app/screen/earnings/model/driver_earnings_model.dart';
import 'package:alo_ride_driver_app/screen/earnings/model/earnings_date_range.dart';
import 'package:alo_ride_driver_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

/// Driver earnings summary — today, yesterday, this week and last week.
///
/// Every total comes from `GET driver/earnings`; nothing is computed or
/// hardcoded here. What the app *does* own is the driver's local "now": the
/// device's calendar date and UTC offset are sent with the request so the
/// backend cuts the day boundary and the Mon–Sun weeks on the driver's clock
/// rather than on the server's.
class EarningsController extends GetxController with WidgetsBindingObserver {
  RxBool isLoading = false.obs;
  RxBool isRefreshing = false.obs;
  RxString errorMessage = ''.obs;

  Rx<DriverEarningsModel> earningsModel = DriverEarningsModel().obs;

  EarningsData? get _data => earningsModel.value.data;

  String get currency => _data?.currency ?? 'CAD';

  /// Each getter falls back to a zeroed period so a missing section still
  /// renders a card with the correct title and locally computed date range.
  EarningsPeriod get today =>
      _data?.today ??
      EarningsPeriod.empty(
        label: "Today",
        date: EarningsDateRanges.today(),
      );

  EarningsPeriod get yesterday =>
      _data?.yesterday ??
      EarningsPeriod.empty(
        label: "Yesterday",
        date: EarningsDateRanges.yesterday(),
      );

  EarningsPeriod get thisWeek =>
      _data?.thisWeek ??
      EarningsPeriod.empty(
        label: "This Week",
        range: EarningsDateRanges.thisWeek(),
      );

  EarningsPeriod get lastWeek =>
      _data?.lastWeek ??
      EarningsPeriod.empty(
        label: "Last Week",
        range: EarningsDateRanges.lastWeek(),
      );

  bool get hasData => _data != null;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    getEarnings(showLoader: true);
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  /// Coming back to the app re-fetches, so totals stay current after rides
  /// completed elsewhere — and after the local day has rolled over.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      getEarnings();
    }
  }

  // ================= API CALL =================
  Future<void> getEarnings({bool showLoader = false}) async {
    try {
      if (showLoader) isLoading.value = true;
      isRefreshing.value = true;
      errorMessage.value = '';

      final response = await ApiService.get(
        endpoint: 'earnings',
        isShow: false,
      );

      earningsModel.value = DriverEarningsModel.fromJson(response);
    } catch (e) {
      debugPrint("Driver Earnings Error: $e");
      errorMessage.value = e.toString();
    } finally {
      if (showLoader) isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  /// Pulls fresh totals if (and only if) the summary is currently on screen /
  /// in memory. Call this after a ride is completed so the numbers move
  /// without the driver having to pull-to-refresh.
  static void refreshIfRegistered() {
    if (Get.isRegistered<EarningsController>()) {
      Get.find<EarningsController>().getEarnings();
    }
  }

  // ================= FORMATTING =================
  /// "$81.97" — symbol comes from the API's `currency`.
  String amount(double? value) {
    final format = NumberFormat.simpleCurrency(name: currency);
    return format.format(value ?? 0);
  }

  String ridesText(int count) => count == 1 ? "1 ride" : "$count rides";
}
