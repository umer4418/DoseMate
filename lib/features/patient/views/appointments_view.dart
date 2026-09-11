import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/widgets/app_widgets.dart';
import '../../chat/controllers/chat_list_controller.dart';
import '../controllers/appointment_controller.dart';

class AppointmentsView extends GetView<AppointmentController> {
  const AppointmentsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My appointments')),
      body: Obx(() {
        final items = [...controller.myAppointments]
          ..sort((a, b) => '${b.date}${b.time}'.compareTo('${a.date}${a.time}'));
        if (items.isEmpty) {
          return const EmptyState(
            icon: Icons.event_busy_outlined,
            title: 'No bookings yet',
            subtitle: 'Book an appointment from Consult to see it here.',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(
                  item.doctorName,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text(
                  '${item.specialization}\n${item.date} · ${item.time}',
                ),
                isThreeLine: true,
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    StatusChip(status: item.status),
                    if (item.status == 'confirmed')
                      TextButton(
                        onPressed: () {
                          final doctor = controller.doctors.firstWhereOrNull(
                            (d) => d.uid == item.doctorId,
                          );
                          if (doctor != null) {
                            Get.find<ChatListController>().openChat(doctor);
                          }
                        },
                        child: const Text('Chat'),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
