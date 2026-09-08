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
      backgroundColor: const Color(0xFFF5F8FC),

      floatingActionButton: FloatingActionButton.extended(
        elevation: 4,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () => Get.to(() => const AddReminderView()),
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add reminder',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            // ================================================================
            // CUSTOM HEADER
            // ================================================================

            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(.10),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.medication_rounded,
                      color: AppColors.primary,
                      size: 25,
                    ),
                  ),

                  const SizedBox(width: 13),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Medicine reminders',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkText,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Manage your daily medicines',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ================================================================
            // REMINDERS
            // ================================================================
            Expanded(
              child: Obx(() {
                if (controller.reminders.isEmpty) {
                  return _EmptyReminderState(
                    onAdd: () => Get.to(() => const AddReminderView()),
                  );
                }

                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
                  itemCount: controller.reminders.length,
                  itemBuilder: (context, index) {
                    final reminder = controller.reminders[index];

                    return _ReminderCard(
                      medicineName: reminder.medicineName,
                      dosage: reminder.dosage,
                      times: reminder.times,
                      days: reminder.days,
                      onDelete: () => controller.remove(reminder.id),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  const _ReminderCard({
    required this.medicineName,
    required this.dosage,
    required this.times,
    required this.days,
    required this.onDelete,
  });

  final String medicineName;
  final String dosage;
  final List<String> times;
  final List<String> days;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.025),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Medicine name and delete
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(.10),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: const Icon(
                  Icons.medication_rounded,
                  color: AppColors.primary,
                  size: 27,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medicineName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkText,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Row(
                      children: [
                        const Icon(
                          Icons.science_outlined,
                          size: 14,
                          color: AppColors.secondaryText,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            dosage,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Material(
                color: AppColors.danger.withOpacity(.08),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: onDelete,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 42,
                    height: 42,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.danger,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          Divider(height: 1, color: AppColors.border),

          const SizedBox(height: 14),

          // Times
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.access_time_rounded,
                color: AppColors.primary,
                size: 18,
              ),

              const SizedBox(width: 8),

              Expanded(
                child: Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: times.map((time) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        time,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Days
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                color: AppColors.primary,
                size: 17,
              ),

              const SizedBox(width: 8),

              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: days.map((day) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F5F9),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Text(
                        day.substring(0, 3),
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkText,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyReminderState extends StatelessWidget {
  const _EmptyReminderState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 105,
              height: 105,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(.09),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.medication_outlined,
                size: 50,
                color: AppColors.primary,
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              'No reminders yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.darkText,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Add your medicines and DoseMate will help you stay on track.',
              textAlign: TextAlign.center,
              style: TextStyle(height: 1.5, color: AppColors.secondaryText),
            ),

            const SizedBox(height: 22),

            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create reminder'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
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

    // Keep existing functionality
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
      backgroundColor: const Color(0xFFF5F8FC),

      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Text(
          'New reminder',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: AppColors.darkText,
          ),
        ),
      ),

      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: PrimaryButton(
            label: 'Save reminder',
            onPressed: () => controller.save(
              medicine: medicine.text,
              dosage: dosage.text,
              notes: notes.text,
            ),
          ),
        ),
      ),

      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
        children: [
          Container(
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(.12),
                  AppColors.primary.withOpacity(.04),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.notifications_active_rounded,
                  color: AppColors.primary,
                  size: 28,
                ),

                SizedBox(width: 12),

                Expanded(
                  child: Text(
                    'Set your medicine schedule and we will help you remember every dose.',
                    style: TextStyle(
                      color: AppColors.darkText,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          const _FormSectionTitle(
            title: 'Medicine information',
            subtitle: 'Enter details about your medicine',
          ),

          const SizedBox(height: 14),

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

          const SizedBox(height: 28),
          const _FormSectionTitle(
            title: 'Repeat days',
            subtitle: 'Choose the days you take this medicine',
          ),

          const SizedBox(height: 14),

          Obx(
            () => Wrap(
              spacing: 8,
              runSpacing: 10,
              children: controller.days.map((day) {
                final selected = controller.selectedDays.contains(day);

                return InkWell(
                  onTap: () => controller.toggleDay(day),
                  borderRadius: BorderRadius.circular(13),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(
                        color: selected ? AppColors.primary : AppColors.border,
                      ),
                    ),
                    child: Text(
                      day.substring(0, 3),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: selected ? Colors.white : AppColors.darkText,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 30),
          Row(
            children: [
              const Expanded(
                child: _FormSectionTitle(
                  title: 'Reminder times',
                  subtitle: 'Choose when you want to be reminded',
                ),
              ),

              Material(
                color: AppColors.primary.withOpacity(.09),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () => controller.addTime(context),
                  borderRadius: BorderRadius.circular(12),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                    child: Row(
                      children: [
                        Icon(
                          Icons.add_rounded,
                          color: AppColors.primary,
                          size: 18,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Add time',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Obx(() {
            if (controller.times.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.access_time_outlined,
                      color: AppColors.secondaryText,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'No reminder times added',
                      style: TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              );
            }

            return Wrap(
              spacing: 9,
              runSpacing: 9,
              children: controller.times.map((time) {
                return Container(
                  padding: const EdgeInsets.only(
                    left: 12,
                    right: 5,
                    top: 7,
                    bottom: 7,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 15,
                        color: AppColors.primary,
                      ),

                      const SizedBox(width: 6),

                      Text(
                        time,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),

                      const SizedBox(width: 3),

                      IconButton(
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(4),
                        iconSize: 17,
                        icon: const Icon(
                          Icons.close_rounded,
                          color: AppColors.primary,
                        ),
                        onPressed: () => controller.times.remove(time),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          }),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class _FormSectionTitle extends StatelessWidget {
  const _FormSectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppColors.darkText,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
        ),
      ],
    );
  }
}
