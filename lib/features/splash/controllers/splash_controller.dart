import 'package:get/get.dart';

import '../../../core/routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    _boot();
  }

  Future<void> _boot() async {
    // Keep splash screen visible for 2.2 seconds
    await Future.delayed(
      const Duration(milliseconds: 2200),
    );

    // Always show onboarding when the app starts
    Get.offAllNamed(AppRoutes.onboarding);
  }
}