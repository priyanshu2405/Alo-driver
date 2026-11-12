import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class BookingController extends GetxController {
  RxInt selectValue = 0.obs;

  Rxn<DateTime> selectedDate = Rxn<DateTime>();
  Rxn<DateTime> selectedTime = Rxn<DateTime>();

  String get formattedDate => selectedDate.value == null
      ? "Select Date"
      : DateFormat("dd MMM yyyy").format(selectedDate.value!);

  String get formattedTime => selectedTime.value == null
      ? "Select Time"
      : DateFormat("hh:mm a").format(selectedTime.value!);

  Future<void> pickDate(BuildContext context) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      selectedDate.value = date;
    }
  }

  Future<void> pickTime(BuildContext context) async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null) {
      final now = DateTime.now();
      selectedTime.value = DateTime(
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );
    }
  }

}
