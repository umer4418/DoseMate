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
      appBar: AppBar(
        title: const Text(
          'Book Appointment',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(
            Responsive.pagePadding(context),
          ),
          children: [
            // ==================================================
            // HEADER
            // ==================================================

            const Text(
              'Find a Doctor',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.darkText,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Choose a doctor and book an appointment that fits your schedule.',
              style: TextStyle(
                color: AppColors.secondaryText,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 20),

            // ==================================================
            // SEARCH
            // ==================================================

            TextField(
              decoration: InputDecoration(
                hintText: 'Search doctor or specialization',
                prefixIcon: const Icon(
                  Icons.search_rounded,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ==================================================
            // SPECIALIZATIONS
            // ==================================================

            const Text(
              'Specialization',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              height: 42,
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

            const SizedBox(height: 24),

            // ==================================================
            // DOCTORS
            // ==================================================

            const Text(
              'Available Doctors',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
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

  // ============================================================
  // SPECIALIZATION CHIP
  // ============================================================

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
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ============================================
                // DOCTOR IMAGE
                // ============================================

                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    size: 38,
                    color: AppColors.primary,
                  ),
                ),

                const SizedBox(width: 14),

                // ============================================
                // DOCTOR INFORMATION
                // ============================================

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        specialization,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        experience,
                        style: const TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 13,
                        ),
                      ),

                      const SizedBox(height: 5),

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
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // ================================================
            // AVAILABILITY
            // ================================================

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 18,
                    color: Colors.green,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Available for appointments',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ================================================
            // BOOK BUTTON
            // ================================================

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  _showBookingSheet(
                    context,
                    doctorName: name,
                    specialization: specialization,
                  );
                },
                child: const Text(
                  'Book Appointment',
                ),
              ),
            ),
          ],
        ),
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
          20,
          20,
          30,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(28),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            // ================================================
            // TITLE
            // ================================================

            Text(
              'Book with $doctorName',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              specialization,
              style: const TextStyle(
                color: AppColors.secondaryText,
              ),
            ),

            const SizedBox(height: 20),

            // ================================================
            // DATE
            // ================================================

            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.calendar_month_rounded,
                  color: AppColors.primary,
                ),
              ),
              title: const Text(
                'Select date',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
              subtitle: const Text(
                'Choose appointment date',
              ),
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

            const SizedBox(height: 8),

            // ================================================
            // TIME
            // ================================================

            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.access_time_rounded,
                  color: AppColors.primary,
                ),
              ),
              title: const Text(
                'Select time',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
              subtitle: const Text(
                'Choose available time',
              ),
              onTap: () async {
                await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
              },
            ),

            const SizedBox(height: 20),

            // ================================================
            // CONFIRM
            // ================================================

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
                  );
                },
                child: const Text(
                  'Confirm Appointment',
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