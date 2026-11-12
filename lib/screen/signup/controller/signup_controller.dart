import 'dart:convert';
import 'package:alo_ride_driver_app/screen/login/view/login_screen.dart';
import 'package:alo_ride_driver_app/screen/signup/model/vehicle_types_model.dart';
import 'package:alo_ride_driver_app/services/token_store.dart' show AuthController;
import 'package:http/http.dart' as http;
import 'package:alo_ride_driver_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';

class SignupController extends GetxController {
  final AuthController authController = Get.put(AuthController());

  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final vehicleNumberCtrl = TextEditingController();

  /// New Expiry Date Controllers
  final vehicleExpireDateCtrl = TextEditingController();
  final insuranceExpireDateCtrl = TextEditingController();
  final licenceExpireDateCtrl = TextEditingController();

  /// Internal variables to store API-friendly format (yyyy-mm-dd)
  String vehicleExpireDateApi = "";
  String insuranceExpireDateApi = "";
  String licenceExpireDateApi = "";

  RxString selectedCountryCode = "+1".obs;   // 🇨🇦 Canada
  RxString selectedCountryFlag = "CA".obs;


  /// Uploaded files
  Rx<File?> profileImage = Rx<File?>(null);
  Rx<File?> licenseFront = Rx<File?>(null);
  Rx<File?> licenseBack = Rx<File?>(null);
  Rx<File?> vehicleRc = Rx<File?>(null);
  Rx<File?> insurance = Rx<File?>(null);
  Rx<File?> numberPlate = Rx<File?>(null);

  bool areAllDocumentsUploaded() {
    if (profileImage.value == null) return false;
    if (licenseFront.value == null) return false;
    if (licenseBack.value == null) return false;
    if (vehicleRc.value == null) return false;
    if (insurance.value == null) return false;
    if (numberPlate.value == null) return false;

    /// Also check for expiry dates
    if (vehicleExpireDateCtrl.text.isEmpty) return false;
    if (insuranceExpireDateCtrl.text.isEmpty) return false;
    if (licenceExpireDateCtrl.text.isEmpty) return false;

    return true;
  }


  final ImagePicker _picker = ImagePicker();

  /// Pick image from camera/gallery
  Future<File?> pickImage() async {
    final XFile? picked =
    await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      return File(picked.path);
    }
    return null;
  }

  /// Pick document (PDF / image)
  Future<File?> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );
    if (result != null && result.files.single.path != null) {
      return File(result.files.single.path!);
    }
    return null;
  }

  /// Select Date Picker
  Future<void> selectDate(BuildContext context, TextEditingController controller, String type) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      // Formats date as dd-MM-yyyy for UI
      controller.text = DateFormat('dd-MM-yyyy').format(picked);

      // Store in API format (yyyy-MM-dd)
      String apiFormat = DateFormat('yyyy-MM-dd').format(picked);
      if (type == "vehicle") {
        vehicleExpireDateApi = apiFormat;
      } else if (type == "insurance") {
        insuranceExpireDateApi = apiFormat;
      } else if (type == "licence") {
        licenceExpireDateApi = apiFormat;
      }
    }
  }

  RxBool isRegisterDriver = false.obs;
  RxBool isVehicleTypes = false.obs;
  RxInt selectedVehicleTypeId = 0.obs;



  Rx<GetVehicleTypesModel> getVehicleTypesModel = GetVehicleTypesModel().obs;
  Future<void> getVehicleTypes() async {
    try {
      isVehicleTypes.value = true;

      final response = await ApiService.get1(endpoint: "${ApiService.userBaseUrl}vehicle-types",useBaseUrl: false, isShow: false);

      // Convert the entire response to GetPackageModel (not each item)
      final vehicleTypes = GetVehicleTypesModel.fromJson(response);

      // Store the single GetPackageModel instance
      getVehicleTypesModel.value = vehicleTypes;
      debugPrint("length ==> ${getVehicleTypesModel.value.data?.length}");
    } catch (e) {
      print('Error fetching packages: $e');
    } finally {
      isVehicleTypes.value = false;
    }
  }

  Future<void> registerDriver() async {
    isRegisterDriver.value = true;
    try {
      final uri = Uri.parse("${ApiService.baseUrl}register2");
      final request = http.MultipartRequest("POST", uri);

      /// 🔹 HEADERS
      request.headers.addAll({
        "Accept": "application/json",
      });

      /// 🔹 TEXT FIELDS (MATCH POSTMAN)
      request.fields.addAll({
        "name": nameCtrl.text.trim(),
        "email": emailCtrl.text.trim(),
        "mobile": phoneCtrl.text.trim(),
        "vehicle_number": vehicleNumberCtrl.text,
        "vehicle_type_id": selectedVehicleTypeId.value.toString(),
        "country_code": selectedCountryCode.value,
        "vehicle_expire_date": vehicleExpireDateApi,
        "insurance_expire_date": insuranceExpireDateApi,
        "licence_expire_date": licenceExpireDateApi,
      });

      /// 🔹 FILES (MATCH POSTMAN KEYS)
      if (profileImage.value != null) {
        final file = profileImage.value!;
        final length = await file.length();
        debugPrint("profile_photo size: ${length / 1024} KB");

        request.files.add(await http.MultipartFile.fromPath(
          "profile_photo",
          profileImage.value!.path,
        ));
      }

      if (licenseFront.value != null) {
        final file = licenseFront.value!;
        final length = await file.length();
        debugPrint("driving_license_front size: ${length / 1024} KB");

        request.files.add(await http.MultipartFile.fromPath(
          "driving_license_front",
          licenseFront.value!.path,
        ));
      }
      if (vehicleRc.value != null) {

        final file = vehicleRc.value!;
        final length = await file.length();
        debugPrint("vehicle_registration size: ${length / 1024} KB");

        request.files.add(await http.MultipartFile.fromPath(
          "vehicle_registration",
          vehicleRc.value!.path,
        ));
      }

      if (licenseBack.value != null) {

        final file = licenseBack.value!;
        final length = await file.length();
        debugPrint("driving_license_back size: ${length / 1024} KB");

        request.files.add(await http.MultipartFile.fromPath(
          "driving_license_back",
          licenseBack.value!.path,
        ));
      }

      if (insurance.value != null) {

        final file = insurance.value!;
        final length = await file.length();
        debugPrint("vehicle_insurance size: ${length / 1024} KB");

        request.files.add(await http.MultipartFile.fromPath(
          "vehicle_insurance",
          insurance.value!.path,
        ));
      }

      if (numberPlate.value != null) {

        final file = numberPlate.value!;
        final length = await file.length();
        debugPrint("number_plate_photo size: ${length / 1024} KB");

        request.files.add(await http.MultipartFile.fromPath(
          "number_plate_photo",
          numberPlate.value!.path,
        ));
      }

      /// 🔥 PRINT REQUEST
      debugPrint("━━━━━━━━ REGISTER DRIVER ━━━━━━━━");
      debugPrint("URL     : ${request.url}");
      debugPrint("FIELDS  : ${request.fields}");
      debugPrint("FILES   :");
      for (var f in request.files) {
        debugPrint(" - ${f.field} → ${f.filename}");
      }

      /// 🔹 SEND REQUEST
      final streamedResponse = await request.send();
      final responseBody = await streamedResponse.stream.bytesToString();

      /// 🔥 PRINT RESPONSE
      debugPrint("STATUS  : ${streamedResponse.statusCode}");
      debugPrint("BODY    : $responseBody");
      debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

      final decoded = json.decode(responseBody);

      if (streamedResponse.statusCode == 200 ||
          streamedResponse.statusCode == 201) {
        if (decoded['success'] == true) {
          Get.snackbar("Success", decoded['message']);
          Get.to(()=> LoginScreen());
        } else {
          Get.snackbar("Error", decoded['message'] ?? "Something went wrong");
        }
      } else {
        Get.snackbar("Error", decoded['message'] ?? "Server Error");
      }

    } catch (e, stack) {
      /// ❌ FULL ERROR PRINT
      debugPrint("❌ REGISTER ERROR");
      debugPrint(e.toString());
      debugPrint(stack.toString());

      Get.snackbar("Error", e.toString());
    } finally {
      isRegisterDriver.value = false;
    }
  }

}
