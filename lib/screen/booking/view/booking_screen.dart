// import 'package:alo_ride_driver_app/res/common/app_appbar.dart';
// import 'package:alo_ride_driver_app/res/common/app_button.dart';
// import 'package:alo_ride_driver_app/res/common/app_image.dart';
// import 'package:alo_ride_driver_app/res/common/app_text.dart';
// import 'package:alo_ride_driver_app/res/constant/app_colors.dart';
// import 'package:alo_ride_driver_app/res/constant/app_images.dart';
// import 'package:alo_ride_driver_app/screen/booking/controller/booking_controller.dart';
// import 'package:alo_ride_driver_app/screen/booking/view/ride_confirmed_widget.dart';
// import 'package:alo_ride_driver_app/screen/booking/view/ride_tracking_screen.dart';
// import 'package:alo_ride_driver_app/screen/home/controller/location_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:alo_ride_driver_app/res/utils/app_responsive.dart';
// import 'package:gap/gap.dart';
// import 'package:get/get.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
//
// class BookingScreen extends StatefulWidget {
//   const BookingScreen({super.key});
//
//   @override
//   State<BookingScreen> createState() => _BookingScreenState();
// }
//
// class _BookingScreenState extends State<BookingScreen> {
//   final LocationController controller = Get.put(LocationController());
//   final BookingController bookingController = Get.put(BookingController());
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.white,
//       extendBodyBehindAppBar: true,
//       appBar: AppAppBar(
//         backgroundColor: Colors.transparent,
//         // leading: Icon(Icons.menu),
//         title: "Booking",
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             Container(
//               height: 600.h,
//               child: Obx(() {
//                 if (controller.isLoading.value) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//
//                 return Stack(
//                   children: [
//                     GoogleMap(
//                       initialCameraPosition: CameraPosition(
//                         target:
//                             controller.currentLatLng.value ??
//                             const LatLng(0, 0),
//                         zoom: 14,
//                       ),
//                       onMapCreated: (mapController) {
//                         if (!controller.mapController.isCompleted) {
//                           controller.mapController.complete(mapController);
//                         }
//                         controller.googleController = mapController;
//
//                         final latLng = controller.currentLatLng.value;
//                         if (latLng != null) {
//                           mapController.animateCamera(
//                             CameraUpdate.newLatLng(latLng),
//                           );
//                         }
//                       },
//                       markers: controller.markers,
//                       myLocationEnabled: true,
//                       myLocationButtonEnabled: false,
//                       circles: controller.currentLatLng.value == null
//                           ? {}
//                           : {
//                               Circle(
//                                 circleId: const CircleId('radius'),
//                                 center: controller.currentLatLng.value!,
//                                 radius:
//                                     controller.selectedDistance.value * 1000,
//                                 strokeColor: AppColors.secondary.withOpacity(
//                                   0.5,
//                                 ),
//                                 fillColor: AppColors.secondary.withOpacity(0.2),
//                                 strokeWidth: 1,
//                               ),
//                             },
//                       onTap: controller.onMapTap,
//                     ),
//                     Positioned(
//                       top: 80.h,
//                       left: 16,
//                       right: 16,
//                       child: Column(
//                         children: [
//                           Container(
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(6),
//                               border: Border.all(
//                                 color: AppColors.lightGray,
//                                 width: 2,
//                               ),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.black.withOpacity(0.1),
//                                   blurRadius: 10,
//                                   offset: const Offset(0, 4),
//                                 ),
//                               ],
//                             ),
//                             child: Column(
//                               children: [
//                                 // From location
//                                 Gap(10),
//                                 _buildLocationRow(
//                                   icon: Icons.circle,
//                                   iconColor: AppColors.pinkColor,
//                                   title: 'From',
//                                   subtitle: '341-205 Barrinou Rd, Moncton,',
//                                   showDivider: true,
//                                 ),
//
//                                 // Drop off location
//                                 _buildLocationRow(
//                                   icon: Icons.location_on,
//                                   iconColor: AppColors.pinkColor,
//                                   title: 'Drop off Location',
//                                   subtitle: '100 Holland Dr, Moncton, NB E1...',
//                                   showDivider: false,
//                                 ),
//                                 Gap(10),
//                               ],
//                             ),
//                           ),
//                           Gap(10),
//                           Container(
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(6),
//                               border: Border.all(
//                                 color: AppColors.lightGray,
//                                 width: 2,
//                               ),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.black.withOpacity(0.1),
//                                   blurRadius: 10,
//                                   offset: const Offset(0, 4),
//                                 ),
//                               ],
//                             ),
//                             child: Padding(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 10.0,
//                               ),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   // From location
//                                   Gap(12.h),
//
//                                   /// PICKUP TYPE
//                                   Row(
//                                     children: [
//                                       _radioOption("Pickup & Drop", 0),
//                                       Gap(20.w),
//                                       _radioOption(
//                                         "Round-Trip Pickup & Drop",
//                                         1,
//                                       ),
//                                     ],
//                                   ),
//
//                                   Gap(14.h),
//
//                                   AppText(
//                                     text: "Ride Later",
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//
//                                   Gap(8.h),
//                                   Row(
//                                     children: [
//                                       _dateTimeBox(
//                                         type: "date",
//                                         icon: Icons.calendar_month,
//                                         title: "Select Date",
//                                       ),
//                                       Gap(12.w),
//                                       _dateTimeBox(
//                                         type: "time",
//                                         icon: Icons.access_time,
//                                         title: "Select Time",
//                                       ),
//                                       // Gap(10),
//                                       // Container(
//                                       //   height: 45.h,
//                                       //   width: 45.w,
//                                       //   decoration: BoxDecoration(
//                                       //     border: Border.all(
//                                       //       color: AppColors.borderColor,
//                                       //     ),
//                                       //     borderRadius: BorderRadius.circular(
//                                       //       8.r,
//                                       //     ),
//                                       //   ),
//                                       //   child: const Icon(Icons.add),
//                                       // ),
//                                     ],
//                                   ),
//                                   Gap(20.w),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Positioned(
//                       bottom: 10,right: 10,
//                       child: AppImage(
//                         height: 55,width: 55,
//                         image: AppImages.sosButton,
//                         imageType: ImageType.asset,
//                       ),
//                     ),
//                   ],
//                 );
//               }),
//             ),
//             Gap(20),
//             AppText(
//               text: "Ride on 10 Dec at 7:30 AM",
//               fontSize: 16,
//               fontWeight: FontWeight.w500,
//             ),
//             Gap(8.h),
//             Divider(color: AppColors.darkTextColor),
//             Gap(8.h),
//             AppText(
//               text: "Selected car : SUV     Fare estimate : \$ 20",
//               fontSize: 12,
//               color: AppColors.lightBlackColor,
//             ),
//             Gap(8.h),
//             Divider(color: AppColors.darkTextColor),
//             Gap(8.h),
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: 16.w),
//               child: RichText(
//                 text: TextSpan(
//                   children: [
//                     TextSpan(
//                       text: "Note: ",
//                       style: TextStyle(
//                         fontSize: 13,
//                         fontWeight: FontWeight.w500,
//                         color: AppColors.lightBlackColor,
//                         height: 1.4,
//                       ),
//                     ),
//                     TextSpan(
//                       text:
//                           "This is an approximate estimate. Actual cost may be different due to traffic and waiting time.",
//                       style: TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.normal,
//                         color: AppColors.lightBlackColor,
//                           height: 1.4,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//
//             Gap(20.h),
//
//             /// BOOK NOW BUTTON
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: 16.0.w),
//               child: AppButton(text: "Book Now", onTap: () {
//                 // showRideConfirmed(context);
//                 // Get.to(()=>RideTrackingScreen());
//               }),
//             ),
//             Gap(30.h),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildLocationRow({
//     required IconData icon,
//     required Color iconColor,
//     required String title,
//     required String subtitle,
//     required bool showDivider,
//   }) {
//     return Column(
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 10.0),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Icon with connecting line
//               Column(
//                 children: [
//                   Icon(icon, color: iconColor, size: 20),
//                   if (showDivider)
//                     Column(
//                       children: List.generate(10, (index) {
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
//                     Text(
//                       title,
//                       style: const TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w500,
//                         color: Colors.black87,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       subtitle,
//                       style: TextStyle(fontSize: 13, color: Colors.grey[600]),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ],
//                 ),
//               ),
//
//               // Favorite icon
//               IconButton(
//                 icon: const Icon(Icons.favorite_border),
//                 color: Colors.grey[400],
//                 onPressed: () {},
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   /// ================= RADIO OPTION =================
//   Widget _radioOption(String text, int value) {
//     return Obx(() {
//       final isSelected = bookingController.selectValue.value == value;
//
//       return InkWell(
//         onTap: () {
//           bookingController.selectValue.value = value; // ✅ FIX
//         },
//         child: Row(
//           children: [
//             Icon(
//               isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
//               color: AppColors.black,
//             ),
//             Gap(6.w),
//             AppText(text: text, fontSize: 12),
//           ],
//         ),
//       );
//     });
//   }
//
//   /// ================= DATE TIME BOX =================
//   Widget _dateTimeBox({
//     required String type, // "date" or "time"
//     required String title,
//     required IconData icon,
//   }) {
//     return Expanded(
//       child: InkWell(
//         onTap: () {
//           if (type == "date") {
//             bookingController.pickDate(context);
//           } else {
//             bookingController.pickTime(context);
//           }
//         },
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             AppText(
//               text: title,
//               fontSize: 12,
//               color: AppColors.textColor,
//               fontWeight: FontWeight.w500,
//             ),
//             Gap(7),
//             Container(
//               height: 45.h,
//               padding: EdgeInsets.symmetric(horizontal: 10.w),
//               decoration: BoxDecoration(
//                 border: Border.all(color: AppColors.borderColor),
//                 borderRadius: BorderRadius.circular(8.r),
//               ),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Obx(() {
//                       return AppText(
//                         text: type == "date"
//                             ? bookingController.formattedDate
//                             : bookingController.formattedTime,
//                         fontSize: 12,
//                         color: AppColors.greyColor,
//                       );
//                     }),
//                   ),
//                   Icon(icon, color: AppColors.secondary),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//
//   void showRideConfirmed(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (_) {
//         return RideConfirmedWidget(
//           dateTimeText: "10 Dec at 07:30 AM",
//         );
//       },
//     );
//   }
//
// }
