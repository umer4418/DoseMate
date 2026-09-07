import 'package:get/get.dart';

import '../../../core/services/data_service.dart';
import '../../../core/utils/time_utils.dart';
import '../../../models/appointment_model.dart';
import '../../../models/user_model.dart';
import '../../auth/controllers/auth_controller.dart';

class AppointmentController extends GetxController {
  final DataService dataService;
  AppointmentController({required this.dataService});

  final doctors = <AppUser>[].obs;
  final selectedDate = Rxn<DateTime>();
  final availableSlots = <String>[].obs;
  final bookedTimes = <String>[].obs;
  final loadingSlots = false.obs;
  final myAppointments = <AppointmentModel>[].obs;
  final doctorAppointments = <AppointmentModel>[].obs;

  AppUser? get me => Get.find<AuthController>().currentUser.value;

  @override
  void onInit() {
    super.onInit();
    doctors.bindStream(dataService.doctorsStream());
    final user = me;
    if (user == null) return;
    if (user.isPatient) {
      myAppointments.bindStream(dataService.patientAppointments(user.uid));
    } else {
      doctorAppointments.bindStream(dataService.doctorAppointments(user.uid));
    }
  }

  bool isWorkingDay(AppUser doctor, DateTime date) {
    return doctor.workingDays.contains(TimeUtils.weekdayName(date));
  }

  Future<void> loadSlots(AppUser doctor, DateTime date) async {
    selectedDate.value = date;
    loadingSlots.value = true;
    try {
      final booked = await dataService.bookedSlots(
        doctorId: doctor.uid,
        date: TimeUtils.dateKey(date),
      );
      bookedTimes.assignAll(booked.map((e) => e.time));
      final all = TimeUtils.generateSlots(
        startTime: doctor.startTime,
        endTime: doctor.endTime,
      );
      availableSlots.assignAll(
        all.where((slot) => !bookedTimes.contains(slot)).toList(),
      );
    } finally {
      loadingSlots.value = false;
    }
  }

  Future<void> book({
    required AppUser doctor,
    required String time,
    String notes = '',
  }) async {
    final patient = me;
    final date = selectedDate.value;
    if (patient == null || date == null) return;
    if (!doctor.isAvailable) {
      Get.snackbar('Unavailable', 'This doctor is not accepting bookings.');
      return;
    }

    await dataService.bookAppointment(
      AppointmentModel(
        id: '',
        patientId: patient.uid,
        patientName: patient.name,
        doctorId: doctor.uid,
        doctorName: doctor.name,
        specialization: doctor.specialization,
        date: TimeUtils.dateKey(date),
        time: time,
        notes: notes,
      ),
    );
    Get.back();
    Get.snackbar('Requested', 'Appointment request sent to ${doctor.name}.');
  }

  Future<void> updateStatus(String id, String status) {
    return dataService.updateAppointmentStatus(id, status);
  }
}
