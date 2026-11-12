import 'package:alo_ride_driver_app/res/utils/ride_status_flow.dart';
import 'package:alo_ride_driver_app/screen/current_ride/controller/current_ride_controller.dart';
import 'package:alo_ride_driver_app/screen/dashboard/screen/dashboard_screen.dart';
import 'package:alo_ride_driver_app/screen/ride/view/ride_screen_router.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class RideStatusWrapperScreen extends StatefulWidget {
  RideStatusWrapperScreen({super.key});

  @override
  State<RideStatusWrapperScreen> createState() => _RideStatusWrapperScreenState();
}

class _RideStatusWrapperScreenState extends State<RideStatusWrapperScreen> {
  final CurrentRideController controller = Get.find<CurrentRideController>();


  @override
  void initState() {
    // TODO: implement initState
    controller.getCurrentRide();

    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final ride = controller.getCurrentRideModel.value;

      if (ride.id == null) {
        return const Center(child: Text("No Current Ride"));
      }

      if (ride.status == RideStatus.completed) {
        return DashboardScreen();
      }

      /// 🔹 Screen always matches the ride's current backend status
      /// (accepted / going_to_pickup / arrived / pickup_done).
      final screen = RideScreenRouter.screenFor(ride, backScreen: true);

      return screen ?? const Center(child: Text("No Current Ride Found"));
    });
  }

  String formatPickupDate(String isoDate) {
    if(isoDate.isEmpty) return "";
    final DateTime dateTime = DateTime.parse(isoDate).toLocal();

    return DateFormat("dd MMM,yyyy  h:mm a").format(dateTime);
  }
}
