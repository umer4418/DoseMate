import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../chat/views/people_chat_view.dart';
import '../../patient/controllers/appointment_controller.dart';
import '../controllers/doctor_controllers.dart';

class DoctorShellView extends GetView<DoctorHomeController> {
  const DoctorShellView({super.key});

  @override
  Widget build(BuildContext context) {
    final pages = const [
      DoctorHomeTab(),
      DoctorBookingsView(),
      AvailabilityView(),
      PeopleChatView(mode: ChatPeopleMode.mixed),
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
            NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.event_note_outlined), selectedIcon: Icon(Icons.event_note), label: 'Bookings'),
            NavigationDestination(icon: Icon(Icons.schedule_outlined), selectedIcon: Icon(Icons.schedule), label: 'Availability'),
            NavigationDestination(icon: Icon(Icons.chat_outlined), selectedIcon: Icon(Icons.chat), label: 'Chats'),
          ],
        ),
      ),
    );
  }
}

class DoctorHomeTab extends GetView<DoctorHomeController> {
  const DoctorHomeTab({super.key});

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
                UserAvatar(user: user, radius: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Doctor portal', style: TextStyle(color: AppColors.secondaryText)),
                      Text(
                        user?.name ?? 'Doctor',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(user?.specialization ?? ''),
                    ],
                  ),
                ),
                IconButton(onPressed: auth.logout, icon: const Icon(Icons.logout_rounded)),
              ],
            );
          }),
          const SizedBox(height: 18),
          Obx(() {
            final user = auth.currentUser.value;
            return Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Booking status', style: TextStyle(color: Colors.white70)),
                        Text(
                          user?.isAvailable == true ? 'Open for appointments' : 'Not accepting bookings',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: user?.isAvailable ?? true,
                    onChanged: (value) {
                      Get.find<AvailabilityController>().isAvailable.value = value;
                      Get.find<AvailabilityController>().save();
                    },
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 22),
          const Text('Upcoming requests', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          const SizedBox(height: 8),
          Obx(() {
            final items = controller.upcoming;
            if (items.isEmpty) {
              return const EmptyState(
                icon: Icons.event_available_outlined,
                title: 'No upcoming bookings',
                subtitle: 'New patient requests will show here for you to confirm.',
              );
            }
            return Column(
              children: items.take(6).map((item) {
                return Card(
                  child: ListTile(
                    title: Text(item.patientName, style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text('${item.date} · ${item.time}'),
                    trailing: StatusChip(status: item.status),
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

class DoctorBookingsView extends GetView<AppointmentController> {
  const DoctorBookingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Appointment requests')),
      body: Obx(() {
        final items = [...controller.doctorAppointments]
          ..sort((a, b) => '${b.date}${b.time}'.compareTo('${a.date}${a.time}'));
        if (items.isEmpty) {
          return const EmptyState(
            icon: Icons.inbox_outlined,
            title: 'No appointments',
            subtitle: 'Patients will appear here when they book your open slots.',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.patientName,
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                          ),
                        ),
                        StatusChip(status: item.status),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text('${item.date} · ${item.time}'),
                    if (item.notes.isNotEmpty) Text('Notes: ${item.notes}'),
                    if (item.status == 'pending') ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => controller.updateStatus(item.id, 'rejected'),
                              child: const Text('Decline'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => controller.updateStatus(item.id, 'confirmed'),
                              child: const Text('Confirm'),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (item.status == 'confirmed')
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => controller.updateStatus(item.id, 'completed'),
                          child: const Text('Mark completed'),
                        ),
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

class AvailabilityView extends GetView<AvailabilityController> {
  const AvailabilityView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking availability')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Patients can only book slots on the days and hours you enable here. Confirmed or pending bookings occupy a slot so it cannot be double-booked.',
            style: TextStyle(color: AppColors.secondaryText),
          ),
          const SizedBox(height: 16),
          Obx(
            () => SwitchListTile(
              value: controller.isAvailable.value,
              title: const Text('Accept new bookings'),
              onChanged: (v) => controller.isAvailable.value = v,
            ),
          ),
          const SizedBox(height: 8),
          const Text('Working days', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Obx(
            () => Wrap(
              spacing: 8,
              children: controller.days.map((day) {
                final selected = controller.selectedDays.contains(day);
                return FilterChip(
                  label: Text(day.substring(0, 3)),
                  selected: selected,
                  onSelected: (_) => controller.toggleDay(day),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            tileColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Obx(() => Text('Start: ${controller.startTime.value.isEmpty ? 'Select' : controller.startTime.value}')),
            onTap: () => controller.pickStart(context),
          ),
          const SizedBox(height: 8),
          ListTile(
            tileColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Obx(() => Text('End: ${controller.endTime.value.isEmpty ? 'Select' : controller.endTime.value}')),
            onTap: () => controller.pickEnd(context),
          ),
          const SizedBox(height: 24),
          Obx(
            () => PrimaryButton(
              label: 'Save availability',
              loading: controller.saving.value,
              onPressed: controller.save,
            ),
          ),
        ],
      ),
    );
  }
}
