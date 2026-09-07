import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/appointment_model.dart';
import '../../models/chat_model.dart';
import '../../models/reminder_model.dart';
import '../../models/user_model.dart';

class DataService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users => _db.collection('users');
  CollectionReference<Map<String, dynamic>> get _reminders => _db.collection('reminders');
  CollectionReference<Map<String, dynamic>> get _appointments => _db.collection('appointments');
  CollectionReference<Map<String, dynamic>> get _chats => _db.collection('chats');

  Stream<List<AppUser>> doctorsStream() {
    return _users.where('role', isEqualTo: 'doctor').snapshots().map(
          (snap) => snap.docs.map((d) => AppUser.fromMap(d.data())).toList(),
        );
  }

  Stream<List<AppUser>> patientsStream() {
    return _users.where('role', isEqualTo: 'patient').snapshots().map(
          (snap) => snap.docs.map((d) => AppUser.fromMap(d.data())).toList(),
        );
  }

  Stream<List<AppUser>> allUsersStream() {
    return _users.snapshots().map(
          (snap) => snap.docs.map((d) => AppUser.fromMap(d.data())).toList(),
        );
  }

  Stream<List<ReminderModel>> remindersStream(String userId) {
    return _reminders.where('userId', isEqualTo: userId).snapshots().map(
          (snap) => snap.docs
              .map((d) => ReminderModel.fromMap(d.id, d.data()))
              .toList(),
        );
  }

  Future<void> addReminder(ReminderModel reminder) {
    return _reminders.add({
      ...reminder.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateReminder(String id, Map<String, dynamic> data) {
    return _reminders.doc(id).update(data);
  }

  Future<void> deleteReminder(String id) => _reminders.doc(id).delete();

  Stream<List<AppointmentModel>> patientAppointments(String patientId) {
    return _appointments.where('patientId', isEqualTo: patientId).snapshots().map(
          (snap) => snap.docs
              .map((d) => AppointmentModel.fromMap(d.id, d.data()))
              .toList(),
        );
  }

  Stream<List<AppointmentModel>> doctorAppointments(String doctorId) {
    return _appointments.where('doctorId', isEqualTo: doctorId).snapshots().map(
          (snap) => snap.docs
              .map((d) => AppointmentModel.fromMap(d.id, d.data()))
              .toList(),
        );
  }

  Future<List<AppointmentModel>> bookedSlots({
    required String doctorId,
    required String date,
  }) async {
    final snap = await _appointments
        .where('doctorId', isEqualTo: doctorId)
        .where('date', isEqualTo: date)
        .get();

    return snap.docs
        .map((d) => AppointmentModel.fromMap(d.id, d.data()))
        .where((a) => a.status == 'pending' || a.status == 'confirmed')
        .toList();
  }

  Future<void> bookAppointment(AppointmentModel appointment) {
    return _appointments.add({
      ...appointment.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateAppointmentStatus(String id, String status) {
    return _appointments.doc(id).update({'status': status});
  }

  String chatIdFor(String a, String b) {
    final ids = [a, b]..sort();
    return ids.join('_');
  }

  Future<String> openChat({
    required String currentUid,
    required String otherUid,
    required String type,
  }) async {
    final id = chatIdFor(currentUid, otherUid);
    final doc = _chats.doc(id);
    final existing = await doc.get();
    if (!existing.exists) {
      await doc.set({
        'participants': [currentUid, otherUid],
        'type': type,
        'lastMessage': '',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    return id;
  }

  Stream<List<ChatModel>> chatsStream(String uid) {
    return _chats.where('participants', arrayContains: uid).snapshots().map(
          (snap) => snap.docs.map((d) => ChatModel.fromMap(d.id, d.data())).toList(),
        );
  }

  Stream<List<MessageModel>> messagesStream(String chatId) {
    return _chats
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => MessageModel.fromMap(d.id, d.data()))
              .toList(),
        );
  }

  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
  }) async {
    final batch = _db.batch();
    final messageRef = _chats.doc(chatId).collection('messages').doc();
    batch.set(messageRef, {
      'senderId': senderId,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    });
    batch.update(_chats.doc(chatId), {
      'lastMessage': text,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }
}
