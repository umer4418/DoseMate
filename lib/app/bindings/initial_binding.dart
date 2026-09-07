import 'package:get/get.dart';

import '../../core/services/auth_service.dart';
import '../../core/services/data_service.dart';
import '../../core/services/prefs_service.dart';
import '../../features/auth/controllers/auth_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(PrefsService(), permanent: true);
    Get.put(AuthService(), permanent: true);
    Get.put(DataService(), permanent: true);
    Get.put(
      AuthController(
        authService: Get.find(),
        prefsService: Get.find(),
      ),
      permanent: true,
    );
  }
}
