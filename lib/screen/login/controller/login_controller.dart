import 'dart:async';
import 'package:alo_ride_driver_app/res/constant/app_colors.dart';
import 'package:alo_ride_driver_app/screen/login/view/otp_screen.dart';
import 'package:alo_ride_driver_app/services/api_service.dart';
import 'package:alo_ride_driver_app/services/token_store.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// class LoginController extends GetxController {
//   final TextEditingController phoneNumberCtrl = TextEditingController();
//   final GlobalKey<FormState> formKey = GlobalKey<FormState>(); // ✅ ADD
//
//
//   /// ✅ Make country reactive
//   Rx<Country?> countryCode = Country(
//     phoneCode: "91",
//     countryCode: "IN",
//     e164Sc: 0,
//     geographic: true,
//     level: 1,
//     name: "India",
//     example: "9123456789",
//     displayName: "India (IN) [+91]",
//     displayNameNoCountryCode: "India (IN)",
//     e164Key: "91-IN-0",
//   ).obs;
//
//   void pickCountry() {
//     showCountryPicker(
//       context: Get.context!,
//       showPhoneCode: true,
//       useSafeArea: true,
//       onSelect: (Country country) {
//         countryCode.value = country; // ✅ update Rx value
//       },
//     );
//   }
// }

class LoginController extends GetxController {
  final TextEditingController phoneNumberCtrl = TextEditingController();
  final AuthController authController = Get.put(AuthController());
  RxBool isLoading = false.obs;

  Rx<Country?> countryCode = Country(
    phoneCode: "1",
    countryCode: "CA",
    name: "Canada",
    displayName: "Canada (CA) [+1]",
    displayNameNoCountryCode: "Canada (CA)",
    e164Key: "1-CA-0",
    e164Sc: 0,
    geographic: true,
    level: 1,
    example: "2041234567",
  ).obs;

  /// 🔹 Validation states
  RxString phoneError = "".obs;
  RxBool isPhoneValid = false.obs;

  /// 🔹 Call this on text change or button tap
  void validatePhone() {
    final phone = phoneNumberCtrl.text.trim();

    if (phone.isEmpty) {
      phoneError.value = "Phone number is required";
      isPhoneValid.value = false;
    } else if (phone.length < 8 || phone.length > 15) {
      phoneError.value = "Enter a valid phone number";
      isPhoneValid.value = false;
    } else {
      phoneError.value = "";
      isPhoneValid.value = true;
    }
  }

  void pickCountry() {
    showCountryPicker(
      context: Get.context!,
      showPhoneCode: true,
      onSelect: (Country country) {
        countryCode.value = country;
      },
    );
  }

  Future<void> loginApi() async {
    isLoading.value = true; // Start loading

    var body = {
      "country_code": "+${countryCode.value?.phoneCode}",
      "mobile": phoneNumberCtrl.text,
    };
    debugPrint("body : $body");

    try {

      final response = await ApiService.post(
        endpoint: 'send-otp',
        body: body,
      );
      print("response::: $response");
      print("id: ${response["otp"]}");

      debugPrint("otp verify =====>${response["otp"]}");
      if (response['success'] == true) {
        // Get.to(()=>OtpScreen(phoneNumber: phoneNumberCtrl.text));
        Get.to(
              () => OtpScreen(
            countryCode: countryCode.value?.phoneCode??"",
            phoneNumber: phoneNumberCtrl.text,
          ),
        );
      } else{
        Get.snackbar(
          "Error",
          "${response["errors"][0]}",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        debugPrint("errors =====>${response["errors"][0]}");
      }
    } catch (e) {
      debugPrint("Error =====>$e");
      Get.snackbar(
        "Error",
        "$e",
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false; // Stop loading in all cases
    }
  }


}
