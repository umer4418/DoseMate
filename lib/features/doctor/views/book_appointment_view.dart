import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/responsive.dart';
import '../../../features/patient/controllers/appointment_controller.dart';

class BookAppointmentView extends GetView<AppointmentController> {
  const BookAppointmentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F8FC),
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 20,
        title: const Text(
          'Book Appointment',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.darkText,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            Responsive.pagePadding(context),
            8,
            Responsive.pagePadding(context),
            30,
          ),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primaryDark,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.18),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.medical_services_outlined,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 15),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Find the right doctor',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Choose a specialist and book a convenient appointment.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12.5,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Search doctors',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.darkText,
              ),
            ),

            const SizedBox(height: 10),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(17),
                border: Border.all(
                  color: AppColors.border,
                ),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Doctor name or specialization',
                  hintStyle: const TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 14,
                  ),
                  prefixIcon: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.09),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: const Icon(
                      Icons.search_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 15,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Specialization',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkText,
                    ),
                  ),
                ),
                Text(
                  'View all',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            SizedBox(
              height: 43,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _specializationChip('All', true),
                  _specializationChip('Cardiologist', false),
                  _specializationChip('Dentist', false),
                  _specializationChip('Dermatologist', false),
                  _specializationChip('Neurologist', false),
                ],
              ),
            ),

            const SizedBox(height: 26),

            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Available Doctors',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkText,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.circle,
                        size: 7,
                        color: AppColors.success,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'Available',
                        style: TextStyle(
                          color: AppColors.success,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            _doctorCard(
              context,
              name: 'Dr. Ahmed Khan',
              specialization: 'Cardiologist',
              experience: '8 years experience',
              rating: '4.9',
            ),

            _doctorCard(
              context,
              name: 'Dr. Sara Malik',
              specialization: 'Dermatologist',
              experience: '6 years experience',
              rating: '4.8',
            ),

            _doctorCard(
              context,
              name: 'Dr. Hamza Ali',
              specialization: 'General Physician',
              experience: '10 years experience',
              rating: '4.9',
            ),

            _doctorCard(
              context,
              name: 'Dr. Ayesha Noor',
              specialization: 'Neurologist',
              experience: '7 years experience',
              rating: '4.7',
            ),
          ],
        ),
      ),
    );
  }

  Widget _specializationChip(
      String title,
      bool selected,
      ) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(title),
        selected: selected,
        onSelected: (_) {},
        selectedColor: AppColors.primary,
        backgroundColor: Colors.white,
        side: BorderSide(
          color: selected
              ? AppColors.primary
              : AppColors.border,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(13),
        ),
        labelStyle: TextStyle(
          color: selected
              ? Colors.white
              : AppColors.secondaryText,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 5,
        ),
      ),
    );
  }

  // ============================================================
  // DOCTOR CARD
  // ============================================================

  Widget _doctorCard(
      BuildContext context, {
        required String name,
        required String specialization,
        required String experience,
        required String rating,
      }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Doctor avatar
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.14),
                      AppColors.primary.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(19),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(width: 14),

              // Doctor information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkText,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      specialization,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Row(
                      children: [
                        const Icon(
                          Icons.workspace_premium_outlined,
                          size: 15,
                          color: AppColors.secondaryText,
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            experience,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.secondaryText,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 17,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          rating,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkText,
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Text(
                          'Excellent',
                          style: TextStyle(
                            color: AppColors.secondaryText,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Online indicator
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 1.5,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          // Availability
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.07),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: AppColors.success.withOpacity(0.10),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  size: 17,
                  color: AppColors.success,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Available for appointments',
                    style: TextStyle(
                      color: AppColors.success,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 11,
                  color: AppColors.success,
                ),
              ],
            ),
          ),

          const SizedBox(height: 13),

          // Book button
          SizedBox(
            width: double.infinity,
            height: 49,
            child: ElevatedButton(
              onPressed: () {
                _showBookingSheet(
                  context,
                  doctorName: name,
                  specialization: specialization,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_month_rounded,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Book Appointment',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BOOKING BOTTOM SHEET
  // ============================================================

  void _showBookingSheet(
      BuildContext context, {
        required String doctorName,
        required String specialization,
      }) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(
          20,
          10,
          20,
          30,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(30),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 42,
                height: 5,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),

            // Doctor header
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.09),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: AppColors.primary,
                    size: 29,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Book with $doctorName',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkText,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        specialization,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            const Text(
              'Choose appointment time',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.darkText,
              ),
            ),

            const SizedBox(height: 12),

            // Date
            _BookingOption(
              icon: Icons.calendar_month_rounded,
              title: 'Select date',
              subtitle: 'Choose your preferred appointment date',
              onTap: () async {
                await showDatePicker(
                  context: context,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(
                    const Duration(days: 90),
                  ),
                  initialDate: DateTime.now(),
                );
              },
            ),

            const SizedBox(height: 10),

            // Time
            _BookingOption(
              icon: Icons.access_time_rounded,
              title: 'Select time',
              subtitle: 'Choose an available appointment time',
              onTap: () async {
                await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
              },
            ),

            const SizedBox(height: 20),

            // Confirm
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Get.back();

                  Get.snackbar(
                    'Appointment requested',
                    'Your appointment request has been sent to $doctorName.',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: AppColors.darkText,
                    colorText: Colors.white,
                    margin: const EdgeInsets.all(14),
                    borderRadius: 14,
                    icon: const Icon(
                      Icons.check_circle_outline,
                      color: Colors.white,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  'Confirm Appointment',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}

// ============================================================
// BOOKING OPTION
// ============================================================

class _BookingOption extends StatelessWidget {
  const _BookingOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F9FC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.09),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 22,
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
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.secondaryText,
            ),
          ],
        ),
      ),
    );
  }
}