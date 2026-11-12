import 'package:alo_ride_driver_app/res/common/app_appbar.dart';
import 'package:alo_ride_driver_app/res/common/app_image.dart';
import 'package:alo_ride_driver_app/res/common/app_text.dart';
import 'package:alo_ride_driver_app/res/constant/app_colors.dart';
import 'package:alo_ride_driver_app/res/constant/app_images.dart';
import 'package:alo_ride_driver_app/screen/dashboard/screen/dashboard_screen.dart';
import 'package:alo_ride_driver_app/screen/my_rides/controller/my_ride_controller.dart';
import 'package:alo_ride_driver_app/screen/my_rides/model/ride_history_model.dart';
import 'package:alo_ride_driver_app/screen/my_rides/view/ride_completed_screen.dart';
import 'package:alo_ride_driver_app/res/utils/ride_status_flow.dart';
import 'package:alo_ride_driver_app/screen/ride/view/ride_screen_router.dart';
import 'package:flutter/material.dart';
import 'package:alo_ride_driver_app/res/utils/app_responsive.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';



class MyRidesScreen extends StatefulWidget {
  MyRidesScreen({super.key});

  @override
  State<MyRidesScreen> createState() => _MyRidesScreenState();
}

class _MyRidesScreenState extends State<MyRidesScreen> {
  final MyRideController controller = Get.put(MyRideController());

  @override
  void initState() {
    // TODO: implement initState
    controller.getRideHistory(showLoader: true);
    controller.startAutoRefresh();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.to(()=>DashboardScreen()); // ✅ CLOSE APP
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppAppBar(
          leading: SizedBox(),
          showBack: false,
          leadingWidth: 0,
          title: "My Rides",
        ),
        body: Column(
          children: [
            /// 🔹 LIST / CALENDAR (PILL TABS)
            _viewTypeTabs(),

            /// 🔹 COMPLETED / ONGOING / CANCELLED
            _statusTabs(),

            /// 🔹 CONTENT
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                return controller.viewType.value == 0
                    ? _listView()
                    : _calendarView();
              }),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  Widget _viewTypeTabs() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          _pillTab("List View", 0),
          Gap(12.w),
          _pillTab("Calendar View", 1),
        ],
      ),
    );
  }

  Widget _pillTab(String title, int index) {
    return Obx(() {
      final selected = controller.viewType.value == index;
      return Expanded(
        child: InkWell(
          // onTap: () => controller.viewType.value = index,
          onTap: () {
            controller.viewType.value = index;

            if (index == 0) {
              // 🔥 LIST VIEW → REFRESH API
              controller.resetCalendarAndReload();
            }
          },

          child: Container(
            padding: EdgeInsets.symmetric(vertical: 10.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: selected ? AppColors.secondary : Colors.grey,
              ),
              color: selected
                  ? AppColors.secondary.withOpacity(0.1)
                  : Colors.white,
            ),
            child: Center(
              child: AppText(
                text: title,
                color: selected
                    ? AppColors.secondary
                    : AppColors.lightGrayText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      );
    });
  }

  // =====================================================
  Widget _statusTabs() {
    return Container(
      color: const Color(0xffEDEDED),
      child: Row(
        children: [
          _statusTab("Completed", 0),
          _statusTab("On Going", 1),
          _statusTab("Cancelled", 2),
        ],
      ),
    );
  }

  Widget _statusTab(String title, int index) {
    return Obx(() {
      final selected = controller.rideTab.value == index;
      return Expanded(
        child: InkWell(
          onTap: () => controller.changeRideTab(index),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: AppText(
                  text: title,
                  color: selected
                      ? AppColors.secondary
                      : AppColors.lightGrayText,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                height: 2,
                color: selected ? AppColors.secondary : Colors.transparent,
              ),
            ],
          ),
        ),
      );
    });
  }

  // =====================================================
  Widget _listView() {
    return Obx(() {
      if (controller.filteredRides.isEmpty) {
        return const Center(child: Text("No rides found"));
      }

      return SingleChildScrollView(
        child: Column(
          children: controller.filteredRides.map((ride) {
            return _rideCard(ride);
          }).toList(),
        ),
      );
    });
  }

  // =====================================================
  Widget _calendarView() {
    return SingleChildScrollView(
      child: Column(
        children: [
          CalendarDatePicker(
            initialDate: controller.selectedDate.value ?? DateTime.now(),
            firstDate: DateTime.now().subtract(const Duration(days: 365)),
            lastDate: DateTime.now().add(const Duration(days: 365)),
            onDateChanged: (value) {
              controller.changeSelectedDate(value);
            },
          ),

          /// 🔹 SHOW RIDES FOR SELECTED DATE
          Obx(() {
            if (controller.filteredRides.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Text("No rides found for this date"),
              );
            }

            return Column(
              children: controller.filteredRides.map((ride) {
                return _rideCard(ride);
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  // =====================================================


  String formatRideDate(String? date) {
    if (date == null || date.isEmpty) return '';

    try {
      final DateTime parsedDate = DateTime.parse(date).toLocal();
      return DateFormat('dd MMM yyyy, hh:mm a').format(parsedDate);
    } catch (e) {
      return date;
    }
  }

  Widget _rideCard(RideData ride) {
    return InkWell(
      splashColor: Colors.transparent,
      onTap: () {
        if (RideStatus.isFinished(ride.status)) {
          Get.to(() => RideCompletedScreen(id: ride.id ?? 0));
          return;
        }

        /// 🔹 Opens the stage that matches the ride's current status
        /// (accepted / going_to_pickup / arrived / pickup_done).
        RideScreenRouter.open(ride, myRidesBack: true);
      },
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// HEADER
                Row(
                  children: [
                    Expanded(
                      child: AppText(
                        text: "Booking ID: ${ride.bookingId ?? ''}",
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        AppText(
                          text: "\$${ride.totalFare ?? '0.00'}",
                          fontWeight: FontWeight.bold,
                        ),
                        Gap(4.h),
                        AppText(
                          text: "Payment Status : ${ride.paymentStatus}",
                          fontSize: 12,
                          color: ride.paymentStatus == "pending" ? AppColors.secondary  : AppColors.greenColor,
                          fontWeight: FontWeight.w500,
                        ),
                        // AppText(
                        //   text: getStatusLabel(ride.status),
                        //   fontSize: 12,
                        //   color: statusColor,
                        //   fontWeight: FontWeight.w500,
                        // ),
                      ],
                    ),
                  ],
                ),

                Gap(6.h),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: AppText(
                        text: "Date: ${formatRideDate(ride.pickupDatetime.toString())}",
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if(ride.isFlight == true)
                    AppText(
                      text:"Airport Pickup(${ride.flightNumber})",
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.red,
                      overflow: TextOverflow.visible,
                    ),
                  ],
                ),

                Gap(12.h),

                _locationSection(
                  pickupAddress: ride.pickupAddress ?? '',
                  dropAddresses: ride.dropAddresses,
                ),
              ],
            ),
          ),

          Container(
            height: 2,
            color: AppColors.darkTextColor,
          ),
        ],
      ),
    );
  }


  // =====================================================
  /// Renders pickup → every stop (in sequence order) with a dotted connector.
  /// Each address is its own row, so the icon always sits beside its own text
  /// however many stops there are and however the text wraps.
  Widget _locationSection({
    required String pickupAddress,
    required List<String> dropAddresses,
  }) {
    final double iconSize   = 20.r;
    final double connectorH = 26.h;

    final rows = <Widget>[
      _addressRow(
        icon: AppImage(
          height: iconSize,
          width: iconSize,
          image: AppImages.recordCircleFill,
          imageType: ImageType.svgAsset,
          fit: BoxFit.contain,
        ),
        address: pickupAddress,
        iconSize: iconSize,
      ),
    ];

    for (final address in dropAddresses) {
      // Dotted connector between the previous row and this one
      rows.add(
        Row(
          children: [
            SizedBox(
              width: iconSize,
              child: Center(
                child: SizedBox(
                  width: 2,
                  height: connectorH,
                  child: CustomPaint(painter: _DottedLinePainter()),
                ),
              ),
            ),
          ],
        ),
      );

      rows.add(
        _addressRow(
          icon: Icon(
            Icons.location_on,
            color: AppColors.pinkColor,
            size: iconSize,
          ),
          address: address,
          iconSize: iconSize,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rows,
    );
  }

  Widget _addressRow({
    required Widget icon,
    required String address,
    required double iconSize,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: iconSize,
          height: iconSize,
          child: Center(child: icon),
        ),
        Gap(10.w),
        Expanded(
          child: AppText(
            text: address,
            color: AppColors.textColor,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // =====================================================
  String getStatusLabel(String? status) {
    switch (status) {
      case 'accepted':
        return 'Accepted';
      case 'going_to_pickup':
        return 'Going to Pickup';
      case 'arrived':
        return 'Arrived';
      case 'pickup_done':
        return 'Pickup Done';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status ?? '';
    }
  }
}

/// Draws a vertical dotted line that fills whatever SizedBox it sits in.
class _DottedLinePainter extends CustomPainter {
  const _DottedLinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    const double dotRadius = 1.5;
    const double spacing   = 4.0;
    final paint = Paint()
      ..color = Colors.black38
      ..style = PaintingStyle.fill;

    double y = dotRadius;
    while (y + dotRadius <= size.height) {
      canvas.drawCircle(Offset(size.width / 2, y), dotRadius, paint);
      y += dotRadius * 2 + spacing;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


