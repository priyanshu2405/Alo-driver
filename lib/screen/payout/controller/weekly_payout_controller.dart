import 'package:alo_ride_driver_app/screen/payout/model/weekly_payout_model.dart';
import 'package:alo_ride_driver_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WeeklyPayoutController extends GetxController {
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;

  Rx<GetWeeklyPayoutModel> weeklyPayoutModel = GetWeeklyPayoutModel().obs;

  double get totalPaid => weeklyPayoutModel.value.data?.totalPaid ?? 0;

  double get totalUnpaid => weeklyPayoutModel.value.data?.totalUnpaid ?? 0;

  List<Week> get weeks => weeklyPayoutModel.value.data?.weeks ?? [];

  @override
  void onInit() {
    super.onInit();
    getWeeklyPayout(showLoader: true);
  }

  // ================= API CALL =================
  Future<void> getWeeklyPayout({bool showLoader = false}) async {
    try {
      if (showLoader) isLoading.value = true;
      errorMessage.value = '';

      final response = await ApiService.get(endpoint: 'payouts', isShow: false);

      weeklyPayoutModel.value = GetWeeklyPayoutModel.fromJson(response);
    } catch (e) {
      debugPrint("Weekly Payout Error: $e");
      errorMessage.value = e.toString();
    } finally {
      if (showLoader) isLoading.value = false;
    }
  }
}
