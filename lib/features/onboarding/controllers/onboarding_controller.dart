import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_images.dart';
import '../../../core/routes/app_routes.dart';

class OnboardingController extends GetxController {
  final PageController pageController = PageController();

  final RxInt index = 0.obs;

  final List<Map<String, String>> pages = const [
    {
      'title': 'Never miss a dose',
      'description':
      'Smart medicine reminders keep you on track every day, with a timeline built around your routine.',
      'image': AppImages.onboardingReminders,
    },
    {
      'title': 'Consult trusted doctors',
      'description':
      'Browse specialists, check live availability, and book appointments that actually fit your schedule.',
      'image': AppImages.onboardingDoctors,
    },
    {
      'title': 'Stay connected & well',
      'description':
      'Chat with doctors or other patients, manage bookings, and take control of your health in one place.',
      'image': AppImages.onboardingHealth,
    },
  ];

  void onPageChanged(int value) {
    index.value = value;
  }

  void next() {
    if (index.value == pages.length - 1) {
      finish();
      return;
    }

    pageController.nextPage(
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeInOut,
    );
  }

  void finish() {
    Get.offAllNamed(AppRoutes.login);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}