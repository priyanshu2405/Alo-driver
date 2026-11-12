import 'package:alo_ride_driver_app/res/common/app_appbar.dart';
import 'package:alo_ride_driver_app/res/common/app_button.dart';
import 'package:alo_ride_driver_app/res/common/app_image.dart';
import 'package:alo_ride_driver_app/res/common/app_text.dart';
import 'package:alo_ride_driver_app/res/constant/app_colors.dart';
import 'package:alo_ride_driver_app/res/constant/app_images.dart';
import 'package:alo_ride_driver_app/screen/dashboard/screen/dashboard_screen.dart';
import 'package:alo_ride_driver_app/screen/home/controller/home_controller.dart';
import 'package:alo_ride_driver_app/screen/my_ride/my_ride_controller.dart';
import 'package:alo_ride_driver_app/screen/my_rides/model/ride_history_model.dart';
import 'package:flutter/material.dart';
import 'package:alo_ride_driver_app/res/utils/app_responsive.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class MyRideView extends StatefulWidget {
  const MyRideView({super.key});

  @override
  State<MyRideView> createState() => _MyRideViewState();
}

class _MyRideViewState extends State<MyRideView> {
  final MyRideRequestController controller = Get.put(MyRideRequestController());
  final HomeController homeController = Get.put(HomeController());

  @override
  void initState() {
    // TODO: implement initState
    controller.getRideHistory(showLoader: true);
    controller.startAutoRefresh();
    super.initState();
  }

  void showRideRequestBottomSheet(BuildContext context,{RideData? data}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        final ride = data;

        if (ride == null) return SizedBox.shrink();
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Padding(
              padding: EdgeInsets.all(16.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  /// DRAG INDICATOR
                  Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),

                  SizedBox(height: 16),

                  /// DRIVER + FARE
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 30.r,
                              backgroundImage: NetworkImage(ride.user?.profilePhoto ?? ""),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppText(
                                    text: ride.user?.name ?? "",
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  if(ride.isFlight == true)
                                  AppText(
                                    text: "Airport Pickup(${ride.flightNumber})",
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.red,
                                    overflow: TextOverflow.visible,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            AppText(
                              text: "${ride.distanceKm} Km",
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                            AppText(
                              text:
                              "Fare estimate: \$${ride.totalFare}",
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  Divider(),

                  /// PICKUP & DROP
                  _buildLocationRow(
                    icon: AppImage(
                      height: 20.h,
                      width: 20.w,
                      image: AppImages.recordCircleFill,
                      imageType: ImageType.svgAsset,
                    ),
                    iconColor: AppColors.pinkColor,
                    title: ride.pickupAddress ?? "",
                    subtitle: formatPickupDate(ride.pickupDatetime),
                    showDivider: true,
                  ),

                  ...List.generate(ride.dropAddresses.length, (index) {
                    final isLast = index == ride.dropAddresses.length - 1;
                    return _buildLocationRow(
                      icon: Icon(Icons.location_on, color: AppColors.pinkColor, size: 20),
                      iconColor: AppColors.pinkColor,
                      title: ride.dropAddresses[index],
                      subtitle: '',
                      showDivider: !isLast,
                    );
                  }),

                  SizedBox(height: 16.h),

                  /// BUTTONS
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          text: "IGNORE",
                          onTap: () {
                            Get.back();
                            homeController.hideRideCard();
                          },
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Obx(() {
                          return AppButton(
                            isLoading: homeController.isAcceptRide.value,
                            text: "ACCEPT",
                            onTap: () {
                              homeController.acceptRide(
                                rideId: ride.id ?? 0,
                              );
                            },
                          );
                        }),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLocationRow({
    required Widget icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool showDivider,
  })
  {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon with connecting line (fixed slot keeps every icon centered)
              SizedBox(
                width: 24.w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 24.w,
                      child: Center(child: icon),
                    ),
                    if (showDivider)
                      Column(
                        children: List.generate(14, (index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 2.0),
                            child: Container(
                              height: 2,
                              width: 2,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.black,
                              ),
                            ),
                          );
                        }),
                      ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //Gap(12),
                    AppText(text: title, color: AppColors.textColor,overflow: TextOverflow.visible,),
                    const SizedBox(height: 4),
                    AppText(text: subtitle, fontSize: 10,),
                  ],
                ),
              ),


            ],
          ),
        ),
      ],
    );
  }

  String formatPickupDate(DateTime? raw) {
    if (raw == null) return "";

    final local = raw.toLocal();

    return DateFormat("dd MMM yyyy, hh:mm a").format(local);
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
          title: "My Rides Request",
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.rideHistoryModel.value.data?.isEmpty ?? false) {
            return  Center(child: Text(controller.rideHistoryModel.value.message??"",style: TextStyle(fontSize: 17),));
          }
          return _listView();

        }),
      ),
    );
  }
  Widget _listView() {
    return Obx(() {
      return SingleChildScrollView(
        child: Column(
          children: controller.rideHistoryModel.value.data?.map((ride) {
            return _rideCard(ride);
          }).toList() ?? [],
        ),
      );
    });
  }

  Widget _rideCard(RideData ride) {
    final statusColor = _statusColor(ride.status);
    final pickupTime =
        ride.pickupDatetime ?? "";

    final formattedPickupTime = formatRideDate("$pickupTime");
    return InkWell(
      splashColor: Colors.transparent,
      onTap: () {
        showRideRequestBottomSheet(context,data: ride);
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
                        // AppText(
                        //   text: ride.status ?? '',
                        //   fontSize: 12,
                        //   color: statusColor,
                        //   fontWeight: FontWeight.w500,
                        // ),
                        AppText(
                          text: getStatusLabel(ride.status),
                          fontSize: 12,
                          color: statusColor,
                          fontWeight: FontWeight.w500,
                        ),
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
                      text: "Airport Pickup(${ride.flightNumber})",
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.red,
                    ),
                  ],
                ),

                Gap(12.h),

                /// PICKUP + EVERY STOP (in sequence order)
                _locationRow(
                  icon: AppImage(
                    height: 20.h,
                    width: 20.w,
                    image: AppImages.recordCircleFill,
                    imageType: ImageType.svgAsset,
                  ),
                  title: ride.pickupAddress ?? '',
                  showDivider: true,
                ),

                ...List.generate(ride.dropAddresses.length, (index) {
                  final isLast = index == ride.dropAddresses.length - 1;
                  return _locationRow(
                    icon: Icon(
                      Icons.location_on,
                      color: AppColors.pinkColor,
                      size: 24.w,
                    ),
                    title: ride.dropAddresses[index],
                    showDivider: !isLast,
                  );
                }),
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

  Widget _locationRow({
    required Widget icon,
    required String title,
    required bool showDivider,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// 🔹 Fixed width slot so every icon (and the dotted line) stays
        /// centered on the same axis, whatever the icon's own size is.
        SizedBox(
          width: 24.w,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 24.w,
                child: Center(child: icon),
              ),
              if (showDivider)
                Column(
                  children: List.generate(
                    5,
                        (index) => Container(
                      margin: const EdgeInsets.only(top: 2),
                      height: 2,
                      width: 2,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Gap(12.w),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 2.h),
            child: AppText(
              text: title,
              color: AppColors.textColor,
            ),
          ),
        ),
      ],
    );
  }
  String formatRideDate(String? date) {
    if (date == null || date.isEmpty) return '';

    try {
      final DateTime parsedDate = DateTime.parse(date).toLocal();
      return DateFormat('dd MMM yyyy, hh:mm a').format(parsedDate);
    } catch (e) {
      return date;
    }
  }
  Color _statusColor(String? status) {
    switch (status) {
      case 'completed':
        return AppColors.greenColor;
      case 'cancelled':
        return Colors.red;
      case 'accepted':
      case 'going_to_pickup':
      case 'arrived':
      case 'pickup_done':
        return AppColors.secondary;
      default:
        return Colors.grey;
    }
  }

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
