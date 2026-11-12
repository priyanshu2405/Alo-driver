// import 'package:diy_exit/services/api_service.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart' hide Trans;
// import 'package:easy_localization/easy_localization.dart';
// import 'package:get_storage/get_storage.dart';
//
// class LanguageController extends GetxController {
//   final GetStorage _storage = GetStorage();
//   static const String _localeKey = 'saved_locale';
//   var isSwitchLanguage = false.obs;
//   Rx<Locale> currentLocale = const Locale('en', 'US').obs;
//
//   @override
//   void onInit() {
//     super.onInit();
//     _loadSavedLocale();
//   }
//
//   void _loadSavedLocale() {
//     final savedLocaleCode = _storage.read(_localeKey);
//     if (savedLocaleCode != null) {
//       final parts = savedLocaleCode.split('_');
//       if (parts.length == 2) {
//         currentLocale.value = Locale(parts[0], parts[1]);
//       }
//     }
//   }
//
//   Future<void> changeLanguage(
//     BuildContext context,
//     Locale locale, {
//     bool? screenCheck,
//   }) async {
//     try {
//       // Update the observable
//       currentLocale.value = locale;
//
//       // Save to storage for persistence
//       await _storage.write(
//         _localeKey,
//         '${locale.languageCode}_${locale.countryCode}',
//       );
//
//       // Update EasyLocalization
//       await context.setLocale(locale);
//
//       // Update GetX locale
//       Get.updateLocale(locale);
//       debugPrint("currentLocale : ${currentLocale.value.languageCode}");
//
//       if (screenCheck == true) {
//         checkCompany(language: currentLocale.value.languageCode);
//       }
//
//       // Force rebuild of GetBuilder
//       update();
//
//       debugPrint(
//         'Language changed to: ${locale.languageCode}_${locale.countryCode}',
//       );
//     } catch (e) {
//       debugPrint('Error changing language: $e');
//     }
//   }
//
//   Future<void> checkCompany({String? language}) async {
//     isSwitchLanguage.value = true; // Start loading
//
//     try {
//       var body = {"language": language};
//       debugPrint("body : $body");
//       final response = await ApiService.post(
//         endpoint: 'switch-language',
//         body: body,
//         isShow: true,
//       );
//       print("response : $response");
//
//       if (response['status'] == true) {
//         print("message : ${response['message']}");
//       }
//     } catch (e) {
//       print("Error in checkCompany: $e");
//       Get.snackbar(
//         "error".tr(),
//         "$e",
//         snackPosition: SnackPosition.TOP,
//         backgroundColor: Colors.red.withOpacity(0.8),
//         colorText: Colors.white,
//       );
//     } finally {
//       isSwitchLanguage.value = false; // Stop loading in all cases
//     }
//   }
// }
