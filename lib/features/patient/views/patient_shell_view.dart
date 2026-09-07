import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/time_utils.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../chat/views/people_chat_view.dart';
import '../controllers/patient_home_controller.dart';
import '../controllers/reminder_controller.dart';
import 'appointments_view.dart';
import 'consult_doctors_view.dart';
import 'reminders_view.dart';

class PatientShellView extends GetView<PatientHomeController> {
  const PatientShellView({super.key});

  @override
  Widget build(BuildContext context) {
    final pages = const [
      PatientHomeTab(),
      RemindersView(),
      ConsultDoctorsView(),
      PeopleChatView(mode: ChatPeopleMode.mixed),
      AppointmentsView(),
    ];

    return Obx(
      () => Scaffold(
        body: IndexedStack(
          index: controller.tabIndex.value,
          children: pages,
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: controller.tabIndex.value,
          onDestinationSelected: (i) => controller.tabIndex.value = i,
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.medication_outlined), selectedIcon: Icon(Icons.medication), label: 'Doses'),
            NavigationDestination(icon: Icon(Icons.medical_services_outlined), selectedIcon: Icon(Icons.medical_services), label: 'Consult'),
            NavigationDestination(icon: Icon(Icons.chat_bubble_outline), selectedIcon: Icon(Icons.chat_bubble), label: 'Chat'),
            NavigationDestination(icon: Icon(Icons.event_outlined), selectedIcon: Icon(Icons.event), label: 'Bookings'),
          ],
        ),
      ),
    );
  }
}

class PatientHomeTab extends GetView<PatientHomeController> {
  const PatientHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          Obx(() {
            final user = auth.currentUser.value;
            return Row(
              children: [
                UserAvatar(user: user, radius: 26),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.greeting(),
                        style: const TextStyle(color: AppColors.secondaryText),
                      ),
                      Text(
                        user?.name ?? 'Patient',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkText,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: auth.logout,
                  icon: const Icon(Icons.logout_rounded),
                ),
              ],
            );
          }),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Obx(() {
              final count = controller.todaysReminders.length;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Today’s medicines',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    count == 0 ? 'No doses scheduled' : '$count reminder${count == 1 ? '' : 's'}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    TimeUtils.prettyDate(DateTime.now()),
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              );
            }),
          ),
          const SizedBox(height: 22),
          const Text(
            'Quick actions',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
          ),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.35,
            children: [
              _ActionCard(
                icon: Icons.medical_services_outlined,
                title: 'Consult doctor',
                onTap: () => controller.tabIndex.value = 2,
              ),
              _ActionCard(
                icon: Icons.event_available_outlined,
                title: 'Book appointment',
                onTap: () => Get.toNamed(AppRoutes.bookAppointment),
              ),
              _ActionCard(
                icon: Icons.forum_outlined,
                title: 'Live chat',
                onTap: () => controller.tabIndex.value = 3,
              ),
              _ActionCard(
                icon: Icons.chat_outlined,
                title: 'Chat with doctor',
                onTap: () => controller.tabIndex.value = 2,
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Upcoming doses',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                ),
              ),
              TextButton(
                onPressed: () {
                  Get.find<ReminderController>();
                  controller.tabIndex.value = 1;
                },
                child: const Text('See all'),
              ),
            ],
          ),
          Obx(() {
            final items = controller.todaysReminders;
            if (items.isEmpty) {
              return const EmptyState(
                icon: Icons.medication_outlined,
                title: 'No reminders yet',
                subtitle: 'Add a medicine reminder so DoseMate can keep you on track.',
              );
            }
            return Column(
              children: items.take(5).map((reminder) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    title: Text(reminder.medicineName, style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text('${reminder.dosage} · ${reminder.times.join(', ')}'),
                    trailing: TextButton(
                      onPressed: () => controller.markTaken(reminder),
                      child: const Text('Taken'),
                    ),
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

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppColors.primary, size: 28),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.darkText),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
