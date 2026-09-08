import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_images.dart';
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

    if (args is AppUser) {
      doctor = args;
    }
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
        '${selected.name} is not available on '
            '${TimeUtils.weekdayName(picked)}.',
      );

      return;
    }

    await controller.loadSlots(selected, picked);
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
          'Book appointment',
          style: TextStyle(
            color: AppColors.darkText,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
        children: [
          // ============================================================
          // TOP BANNER
          // ============================================================

          _AppointmentBanner(),

          const SizedBox(height: 26),

          // ============================================================
          // SELECT DOCTOR
          // ============================================================
          const _SectionTitle(
            title: 'Choose your doctor',
            subtitle: 'Select a healthcare professional for your appointment',
          ),

          const SizedBox(height: 14),

          Obx(() {
            final doctors = controller.doctors;
            final selectedUid = doctor?.uid;

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: DropdownButtonFormField<String>(
                key: ValueKey('${doctors.length}-${selectedUid ?? 'none'}'),

                initialValue: doctors.any((d) => d.uid == selectedUid)
                    ? selectedUid
                    : null,

                isExpanded: true,

                items: doctors
                    .map(
                      (d) => DropdownMenuItem<String>(
                        value: d.uid,
                        child: Text(
                          '${d.name} · '
                          '${d.specialization.isEmpty ? 'General' : d.specialization}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),

                onChanged: (uid) {
                  setState(() {
                    doctor = doctors.firstWhereOrNull((d) => d.uid == uid);
                  });

                  // Keep original functionality
                  controller.availableSlots.clear();
                  controller.selectedDate.value = null;
                },

                decoration: const InputDecoration(
                  hintText: 'Select a doctor',
                  prefixIcon: Icon(
                    Icons.medical_services_outlined,
                    color: AppColors.primary,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 17,
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: 16),

          // ============================================================
          // DOCTOR INFORMATION CARD
          // ============================================================
          if (doctor != null) _DoctorInfoCard(doctor: doctor!),

          if (doctor != null) const SizedBox(height: 26),

          // ============================================================
          // DATE
          // ============================================================
          const _SectionTitle(
            title: 'Choose a date',
            subtitle: 'Select an available working day',
          ),

          const SizedBox(height: 13),

          Obx(() {
            final date = controller.selectedDate.value;

            return Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              child: InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.all(17),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: date == null
                          ? AppColors.border
                          : AppColors.primary,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(.10),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.calendar_month_rounded,
                          color: AppColors.primary,
                          size: 25,
                        ),
                      ),

                      const SizedBox(width: 13),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              date == null
                                  ? 'Select appointment date'
                                  : TimeUtils.prettyDate(date),
                              style: const TextStyle(
                                color: AppColors.darkText,
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              date == null
                                  ? 'Tap to view the calendar'
                                  : 'Date selected successfully',
                              style: const TextStyle(
                                color: AppColors.secondaryText,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 17,
                        color: AppColors.secondaryText,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: 26),

          // ============================================================
          // AVAILABLE TIME SLOTS
          // ============================================================
          const _SectionTitle(
            title: 'Available time slots',
            subtitle: 'Choose a convenient time for your appointment',
          ),

          const SizedBox(height: 14),

          Obx(() {
            if (controller.loadingSlots.value) {
              return Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              );
            }

            if (controller.selectedDate.value == null) {
              return _InfoBox(
                icon: Icons.calendar_today_outlined,
                title: 'No date selected',
                subtitle:
                    'Choose a working day to see available appointment times.',
              );
            }

            if (controller.availableSlots.isEmpty) {
              return _InfoBox(
                icon: Icons.event_busy_outlined,
                title: 'No slots available',
                subtitle: 'There are no open appointment times on this date.',
              );
            }

            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: controller.availableSlots.map((slot) {
                return Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    onTap: () => controller.book(
                      doctor: doctor!,
                      time: slot,
                      notes: notes.text,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 13,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(.25),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            size: 17,
                            color: AppColors.primary,
                          ),

                          const SizedBox(width: 7),

                          Text(
                            slot,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          }),

          const SizedBox(height: 28),

          // ============================================================
          // NOTES
          // ============================================================
          const _SectionTitle(
            title: 'Appointment notes',
            subtitle: 'Tell the doctor about your reason for visiting',
          ),

          const SizedBox(height: 13),

          AppTextField(
            controller: notes,
            hint: 'Reason / notes (optional)',
            icon: Icons.notes_outlined,
          ),

          const SizedBox(height: 35),
        ],
      ),
    );
  }
}

// ============================================================================
// APPOINTMENT BANNER
// ============================================================================

class _AppointmentBanner extends StatelessWidget {
  const _AppointmentBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 175,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(.20),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circle
          Positioned(
            right: -50,
            top: -50,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(.08),
              ),
            ),
          ),

          Positioned(
            left: -40,
            bottom: -60,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(.06),
              ),
            ),
          ),

          Row(
            children: [
              const Expanded(
                flex: 6,
                child: Padding(
                  padding: EdgeInsets.only(left: 20, top: 20, bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Your health\ncomes first',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          height: 1.1,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      SizedBox(height: 10),

                      Text(
                        'Book an appointment with a trusted healthcare professional.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Expanded(
                flex: 4,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Image.asset(
                    AppImages.onboardingReminders,
                    height: 170,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// DOCTOR INFORMATION CARD
// ============================================================================

class _DoctorInfoCard extends StatelessWidget {
  const _DoctorInfoCard({required this.doctor});

  final AppUser doctor;

  @override
  Widget build(BuildContext context) {
    final specialization = doctor.specialization.isEmpty
        ? 'General physician'
        : doctor.specialization;

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: doctor.isAvailable
            ? const Color(0xFFEAF8F2)
            : const Color(0xFFFFEEEE),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: doctor.isAvailable
              ? AppColors.success.withOpacity(.20)
              : AppColors.danger.withOpacity(.20),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.8),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.person_rounded,
                  color: doctor.isAvailable
                      ? AppColors.success
                      : AppColors.danger,
                  size: 28,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkText,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      specialization,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: doctor.isAvailable
                      ? AppColors.success.withOpacity(.12)
                      : AppColors.danger.withOpacity(.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  doctor.isAvailable ? 'Available' : 'Unavailable',
                  style: TextStyle(
                    color: doctor.isAvailable
                        ? AppColors.success
                        : AppColors.danger,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          Divider(
            color: doctor.isAvailable
                ? AppColors.success.withOpacity(.15)
                : AppColors.danger.withOpacity(.15),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color: AppColors.secondaryText,
              ),

              const SizedBox(width: 7),

              Expanded(
                child: Text(
                  'Working: ${doctor.workingDays.join(', ')}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.secondaryText,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              const Icon(
                Icons.access_time_outlined,
                size: 17,
                color: AppColors.secondaryText,
              ),

              const SizedBox(width: 7),

              Text(
                '${doctor.startTime} – ${doctor.endTime}',
                style: const TextStyle(
                  fontSize: 11.5,
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// INFORMATION BOX
// ============================================================================

class _InfoBox extends StatelessWidget {
  const _InfoBox({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(.08),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkText,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// SECTION TITLE
// ============================================================================

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

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
            fontSize: 18,
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
