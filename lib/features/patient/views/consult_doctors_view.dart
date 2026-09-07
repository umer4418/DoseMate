import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../models/user_model.dart';
import '../../chat/controllers/chat_list_controller.dart';
import '../controllers/appointment_controller.dart';

class ConsultDoctorsView extends GetView<AppointmentController> {
  const ConsultDoctorsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Consult a doctor')),
      body: Obx(() {
        final doctors = controller.doctors;
        if (doctors.isEmpty) {
          return const EmptyState(
            icon: Icons.medical_services_outlined,
            title: 'No doctors yet',
            subtitle: 'When doctors join DoseMate they will appear here.',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          itemCount: doctors.length,
          itemBuilder: (context, index) {
            final doctor = doctors[index];
            return _DoctorCard(doctor: doctor);
          },
        );
      }),
    );
  }
}

class _DoctorCard extends StatelessWidget {
  const _DoctorCard({required this.doctor});

  final AppUser doctor;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                UserAvatar(user: doctor, radius: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        doctor.specialization.isEmpty
                            ? 'General physician'
                            : doctor.specialization,
                        style: const TextStyle(color: AppColors.secondaryText),
                      ),
                      Text(
                        doctor.hospitalClinic,
                        style: const TextStyle(color: AppColors.secondaryText, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (doctor.isAvailable ? AppColors.success : AppColors.danger)
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    doctor.isAvailable ? 'Available' : 'Offline',
                    style: TextStyle(
                      color: doctor.isAvailable ? AppColors.success : AppColors.danger,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Hours: ${doctor.startTime.isEmpty ? '--' : doctor.startTime} – ${doctor.endTime.isEmpty ? '--' : doctor.endTime}',
              style: const TextStyle(fontSize: 13),
            ),
            Text(
              'Days: ${doctor.workingDays.isEmpty ? 'Not set' : doctor.workingDays.map((d) => d.substring(0, 3)).join(', ')}',
              style: const TextStyle(fontSize: 13),
            ),
            if (doctor.consultationFee.isNotEmpty)
              Text('Fee: ${doctor.consultationFee}', style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.find<ChatListController>().openChat(doctor),
                    child: const Text('Chat'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: doctor.isAvailable
                        ? () => Get.toNamed(
                              AppRoutes.bookAppointment,
                              arguments: doctor,
                            )
                        : null,
                    child: const Text('Book'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
