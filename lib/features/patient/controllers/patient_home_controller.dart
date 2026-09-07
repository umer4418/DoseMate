import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/services/data_service.dart';
import '../../../core/utils/time_utils.dart';
import '../../../models/reminder_model.dart';
import '../../../models/user_model.dart';
import '../../auth/controllers/auth_controller.dart';

class PatientHomeController extends GetxController {
  final DataService dataService;
  PatientHomeController({required this.dataService});

  final tabIndex = 0.obs;
  final reminders = <ReminderModel>[].obs;

  AppUser? get user => Get.find<AuthController>().currentUser.value;

  @override
  void onInit() {
    super.onInit();
    final uid = user?.uid;
    if (uid != null) {
      reminders.bindStream(dataService.remindersStream(uid));
    }
  }

  List<ReminderModel> get todaysReminders {
    final day = DateFormat('EEEE').format(DateTime.now());
    return reminders.where((r) => r.days.contains(day) || r.days.isEmpty).toList();
  }

  String greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Future<void> markTaken(ReminderModel reminder) async {
    final key = TimeUtils.dateKey(DateTime.now());
    final taken = [...reminder.takenDates];
    if (!taken.contains(key)) taken.add(key);
    await dataService.updateReminder(reminder.id, {'takenDates': taken});
  }
}
