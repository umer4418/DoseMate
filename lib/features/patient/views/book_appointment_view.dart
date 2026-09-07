import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/utils/time_utils.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../models/user_model.dart';
import '../controllers/appointment_controller.dart';

class BookAppointmentView extends StatefulWidget {
  const BookAppointmentView({super.key});

  @override
  State<BookAppointmentView> createState() => _BookAppointmentViewState();
}

class _BookAppointmentViewState extends State<BookAppointmentView> {
  late final AppointmentController controller;
  AppUser? doctor;
  final notes = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller = Get.find<AppointmentController>();
    final args = Get.arguments;
    if (args is AppUser) doctor = args;
  }

  @override
  void dispose() {
    notes.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final selected = doctor;
    if (selected == null) {
      Get.snackbar('Choose a doctor', 'Select who you want to book with.');
      return;
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );
    if (picked == null) return;
    if (!controller.isWorkingDay(selected, picked)) {
      Get.snackbar(
        'Not a working day',
        '${selected.name} is not available on ${TimeUtils.weekdayName(picked)}.',
      );
      return;
    }
    await controller.loadSlots(selected, picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book appointment')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Doctor', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Obx(() {
            final doctors = controller.doctors;
            final selectedUid = doctor?.uid;
            return DropdownButtonFormField<String>(
              key: ValueKey('${doctors.length}-${selectedUid ?? 'none'}'),
              initialValue: doctors.any((d) => d.uid == selectedUid) ? selectedUid : null,
              items: doctors
                  .map(
                    (d) => DropdownMenuItem(
                      value: d.uid,
                      child: Text(
                        '${d.name} · ${d.specialization.isEmpty ? 'General' : d.specialization}',
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (uid) {
                setState(() {
                  doctor = doctors.firstWhereOrNull((d) => d.uid == uid);
                });
                controller.availableSlots.clear();
                controller.selectedDate.value = null;
              },
              decoration: const InputDecoration(
                hintText: 'Select a doctor',
                filled: true,
                fillColor: Colors.white,
              ),
            );
          }),
          const SizedBox(height: 16),
          if (doctor != null) ...[
            Text(
              doctor!.isAvailable
                  ? 'Accepting bookings'
                  : 'This doctor is not accepting bookings',
              style: TextStyle(
                color: doctor!.isAvailable ? AppColors.success : AppColors.danger,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text('Working days: ${doctor!.workingDays.join(', ')}'),
            Text('Hours: ${doctor!.startTime} – ${doctor!.endTime}'),
          ],
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _pickDate,
            icon: const Icon(Icons.calendar_month_outlined),
            label: Obx(() {
              final date = controller.selectedDate.value;
              return Text(
                date == null ? 'Choose date' : TimeUtils.prettyDate(date),
              );
            }),
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: notes,
            hint: 'Reason / notes (optional)',
            icon: Icons.notes_outlined,
          ),
          const SizedBox(height: 18),
          const Text('Available slots', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Obx(() {
            if (controller.loadingSlots.value) {
              return const Center(child: CircularProgressIndicator());
            }
            if (controller.selectedDate.value == null) {
              return const Text('Pick a working day to see open times.');
            }
            if (controller.availableSlots.isEmpty) {
              return const Text('No open slots on this date.');
            }
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: controller.availableSlots.map((slot) {
                return ActionChip(
                  label: Text(slot),
                  onPressed: () => controller.book(
                    doctor: doctor!,
                    time: slot,
                    notes: notes.text,
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }
}
