import 'dart:async';

import 'package:alo_ride_driver_app/res/common/app_appbar.dart';
import 'package:alo_ride_driver_app/res/common/app_button.dart';
import 'package:alo_ride_driver_app/res/common/app_image.dart';
import 'package:alo_ride_driver_app/res/common/app_text.dart';
import 'package:alo_ride_driver_app/res/constant/app_colors.dart';
import 'package:alo_ride_driver_app/res/constant/app_images.dart';
import 'package:alo_ride_driver_app/res/utils/ride_status_flow.dart';
import 'package:alo_ride_driver_app/screen/chat/view/chat_entry_button.dart';
import 'package:alo_ride_driver_app/screen/dashboard/screen/dashboard_screen.dart';
import 'package:alo_ride_driver_app/screen/my_rides/model/ride_history_model.dart';
import 'package:alo_ride_driver_app/screen/ride/controller/ride_completed_controller.dart';
import 'package:alo_ride_driver_app/screen/ride/view/cancel_ride_button.dart';
import 'package:flutter/material.dart';
import 'package:alo_ride_driver_app/res/utils/app_responsive.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

// class RideDetailsScreen extends StatefulWidget {
//   const RideDetailsScreen({super.key});
//
//   @override
//   State<RideDetailsScreen> createState() => _RideDetailsScreenState();
// }
//
// class _RideDetailsScreenState extends State<RideDetailsScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.white,
//       appBar: AppAppBar(title: "Ride Completed"),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             Divider(color: AppColors.darkTextColor),
//             Gap(10),
//             Padding(
//               padding:  EdgeInsets.symmetric(horizontal: 16.h),
//               child: Row(
//                 children: [
//                   CircleAvatar(
//                     radius: 30.r,
//                     backgroundImage: const NetworkImage(
//                       "https://i.pravatar.cc/150?img=47",
//                     ),
//                   ),
//                   Gap(12.w),
//                   Expanded(
//                     child: AppText(
//                       text: "Léonie",
//                       fontSize: 13,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.end,
//                       children: [
//                         AppText(
//                           text: "1.2 Km",
//                           fontSize: 13,
//                           fontWeight: FontWeight.w500,
//                         ),
//                         AppText(
//                           text: "Fare estimate: \$20",
//                           fontSize: 13,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Gap(10),
//             Divider(color: AppColors.darkTextColor),
//             Gap(10),
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: 16),
//               child: Row(
//                 children: [
//                   AppText(text: "Booking ID: 23356", fontWeight: FontWeight.w600,color: AppColors.blueColor,),
//                   Spacer(),
//                   AppText(text: "Date: 10/12/2025 10.30 AM", fontWeight: FontWeight.w500,fontSize: 12,),
//                 ],
//               ),
//             ),
//             Gap(10),
//             Divider(color: AppColors.darkTextColor),
//             Gap(10),
//
//             Column(
//               children: [
//                 // From location
//                 // Gap(10),
//                 _buildLocationRow(
//                   icon:  AppImage(
//                     height: 20.h,
//                     width: 20.w,
//                     image: AppImages.recordCircleFill,
//                     imageType: ImageType.svgAsset,
//                   ),
//                   iconColor: AppColors.pinkColor,
//                   title: '241-205 Barrieau Rd, Moncton.',
//                   subtitle: '11 Dec,2025  7:20 PM',
//                   showDivider: true,
//                 ),
//
//                 // Drop off location
//                 _buildLocationRow(
//                   icon: Icon(Icons.location_on, color: AppColors.pinkColor, size: 20),
//                   iconColor: AppColors.pinkColor,
//                   title: '100 Holland Dr, Moncton, NB E1...',
//                   subtitle: '',
//                   showDivider: false,
//                 ),
//
//               ],
//             ),
//             Gap(10),
//
//             Divider(color: AppColors.darkTextColor),
//             Gap(10),
//             _fareRow(
//               "Fare estimate",
//               "\$20.00",
//               fontSize: 16,
//               bold: true,
//             ),
//             Gap(10),
//             Divider(color: AppColors.darkTextColor),
//           ],
//         ),
//       ),
//       bottomNavigationBar: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//           child: Column(
//             mainAxisSize: MainAxisSize.min, // ✅ VERY IMPORTANT
//             children: [
//               Row(
//                 children: [
//                   Expanded(
//                     child: AppButton(
//                       text: "CALL RIDER",
//                       backgroundColor: Colors.white,
//                       textColor: AppColors.lightBlackColor,
//                       borderColor: AppColors.lightBlackColor,
//                       onTap: () {},
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: AppButton(
//                       text: "CANCEL",
//                       backgroundColor: Colors.white,
//                       textColor: AppColors.lightBlackColor,
//                       borderColor: AppColors.lightBlackColor,
//                       onTap: () {},
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 12),
//               AppButton(
//                 text: "GO TO PICKUP",
//                 onTap: () {
//                   Get.to(()=>StartPickupScreen());
//                   // show dialog / next screen
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//
//     );
//   }
//
//
//   Widget _buildLocationRow({
//     required Widget icon,
//     required Color iconColor,
//     required String title,
//     required String subtitle,
//     required bool showDivider,
//   }) {
//     return Column(
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16.0),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Icon with connecting line
//               Column(
//                 children: [
//                   // Icon(icon, color: iconColor, size: 20),
//                   icon,
//                   if (showDivider)
//                     Column(
//                       children: List.generate(14, (index) {
//                         return Padding(
//                           padding: const EdgeInsets.only(bottom: 2.0),
//                           child: Container(
//                             height: 2,
//                             width: 2,
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               color: AppColors.black,
//                             ),
//                           ),
//                         );
//                       }),
//                     ),
//                 ],
//               ),
//
//               const SizedBox(width: 12),
//
//               // Text content
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     AppText(text: title,  color: AppColors.textColor,),
//                     const SizedBox(height: 4),
//                     AppText(text: subtitle,fontSize: 10,),
//                   ],
//                 ),
//               ),
//
//
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//
//   Widget _fareRow(String title, String value, {bool bold = false,double fontSize = 14}) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 16.h),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           AppText(
//             text: title,
//             fontSize: fontSize,
//             fontWeight: bold ? FontWeight.w500 : FontWeight.normal,
//           ),
//           AppText(
//             text: value,
//             fontSize: fontSize,
//             fontWeight: bold ? FontWeight.w500 : FontWeight.normal,
//           ),
//         ],
//       ),
//     );
//   }
//
// }

class RideDetailsScreen extends StatefulWidget {
  final int riderId;
  final String riderName;

  /// The ride's **current** status (`accepted`). The status that gets posted is
  /// derived from it, so the flow can never skip a step.
  final String status;
  final String bookingId;
  final String distance;
  final String fare;
  final String pickupAddress;
  final String dropAddress;
  final String pickupTime;
  final String profileImage;
  final bool? backScreen;
  final bool? myRidesBack;
  final RideData? ride;


  const RideDetailsScreen({
    super.key,
    required this.riderName,
    required this.bookingId,
    required this.distance,
    required this.fare,
    required this.pickupAddress,
    required this.dropAddress,
    required this.pickupTime,
    required this.profileImage,
    required this.riderId,
    required this.status,
    this.backScreen, this.myRidesBack,
    this.ride,
  });

  @override
  State<RideDetailsScreen> createState() => _RideDetailsScreenState();
}

class _RideDetailsScreenState extends State<RideDetailsScreen> {
  final RideCompletedController rideCompletedController = Get.put(
    RideCompletedController(),
  );

  /// 🔹 SCHEDULED RIDE GATE (start allowed only 1 hour before pickup)
  Timer? _startCountdownTimer;
  bool _canStart = true;

  DateTime? get _startAvailableAt => widget.ride?.startAvailableAt;

  /// 🔹 Drop-offs come from `stops` (ascending sequence); `drop_address` is
  /// only used when the ride has no stops.
  List<String> get _dropAddresses {
    final stopAddresses = widget.ride?.dropAddresses ?? [];
    if (stopAddresses.isNotEmpty) return stopAddresses;
    return widget.dropAddress.isEmpty ? [] : [widget.dropAddress];
  }

  /// Gate applies only to the "start ride" action (accepted -> going_to_pickup)
  bool get _isStartAction => widget.status == RideStatus.accepted;

  /// 🔹 IMAGE BUILDER (API + FALLBACK SAFE)
  String buildProfileImage(String? path) {
    if (path == null || path.isEmpty) {
      return "";
    }

    if (path.startsWith('http')) {
      return path;
    }

    return "https://deliverymate.volive.me/alodrive/public/$path";
  }

  @override
  void initState() {
    super.initState();
    _initStartGate();
  }

  @override
  void dispose() {
    _startCountdownTimer?.cancel();
    super.dispose();
  }

  /// Uses `can_start` from the API, then keeps a local countdown running so the
  /// button enables itself at `start_available_at` without a refresh.
  void _initStartGate() {
    if (!_isStartAction) {
      _canStart = true;
      return;
    }

    // Older responses (or non scheduled rides) don't send the flag -> allow.
    _canStart = widget.ride?.canStart ?? true;
    if (_canStart) return;

    final availableAt = _startAvailableAt;
    if (availableAt == null) {
      // Disabled with no known unlock time -> let the API 422 decide.
      _canStart = true;
      return;
    }

    _startCountdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _canStart = !DateTime.now().isBefore(availableAt);
      });
      if (_canStart) timer.cancel();
    });
  }

  /// "Available in 2h 0m" / "Available in 45m 10s"
  String _startCountdownText() {
    final availableAt = _startAvailableAt;
    if (availableAt == null) return "";

    var remaining = availableAt.difference(DateTime.now());
    if (remaining.isNegative) remaining = Duration.zero;

    final hours = remaining.inHours;
    final minutes = remaining.inMinutes % 60;
    final seconds = remaining.inSeconds % 60;

    if (hours > 0) return "Available in ${hours}h ${minutes}m";
    return "Available in ${minutes}m ${seconds}s";
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if(widget.myRidesBack == true){
          Get.back();
        }else{
          Get.offAll(() => const DashboardScreen());
        }
        return false; // ⛔ prevent default back
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppAppBar(
          title: "Ride Details",
          onBack: () {
            if(widget.myRidesBack == true){
              Get.back();
            }else{
              Get.to(()=>DashboardScreen());
            }

          },
          showBack: widget.backScreen == true ? false : true,
          actions: [
            /// 💬 Chat with the customer — hidden until the ride has a room.
            ChatEntryButton(
              rideId: widget.riderId,
              rideStatus: widget.status,
              customerName: widget.riderName,
              customerMobile: widget.ride?.user?.mobile ?? '',
              customerPhoto: widget.profileImage,
            ),
            Gap(12.w),
          ],
        ),
        body: SingleChildScrollView(
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
                        buildProfileImage(widget.profileImage),
                        width: 60.r,
                        height: 60.r,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) {
                          return Container(
                            width: 60.r,
                            height: 60.r,
                            color: Colors.grey.shade300,
                            child: Icon(Icons.person, size: 30.r),
                          );
                        },
                      ),
                    ),
                    Gap(12.w),
                    Expanded(
                      child: AppText(
                        text: widget.riderName,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          AppText(
                            text: "${widget.distance} Km",
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          AppText(
                            text: "Fare estimate: \$${widget.fare}",
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
                child: Row(
                  children: [
                    AppText(
                      text: "Booking ID: ${widget.bookingId}",
                      fontWeight: FontWeight.w600,
                      color: AppColors.blueColor,
                    ),
                    const Spacer(),
                    AppText(
                      text: _formatDate(widget.pickupTime),
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ],
                ),
              ),

              Gap(10),
              Divider(color: AppColors.darkTextColor),
              if(widget.ride?.isFlight == true)
              Column(
                children: [
                  Gap(10),
                 // Divider(color: AppColors.darkTextColor),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        AppText(
                          text: "Airport Pickup: ",
                          fontWeight: FontWeight.w600,
                          color: AppColors.blueColor,
                        ),
                        const Spacer(),
                        AppText(
                          text: widget.ride?.flightNumber ?? "",
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ],
                    ),
                  ),
                  Gap(10),
                  Divider(color: AppColors.darkTextColor),
                  ///Gap(10),
                ],
              ),
              Gap(10),

              /// 📍 LOCATIONS
              _buildLocationRow(
                icon: AppImage(
                  height: 20.h,
                  width: 20.w,
                  image: AppImages.recordCircleFill,
                  imageType: ImageType.svgAsset,
                ),
                title: widget.pickupAddress,
                subtitle: _formatDate(widget.pickupTime),
                showDivider: true,
              ),

              ...List.generate(_dropAddresses.length, (index) {
                final isLast = index == _dropAddresses.length - 1;
                return _buildLocationRow(
                  icon: Icon(
                    Icons.location_on,
                    color: AppColors.pinkColor,
                    size: 20,
                  ),
                  title: _dropAddresses[index],
                  subtitle: '',
                  showDivider: !isLast,
                );
              }),

              Gap(10),
              Divider(color: AppColors.darkTextColor),
              Gap(10),

              _fareRow(
                "Fare estimate",
                "\$${widget.fare}",
                fontSize: 16,
                bold: true,
              ),

              Gap(10),
              Divider(color: AppColors.darkTextColor),

              if(widget.ride?.isPackageStatus == 1)...[
                Gap(10),
              Padding(
                padding:  EdgeInsets.symmetric(horizontal: 16.h),
                child: Align(
                  alignment: AlignmentGeometry.centerLeft,
                  child: AppText(
                    text: "Package Used - ${widget.ride?.packageName}",
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    textAlign: TextAlign.left,
                    color: AppColors.red,
                  ),
                ),
              ),
    ],
            ],
          ),
        ),

        /// 🔘 BUTTONS
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!_canStart) ...[
                  AppText(
                    text: _startCountdownText(),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.red,
                  ),
                  Gap(8),
                ],
                /// 🔘 Label always mirrors the ride's current status.
                if (RideStatus.actionLabel(widget.status) != null)
                  Obx(() {
                    final isLoading = rideCompletedController.isLoading.value;
                    return AppButton(
                      isLoading: isLoading,
                      text: RideStatus.actionLabel(widget.status)!,
                      onTap: (_canStart && !isLoading)
                          ? () {
                              rideCompletedController.advanceRideStatus(
                                rideId: widget.riderId,
                                currentStatus: widget.status,
                                hostedInTab: widget.backScreen == true,
                              );
                            }
                          : null,
                    );
                  }),

                /// ❌ Only while the backend status allows cancelling.
                Gap(10),
                CancelRideButton(
                  rideId: widget.riderId,
                  status: widget.ride?.status ?? widget.status,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= HELPERS =================
  /// `pickupTime` reaches this screen already formatted for display
  /// ("25 Jul,2026  1:00 PM") but can also arrive as a raw API timestamp.
  /// Raw timestamps are formatted here; anything else is shown as received
  /// instead of falling back to a placeholder date.
  String _formatDate(String date) {
    final value = date.trim();
    if (value.isEmpty) return "";

    final dt = DateTime.tryParse(value);
    if (dt == null) return value;

    return DateFormat("dd MMM,yyyy  h:mm a").format(dt.toLocal());
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
                    13,
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
                AppText(text: title,maxLines: 2,),
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
    bool bold = false,
    double fontSize = 14,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(
            text: title,
            fontSize: fontSize,
            fontWeight: bold ? FontWeight.w500 : FontWeight.normal,
          ),
          AppText(
            text: value,
            fontSize: fontSize,
            fontWeight: bold ? FontWeight.w500 : FontWeight.normal,
          ),
        ],
      ),
    );
  }
}
