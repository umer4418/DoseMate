import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_images.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/responsive.dart';

class SignupRoleView extends StatelessWidget {
  const SignupRoleView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ResponsiveScaffoldBody(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    Responsive.pagePadding(context),
                    18,
                    Responsive.pagePadding(context),
                    24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _TopBar(
                        onBack: () => Get.back(),
                        icon: Icons.person_add_alt_1_rounded,
                      ),
                      const SizedBox(height: 24),
                      _HeroSection(
                        title: 'Create your\nDoseMate account',
                        subtitle:
                        'Choose your role to get started with a personalized healthcare experience.',
                      ),
                      const SizedBox(height: 28),
                      Text(
                        'Choose your role',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Select the option that best describes you.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.secondaryText,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _RoleCard(
                        image: AppImages.heroPatient,
                        icon: Icons.person_rounded,
                        title: 'I’m a Patient',
                        subtitle:
                        'Manage medicines, book doctors, get reminders and chat with healthcare professionals.',
                        badge: 'PATIENT',
                        onTap: () =>
                            Get.toNamed(AppRoutes.patientSignup),
                      ),
                      const SizedBox(height: 16),
                      _RoleCard(
                        image: AppImages.doctorAvatar1,
                        icon: Icons.medical_services_rounded,
                        title: 'I’m a Doctor',
                        subtitle:
                        'Manage appointments, availability, consultations and patient communication.',
                        badge: 'DOCTOR',
                        onTap: () =>
                            Get.toNamed(AppRoutes.doctorSignup),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _LoginPrompt(
              onTap: Get.back,
            ),
          ],
        ),
      ),
    );
  }
}

class GoogleRoleView extends StatelessWidget {
  const GoogleRoleView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ResponsiveScaffoldBody(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    Responsive.pagePadding(context),
                    18,
                    Responsive.pagePadding(context),
                    24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _TopBar(
                        onBack: () => Get.back(),
                        icon: Icons.g_mobiledata_rounded,
                      ),
                      const SizedBox(height: 24),
                      _HeroSection(
                        title: 'Complete your\nGoogle signup',
                        subtitle:
                        'Tell us how you want to use DoseMate so we can personalize your experience.',
                        google: true,
                      ),
                      const SizedBox(height: 28),
                      Text(
                        'Continue as',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Choose your account type.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.secondaryText,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _RoleCard(
                        image: AppImages.heroPatient,
                        icon: Icons.person_rounded,
                        title: 'Continue as Patient',
                        subtitle:
                        'Track medicines, manage reminders, book appointments and consult doctors.',
                        badge: 'PATIENT',
                        onTap: () =>
                            Get.toNamed(AppRoutes.googlePatient),
                      ),
                      const SizedBox(height: 16),
                      _RoleCard(
                        image: AppImages.doctorAvatar2,
                        icon: Icons.medical_services_rounded,
                        title: 'Continue as Doctor',
                        subtitle:
                        'Offer consultations, manage appointments and control your availability.',
                        badge: 'DOCTOR',
                        onTap: () =>
                            Get.toNamed(AppRoutes.googleDoctor),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _LoginPrompt(
              onTap: Get.back,
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.onBack,
    required this.icon,
  });

  final VoidCallback onBack;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        InkWell(
          onTap: onBack,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(14),
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
        const Spacer(),
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
            size: 23,
          ),
        ),
      ],
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({
    required this.title,
    required this.subtitle,
    this.google = false,
  });

  final String title;
  final String subtitle;
  final bool google;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -28,
            top: -34,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                color: colors.onPrimary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 24,
            bottom: -50,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: colors.onPrimary.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colors.onPrimary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      google
                          ? Icons.g_mobiledata_rounded
                          : Icons.health_and_safety_rounded,
                      color: colors.onPrimary,
                      size: 18,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      google ? 'GOOGLE SIGNUP' : 'WELCOME TO DOSEMATE',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colors.onPrimary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: colors.onPrimary,
                  fontWeight: FontWeight.w800,
                  height: 1.08,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onPrimary.withValues(alpha: 0.78),
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    width: 25,
                    height: 25,
                    decoration: BoxDecoration(
                      color: colors.onPrimary.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.verified_rounded,
                      color: colors.onPrimary,
                      size: 15,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Secure & personalized',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colors.onPrimary.withValues(alpha: 0.88),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.image,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.onTap,
  });

  final String image;
  final IconData icon;
  final String title;
  final String subtitle;
  final String badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: colors.outlineVariant,
            ),
            boxShadow: [
              BoxShadow(
                color: colors.shadow.withValues(alpha: 0.045),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(19),
                    child: Image.asset(
                      image,
                      width: 88,
                      height: 88,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    left: 7,
                    bottom: 7,
                    child: Container(
                      width: 31,
                      height: 31,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: colors.surface,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        icon,
                        color: colors.onPrimary,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        badge,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.secondaryText,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.primary,
                  size: 19,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginPrompt extends StatelessWidget {
  const _LoginPrompt({
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Center(
          child: TextButton(
            onPressed: onTap,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
            ),
            child: RichText(
              text: TextSpan(
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.secondaryText,
                ),
                children: [
                  const TextSpan(
                    text: 'Already have an account? ',
                  ),
                  TextSpan(
                    text: 'Login',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}