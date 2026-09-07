import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/app_widgets.dart';
import '../controllers/reminder_controller.dart';

class RemindersView extends GetView<ReminderController> {
  const RemindersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Medicine reminders')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => const AddReminderView()),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      body: Obx(() {
        if (controller.reminders.isEmpty) {
          return const EmptyState(
            icon: Icons.alarm_add_outlined,
            title: 'No reminders',
            subtitle: 'Create a medicine reminder with days and times.',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          itemCount: controller.reminders.length,
          itemBuilder: (context, index) {
            final reminder = controller.reminders[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(
                  reminder.medicineName,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text(
                  '${reminder.dosage}\n${reminder.times.join(' · ')}\n${reminder.days.map((d) => d.substring(0, 3)).join(', ')}',
                ),
                isThreeLine: true,
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.danger),
                  onPressed: () => controller.remove(reminder.id),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

class AddReminderView extends StatefulWidget {
  const AddReminderView({super.key});

  @override
  State<AddReminderView> createState() => _AddReminderViewState();
}

class _AddReminderViewState extends State<AddReminderView> {
  final medicine = TextEditingController();
  final dosage = TextEditingController();
  final notes = TextEditingController();
  late final ReminderController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<ReminderController>();
    controller.selectedDays.clear();
    controller.times.clear();
  }

  @override
  void dispose() {
    medicine.dispose();
    dosage.dispose();
    notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New reminder')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          AppTextField(
            controller: medicine,
            hint: 'Medicine name',
            icon: Icons.medication_outlined,
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: dosage,
            hint: 'Dosage (e.g. 1 tablet)',
            icon: Icons.science_outlined,
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: notes,
            hint: 'Notes (optional)',
            icon: Icons.notes_outlined,
          ),
          const SizedBox(height: 18),
          const Text('Days', style: TextStyle(fontWeight: FontWeight.w800)),
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
          Row(
            children: [
              const Expanded(
                child: Text('Times', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
              TextButton.icon(
                onPressed: () => controller.addTime(context),
                icon: const Icon(Icons.add),
                label: const Text('Add time'),
              ),
            ],
          ),
          Obx(
            () => Wrap(
              spacing: 8,
              children: controller.times
                  .map(
                    (time) => Chip(
                      label: Text(time),
                      onDeleted: () => controller.times.remove(time),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Save reminder',
            onPressed: () => controller.save(
              medicine: medicine.text,
              dosage: dosage.text,
              notes: notes.text,
            ),
          ),
        ],
      ),
    );
  }
}
