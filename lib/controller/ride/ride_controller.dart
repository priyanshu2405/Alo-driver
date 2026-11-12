import 'package:get/get.dart';

class RideController extends GetxController{

  RxBool isAcceptRide = false.obs;

}




// class RideController extends GetxController {
//   RxBool isAcceptRide = false.obs;
//
//   // ================= ACCEPT RIDE =================
//   Future<void> acceptRide({
//     required int rideId,
//   }) async {
//     isAcceptRide.value = true;
//
//     try {
//       final response = await ApiService.post(
//         endpoint: 'rides/$rideId/accept',
//         isShow: true,
//         body: {},
//       );
//
//       debugPrint("Accept Ride Response: $response");
//
//       if (response['success'] == true) {
//         final ride = response['ride'];
//
//         /// ✅ SUCCESS MESSAGE
//         Get.snackbar(
//           "Success",
//           response['message'] ?? "Ride accepted successfully",
//           snackPosition: SnackPosition.TOP,
//           backgroundColor: Colors.green.withOpacity(0.85),
//           colorText: Colors.white,
//         );
//
//         /// ✅ OPTIONAL: Navigate to ride detail / tracking screen
//         // Get.off(() => RideDetailScreen(ride: ride));
//
//         /// ✅ OPTIONAL: Update global ride state
//         // currentRide.value = RideModel.fromJson(ride);
//
//       } else {
//         _showError("Failed to accept ride");
//       }
//     } catch (e) {
//       debugPrint("Accept Ride Error: $e");
//       _showError(e.toString());
//     } finally {
//       isAcceptRide.value = false;
//     }
//   }
//
//   // ================= ERROR HANDLER =================
//   void _showError(String message) {
//     Get.snackbar(
//       "Error",
//       message,
//       snackPosition: SnackPosition.TOP,
//       backgroundColor: Colors.red.withOpacity(0.85),
//       colorText: Colors.white,
//     );
//   }
// }
