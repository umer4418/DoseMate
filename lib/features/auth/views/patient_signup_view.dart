import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/widgets/responsive.dart';
import '../controllers/auth_controller.dart';

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
    final file = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (file != null) setState(() => image = File(file.path));
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Patient Registration')),
      body: ResponsiveScaffoldBody(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(Responsive.pagePadding(context)),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pick,
                  child: CircleAvatar(
                    radius: 52,
                    backgroundColor: AppColors.primarySoft,
                    backgroundImage: image != null ? FileImage(image!) : null,
                    child: image == null
                        ? const Icon(Icons.camera_alt, color: AppColors.primary, size: 32)
                        : null,
                  ),
                ),
                const SizedBox(height: 8),
                const Text('Profile picture is optional', style: TextStyle(color: AppColors.secondaryText)),
                const SizedBox(height: 22),
                AppTextField(
                  controller: name,
                  hint: 'Full name',
                  icon: Icons.person_outline,
                  validator: (v) => v == null || v.trim().length < 3 ? 'Enter your name' : null,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: email,
                  hint: 'Email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v == null || !v.contains('@') ? 'Enter a valid email' : null,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: password,
                  hint: 'Password',
                  icon: Icons.lock_outline,
                  obscureText: obscure,
                  suffix: IconButton(
                    icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => obscure = !obscure),
                  ),
                  validator: (v) => v == null || v.length < 6 ? 'Min 6 characters' : null,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: confirm,
                  hint: 'Confirm password',
                  icon: Icons.lock_reset_outlined,
                  obscureText: obscureConfirm,
                  suffix: IconButton(
                    icon: Icon(obscureConfirm ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => obscureConfirm = !obscureConfirm),
                  ),
                  validator: (v) => v != password.text ? 'Passwords do not match' : null,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: phone,
                  hint: 'Phone number',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (v) => v == null || v.length < 7 ? 'Enter a valid phone' : null,
                ),
                const SizedBox(height: 14),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime(2000),
                      firstDate: DateTime(1940),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) setState(() => dob = picked);
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.cake_outlined, color: AppColors.primary),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(
                      dob == null ? 'Date of birth' : '${dob!.day}/${dob!.month}/${dob!.year}',
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: gender,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.wc_outlined, color: AppColors.primary),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  hint: const Text('Gender'),
                  items: const [
                    DropdownMenuItem(value: 'Male', child: Text('Male')),
                    DropdownMenuItem(value: 'Female', child: Text('Female')),
                    DropdownMenuItem(value: 'Other', child: Text('Other')),
                  ],
                  onChanged: (v) => setState(() => gender = v),
                ),
                const SizedBox(height: 24),
                Obx(
                  () => PrimaryButton(
                    label: 'Create Patient Account',
                    loading: auth.isLoading.value,
                    onPressed: () {
                      if (!formKey.currentState!.validate()) return;
                      if (dob == null || gender == null) {
                        Get.snackbar('Missing details', 'Select date of birth and gender.');
                        return;
                      }
                      auth.registerPatient(
                        name: name.text,
                        email: email.text,
                        password: password.text,
                        phone: phone.text,
                        dateOfBirth: '${dob!.day}/${dob!.month}/${dob!.year}',
                        gender: gender!,
                        image: image,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
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
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Patient details')),
      body: Padding(
        padding: EdgeInsets.all(Responsive.pagePadding(context)),
        child: Column(
          children: [
            AppTextField(
              controller: phone,
              hint: 'Phone number',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 14),
            ListTile(
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(dob == null ? 'Date of birth' : '${dob!.day}/${dob!.month}/${dob!.year}'),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime(2000),
                  firstDate: DateTime(1940),
                  lastDate: DateTime.now(),
                );
                if (picked != null) setState(() => dob = picked);
              },
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: gender,
              items: const [
                DropdownMenuItem(value: 'Male', child: Text('Male')),
                DropdownMenuItem(value: 'Female', child: Text('Female')),
                DropdownMenuItem(value: 'Other', child: Text('Other')),
              ],
              onChanged: (v) => setState(() => gender = v),
              decoration: const InputDecoration(hintText: 'Gender'),
            ),
            const Spacer(),
            Obx(
              () => PrimaryButton(
                label: 'Finish setup',
                loading: auth.isLoading.value,
                onPressed: () {
                  if (dob == null || gender == null) {
                    Get.snackbar('Missing details', 'Select date of birth and gender.');
                    return;
                  }
                  auth.completeGooglePatient(
                    phone: phone.text,
                    dateOfBirth: '${dob!.day}/${dob!.month}/${dob!.year}',
                    gender: gender!,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
