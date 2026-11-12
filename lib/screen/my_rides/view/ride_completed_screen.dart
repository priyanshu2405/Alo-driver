import 'package:alo_ride_driver_app/res/common/app_appbar.dart';
import 'package:alo_ride_driver_app/res/common/app_image.dart';
import 'package:alo_ride_driver_app/res/common/app_text.dart';
import 'package:alo_ride_driver_app/res/constant/app_colors.dart';
import 'package:alo_ride_driver_app/res/constant/app_images.dart';
import 'package:alo_ride_driver_app/screen/my_rides/controller/my_ride_controller.dart';
import 'package:flutter/material.dart';
import 'package:alo_ride_driver_app/res/utils/app_responsive.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class RideCompletedScreen extends StatefulWidget {
  final int id;
  const RideCompletedScreen({super.key, required this.id});

  @override
  State<RideCompletedScreen> createState() => _RideCompletedScreenState();
}

class _RideCompletedScreenState extends State<RideCompletedScreen> {
  final MyRideController controller = Get.put(MyRideController());

  @override
  void initState() {
    // TODO: implement initState
    controller.getRideDetails(id: widget.id);
    super.initState();
  }

  /// 🔹 IMAGE BUILDER (API + FALLBACK SAFE)
  String buildProfileImage(String? path) {
    if (path == null || path.isEmpty) {
      return "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQq-NZ7ZR07kcwZMHrAPKhjvna_6Uy8NBIdRkwndVWyMA&s";
    }

    if (path.startsWith('http')) {
      return path;
    }

    return "https://deliverymate.volive.me/alodrive/public/$path";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppAppBar(title: "Ride Completed"),
      body: Obx(() {
        String amount(String? value) {
          if (value == null || value.isEmpty) return "0.00";
          return value;
        }

        return controller.isGetRideDetails.value
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    Divider(color: AppColors.darkTextColor),
                    Gap(10),

                    /// 👤 USER INFO
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.h),
                      child: Row(
                        children: [
                          ClipOval(
                            child: Image.network(
                              buildProfileImage(
                                controller
                                        .getRideDetailsModel
                                        .value
                                        .data
                                        ?.ride
                                        ?.user
                                        ?.profilePhoto ??
                                    "",
                              ),
                              width: 60.r,
                              height: 60.r,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) {
                                return Container(
                                  width: 60.r,
                                  height: 60.r,
                                  color: Colors.grey.shade300,
                                  child: Icon(Icons.person, size: 50.r),
                                );
                              },
                            ),
                          ),
                          Gap(12.w),
                          Expanded(
                            child: AppText(
                              text:
                                  controller
                                      .getRideDetailsModel
                                      .value
                                      .data
                                      ?.ride
                                      ?.user
                                      ?.name ??
                                  "",
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                AppText(
                                  text:
                                      "${controller.getRideDetailsModel.value.data?.ride?.distanceKm} Km",
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                                AppText(
                                  text:
                                      "Fare estimate: \$${controller.getRideDetailsModel.value.data?.ride?.totalFare}",
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  overflow: TextOverflow.visible,
                                  textAlign: TextAlign.end,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    Gap(10),
                    Divider(color: AppColors.darkTextColor),
                    Gap(10),

                    /// 📄 BOOKING INFO
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              AppText(
                                text:
                                    "Booking ID: ${controller.getRideDetailsModel.value.data?.ride?.bookingId}",
                                fontWeight: FontWeight.w600,
                                color: AppColors.blueColor,
                              ),
                              const Spacer(),
                              AppText(
                                text: formatDateTime(
                                  "${controller.getRideDetailsModel.value.data?.ride?.pickupDatetime}",
                                ),
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ],
                          ),
                          if(controller.getRideDetailsModel.value.data?.ride?.isFlight == true)...[
                            Gap(8),
                            Divider(color: AppColors.darkTextColor),
                            Gap(8),
                            AppText(
                              text: "Airport Pickup : ${controller.getRideDetailsModel.value.data?.ride?.flightNumber}",
                              fontWeight: FontWeight.w600,
                              color: AppColors.red,
                            ),
                          ],
                        ],
                      ),
                    ),

                    Gap(10),
                    Divider(color: AppColors.darkTextColor),
                    Gap(10),

                    /// 📍 LOCATIONS
                    _buildLocationRow(
                      icon: AppImage(
                        height: 12.h,
                        width: 12.w,
                        image: AppImages.recordCircleFill,
                        imageType: ImageType.svgAsset,
                      ),
                      title:
                          controller
                              .getRideDetailsModel
                              .value
                              .data
                              ?.ride
                              ?.pickupAddress ??
                          '',
                      subtitle: formatDateTime(
                        "${controller.getRideDetailsModel.value.data?.ride?.pickupDatetime}",
                      ),
                      showDivider: true,
                    ),

                    /// 🛑 INTERMEDIATE STOPS (in `sequence` order, if any)
                    ...(controller
                                .getRideDetailsModel
                                .value
                                .data
                                ?.ride
                                ?.intermediateStops ??
                            [])
                        .map(
                          (stop) => _buildLocationRow(
                            icon: Icon(
                              Icons.location_on,
                              color: AppColors.pinkColor,
                              size: 20,
                            ),
                            title: stop.address ?? '',
                            subtitle: '',
                            showDivider: true,
                          ),
                        ),

                    _buildLocationRow(
                      icon: Icon(
                        Icons.location_on,
                        color: AppColors.pinkColor,
                        size: 20,
                      ),
                      title:
                          controller
                              .getRideDetailsModel
                              .value
                              .data
                              ?.ride
                              ?.dropAddress ??
                          '',
                      subtitle: '',
                      showDivider: false,
                    ),

                    Gap(10),
                    Divider(color: AppColors.darkTextColor),
                    Gap(10),
                    /// 💰 FARE BREAKDOWN
                    _fareRow(
                      "Base Fare",
                      "\$${amount(controller.getRideDetailsModel.value.data?.ride?.baseFare)}",
                    ),

                    // Gap(6),
                    //
                    // _fareRow(
                    //   "Commission",
                    //   "\$${amount(controller.getRideDetailsModel.value.data?.ride?.commissionAmount)}",
                    // ),

                    // Gap(6),
                    //
                    // _fareRow(
                    //   "Tax",
                    //   "\$${amount(controller.getRideDetailsModel.value.data?.ride?.taxAmount)}",
                    // ),

                    Gap(6),

                    _fareRow(
                      "Tip",
                      "\$${amount(controller.getRideDetailsModel.value.data?.ride?.tipAmount)}",
                    ),

                    Gap(10),
                    Divider(color: AppColors.darkTextColor),
                    Gap(10),

                    _fareRow(
                      "Total Fare",
                      "\$${amount(controller.getRideDetailsModel.value.data?.ride?.totalFare)}",
                      bold: true,
                      fontSize: 16,
                    ),

                    // _fareRow(
                    //   "Fare estimate",
                    //   "\$${controller.getRideDetailsModel.value.data?.ride?.totalFare ?? ''}",
                    //   fontSize: 16,
                    //   bold: true,
                    // ),

                    Gap(10),
                    Divider(color: AppColors.darkTextColor),
                    if(controller.getRideDetailsModel.value.data?.ride?.isPackageStatus == 1)...[
                      Gap(10),
                      Padding(
                        padding:  EdgeInsets.symmetric(horizontal: 16.h),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: AppText(
                            text:
                            "Package used - ${controller.getRideDetailsModel.value.data?.ride?.packageName}",
                            fontSize: 12,
                            maxLines: 2,
                            color: AppColors.red,
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                    ],

                  ],
                ),
              );
      }),
    );
  }

  Widget _buildLocationRow({
    required Widget icon,
    required String title,
    required String subtitle,
    required bool showDivider,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              icon,
              if (showDivider)
                Column(
                  children: List.generate(
                    12,
                    (_) => Container(
                      margin: const EdgeInsets.only(bottom: 2),
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
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(text: title,overflow: TextOverflow.visible,),
                if (subtitle.isNotEmpty) AppText(text: subtitle, fontSize: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _fareRow(
    String title,
    String value, {
    String? trailing,
    bool bold = false,
    double fontSize = 14,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppText(
            text: title,
            fontSize: fontSize,
            fontWeight: bold ? FontWeight.w500 : FontWeight.normal,
          ),
          if (trailing != "") ...[
            const SizedBox(width: 8),
            AppText(
              text: trailing ?? "",
              fontSize: fontSize,
              color: AppColors.secondary,
              fontWeight: bold ? FontWeight.w500 : FontWeight.normal,
            ),
          ],
          Spacer(),
          AppText(
            text: value,
            fontSize: fontSize,
            fontWeight: bold ? FontWeight.w500 : FontWeight.normal,
          ),
        ],
      ),
    );
  }

  String formatDateTime(String? dateTime) {
    if (dateTime == null || dateTime.trim().isEmpty) {
      return '';
    }

    final dt = DateTime.tryParse(dateTime);

    if (dt == null) {
      debugPrint('Invalid date format: $dateTime');
      return '';
    }

    return DateFormat('dd/MM/yyyy hh:mm a').format(dt.toLocal());
  }
}
