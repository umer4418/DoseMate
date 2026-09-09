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

  AppUser? selectedDoctor;
  String? expandedDoctorUid;

  final notes = TextEditingController();

  @override
  void initState() {
    super.initState();

    controller = Get.find<AppointmentController>();

    final args = Get.arguments;

    if (args is AppUser) {
      selectedDoctor = args;
      expandedDoctorUid = args.uid;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  @override
  void dispose() {
    notes.dispose();
    super.dispose();
  }

  Future<void> _selectDoctorDate(AppUser doctor) async {
    if (!doctor.isAvailable) {
      Get.snackbar(
        'Doctor unavailable',
        '${doctor.name} is currently unavailable for appointments.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );

    if (picked == null) return;

    if (!controller.isWorkingDay(doctor, picked)) {
      Get.snackbar(
        'Not a working day',
        '${doctor.name} is not available on '
            '${TimeUtils.weekdayName(picked)}.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() {
      selectedDoctor = doctor;
      expandedDoctorUid = doctor.uid;
    });

    await controller.loadSlots(doctor, picked);
  }

  void _openBooking(AppUser doctor) {
    if (!doctor.isAvailable) {
      Get.snackbar(
        'Doctor unavailable',
        '${doctor.name} is currently unavailable for appointments.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() {
      if (expandedDoctorUid == doctor.uid) {
        expandedDoctorUid = null;
        selectedDoctor = null;
      } else {
        expandedDoctorUid = doctor.uid;
        selectedDoctor = doctor;
      }
    });

    controller.availableSlots.clear();
    controller.selectedDate.value = null;
  }

  void _showDoctorProfile(AppUser doctor) {
    final specialization = doctor.specialization.isEmpty
        ? 'General Physician'
        : doctor.specialization;

    Get.bottomSheet(
      Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * .80,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(30),
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 30),
          child: Column(
            children: [
              // Handle
              Container(
                width: 45,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFD7DCE3),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),

              const SizedBox(height: 25),

              // Doctor avatar
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(.10),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withOpacity(.18),
                    width: 4,
                  ),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  size: 50,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                doctor.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkText,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                specialization,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 12),

              // Availability
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: doctor.isAvailable
                      ? AppColors.success.withOpacity(.10)
                      : AppColors.danger.withOpacity(.10),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  doctor.isAvailable
                      ? 'Available for appointment'
                      : 'Currently unavailable',
                  style: TextStyle(
                    color: doctor.isAvailable
                        ? AppColors.success
                        : AppColors.danger,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              const Divider(),

              const SizedBox(height: 18),

              _ProfileInformationTile(
                icon: Icons.medical_services_outlined,
                title: 'Specialization',
                value: specialization,
              ),

              const SizedBox(height: 14),

              _ProfileInformationTile(
                icon: Icons.calendar_month_outlined,
                title: 'Working days',
                value: doctor.workingDays.isEmpty
                    ? 'Not provided'
                    : doctor.workingDays.join(', '),
              ),

              const SizedBox(height: 14),

              _ProfileInformationTile(
                icon: Icons.schedule_rounded,
                title: 'Consultation hours',
                value: '${doctor.startTime} - ${doctor.endTime}',
              ),

              const SizedBox(height: 28),

              // Book button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: doctor.isAvailable
                      ? () {
                    Get.back();
                    _openBooking(doctor);
                  }
                      : null,
                  icon: const Icon(
                    Icons.calendar_month_rounded,
                  ),
                  label: const Text(
                    'Book Appointment',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                    AppColors.secondaryText.withOpacity(.15),
                    disabledForegroundColor:
                    AppColors.secondaryText,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
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
          'Book Appointment',
          style: TextStyle(
            color: AppColors.darkText,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 35),
        children: [
          const _AppointmentBanner(),

          const SizedBox(height: 28),

          const _SectionTitle(
            title: 'Find your doctor',
            subtitle:
            'Choose a healthcare professional and book your appointment',
          ),

          const SizedBox(height: 16),

          Obx(() {
            final doctors = controller.doctors;

            if (doctors.isEmpty) {
              return const _InfoBox(
                icon: Icons.medical_services_outlined,
                title: 'No doctors available',
                subtitle:
                'There are currently no registered doctors available.',
              );
            }

            return Column(
              children: doctors.map((doctor) {
                final isExpanded =
                    expandedDoctorUid == doctor.uid;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _ProfessionalDoctorCard(
                    doctor: doctor,
                    isExpanded: isExpanded,
                    controller: controller,
                    notes: notes,
                    onProfile: () {
                      _showDoctorProfile(doctor);
                    },
                    onBook: () {
                      _openBooking(doctor);
                    },
                    onChooseDate: () {
                      _selectDoctorDate(doctor);
                    },
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
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
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
                  padding: EdgeInsets.only(
                    left: 20,
                    top: 20,
                    bottom: 20,
                  ),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    mainAxisAlignment:
                    MainAxisAlignment.center,
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

class _ProfessionalDoctorCard extends StatelessWidget {
  const _ProfessionalDoctorCard({
    required this.doctor,
    required this.isExpanded,
    required this.controller,
    required this.notes,
    required this.onProfile,
    required this.onBook,
    required this.onChooseDate,
  });

  final AppUser doctor;
  final bool isExpanded;
  final AppointmentController controller;
  final TextEditingController notes;

  final VoidCallback onProfile;
  final VoidCallback onBook;
  final VoidCallback onChooseDate;

  @override
  Widget build(BuildContext context) {
    final specialization = doctor.specialization.isEmpty
        ? 'General Physician'
        : doctor.specialization;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isExpanded
              ? AppColors.primary.withOpacity(.35)
              : AppColors.border,
          width: isExpanded ? 1.3 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.035),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(17),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(.10),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    size: 34,
                    color: AppColors.primary,
                  ),
                ),

                const SizedBox(width: 13),

                // Doctor information
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkText,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        specialization,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Availability
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: doctor.isAvailable
                                  ? AppColors.success
                                  : AppColors.danger,
                            ),
                          ),

                          const SizedBox(width: 6),

                          Text(
                            doctor.isAvailable
                                ? 'Available'
                                : 'Unavailable',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: doctor.isAvailable
                                  ? AppColors.success
                                  : AppColors.danger,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Profile button
                IconButton(
                  onPressed: onProfile,
                  tooltip: 'View profile',
                  style: IconButton.styleFrom(
                    backgroundColor:
                    AppColors.primary.withOpacity(.08),
                  ),
                  icon: const Icon(
                    Icons.visibility_outlined,
                    size: 19,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 17),
            child: Row(
              children: [
                Expanded(
                  child: _MiniDoctorInfo(
                    icon: Icons.calendar_month_outlined,
                    text: doctor.workingDays.isEmpty
                        ? 'Days not set'
                        : doctor.workingDays.join(', '),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: _MiniDoctorInfo(
                    icon: Icons.schedule_outlined,
                    text:
                    '${doctor.startTime} - ${doctor.endTime}',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 17),

          Padding(
            padding: const EdgeInsets.fromLTRB(
              17,
              0,
              17,
              17,
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onProfile,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(
                        color:
                        AppColors.primary.withOpacity(.25),
                      ),
                      minimumSize:
                      const Size(double.infinity, 46),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(13),
                      ),
                    ),
                    child: const Text(
                      'View Profile',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: ElevatedButton(
                    onPressed: doctor.isAvailable
                        ? onBook
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                      Colors.grey.shade200,
                      disabledForegroundColor:
                      Colors.grey.shade500,
                      elevation: 0,
                      minimumSize:
                      const Size(double.infinity, 46),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(13),
                      ),
                    ),
                    child: Text(
                      isExpanded
                          ? 'Close Booking'
                          : 'Book Now',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (isExpanded)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                17,
                18,
                17,
                20,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFD),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(22),
                ),
                border: Border(
                  top: BorderSide(
                    color: AppColors.border,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select appointment date',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkText,
                    ),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    'Choose a working day to see available time slots.',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: AppColors.secondaryText,
                    ),
                  ),

                  const SizedBox(height: 13),

                  // DATE BUTTON
                  Obx(() {
                    final selectedDate =
                        controller.selectedDate.value;

                    return Material(
                      color: Colors.white,
                      borderRadius:
                      BorderRadius.circular(15),
                      child: InkWell(
                        onTap: onChooseDate,
                        borderRadius:
                        BorderRadius.circular(15),
                        child: Container(
                          width: double.infinity,
                          padding:
                          const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            borderRadius:
                            BorderRadius.circular(15),
                            border: Border.all(
                              color: selectedDate == null
                                  ? AppColors.border
                                  : AppColors.primary,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.primary
                                      .withOpacity(.09),
                                  borderRadius:
                                  BorderRadius.circular(
                                    12,
                                  ),
                                ),
                                child: const Icon(
                                  Icons
                                      .calendar_month_rounded,
                                  color:
                                  AppColors.primary,
                                  size: 23,
                                ),
                              ),

                              const SizedBox(width: 12),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      selectedDate == null
                                          ? 'Choose a date'
                                          : TimeUtils.prettyDate(
                                        selectedDate,
                                      ),
                                      style:
                                      const TextStyle(
                                        fontSize: 13,
                                        fontWeight:
                                        FontWeight.w800,
                                        color:
                                        AppColors.darkText,
                                      ),
                                    ),

                                    const SizedBox(height: 3),

                                    Text(
                                      selectedDate == null
                                          ? 'Tap to open calendar'
                                          : 'Date selected',
                                      style:
                                      const TextStyle(
                                        fontSize: 11,
                                        color: AppColors
                                            .secondaryText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const Icon(
                                Icons
                                    .arrow_forward_ios_rounded,
                                size: 15,
                                color:
                                AppColors.secondaryText,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 18),

                  const Text(
                    'Available time slots',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkText,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Obx(() {
                    if (controller.loadingSlots.value) {
                      return Container(
                        width: double.infinity,
                        padding:
                        const EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                          BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.border,
                          ),
                        ),
                        child: const Center(
                          child:
                          CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                      );
                    }

                    if (controller.selectedDate.value ==
                        null) {
                      return const _InfoBox(
                        icon: Icons
                            .calendar_today_outlined,
                        title: 'No date selected',
                        subtitle:
                        'Choose a working day to see available appointment times.',
                      );
                    }

                    if (controller.availableSlots.isEmpty) {
                      return const _InfoBox(
                        icon: Icons.event_busy_outlined,
                        title: 'No slots available',
                        subtitle:
                        'There are no open appointment times on this date.',
                      );
                    }

                    return Wrap(
                      spacing: 9,
                      runSpacing: 9,
                      children: controller.availableSlots
                          .map(
                            (slot) {
                          return Material(
                            color: Colors.white,
                            borderRadius:
                            BorderRadius.circular(13),
                            child: InkWell(
                              onTap: () {
                                controller.book(
                                  doctor: doctor,
                                  time: slot,
                                  notes: notes.text,
                                );
                              },
                              borderRadius:
                              BorderRadius.circular(13),
                              child: Container(
                                padding:
                                const EdgeInsets
                                    .symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius:
                                  BorderRadius.circular(
                                    13,
                                  ),
                                  border: Border.all(
                                    color: AppColors.primary
                                        .withOpacity(.25),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize:
                                  MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons
                                          .access_time_rounded,
                                      size: 16,
                                      color:
                                      AppColors.primary,
                                    ),

                                    const SizedBox(width: 6),

                                    Text(
                                      slot,
                                      style:
                                      const TextStyle(
                                        fontSize: 12,
                                        fontWeight:
                                        FontWeight.w700,
                                        color:
                                        AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ).toList(),
                    );
                  }),

                  const SizedBox(height: 20),

                  const Text(
                    'Appointment notes',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkText,
                    ),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    'Optional information for your doctor.',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: AppColors.secondaryText,
                    ),
                  ),

                  const SizedBox(height: 10),

                  AppTextField(
                    controller: notes,
                    hint: 'Reason / notes (optional)',
                    icon: Icons.notes_outlined,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _MiniDoctorInfo extends StatelessWidget {
  const _MiniDoctorInfo({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: AppColors.secondaryText,
          ),

          const SizedBox(width: 6),

          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10.5,
                color: AppColors.secondaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileInformationTile extends StatelessWidget {
  const _ProfileInformationTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(.09),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 20,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.secondaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.darkText,
                    fontWeight: FontWeight.w700,
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
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(.08),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
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
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.secondaryText,
          ),
        ),
      ],
    );
  }
}