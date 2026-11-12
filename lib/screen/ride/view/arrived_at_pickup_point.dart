// import 'package:alo_ride_driver_app/res/common/app_appbar.dart';
// import 'package:alo_ride_driver_app/res/common/app_button.dart';
// import 'package:alo_ride_driver_app/res/common/app_text.dart';
// import 'package:alo_ride_driver_app/res/constant/app_colors.dart';
// import 'package:alo_ride_driver_app/screen/ride/view/reached_destination_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:alo_ride_driver_app/res/utils/app_responsive.dart';
// import 'package:gap/gap.dart';
// import 'package:get/get.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
//
// class ArrivedAtPickupPoint extends StatefulWidget {
//   const ArrivedAtPickupPoint({super.key});
//
//   @override
//   State<ArrivedAtPickupPoint> createState() => _ArrivedAtPickupPointState();
// }
//
// class _ArrivedAtPickupPointState extends State<ArrivedAtPickupPoint> {
//   late GoogleMapController mapController;
//
//   final LatLng pickupLocation = const LatLng(46.0878, -64.7782);
//   final LatLng dropLocation = const LatLng(46.0915, -64.7500);
//
//   final Set<Marker> markers = {};
//   final Set<Polyline> polylines = {};
//
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
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.white,
//       appBar: AppAppBar(title: "Start Pickup"),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             Divider(color: AppColors.darkTextColor),
//             Gap(10),
//             Container(
//               padding: EdgeInsets.symmetric(horizontal: 16.w),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Icon(Icons.location_on, color: Colors.red),
//                       Gap(8.w),
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           AppText(
//                             text: "241–205 Barrieau Rd, Moncton.",
//                             fontSize: 12,
//                             color: AppColors.textColor,
//                           ),
//                           Gap(3.h),
//                           AppText(
//                             text: "11 Dec,2025  7:20 PM",
//                             fontSize: 12,
//                           ),
//                         ],
//                       ),
//                       Spacer(),
//                       Column(
//                         children: [
//                           const Icon(Icons.navigation, color: AppColors.secondary),
//                           Gap(2.h),
//                           AppText(
//                             text: "Navigate",
//                             fontSize: 11,
//                           ),
//                           Gap(2.h),
//                           AppText(
//                             text: "1.2 Km",
//                             fontSize: 12,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ],
//                       ),
//                     ],
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
//             Gap(15),
//             Container(
//               width: double.infinity,
//               height: 1,
//               color: AppColors.darkTextColor,
//             ),
//
//             Container(
//               height: 425.h,
//               child: GoogleMap(
//                 initialCameraPosition: CameraPosition(
//                   target: pickupLocation,
//                   zoom: 14,
//                 ),
//                 onMapCreated: (controller) {
//                   mapController = controller;
//                 },
//                 markers: markers,
//                 polylines: polylines,
//                 myLocationEnabled: true,
//                 myLocationButtonEnabled: false,
//               ),
//             ),
//             Gap(10),
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
//             Padding(
//               padding: EdgeInsets.all(16.w),
//               child: AppButton(
//                 text: "Start Ride",
//                 onTap: () {
//                   Get.to(()=>ReachedDestinationScreen());
//                   // navigate to next step
//                 },
//               ),
//             ),
//             Gap(10),
//           ],
//         ),
//       ),
//     );
//   }
// }
