class PatientModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String dateOfBirth;
  final String gender;
  final String role;
  final String? profileImage;
  final DateTime? createdAt;

  PatientModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.dateOfBirth,
    required this.gender,
    this.role = 'patient',
    this.profileImage,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'role': role,
      'profileImage': profileImage,
      'createdAt': createdAt,
    };
  }

  factory PatientModel.fromMap(Map<String, dynamic> map) {
    return PatientModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      dateOfBirth: map['dateOfBirth'] ?? '',
      gender: map['gender'] ?? '',
      role: map['role'] ?? 'patient',
      profileImage: map['profileImage'],
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as dynamic).toDate()
          : null,
    );
  }
}