import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String id;
  final List<String> participants;
  final String type;
  final String lastMessage;
  final DateTime? updatedAt;

  const ChatModel({
    required this.id,
    required this.participants,
    required this.type,
    this.lastMessage = '',
    this.updatedAt,
  });

  factory ChatModel.fromMap(String id, Map<String, dynamic> map) {
    return ChatModel(
      id: id,
      participants: List<String>.from(map['participants'] ?? const []),
      type: map['type'] ?? 'peer',
      lastMessage: map['lastMessage'] ?? '',
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}

class MessageModel {
  final String id;
  final String senderId;
  final String text;
  final DateTime? createdAt;

  const MessageModel({
    required this.id,
    required this.senderId,
    required this.text,
    this.createdAt,
  });

  factory MessageModel.fromMap(String id, Map<String, dynamic> map) {
    return MessageModel(
      id: id,
      senderId: map['senderId'] ?? '',
      text: map['text'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
