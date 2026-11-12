// import 'package:alo_ride_driver_app/res/common/app_appbar.dart';
// import 'package:alo_ride_driver_app/res/common/app_button.dart';
// import 'package:alo_ride_driver_app/res/common/app_image.dart';
// import 'package:alo_ride_driver_app/res/common/app_text.dart';
// import 'package:alo_ride_driver_app/res/constant/app_colors.dart';
// import 'package:alo_ride_driver_app/res/constant/app_images.dart';
// import 'package:flutter/material.dart';
// import 'package:alo_ride_driver_app/res/utils/app_responsive.dart';
// import 'package:gap/gap.dart';
// import 'package:get/get.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
//
// class RideTrackingScreen extends StatefulWidget {
//   const RideTrackingScreen({super.key});
//
//   @override
//   State<RideTrackingScreen> createState() => _RideTrackingScreenState();
// }
//
// class _RideTrackingScreenState extends State<RideTrackingScreen> {
//   late GoogleMapController mapController;
//
//   final LatLng pickupLocation = const LatLng(46.0878, -64.7782);
//   final LatLng dropLocation = const LatLng(46.0915, -64.7500);
//
//   final Set<Marker> markers = {};
//   final Set<Polyline> polylines = {};
//
//   @override
//   void initState() {
//     super.initState();
//
//     /// Pickup Marker
//     markers.add(
//       Marker(
//         markerId: const MarkerId("pickup"),
//         position: pickupLocation,
//         icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
//       ),
//     );
//
//     /// Drop Marker
//     markers.add(
//       Marker(
//         markerId: const MarkerId("drop"),
//         position: dropLocation,
//         icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
//       ),
//     );
//
//     /// Route Polyline (dummy example)
//     polylines.add(
//       Polyline(
//         polylineId: const PolylineId("route"),
//         points: [pickupLocation, const LatLng(46.0895, -64.7700), dropLocation],
//         color: Colors.blue,
//         width: 5,
//       ),
//     );
//   }
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
//               height: 620.h,
//               child: Stack(
//                 children: [
//                   GoogleMap(
//                     initialCameraPosition: CameraPosition(
//                       target: pickupLocation,
//                       zoom: 14,
//                     ),
//                     onMapCreated: (controller) {
//                       mapController = controller;
//                     },
//                     markers: markers,
//                     polylines: polylines,
//                     myLocationEnabled: true,
//                     myLocationButtonEnabled: false,
//                   ),
//                   Positioned(
//                     top: 80.h,
//                     left: 16,
//                     right: 16,
//                     child: Column(
//                       children: [
//                         Container(
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(6),
//                             border: Border.all(
//                               color: AppColors.lightGray,
//                               width: 2,
//                             ),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.1),
//                                 blurRadius: 10,
//                                 offset: const Offset(0, 4),
//                               ),
//                             ],
//                           ),
//                           child: Column(
//                             children: [
//                               // From location
//                               Gap(10),
//                               _buildLocationRow(
//                                 icon: Icons.circle,
//                                 iconColor: AppColors.pinkColor,
//                                 title: 'From',
//                                 subtitle: '341-205 Barrinou Rd, Moncton,',
//                                 showDivider: true,
//                               ),
//
//                               // Drop off location
//                               _buildLocationRow(
//                                 icon: Icons.location_on,
//                                 iconColor: AppColors.pinkColor,
//                                 title: 'Drop off Location',
//                                 subtitle: '100 Holland Dr, Moncton, NB E1...',
//                                 showDivider: false,
//                               ),
//                               Gap(10),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Positioned(
//                     bottom: 10,right: 10,
//                     child: AppImage(
//                       height: 55,width: 55,
//                       image: AppImages.sosButton,
//                       imageType: ImageType.asset,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Gap(20),
//             Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 /// Driver Info
//                 Padding(
//                   padding:  EdgeInsets.symmetric(horizontal: 16.h),
//                   child: InkWell(
//                     onTap: () {
//                       // Get.to(()=>RideCompletedScreen());
//                     },
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         CircleAvatar(
//                           radius: 30.r,
//                           backgroundImage: const NetworkImage(
//                             "https://i.pravatar.cc/150?img=3",
//                           ),
//                         ),
//                         Gap(12.w),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               AppText(
//                                 text: "Driver: Philippe",
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                               Gap(1),
//                               AppText(
//                                 text: "2 mins away!",
//                                 fontSize: 12,
//                                 color: AppColors.lightBlackColor,
//                               ),
//                               Gap(12.h),
//
//                               /// Vehicle Info
//                               Row(
//                                 children: [
//                                   Container(
//                                     padding: EdgeInsets.symmetric(
//                                       horizontal: 10.w,
//                                       vertical: 4.h,
//                                     ),
//                                     decoration: BoxDecoration(
//                                       borderRadius: BorderRadius.circular(6.r),
//                                       border: Border.all(color: AppColors.greyColor),
//                                     ),
//                                     child: AppText(text: "AI3958", fontSize: 12),
//                                   ),
//                                   Gap(10.w),
//                                   AppText(
//                                     text: "KIA EV6 2020 (White)",
//                                     fontSize: 12,
//                                     color: AppColors.lightBlackColor,
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                         AppText(
//                           text: "1.5 KM",
//                           fontSize: 12,
//                           fontWeight: FontWeight.w500,
//                           color: AppColors.lightBlackColor,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//
//
//
//                 Gap(17.h),
//                 Divider(color: AppColors.darkTextColor),
//                 Gap(17.h),
//                 /// Buttons
//                 Padding(
//                   padding:  EdgeInsets.symmetric(horizontal: 16.h),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: AppButton(text: "CALL DRIVER", onTap: () {}),
//                       ),
//                       Gap(12.w),
//                       Expanded(
//                         child: AppButton(text: "CANCEL RIDE", onTap: () {}),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Gap(20.h),
//               ],
//             ),
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
// }
