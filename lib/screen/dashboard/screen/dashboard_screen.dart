import 'package:alo_ride_driver_app/res/common/common_bottom_bar.dart';
import 'package:alo_ride_driver_app/screen/dashboard/controller/dashboard_conroller.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboardScreen extends StatefulWidget {
  final int? initialIndex;
  const DashboardScreen({super.key, this.initialIndex,});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashBoardController dashboardController = Get.put(DashBoardController());

  @override
  void initState() {
    super.initState();
    if (widget.initialIndex != null) {
      dashboardController.changeIndex(widget.initialIndex!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () =>
            dashboardController.pages[dashboardController.selectedIndex.value],
      ),
      bottomNavigationBar: Obx(
        () => CommonBottomBar(
          currentIndex: dashboardController.selectedIndex.value,
          onTap: (index) => dashboardController.changeIndex(index),
        ),
      ),
    );
  }
}
