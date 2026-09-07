import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_images.dart';
import '../../../core/widgets/responsive.dart';

class SignupRoleView extends StatelessWidget {
  const SignupRoleView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ResponsiveScaffoldBody(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: Responsive.pagePadding(context)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkText,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Choose how you want to join DoseMate.',
                style: TextStyle(color: AppColors.secondaryText, fontSize: 16),
              ),
              const SizedBox(height: 28),
              _RoleCard(
                image: AppImages.heroPatient,
                title: 'Signup as Patient',
                subtitle: 'Reminders, doctor consults, live chat and bookings',
                onTap: () => Get.toNamed(AppRoutes.patientSignup),
              ),
              const SizedBox(height: 16),
              _RoleCard(
                image: AppImages.doctorAvatar1,
                title: 'Signup as Doctor',
                subtitle: 'Manage availability, appointments and patient chats',
                onTap: () => Get.toNamed(AppRoutes.doctorSignup),
              ),
              const Spacer(),
              Center(
                child: TextButton(
                  onPressed: Get.back,
                  child: const Text(
                    'Already have an account? Login',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class GoogleRoleView extends StatelessWidget {
  const GoogleRoleView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complete Google signup')),
      body: ResponsiveScaffoldBody(
        child: Padding(
          padding: EdgeInsets.all(Responsive.pagePadding(context)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'How should we set up your Google account?',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 20),
              _RoleCard(
                image: AppImages.heroPatient,
                title: 'Continue as Patient',
                subtitle: 'Track medicines and consult doctors',
                onTap: () => Get.toNamed(AppRoutes.googlePatient),
              ),
              const SizedBox(height: 16),
              _RoleCard(
                image: AppImages.doctorAvatar2,
                title: 'Continue as Doctor',
                subtitle: 'Offer consults and manage booking availability',
                onTap: () => Get.toNamed(AppRoutes.googleDoctor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.image,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String image;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(image, width: 72, height: 72, fit: BoxFit.cover),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
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
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16),
          ],
        ),
      ),
    );
  }
}
