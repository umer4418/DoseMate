import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/widgets/responsive.dart';
import '../controllers/auth_controller.dart';

Widget patientSectionTitle({
  required BuildContext context,
  required IconData icon,
  required String title,
  required String subtitle,
}) {
  final theme = Theme.of(context);
  final colors = theme.colorScheme;

  return Row(
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
  );
}

Widget patientSectionCard({
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

class PatientSignupView extends StatefulWidget {
  const PatientSignupView({super.key});

  @override
  State<PatientSignupView> createState() => _PatientSignupViewState();
}

class _PatientSignupViewState extends State<PatientSignupView> {
  final formKey = GlobalKey<FormState>();

  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirm = TextEditingController();
  final phone = TextEditingController();

  DateTime? dob;
  String? gender;
  File? image;

  bool obscure = true;
  bool obscureConfirm = true;

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    password.dispose();
    confirm.dispose();
    phone.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 1000,
        maxHeight: 1000,
      );

      if (file != null) {
        setState(() {
          image = File(file.path);
        });
      }
    } catch (e) {
      Get.snackbar(
        'Image Error',
        'Unable to select profile picture.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: dob ?? DateTime(2000),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      builder: (context, child) {
        final theme = Theme.of(context);

        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        dob = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  InputDecoration _dropdownDecoration({
    required BuildContext context,
    required IconData icon,
  }) {
    final colors = Theme.of(context).colorScheme;

    return InputDecoration(
      prefixIcon: Icon(
        icon,
        color: AppColors.primary,
        size: 21,
      ),
      filled: true,
      fillColor: colors.surfaceContainerHighest.withValues(
        alpha: 0.35,
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

  Widget _profilePicker() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      children: [
        GestureDetector(
          onTap: _pick,
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 112,
                height: 112,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primarySoft,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.18),
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  backgroundColor: AppColors.primarySoft,
                  backgroundImage:
                  image != null ? FileImage(image!) : null,
                  child: image == null
                      ? Icon(
                    Icons.person_outline_rounded,
                    color: AppColors.primary,
                    size: 48,
                  )
                      : null,
                ),
              ),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colors.surface,
                    width: 3,
                  ),
                ),
                child: Icon(
                  Icons.camera_alt_outlined,
                  color: colors.onPrimary,
                  size: 16,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Add profile picture',
          style: theme.textTheme.titleSmall?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Optional — you can add one later',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.secondaryText,
          ),
        ),
      ],
    );
  }

  Widget _datePicker() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest.withValues(
            alpha: 0.35,
          ),
          borderRadius: BorderRadius.circular(16),
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
                Icons.cake_outlined,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Date of birth',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    dob == null
                        ? 'Select your date of birth'
                        : _formatDate(dob!),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: dob == null
                          ? AppColors.secondaryText
                          : colors.onSurface,
                      fontWeight: dob == null
                          ? FontWeight.w400
                          : FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.calendar_month_outlined,
              color: AppColors.primary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _genderDropdown() {
    final theme = Theme.of(context);

    return DropdownButtonFormField<String>(
      initialValue: gender,
      decoration: _dropdownDecoration(
        context: context,
        icon: Icons.wc_outlined,
      ),
      hint: Text(
        'Select gender',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: AppColors.secondaryText,
        ),
      ),
      icon: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: AppColors.secondaryText,
      ),
      items: const [
        DropdownMenuItem(
          value: 'Male',
          child: Text('Male'),
        ),
        DropdownMenuItem(
          value: 'Female',
          child: Text('Female'),
        ),
        DropdownMenuItem(
          value: 'Other',
          child: Text('Other'),
        ),
      ],
      onChanged: (value) {
        setState(() {
          gender = value;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select your gender';
        }
        return null;
      },
    );
  }

  void _submit() {
    FocusScope.of(context).unfocus();

    if (!formKey.currentState!.validate()) {
      return;
    }

    if (dob == null) {
      Get.snackbar(
        'Missing details',
        'Please select your date of birth.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final auth = Get.find<AuthController>();

    auth.registerPatient(
      name: name.text.trim(),
      email: email.text.trim(),
      password: password.text,
      phone: phone.text.trim(),
      dateOfBirth: _formatDate(dob!),
      gender: gender!,
      image: image,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Patient Registration',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Create your personal health profile',
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
                      Icons.health_and_safety_outlined,
                      color: AppColors.primary,
                      size: 21,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ResponsiveScaffoldBody(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    Responsive.pagePadding(context),
                    12,
                    Responsive.pagePadding(context),
                    35,
                  ),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
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
                                      padding: const EdgeInsets.symmetric(
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
                                        'PATIENT PORTAL',
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                          color: colors.onPrimary,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Your health,\nyour journey.',
                                      style: theme.textTheme.headlineSmall
                                          ?.copyWith(
                                        color: colors.onPrimary,
                                        height: 1.1,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Create your profile to manage appointments and healthcare.',
                                      style: theme.textTheme.bodySmall
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
                              Container(
                                width: 88,
                                height: 88,
                                decoration: BoxDecoration(
                                  color: colors.onPrimary.withValues(
                                    alpha: 0.12,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.person_rounded,
                                  color: colors.onPrimary,
                                  size: 48,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        patientSectionCard(
                          context: context,
                          child: Column(
                            children: [
                              patientSectionTitle(
                                context: context,
                                icon: Icons.person_outline_rounded,
                                title: 'Profile picture',
                                subtitle:
                                'Help doctors recognize you easily',
                              ),
                              const SizedBox(height: 8),
                              _profilePicker(),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        patientSectionCard(
                          context: context,
                          child: Column(
                            children: [
                              patientSectionTitle(
                                context: context,
                                icon: Icons.lock_outline_rounded,
                                title: 'Account details',
                                subtitle:
                                'Set up your secure login information',
                              ),
                              const SizedBox(height: 4),
                              AppTextField(
                                controller: name,
                                hint: 'Full name',
                                icon: Icons.person_outline,
                                validator: (v) {
                                  if (v == null ||
                                      v.trim().length < 3) {
                                    return 'Enter your name';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              AppTextField(
                                controller: email,
                                hint: 'Email address',
                                icon: Icons.email_outlined,
                                keyboardType:
                                TextInputType.emailAddress,
                                validator: (v) {
                                  if (v == null ||
                                      v.trim().isEmpty) {
                                    return 'Enter your email';
                                  }

                                  if (!GetUtils.isEmail(
                                    v.trim(),
                                  )) {
                                    return 'Enter a valid email';
                                  }

                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              AppTextField(
                                controller: password,
                                hint: 'Password',
                                icon: Icons.lock_outline,
                                obscureText: obscure,
                                suffix: IconButton(
                                  icon: Icon(
                                    obscure
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color:
                                    AppColors.secondaryText,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      obscure = !obscure;
                                    });
                                  },
                                ),
                                validator: (v) {
                                  if (v == null || v.length < 6) {
                                    return 'Minimum 6 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              AppTextField(
                                controller: confirm,
                                hint: 'Confirm password',
                                icon: Icons.lock_reset_outlined,
                                obscureText: obscureConfirm,
                                suffix: IconButton(
                                  icon: Icon(
                                    obscureConfirm
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color:
                                    AppColors.secondaryText,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      obscureConfirm =
                                      !obscureConfirm;
                                    });
                                  },
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Confirm your password';
                                  }

                                  if (v != password.text) {
                                    return 'Passwords do not match';
                                  }

                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              AppTextField(
                                controller: phone,
                                hint: 'Phone number',
                                icon: Icons.phone_outlined,
                                keyboardType: TextInputType.phone,
                                validator: (v) {
                                  if (v == null ||
                                      v.trim().length < 7) {
                                    return 'Enter a valid phone';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        patientSectionCard(
                          context: context,
                          child: Column(
                            children: [
                              patientSectionTitle(
                                context: context,
                                icon: Icons.badge_outlined,
                                title: 'Personal details',
                                subtitle:
                                'A few details help personalize your care',
                              ),
                              const SizedBox(height: 4),
                              _datePicker(),
                              const SizedBox(height: 12),
                              _genderDropdown(),
                            ],
                          ),
                        ),
                        const SizedBox(height: 22),
                        Obx(
                              () => PrimaryButton(
                            label: 'Create Patient Account',
                            loading: auth.isLoading.value,
                            onPressed: auth.isLoading.value
                                ? null
                                : _submit,
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GooglePatientView extends StatefulWidget {
  const GooglePatientView({super.key});

  @override
  State<GooglePatientView> createState() => _GooglePatientViewState();
}

class _GooglePatientViewState extends State<GooglePatientView> {
  final phone = TextEditingController();

  DateTime? dob;
  String? gender;

  @override
  void dispose() {
    phone.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: dob ?? DateTime(2000),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      builder: (context, child) {
        final theme = Theme.of(context);

        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        dob = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  InputDecoration _dropdownDecoration() {
    final colors = Theme.of(context).colorScheme;

    return InputDecoration(
      prefixIcon: Icon(
        Icons.wc_outlined,
        color: AppColors.primary,
        size: 21,
      ),
      filled: true,
      fillColor: colors.surfaceContainerHighest.withValues(
        alpha: 0.35,
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

  Widget _datePicker() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest.withValues(
            alpha: 0.35,
          ),
          borderRadius: BorderRadius.circular(16),
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
                Icons.cake_outlined,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Date of birth',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    dob == null
                        ? 'Select your date of birth'
                        : _formatDate(dob!),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: dob == null
                          ? AppColors.secondaryText
                          : colors.onSurface,
                      fontWeight: dob == null
                          ? FontWeight.w400
                          : FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.calendar_month_outlined,
              color: AppColors.primary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    FocusScope.of(context).unfocus();

    if (dob == null || gender == null) {
      Get.snackbar(
        'Missing details',
        'Please select your date of birth and gender.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final auth = Get.find<AuthController>();

    auth.completeGooglePatient(
      phone: phone.text.trim(),
      dateOfBirth: _formatDate(dob!),
      gender: gender!,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

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
                          'Patient Setup',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Complete your health profile',
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
                      Icons.health_and_safety_outlined,
                      color: AppColors.primary,
                      size: 21,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  Responsive.pagePadding(context),
                  12,
                  Responsive.pagePadding(context),
                  30,
                ),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
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
                                    'GOOGLE SIGN-IN',
                                    style: theme
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                      color: colors.onPrimary,
                                      fontWeight:
                                      FontWeight.w800,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Almost\ndone.',
                                  style: theme
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                    color: colors.onPrimary,
                                    height: 1.1,
                                    fontWeight:
                                    FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Just a few details to complete your patient profile.',
                                  style: theme
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                    color: colors.onPrimary
                                        .withValues(
                                      alpha: 0.78,
                                    ),
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              color: colors.onPrimary.withValues(
                                alpha: 0.12,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.person_rounded,
                              color: colors.onPrimary,
                              size: 48,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    patientSectionCard(
                      context: context,
                      child: Column(
                        children: [
                          patientSectionTitle(
                            context: context,
                            icon: Icons.contact_phone_outlined,
                            title: 'Contact details',
                            subtitle:
                            'Add your phone number for appointments',
                          ),
                          const SizedBox(height: 8),
                          AppTextField(
                            controller: phone,
                            hint: 'Phone number',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            validator: (v) {
                              if (v == null ||
                                  v.trim().length < 7) {
                                return 'Enter a valid phone';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    patientSectionCard(
                      context: context,
                      child: Column(
                        children: [
                          patientSectionTitle(
                            context: context,
                            icon: Icons.badge_outlined,
                            title: 'Personal details',
                            subtitle:
                            'Complete your basic health profile',
                          ),
                          const SizedBox(height: 8),
                          _datePicker(),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            initialValue: gender,
                            decoration:
                            _dropdownDecoration(),
                            hint: Text(
                              'Select gender',
                              style: theme
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                color:
                                AppColors.secondaryText,
                              ),
                            ),
                            icon: Icon(
                              Icons
                                  .keyboard_arrow_down_rounded,
                              color:
                              AppColors.secondaryText,
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'Male',
                                child: Text('Male'),
                              ),
                              DropdownMenuItem(
                                value: 'Female',
                                child: Text('Female'),
                              ),
                              DropdownMenuItem(
                                value: 'Other',
                                child: Text('Other'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                gender = value;
                              });
                            },
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty) {
                                return 'Please select your gender';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    Obx(
                          () => PrimaryButton(
                        label: 'Finish Patient Setup',
                        loading: auth.isLoading.value,
                        onPressed: auth.isLoading.value
                            ? null
                            : _submit,
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