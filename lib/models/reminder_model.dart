import 'package:cloud_firestore/cloud_firestore.dart';

class ReminderModel {
  final String id;
  final String userId;
  final String medicineName;
  final String dosage;
  final List<String> times;
  final List<String> days;
  final String notes;
  final List<String> takenDates;
  final DateTime? createdAt;

  const ReminderModel({
    required this.id,
    required this.userId,
    required this.medicineName,
    required this.dosage,
    required this.times,
    required this.days,
    this.notes = '',
    this.takenDates = const [],
    this.createdAt,
  });

  factory ReminderModel.fromMap(String id, Map<String, dynamic> map) {
    return ReminderModel(
      id: id,
      userId: map['userId'] ?? '',
      medicineName: map['medicineName'] ?? '',
      dosage: map['dosage'] ?? '',
      times: List<String>.from(map['times'] ?? const []),
      days: List<String>.from(map['days'] ?? const []),
      notes: map['notes'] ?? '',
      takenDates: List<String>.from(map['takenDates'] ?? const []),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'medicineName': medicineName,
      'dosage': dosage,
      'times': times,
      'days': days,
      'notes': notes,
      'takenDates': takenDates,
      'createdAt': createdAt,
    };
  }
}
