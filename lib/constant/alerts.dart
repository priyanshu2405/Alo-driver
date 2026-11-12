import 'package:flutter/material.dart';
import 'package:get/get.dart';


void showSuccessMessage({
  required BuildContext context,
  required String title,
  required String content,
}) {
  Get.closeAllSnackbars();
  Get.snackbar(
    title,
    content,
    snackPosition: SnackPosition.TOP,
    backgroundColor: Colors.green,
    colorText: Colors.white,
    margin: const EdgeInsets.all(12),
    borderRadius: 8,
    duration: const Duration(seconds: 3),
  );
  /*ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(AlertMessage(
    title: title,
    description: content,
    backgroundColor: context.appColor.success.withValues(alpha: 0.8),
    foregroundColor: context.colorScheme.surface,
    duration: const Duration(seconds: 3),
  ));*/
}

void showErrorMessage({
  required BuildContext context,
  required String title,
  required String content,
}) {
  Get.closeAllSnackbars();
  Get.snackbar(
    title,
    content,
    snackPosition: SnackPosition.TOP,
    backgroundColor: Colors.red,
    colorText: Colors.white,
    margin: const EdgeInsets.all(12),
    borderRadius: 8,
    duration: const Duration(seconds: 3),
  );
  /* ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(
    AlertMessage(
      title: title,
      description: content,
      backgroundColor: context.appColor.failure,
      foregroundColor: context.colorScheme.surface,
      duration: const Duration(seconds: 3),
    ),
  );*/
}
