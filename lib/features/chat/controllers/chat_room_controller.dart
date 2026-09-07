import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/data_service.dart';
import '../../../models/chat_model.dart';
import '../../../models/user_model.dart';
import '../../auth/controllers/auth_controller.dart';

class ChatRoomController extends GetxController {
  ChatRoomController({
    required this.dataService,
    required this.chatId,
    required this.other,
  });

  final DataService dataService;
  final String chatId;
  final AppUser other;
  final messages = <MessageModel>[].obs;
  final textController = TextEditingController();

  String get myUid => Get.find<AuthController>().currentUser.value?.uid ?? '';

  @override
  void onInit() {
    super.onInit();
    messages.bindStream(dataService.messagesStream(chatId));
  }

  Future<void> send() async {
    final text = textController.text.trim();
    if (text.isEmpty) return;
    textController.clear();
    await dataService.sendMessage(
      chatId: chatId,
      senderId: myUid,
      text: text,
    );
  }

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }
}
