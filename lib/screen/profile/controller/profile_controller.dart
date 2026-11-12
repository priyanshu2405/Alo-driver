import 'dart:io';

import 'package:alo_ride_driver_app/screen/login/view/login_screen.dart';
import 'package:alo_ride_driver_app/screen/profile/model/get_profile_model.dart';
import 'package:alo_ride_driver_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ProfileController extends GetxController{
  RxBool isLoading = false.obs;
  RxBool isLogoutUser = false.obs;
  RxBool isEditProfile = false.obs;


  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();




  RxString errorFullName = ''.obs;
  RxString errorEmail = ''.obs;
  RxString errorMessage = ''.obs;
  RxString errorPhoneNumber = ''.obs;

  RxBool isSave = false.obs;


  Rx<File?> profileImageFile = Rx<File?>(null); // picked image
  RxString profileImageUrl = ''.obs;
  final ImagePicker _picker = ImagePicker();


  Rx<GetProfileModel> profileData = GetProfileModel().obs;
  Future<void> getProfile() async {
    try {
      isLoading.value = true;

      final response = await ApiService.get(endpoint: 'profile', isShow: false);

      // Convert the entire response to GetPackageModel (not each item)
      final packageModel = GetProfileModel.fromJson(response);

      // Store the single GetPackageModel instance
      profileData.value = packageModel;

      nameController.text = profileData.value.data?.driver?.name??"";
      emailController.text = profileData.value.data?.driver?.email??"";
      phoneNumberController.text = profileData.value.data?.driver?.mobile??"";
      profileImageUrl.value = profileData.value.data?.driver?.profilePhoto??"";

      debugPrint("profileImageUrl ==> ${profileImageUrl.value}");


      print("name===>${profileData.value.data?.driver?.name}");
      print("id===>${profileData.value.data?.driver?.id}");
    } catch (e) {
      print('Error fetching packages: $e');
    } finally {
      isLoading.value = false;
    }
  }


  // Rx<File?> profileImage = Rx<File?>(null);


  /// PICK IMAGE (CAMERA / GALLERY)
  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 70,
      );

      if (image != null) {
        profileImageFile.value = File(image.path);
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Image picker failed",
        snackPosition: SnackPosition.TOP,
      );
    }
  }



  /// IMAGE PICKER BOTTOM SHEET
  void showImagePicker() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Camera"),
              onTap: () {
                Get.back();
                pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text("Gallery"),
              onTap: () {
                Get.back();
                pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Future<void> editProfile() async {
  //   isLoading.value = true; // Start loading
  //
  //   var body = {
  //     "name": nameController.text
  //   };
  //   debugPrint("body : $body");
  //   try {
  //     final response = await ApiService.post(
  //       endpoint: 'profile',
  //       body: body,
  //     );
  //
  //     print("otp: ${response['message']}");
  //     if (response['success'] == true) {
  //       getProfile();
  //     }/* else {
  //       // Handle case when API doesn't return expected data
  //       Get.snackbar(
  //         "error".tr(),
  //         "${response["error_message"]}",
  //         snackPosition: SnackPosition.TOP,
  //         backgroundColor: Colors.red.withOpacity(0.8),
  //         colorText: Colors.white,
  //       );
  //     }*/
  //
  //   } catch (e) {
  //     print("Error in resendOtp: $e"); // Updated error message
  //     Get.snackbar(
  //       "Error",
  //       "$e",
  //       snackPosition: SnackPosition.TOP,
  //       backgroundColor: Colors.red.withOpacity(0.8),
  //       colorText: Colors.white,
  //     );
  //   } finally {
  //     isLoading.value = false; // Stop loading in all cases
  //   }
  // }

  Future<void> editProfile({String? name,bool? nameCheck}) async {
    isEditProfile.value = true;

    try {
      String? userName;
      if(nameCheck == true){
        userName = "$name";
      } else {
        userName = nameController.text;
      }
      final response = await ApiService.multipartPostWithFile(
        endpoint: 'profile',
        fields: {
          "name": userName,
        },
        file: profileImageFile.value, // 👈 FILE
        fileKey: "profile_photo", // 👈 backend key
        isShow: true,
      );

      debugPrint("profileImage : ${profileImageFile.value}");
      if (response['success'] == true) {
        getProfile();
        isSave.value = false;
      }
    } catch (e) {
      debugPrint("e : ${e}");
      Get.snackbar("Error", e.toString());
    } finally {
      isEditProfile.value = false;
    }
  }


  Future<void> logoutUser() async {
    isLogoutUser.value = true; // Start loading

    try {
      final response = await ApiService.post(
          isShow: true,
          endpoint: 'logout',
          body: {}
      );

      if (response['success'] == true) {
        Get.offAll(() => LoginScreen());
      } else {
        // Handle case when API doesn't return expected data
        Get.snackbar(
          "Error",
          "Failed to logout. Please try again.",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
        );
      }

    } catch (e) {
      print("Error in logoutUser: $e");
      Get.snackbar(
        "Error",
        "$e",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } finally {
      isLogoutUser.value = false; // Stop loading in all cases
    }
  }

  RxBool isDeleteLoading = false.obs;
  Future<void> deleteAccount() async {
    try {
      isDeleteLoading.value = true;

      final response = await ApiService.delete(
        endpoint: 'delete-account', // ⚠️ correct endpoint
        isShow: true,
      );

      /// 🔥 PRINT FULL RESPONSE
      print("DELETE RESPONSE ==> $response");

      /// 🔥 PRINT MESSAGE
      print("MESSAGE ==> ${response['message']}");

      if (response['success'] == true) {
        print("DELETE SUCCESS ✅");
        Get.offAll(() => LoginScreen());
      } else {
        print("DELETE FAILED ❌");

        Get.snackbar("Error", response['message'] ?? "Failed");
      }
    } catch (e) {
      print("DELETE ERROR ==> $e");

      Get.snackbar("Error", e.toString());
    } finally {
      isDeleteLoading.value = false;
    }
  }


}