import 'package:get/get.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/services/data_service.dart';
import '../../../models/chat_model.dart';
import '../../../models/user_model.dart';
import '../../auth/controllers/auth_controller.dart';

class ChatListController extends GetxController {
  final DataService dataService;
  ChatListController({required this.dataService});

  final users = <AppUser>[].obs;
  final chats = <ChatModel>[].obs;
  final query = ''.obs;

  AppUser? get me => Get.find<AuthController>().currentUser.value;

  @override
  void onInit() {
    super.onInit();
    users.bindStream(dataService.allUsersStream());
    final uid = me?.uid;
    if (uid != null) {
      chats.bindStream(dataService.chatsStream(uid));
    }
  }

  List<AppUser> filtered({required String role}) {
    final q = query.value.trim().toLowerCase();
    return users.where((u) {
      if (u.uid == me?.uid) return false;
      if (u.role != role) return false;
      if (q.isEmpty) return true;
      return u.name.toLowerCase().contains(q) ||
          u.specialization.toLowerCase().contains(q);
    }).toList();
  }

  Future<void> openChat(AppUser other) async {
    final current = me;
    if (current == null) return;
    final type = other.isDoctor || current.isDoctor ? 'doctor' : 'peer';
    final chatId = await dataService.openChat(
      currentUid: current.uid,
      otherUid: other.uid,
      type: type,
    );
    Get.toNamed(
      AppRoutes.chatRoom,
      arguments: {
        'chatId': chatId,
        'other': other,
      },
    );
  }
}
