import 'dart:io';

import 'package:alo_ride_driver_app/res/common/app_appbar.dart';
import 'package:alo_ride_driver_app/res/common/app_button.dart';
import 'package:alo_ride_driver_app/res/common/app_image.dart';
import 'package:alo_ride_driver_app/res/common/app_text.dart';
import 'package:alo_ride_driver_app/res/common/common_text_field.dart';
import 'package:alo_ride_driver_app/res/constant/app_colors.dart';
import 'package:alo_ride_driver_app/res/constant/app_images.dart';
import 'package:alo_ride_driver_app/screen/login/view/login_screen.dart';
import 'package:alo_ride_driver_app/screen/signup/controller/signup_controller.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:alo_ride_driver_app/res/utils/app_responsive.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final SignupController signupController = Get.put(SignupController());

  @override
  void initState() {
    super.initState();

    /// ✅ Call API AFTER first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      signupController.getVehicleTypes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Form(
            key: _formKey, // ✅ ONLY ONE FORM KEY
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Gap(10.h),

                /// 🔹 TITLE
                AppText(
                  text: "Sign up",
                  fontSize: 16,
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w500,
                ),

                Gap(20.h),

                /// 🔹 LOGO
                Center(
                  child: AppImage(
                    image: AppImages.loginLogo,
                    imageType: ImageType.svgAsset,
                    height: 146.h,
                    width: 219.w,
                  ),
                ),

                Gap(20.h),

                AppText(
                  text: "Let's Drive with Alo Drive",
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),

                Gap(20.h),

                /// 🔹 NAME
                AppText(text: "Your Name"),
                Gap(6.h),
                CommonTextField(
                  controller: signupController.nameCtrl,
                  hintText: "Enter your name",
                  validator: (v) =>
                  v == null || v.isEmpty ? "Name is required" : null,
                ),

                Gap(20.h),

                /// 🔹 EMAIL
                AppText(text: "Email"),
                Gap(6.h),
                CommonTextField(
                  controller: signupController.emailCtrl,
                  hintText: "Enter your email",
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Email is required";
                    if (!v.contains("@")) return "Enter valid email";
                    return null;
                  },
                ),

                Gap(20.h),

                /// 🔹 PHONE + COUNTRY PICKER
                AppText(text: "Mobile number"),
                Gap(6.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() {
                      return InkWell(
                        onTap: () {
                          showCountryPicker(
                            context: context,
                            showPhoneCode: true,
                            onSelect: (country) {
                              signupController.selectedCountryCode.value =
                              "+${country.phoneCode}";
                              signupController.selectedCountryFlag.value =
                                  country.flagEmoji;
                            },
                          );
                        },
                        child: Container(
                          height: 50,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.borderColor),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 4),
                              Text(
                                signupController.selectedCountryCode.value,
                              ),
                              const Icon(Icons.arrow_drop_down),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CommonTextField(
                        controller: signupController.phoneCtrl,
                        hintText: "Mobile number",
                        keyboardType: TextInputType.phone,

                        inputFormatters: [
                        //  FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(15),
                        ],
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return "Mobile number is required";
                          }
                          if (v.length < 7) {
                            return "Enter valid mobile number";
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),

                Gap(20.h),

                /// 🔹 VEHICLE NUMBER
                AppText(text: "Vehicle Number"),
                Gap(6.h),
                CommonTextField(
                  controller: signupController.vehicleNumberCtrl,
                  hintText: "Enter vehicle number",
                  validator: (v) =>
                  v == null || v.isEmpty ? "Vehicle number required" : null,
                ),

                Gap(20.h),

                /// 🔹 VEHICLE TYPE DROPDOWN
                Obx(() {
                  if (signupController.isVehicleTypes.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final list =
                      signupController.getVehicleTypesModel.value.data;

                  if (list == null || list.isEmpty) {
                    return const Text("No vehicle types available");
                  }

                  return DropdownButtonFormField<int>(
                    value:
                    signupController.selectedVehicleTypeId.value == 0
                        ? null
                        : signupController.selectedVehicleTypeId.value,
                    decoration: const InputDecoration(
                      labelText: "Vehicle Type",
                      border: OutlineInputBorder(),
                    ),
                    items: list.map((v) {
                      return DropdownMenuItem<int>(
                        value: v.id,
                        child: Text("${v.name}"),
                      );
                    }).toList(),
                    onChanged: (val) {
                      signupController.selectedVehicleTypeId.value = val!;
                    },
                    validator: (val) =>
                    val == null ? "Select vehicle type" : null,
                  );
                }),

                Gap(20.h),

                /// 📅 EXPIRY DATES
                AppText(text: "Vehicle Expire Date"),
                Gap(6.h),
                CommonTextField(
                  controller: signupController.vehicleExpireDateCtrl,
                  hintText: "dd-mm-yyyy",
                  readOnly: true,
                  onTap: () => signupController.selectDate(context, signupController.vehicleExpireDateCtrl, "vehicle"),
                  validator: (v) => v == null || v.isEmpty ? "Vehicle expire date is required" : null,
                  suffixIcon: const Icon(Icons.calendar_today, size: 20),
                ),

                Gap(20.h),

                AppText(text: "Insurance Expire Date"),
                Gap(6.h),
                CommonTextField(
                  controller: signupController.insuranceExpireDateCtrl,
                  hintText: "dd-mm-yyyy",
                  readOnly: true,
                  onTap: () => signupController.selectDate(context, signupController.insuranceExpireDateCtrl, "insurance"),
                  validator: (v) => v == null || v.isEmpty ? "Insurance expire date is required" : null,
                  suffixIcon: const Icon(Icons.calendar_today, size: 20),
                ),

                Gap(20.h),

                AppText(text: "Licence Expire Date"),
                Gap(6.h),
                CommonTextField(
                  controller: signupController.licenceExpireDateCtrl,
                  hintText: "dd-mm-yyyy",
                  readOnly: true,
                  onTap: () => signupController.selectDate(context, signupController.licenceExpireDateCtrl, "licence"),
                  validator: (v) => v == null || v.isEmpty ? "Licence expire date is required" : null,
                  suffixIcon: const Icon(Icons.calendar_today, size: 20),
                ),

                Gap(20.h),

                /// 🔹 UPLOAD DOCUMENTS
                AppText(
                  text: "Upload Documents",
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondary,
                ),

                Gap(12.h),

                _uploadTile(
                  text: "Add Profile Picture",
                  file: signupController.profileImage,
                  onTap: () async {
                    final f = await signupController.pickImage();
                    if (f != null) signupController.profileImage.value = f;
                  },
                ),
                _uploadTile(
                  text: "Add Driving License Front",
                  file: signupController.licenseFront,
                  onTap: () async {
                    final f = await signupController.pickImage();
                    if (f != null) signupController.licenseFront.value = f;
                  },
                ),
                _uploadTile(
                  text: "Add Driving License Back",
                  file: signupController.licenseBack,
                  onTap: () async {
                    final f = await signupController.pickImage();
                    if (f != null) signupController.licenseBack.value = f;
                  },
                ),
                _uploadTile(
                  text: "Add Vehicle Registration",
                  file: signupController.vehicleRc,
                  onTap: () async {
                    final f = await signupController.pickFile();
                    if (f != null) signupController.vehicleRc.value = f;
                  },
                ),
                _uploadTile(
                  text: "Add Vehicle Insurance",
                  file: signupController.insurance,
                  onTap: () async {
                    final f = await signupController.pickFile();
                    if (f != null) signupController.insurance.value = f;
                  },
                ),
                _uploadTile(
                  text: "Add Vehicle Number Plate",
                  file: signupController.numberPlate,
                  onTap: () async {
                    final f = await signupController.pickImage();
                    if (f != null) signupController.numberPlate.value = f;
                  },
                ),

                Gap(10.h),

                /// 🔹 SUBMIT
                Obx(() {
                  return AppButton(
                    isLoading:
                    signupController.isRegisterDriver.value,
                    text: "COMPLETE REGISTRATION",
                    onTap: () {
                      print(signupController.vehicleExpireDateApi);
                      print(signupController.insuranceExpireDateApi);
                      print(signupController.licenceExpireDateApi);
                      if (_formKey.currentState!.validate()) {
                        if (!signupController.areAllDocumentsUploaded()) {
                          Get.snackbar(
                            "Missing Information",
                            "Please upload all documents and select all expiry dates",
                            snackPosition: SnackPosition.TOP,
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                          return;
                        }

                        signupController.registerDriver();
                      }
                    },
                  );
                }),

                Gap(20.h),

                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppText(text: "Already have an account ?"),
                      InkWell(
                        onTap: () => Get.to(() => LoginScreen()),
                        child: AppText(
                          text: " Login",
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),

                Gap(30.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 🔹 UPLOAD TILE
  Widget _uploadTile({
    required String text,
    required Rx<File?> file,
    required VoidCallback onTap,
  }) {
    return Obx(() {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.only(bottom: 16.h),
          height: 52.h,
          padding: EdgeInsets.symmetric(horizontal: 14.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: file.value != null
                  ? AppColors.secondary
                  : AppColors.borderColor,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: AppText(
                  text: file.value == null
                      ? text
                      : file.value!.path.split('/').last,
                  color: file.value == null
                      ? AppColors.textColor
                      : AppColors.secondary,
                ),
              ),
              CircleAvatar(
                radius: 10,
                backgroundColor: AppColors.secondary,
                child: Icon(
                  file.value == null ? Icons.add : Icons.check,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
