import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../../../core/services/data_service.dart';
import '../../../core/utils/time_utils.dart';
import '../../../models/reminder_model.dart';
import '../../auth/controllers/auth_controller.dart';

class ReminderController extends GetxController {
  final DataService dataService;
  ReminderController({required this.dataService});

  final reminders = <ReminderModel>[].obs;
  final selectedDays = <String>[].obs;
  final times = <String>[].obs;

  final days = const [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  void onInit() {
    super.onInit();
    final uid = Get.find<AuthController>().currentUser.value?.uid;
    if (uid != null) {
      reminders.bindStream(dataService.remindersStream(uid));
    }
  }

  void toggleDay(String day) {
    if (selectedDays.contains(day)) {
      selectedDays.remove(day);
    } else {
      selectedDays.add(day);
    }
  }

  Future<void> addTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 8, minute: 0),
    );
    if (picked != null) {
      times.add(TimeUtils.formatTimeOfDay(picked));
    }
  }

  Future<void> save({
    required String medicine,
    required String dosage,
    required String notes,
  }) async {
    final uid = Get.find<AuthController>().currentUser.value?.uid;
    if (uid == null) return;
    if (medicine.trim().isEmpty || dosage.trim().isEmpty) {
      Get.snackbar('Missing details', 'Enter medicine name and dosage.');
      return;
    }
    if (times.isEmpty) {
      Get.snackbar('Time needed', 'Add at least one reminder time.');
      return;
    }
    if (selectedDays.isEmpty) {
      Get.snackbar('Days needed', 'Choose the days you take this medicine.');
      return;
    }

    await dataService.addReminder(
      ReminderModel(
        id: const Uuid().v4(),
        userId: uid,
        medicineName: medicine.trim(),
        dosage: dosage.trim(),
        times: times.toList(),
        days: selectedDays.toList(),
        notes: notes.trim(),
      ),
    );
    Get.back();
    Get.snackbar('Saved', 'Medicine reminder added.');
  }

  Future<void> remove(String id) => dataService.deleteReminder(id);
}
