import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/utils/time_utils.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/widgets/responsive.dart';
import '../controllers/auth_controller.dart';

class DoctorSignupView extends StatefulWidget {
  const DoctorSignupView({
    super.key,
    this.googleFlow = false,
  });

  final bool googleFlow;

  @override
  State<DoctorSignupView> createState() => _DoctorSignupViewState();
}

class _DoctorSignupViewState extends State<DoctorSignupView> {
  final formKey = GlobalKey<FormState>();

  // ============================================================
  // TEXT CONTROLLERS
  // ============================================================

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final phoneController = TextEditingController();
  final specializationController = TextEditingController();
  final licenseController = TextEditingController();
  final experienceController = TextEditingController();
  final hospitalController = TextEditingController();
  final qualificationController = TextEditingController();
  final feeController = TextEditingController();

  // ============================================================
  // STATE
  // ============================================================

  File? profileImage;

  final List<String> selectedDays = [];

  TimeOfDay? startTime;
  TimeOfDay? endTime;

  bool obscurePassword = true;

  final List<String> days = const [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    phoneController.dispose();
    specializationController.dispose();
    licenseController.dispose();
    experienceController.dispose();
    hospitalController.dispose();
    qualificationController.dispose();
    feeController.dispose();

    super.dispose();
  }

  // ============================================================
  // PICK IMAGE
  // ============================================================

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 1000,
        maxHeight: 1000,
      );

      if (pickedFile == null) {
        return;
      }

      setState(() {
        profileImage = File(pickedFile.path);
      });
    } catch (e) {
      Get.snackbar(
        'Image Error',
        'Unable to select the image.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ============================================================
  // SUBMIT
  // ============================================================

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    final auth = Get.find<AuthController>();

    // Prevent double click
    if (auth.isLoading.value) {
      return;
    }

    // Validate text fields
    if (!formKey.currentState!.validate()) {
      return;
    }

    // Validate working days
    if (selectedDays.isEmpty) {
      Get.snackbar(
        'Availability Required',
        'Please select at least one working day.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Validate start time
    if (startTime == null) {
      Get.snackbar(
        'Start Time Required',
        'Please select your starting time.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Validate end time
    if (endTime == null) {
      Get.snackbar(
        'End Time Required',
        'Please select your ending time.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Convert time to minutes
    final startMinutes =
        startTime!.hour * 60 + startTime!.minute;

    final endMinutes =
        endTime!.hour * 60 + endTime!.minute;

    // End must be after start
    if (endMinutes <= startMinutes) {
      Get.snackbar(
        'Invalid Working Hours',
        'End time must be after start time.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      if (widget.googleFlow) {
        // ======================================================
        // GOOGLE DOCTOR SETUP
        // ======================================================

        await auth.completeGoogleDoctor(
          phone: phoneController.text.trim(),
          specialization:
          specializationController.text.trim(),
          license: licenseController.text.trim(),
          experience: experienceController.text.trim(),
          hospital: hospitalController.text.trim(),
          qualification:
          qualificationController.text.trim(),
          fee: feeController.text.trim(),
          workingDays: List<String>.from(selectedDays),
          startTime: TimeUtils.formatTimeOfDay(startTime!),
          endTime: TimeUtils.formatTimeOfDay(endTime!),
          image: profileImage,
        );
      } else {
        // ======================================================
        // NORMAL DOCTOR SIGNUP
        // ======================================================

        await auth.registerDoctor(
          name: nameController.text.trim(),
          email: emailController.text.trim(),
          password: passwordController.text,
          phone: phoneController.text.trim(),
          image: profileImage,
          specialization:
          specializationController.text.trim(),
          license: licenseController.text.trim(),
          experience: experienceController.text.trim(),
          hospital: hospitalController.text.trim(),
          qualification:
          qualificationController.text.trim(),
          fee: feeController.text.trim(),
          workingDays: List<String>.from(selectedDays),
          startTime: TimeUtils.formatTimeOfDay(startTime!),
          endTime: TimeUtils.formatTimeOfDay(endTime!),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Registration Failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
      );
    }
  }

  // ============================================================
  // REQUIRED VALIDATOR
  // ============================================================

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }

    return null;
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.googleFlow
              ? 'Doctor Google Setup'
              : 'Doctor Registration',
        ),
      ),

      body: ResponsiveScaffoldBody(
        child: Form(
          key: formKey,

          child: ListView(
            padding: EdgeInsets.all(
              Responsive.pagePadding(context),
            ),

            children: [
              // ==================================================
              // PROFILE IMAGE
              // ==================================================

              Center(
                child: GestureDetector(
                  onTap: _pickImage,

                  child: CircleAvatar(
                    radius: 52,

                    backgroundColor:
                    AppColors.primarySoft,

                    backgroundImage:
                    profileImage != null
                        ? FileImage(profileImage!)
                        : null,

                    child: profileImage == null
                        ? const Icon(
                      Icons.camera_alt,
                      color: AppColors.primary,
                      size: 30,
                    )
                        : null,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              const Center(
                child: Text(
                  'Tap to select profile picture',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ==================================================
              // NORMAL SIGNUP FIELDS
              // ==================================================

              if (!widget.googleFlow) ...[
                AppTextField(
                  controller: nameController,
                  hint: 'Full name',
                  icon: Icons.person_outline,
                  validator: _requiredValidator,
                ),

                const SizedBox(height: 12),

                AppTextField(
                  controller: emailController,
                  hint: 'Email',
                  icon: Icons.email_outlined,
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Required';
                    }

                    if (!GetUtils.isEmail(
                      value.trim(),
                    )) {
                      return 'Enter a valid email';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 12),

                AppTextField(
                  controller: passwordController,
                  hint: 'Password',
                  icon: Icons.lock_outline,
                  obscureText: obscurePassword,
                  validator: (value) {
                    if (value == null ||
                        value.length < 6) {
                      return 'Min 6 characters';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 12),

                AppTextField(
                  controller: confirmPasswordController,
                  hint: 'Confirm password',
                  icon: Icons.lock_reset_outlined,
                  obscureText: true,
                  validator: (value) {
                    if (value !=
                        passwordController.text) {
                      return 'Passwords do not match';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 12),
              ],

              // ==================================================
              // PHONE
              // ==================================================

              AppTextField(
                controller: phoneController,
                hint: 'Phone',
                icon: Icons.phone_outlined,
                validator: _requiredValidator,
              ),

              const SizedBox(height: 12),

              // ==================================================
              // SPECIALIZATION
              // ==================================================

              AppTextField(
                controller: specializationController,
                hint: 'Specialization',
                icon: Icons.local_hospital_outlined,
                validator: _requiredValidator,
              ),

              const SizedBox(height: 12),

              // ==================================================
              // LICENSE
              // ==================================================

              AppTextField(
                controller: licenseController,
                hint: 'Medical license number',
                icon: Icons.badge_outlined,
                validator: _requiredValidator,
              ),

              const SizedBox(height: 12),

              // ==================================================
              // EXPERIENCE
              // ==================================================

              AppTextField(
                controller: experienceController,
                hint: 'Experience',
                icon: Icons.work_history_outlined,
                validator: _requiredValidator,
              ),

              const SizedBox(height: 12),

              // ==================================================
              // HOSPITAL
              // ==================================================

              AppTextField(
                controller: hospitalController,
                hint: 'Hospital / Clinic',
                icon: Icons.apartment_outlined,
                validator: _requiredValidator,
              ),

              const SizedBox(height: 12),

              // ==================================================
              // QUALIFICATION
              // ==================================================

              AppTextField(
                controller: qualificationController,
                hint: 'Qualification',
                icon: Icons.school_outlined,
                validator: _requiredValidator,
              ),

              const SizedBox(height: 12),

              // ==================================================
              // CONSULTATION FEE
              // ==================================================

              AppTextField(
                controller: feeController,
                hint: 'Consultation fee',
                icon: Icons.payments_outlined,
                validator: _requiredValidator,
              ),

              const SizedBox(height: 20),

              // ==================================================
              // WORKING DAYS
              // ==================================================

              const Text(
                'Working Days',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 8),

              Wrap(
                spacing: 8,
                runSpacing: 8,

                children: days.map((day) {
                  final selected =
                  selectedDays.contains(day);

                  return FilterChip(
                    label: Text(
                      day.substring(0, 3),
                    ),

                    selected: selected,

                    selectedColor:
                    AppColors.primarySoft,

                    onSelected: (value) {
                      setState(() {
                        if (value) {
                          if (!selectedDays
                              .contains(day)) {
                            selectedDays.add(day);
                          }
                        } else {
                          selectedDays.remove(day);
                        }
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              // ==================================================
              // START TIME
              // ==================================================

              ListTile(
                tileColor: Colors.white,

                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(16),
                ),

                leading: const Icon(
                  Icons.schedule,
                  color: AppColors.primary,
                ),

                title: Text(
                  startTime == null
                      ? 'Start: Select'
                      : 'Start: ${TimeUtils.formatTimeOfDay(startTime!)}',
                ),

                onTap: () async {
                  final picked =
                  await showTimePicker(
                    context: context,

                    initialTime:
                    const TimeOfDay(
                      hour: 9,
                      minute: 0,
                    ),
                  );

                  if (picked != null) {
                    setState(() {
                      startTime = picked;
                    });
                  }
                },
              ),

              const SizedBox(height: 8),

              // ==================================================
              // END TIME
              // ==================================================

              ListTile(
                tileColor: Colors.white,

                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(16),
                ),

                leading: const Icon(
                  Icons.schedule_outlined,
                  color: AppColors.primary,
                ),

                title: Text(
                  endTime == null
                      ? 'End: Select'
                      : 'End: ${TimeUtils.formatTimeOfDay(endTime!)}',
                ),

                onTap: () async {
                  final picked =
                  await showTimePicker(
                    context: context,

                    initialTime:
                    const TimeOfDay(
                      hour: 17,
                      minute: 0,
                    ),
                  );

                  if (picked != null) {
                    setState(() {
                      endTime = picked;
                    });
                  }
                },
              ),

              const SizedBox(height: 28),

              // ==================================================
              // CREATE ACCOUNT BUTTON
              // ==================================================

              Obx(
                    () => PrimaryButton(
                  label: widget.googleFlow
                      ? 'Finish Doctor Setup'
                      : 'Create Doctor Account',

                  loading: auth.isLoading.value,

                  onPressed:
                  auth.isLoading.value
                      ? null
                      : _submit,
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}