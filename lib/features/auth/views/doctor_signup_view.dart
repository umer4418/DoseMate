import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_images.dart';
import '../../../core/utils/time_utils.dart';
import '../controllers/auth_controller.dart';

class DoctorSignupView extends StatefulWidget {
  const DoctorSignupView({super.key, this.googleFlow = false});

  final bool googleFlow;

  @override
  State<DoctorSignupView> createState() => _DoctorSignupViewState();
}

class _DoctorSignupViewState extends State<DoctorSignupView> {
  final formKey = GlobalKey<FormState>();

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

  File? profileImage;

  final List<String> selectedDays = [];

  TimeOfDay? startTime;
  TimeOfDay? endTime;

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  String? selectedAvatar;

  final List<String> days = const [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

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

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 1000,
        maxHeight: 1000,
      );

      if (pickedFile == null) return;

      setState(() {
        profileImage = File(pickedFile.path);
        selectedAvatar = null;
      });
    } catch (e) {
      Get.snackbar(
        'Image Error',
        'Unable to select profile image.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }

    return null;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    final auth = Get.find<AuthController>();

    if (auth.isLoading.value) {
      return;
    }

    if (!formKey.currentState!.validate()) {
      return;
    }

    if (selectedDays.isEmpty) {
      Get.snackbar(
        'Working Days Required',
        'Please select at least one working day.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (startTime == null) {
      Get.snackbar(
        'Start Time Required',
        'Please select your starting time.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (endTime == null) {
      Get.snackbar(
        'End Time Required',
        'Please select your ending time.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final startMinutes = startTime!.hour * 60 + startTime!.minute;
    final endMinutes = endTime!.hour * 60 + endTime!.minute;

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
        await auth.completeGoogleDoctor(
          phone: phoneController.text.trim(),
          specialization: specializationController.text.trim(),
          license: licenseController.text.trim(),
          experience: experienceController.text.trim(),
          hospital: hospitalController.text.trim(),
          qualification: qualificationController.text.trim(),
          fee: feeController.text.trim(),
          workingDays: List<String>.from(selectedDays),
          startTime: TimeUtils.formatTimeOfDay(startTime!),
          endTime: TimeUtils.formatTimeOfDay(endTime!),
          image: profileImage,
        );
      } else {
        await auth.registerDoctor(
          name: nameController.text.trim(),
          email: emailController.text.trim(),
          password: passwordController.text,
          phone: phoneController.text.trim(),
          image: profileImage,
          specialization: specializationController.text.trim(),
          license: licenseController.text.trim(),
          experience: experienceController.text.trim(),
          hospital: hospitalController.text.trim(),
          qualification: qualificationController.text.trim(),
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

  InputDecoration _inputDecoration({
    required BuildContext context,
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return InputDecoration(
      hintText: hint,
      hintStyle: theme.textTheme.bodyMedium?.copyWith(
        color: AppColors.secondaryText,
        fontWeight: FontWeight.w400,
      ),
      prefixIcon: Icon(
        icon,
        color: AppColors.primary,
        size: 21,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: colors.surfaceContainerHighest.withValues(
        alpha: 0.35,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 17,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: colors.outlineVariant,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: colors.outlineVariant,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: AppColors.primary,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: colors.error,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: colors.error,
          width: 1.5,
        ),
      ),
    );
  }

  Widget _field({
    required BuildContext context,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      keyboardType: keyboardType,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: colors.onSurface,
        fontWeight: FontWeight.w500,
      ),
      decoration: _inputDecoration(
        context: context,
        hint: hint,
        icon: icon,
        suffixIcon: suffixIcon,
      ),
    );
  }

  Widget _sectionTitle({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(14),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.secondaryText,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required BuildContext context,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colors.outlineVariant,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _avatarSelector() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      children: [
        Text(
          'Choose your profile image',
          style: theme.textTheme.titleSmall?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'Select an avatar or upload your own photo',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.secondaryText,
          ),
        ),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _avatarOption(
              image: AppImages.doctorAvatar1,
              value: 'doctor_1',
            ),
            const SizedBox(width: 18),
            _avatarOption(
              image: AppImages.doctorAvatar2,
              value: 'doctor_2',
            ),
            const SizedBox(width: 18),
            _uploadAvatar(),
          ],
        ),
      ],
    );
  }

  Widget _avatarOption({
    required String image,
    required String value,
  }) {
    final colors = Theme.of(context).colorScheme;
    final selected = selectedAvatar == value;

    return GestureDetector(
      onTap: () => _selectAvatar(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 76,
        height: 76,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: selected
                ? AppColors.primary
                : colors.surface,
            width: 3,
          ),
        ),
        child: ClipOval(
          child: Image.asset(
            image,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _uploadAvatar() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final selected = profileImage != null;

    return GestureDetector(
      onTap: _pickImage,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 76,
        height: 76,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: selected
                ? AppColors.primary
                : colors.outlineVariant,
            width: 3,
          ),
        ),
        child: ClipOval(
          child: profileImage != null
              ? Image.file(
            profileImage!,
            fit: BoxFit.cover,
          )
              : Container(
            color: AppColors.primarySoft,
            child: Icon(
              Icons.add_a_photo_outlined,
              color: AppColors.primary,
              size: 26,
            ),
          ),
        ),
      ),
    );
  }

  void _selectAvatar(String value) {
    setState(() {
      selectedAvatar = value;
      profileImage = null;
    });
  }

  Widget _timeTile({
    required BuildContext context,
    required bool isStart,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final time = isStart ? startTime : endTime;

    return Expanded(
      child: GestureDetector(
        onTap: () async {
          final picked = await showTimePicker(
            context: context,
            initialTime: time ??
                TimeOfDay(
                  hour: isStart ? 9 : 17,
                  minute: 0,
                ),
          );

          if (picked != null) {
            setState(() {
              if (isStart) {
                startTime = picked;
              } else {
                endTime = picked;
              }
            });
          }
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest.withValues(
              alpha: 0.35,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: colors.outlineVariant,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isStart
                      ? Icons.login_rounded
                      : Icons.logout_rounded,
                  color: AppColors.primary,
                  size: 19,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      isStart ? 'Start Time' : 'End Time',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.secondaryText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      time == null
                          ? 'Select'
                          : TimeUtils.formatTimeOfDay(time),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.secondaryText,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final auth = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                12,
                20,
                8,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(
                          color: colors.outlineVariant,
                        ),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 17,
                        color: colors.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.googleFlow
                              ? 'Doctor Setup'
                              : 'Doctor Registration',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Create your professional profile',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(
                      Icons.medical_services_outlined,
                      color: AppColors.primary,
                      size: 21,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Form(
                key: formKey,
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    12,
                    20,
                    35,
                  ),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(26),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding:
                                  const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colors.onPrimary.withValues(
                                      alpha: 0.15,
                                    ),
                                    borderRadius:
                                    BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'DOCTOR PORTAL',
                                    style: theme
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                      color: colors.onPrimary,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Your care,\nyour profile.',
                                  style: theme
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                    color: colors.onPrimary,
                                    height: 1.1,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Complete your details to connect with patients.',
                                  style: theme
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                    color: colors.onPrimary.withValues(
                                      alpha: 0.78,
                                    ),
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: colors.onPrimary.withValues(
                                    alpha: 0.12,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Image.asset(
                                AppImages.doctorAvatar1,
                                width: 94,
                                height: 94,
                                fit: BoxFit.contain,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _sectionCard(
                      context: context,
                      child: Column(
                        children: [
                          _sectionTitle(
                            context: context,
                            icon: Icons.person_outline,
                            title: 'Profile picture',
                            subtitle:
                            'Choose how patients will see you',
                          ),
                          _avatarSelector(),
                        ],
                      ),
                    ),
                    if (!widget.googleFlow) ...[
                      const SizedBox(height: 18),
                      _sectionCard(
                        context: context,
                        child: Column(
                          children: [
                            _sectionTitle(
                              context: context,
                              icon: Icons.lock_outline,
                              title: 'Account details',
                              subtitle:
                              'Set up your login information',
                            ),
                            _field(
                              context: context,
                              controller: nameController,
                              hint: 'Full name',
                              icon: Icons.person_outline,
                              validator: _requiredValidator,
                            ),
                            const SizedBox(height: 12),
                            _field(
                              context: context,
                              controller: emailController,
                              hint: 'Email address',
                              icon: Icons.email_outlined,
                              keyboardType:
                              TextInputType.emailAddress,
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
                            _field(
                              context: context,
                              controller: passwordController,
                              hint: 'Password',
                              icon: Icons.lock_outline,
                              obscureText: obscurePassword,
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    obscurePassword =
                                    !obscurePassword;
                                  });
                                },
                                icon: Icon(
                                  obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: AppColors.secondaryText,
                                ),
                              ),
                              validator: (value) {
                                if (value == null ||
                                    value.length < 6) {
                                  return 'Minimum 6 characters';
                                }

                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            _field(
                              context: context,
                              controller:
                              confirmPasswordController,
                              hint: 'Confirm password',
                              icon: Icons.lock_reset_outlined,
                              obscureText:
                              obscureConfirmPassword,
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    obscureConfirmPassword =
                                    !obscureConfirmPassword;
                                  });
                                },
                                icon: Icon(
                                  obscureConfirmPassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: AppColors.secondaryText,
                                ),
                              ),
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty) {
                                  return 'Required';
                                }

                                if (value !=
                                    passwordController.text) {
                                  return 'Passwords do not match';
                                }

                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),
                    _sectionCard(
                      context: context,
                      child: Column(
                        children: [
                          _sectionTitle(
                            context: context,
                            icon: Icons.badge_outlined,
                            title: 'Professional details',
                            subtitle:
                            'Tell patients about your medical expertise',
                          ),
                          _field(
                            context: context,
                            controller: phoneController,
                            hint: 'Phone number',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            validator: _requiredValidator,
                          ),
                          const SizedBox(height: 12),
                          _field(
                            context: context,
                            controller:
                            specializationController,
                            hint: 'Specialization',
                            icon:
                            Icons.local_hospital_outlined,
                            validator: _requiredValidator,
                          ),
                          const SizedBox(height: 12),
                          _field(
                            context: context,
                            controller: licenseController,
                            hint: 'Medical license number',
                            icon:
                            Icons.verified_user_outlined,
                            validator: _requiredValidator,
                          ),
                          const SizedBox(height: 12),
                          _field(
                            context: context,
                            controller:
                            experienceController,
                            hint: 'Years of experience',
                            icon:
                            Icons.work_history_outlined,
                            keyboardType:
                            TextInputType.number,
                            validator: _requiredValidator,
                          ),
                          const SizedBox(height: 12),
                          _field(
                            context: context,
                            controller:
                            qualificationController,
                            hint: 'Qualification',
                            icon: Icons.school_outlined,
                            validator: _requiredValidator,
                          ),
                          const SizedBox(height: 12),
                          _field(
                            context: context,
                            controller: hospitalController,
                            hint: 'Hospital / Clinic',
                            icon: Icons.apartment_outlined,
                            validator: _requiredValidator,
                          ),
                          const SizedBox(height: 12),
                          _field(
                            context: context,
                            controller: feeController,
                            hint: 'Consultation fee',
                            icon: Icons.payments_outlined,
                            keyboardType:
                            TextInputType.number,
                            validator: _requiredValidator,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    _sectionCard(
                      context: context,
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          _sectionTitle(
                            context: context,
                            icon: Icons.calendar_month_outlined,
                            title: 'Availability',
                            subtitle:
                            'Set your working days and consultation hours',
                          ),
                          Text(
                            'Working days',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colors.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 9,
                            children: days.map((day) {
                              final selected =
                              selectedDays.contains(day);

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (selected) {
                                      selectedDays.remove(day);
                                    } else {
                                      selectedDays.add(day);
                                    }
                                  });
                                },
                                child: AnimatedContainer(
                                  duration:
                                  const Duration(
                                    milliseconds: 180,
                                  ),
                                  padding:
                                  const EdgeInsets.symmetric(
                                    horizontal: 13,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? AppColors.primary
                                        : colors
                                        .surfaceContainerHighest
                                        .withValues(
                                      alpha: 0.35,
                                    ),
                                    borderRadius:
                                    BorderRadius.circular(
                                      13,
                                    ),
                                    border: Border.all(
                                      color: selected
                                          ? AppColors.primary
                                          : colors
                                          .outlineVariant,
                                    ),
                                  ),
                                  child: Text(
                                    day.substring(0, 3),
                                    style: theme
                                        .textTheme
                                        .labelMedium
                                        ?.copyWith(
                                      color: selected
                                          ? colors.onPrimary
                                          : AppColors
                                          .secondaryText,
                                      fontWeight:
                                      FontWeight.w700,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Consultation hours',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colors.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              _timeTile(
                                context: context,
                                isStart: true,
                              ),
                              const SizedBox(width: 10),
                              _timeTile(
                                context: context,
                                isStart: false,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    Obx(
                          () => SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: ElevatedButton(
                          onPressed:
                          auth.isLoading.value
                              ? null
                              : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                            AppColors.primary,
                            foregroundColor:
                            colors.onPrimary,
                            disabledBackgroundColor:
                            AppColors.primary.withValues(
                              alpha: 0.55,
                            ),
                            elevation: 0,
                            shape:
                            RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(18),
                            ),
                          ),
                          child: auth.isLoading.value
                              ? SizedBox(
                            width: 23,
                            height: 23,
                            child:
                            CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color:
                              colors.onPrimary,
                            ),
                          )
                              : Row(
                            mainAxisAlignment:
                            MainAxisAlignment.center,
                            children: [
                              Text(
                                widget.googleFlow
                                    ? 'Complete Doctor Profile'
                                    : 'Create Doctor Account',
                                style: theme
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                  color:
                                  colors.onPrimary,
                                  fontWeight:
                                  FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 9),
                              Icon(
                                Icons
                                    .arrow_forward_rounded,
                                color:
                                colors.onPrimary,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.verified_user_outlined,
                          color: AppColors.primary,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Your information is securely stored',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color:
                            AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}