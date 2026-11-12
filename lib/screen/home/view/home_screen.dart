
import 'package:alo_ride_driver_app/res/common/app_appbar.dart';
import 'package:alo_ride_driver_app/res/common/app_button.dart';
import 'package:alo_ride_driver_app/res/common/app_image.dart';
import 'package:alo_ride_driver_app/res/common/app_text.dart';
import 'package:alo_ride_driver_app/res/constant/app_colors.dart';
import 'package:alo_ride_driver_app/res/constant/app_images.dart';
import 'package:alo_ride_driver_app/screen/home/controller/home_controller.dart';
import 'package:alo_ride_driver_app/screen/home/controller/location_controller.dart';
import 'package:alo_ride_driver_app/services/socket_services.dart';
import 'package:alo_ride_driver_app/services/token_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:alo_ride_driver_app/res/utils/app_responsive.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeScreen extends StatefulWidget {
  bool isShowBottomDialog = false;

  HomeScreen({super.key, this.isShowBottomDialog = false});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final HomeController homeController = Get.put(HomeController());
  final LocationController controller = Get.put(LocationController());
  final SocketIoService socketIoService = SocketIoService();
  final AuthController authController = Get.put(AuthController());

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
     homeController.getOnlineStatus();
     homeController.startDriverLocationAutoSend();
    });
    // socketIoService.connect(
    //   driverId: authController.userId.value,
    //   token: authController.token.value,
    // );
    /// ✅ Show dialog AFTER first frame

  }

  @override
  void dispose() {
    socketIoService.disconnect();
    homeController.hideRideCard();
    super.dispose();
  }


  // bool isSwitched = false;

  void _toggleSwitch(bool value) {
    final latLng = controller.currentLatLng.value;

    if (latLng == null) {
      Get.snackbar("Error", "Location not available");
      return;
    }

    homeController.updateOnlineStatus(
      status: value,
      latitude: latLng.latitude,
      longitude: latLng.longitude,
    );
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop(); // ✅ CLOSE APP
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        extendBodyBehindAppBar: true,
        appBar: AppAppBar(
          backgroundColor: Colors.transparent,
          leading: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Transform.scale(
              scale: 0.75, // 👈 adjust (0.6 – 0.8 looks best)
              child: Obx(() {
                return Switch(
                  value: homeController.isOnline.value,
                  onChanged: _toggleSwitch,
                  activeTrackColor: AppColors.secondary,
                  activeColor: AppColors.secondary.withOpacity(0.4),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                );
              },),
            ),
          ),
          title: "",
        ),
        body: Column(
          children: [
            Expanded(
              child: Container(
                //height: 540.h,
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return GoogleMap(
                    padding: EdgeInsets.only(
                      top: kToolbarHeight,
                    ),
                    initialCameraPosition: CameraPosition(
                      target: controller.currentLatLng.value ??
                          const LatLng(0, 0),
                      zoom: 14,
                    ),
                    onMapCreated: (mapController) {
                      if (!controller.mapController.isCompleted) {
                        controller.mapController.complete(mapController);
                      }
                      controller.googleController = mapController;
      
                      final latLng = controller.currentLatLng.value;
                      if (latLng != null) {
                        mapController.animateCamera(
                          CameraUpdate.newLatLng(latLng),
                        );
                      }
                    },
                    markers: controller.markers,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    circles: controller.currentLatLng.value == null
                        ? {}
                        : {
                      Circle(
                        circleId: const CircleId('radius'),
                        center: controller.currentLatLng.value!,
                        radius: controller.selectedDistance.value * 1000,
                        strokeColor: AppColors.secondary.withOpacity(0.5),
                        fillColor: AppColors.secondary.withOpacity(0.2),
                        strokeWidth: 1,
                      ),
                    },
                    onTap: controller.onMapTap,
                  );
                }),
              ),
            ),
            Obx(() {
              if (homeController.showBottomDialog.value) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Gap(20.h),
                    _bottomCard(),
                  ],
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }

  /// ================= BOTTOM CARD =================
  Widget _bottomCard() {
    return Obx(() {
      final ride = homeController.rideRequest.value;

      if (ride == null) return SizedBox.shrink();
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          /// DRIVER + FARE
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.h),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30.r,
                        backgroundImage:  NetworkImage(
                          ride.userImage,
                        ),
                      ),
                      Gap(12.w),
                      AppText(
                        text: ride.userName,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      AppText(
                        text: "${ride.distanceKm.toStringAsFixed(2)} Km",
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      AppText(
                        text: "Fare estimate: \$${ride.totalFare.toStringAsFixed(2)}",
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        overflow: TextOverflow.visible,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Divider(
            color: AppColors.darkTextColor,
          ).paddingSymmetric(vertical: 10),

          Column(
            children: [
              // From location
              // Gap(10),
              _buildLocationRow(
                icon: AppImage(
                  height: 20.h,
                  width: 20.w,
                  image: AppImages.recordCircleFill,
                  imageType: ImageType.svgAsset,
                ),
                iconColor: AppColors.pinkColor,
                title: ride.pickupAddress,
                subtitle: ride.pickupDatetime,
                showDivider: true,
              ),

              // Drop off location
              _buildLocationRow(
                icon: Icon(
                    Icons.location_on, color: AppColors.pinkColor, size: 20),
                iconColor: AppColors.pinkColor,
                title: ride.dropAddress,
                subtitle: '',
                showDivider: false,
              ),

            ],
          ),

          Gap(20.h),

          /// ACTION BUTTONS
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.h),
            child: Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: "IGNORE",
                    onTap: () {
                      homeController.hideRideCard();
                      // ignore request
                    },
                  ),
                ),
                Gap(12.w),
                // Expanded(
                //   child: AppButton(
                //     text: "ACCEPT",
                //     onTap: () {
                //       // Get.to(() => RideDetailsScreen());
                //       // accept ride
                //     },
                //   ),
                // ),
                Expanded(
                  child: Obx(() {
                    return AppButton(
                      isLoading: homeController.isAcceptRide.value,
                      text: "ACCEPT",
                      onTap: () {

                        homeController.acceptRide(
                          rideId: ride.rideId, // 🔥 pass actual rideId
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
          Gap(20.h),
        ],
      );
    });
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
              // Icon with connecting line
              Column(
                children: [
                  // Icon(icon, color: iconColor, size: 20),
                  icon,
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

}