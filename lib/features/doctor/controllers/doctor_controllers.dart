import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/utils/time_utils.dart';
import '../../../models/appointment_model.dart';
import '../../../models/user_model.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../patient/controllers/appointment_controller.dart';

class DoctorHomeController extends GetxController {
  final tabIndex = 0.obs;

  AppUser? get user => Get.find<AuthController>().currentUser.value;

  List<AppointmentModel> get upcoming {
    final items = Get.find<AppointmentController>().doctorAppointments;
    return items.where((a) => a.status == 'pending' || a.status == 'confirmed').toList();
  }
}

class AvailabilityController extends GetxController {
  final selectedDays = <String>[].obs;
  final startTime = ''.obs;
  final endTime = ''.obs;
  final isAvailable = true.obs;
  final saving = false.obs;

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
    final user = Get.find<AuthController>().currentUser.value;
    if (user != null) {
      selectedDays.assignAll(user.workingDays);
      startTime.value = user.startTime;
      endTime.value = user.endTime;
      isAvailable.value = user.isAvailable;
    }
  }

  void toggleDay(String day) {
    if (selectedDays.contains(day)) {
      selectedDays.remove(day);
    } else {
      selectedDays.add(day);
    }
  }

  Future<void> pickStart(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeUtils.parseTime(startTime.value) ?? const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null) startTime.value = TimeUtils.formatTimeOfDay(picked);
  }

  Future<void> pickEnd(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeUtils.parseTime(endTime.value) ?? const TimeOfDay(hour: 17, minute: 0),
    );
    if (picked != null) endTime.value = TimeUtils.formatTimeOfDay(picked);
  }

  Future<void> save() async {
    final auth = Get.find<AuthController>();
    final user = auth.currentUser.value;
    if (user == null) return;
    saving.value = true;
    try {
      await Get.find<AuthService>().updateUser(user.uid, {
        'workingDays': selectedDays.toList(),
        'startTime': startTime.value,
        'endTime': endTime.value,
        'isAvailable': isAvailable.value,
      });
      auth.currentUser.value = user.copyWith(
        workingDays: selectedDays.toList(),
        startTime: startTime.value,
        endTime: endTime.value,
        isAvailable: isAvailable.value,
      );
      Get.snackbar('Updated', 'Your booking availability was saved.');
    } finally {
      saving.value = false;
    }
  }
}
