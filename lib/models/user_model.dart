class AppUser {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String? profileImage;
  final String dateOfBirth;
  final String gender;
  final String specialization;
  final String medicalLicenseNumber;
  final String experience;
  final String hospitalClinic;
  final String qualification;
  final String consultationFee;
  final List<String> workingDays;
  final String startTime;
  final String endTime;
  final bool isAvailable;
  final String authProvider;

  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    this.phone = '',
    required this.role,
    this.profileImage,
    this.dateOfBirth = '',
    this.gender = '',
    this.specialization = '',
    this.medicalLicenseNumber = '',
    this.experience = '',
    this.hospitalClinic = '',
    this.qualification = '',
    this.consultationFee = '',
    this.workingDays = const [],
    this.startTime = '',
    this.endTime = '',
    this.isAvailable = true,
    this.authProvider = 'password',
  });

  bool get isDoctor => role == 'doctor';
  bool get isPatient => role == 'patient';

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      role: map['role'] ?? 'patient',
      profileImage: map['profileImage'],
      dateOfBirth: map['dateOfBirth'] ?? '',
      gender: map['gender'] ?? '',
      specialization: map['specialization'] ?? '',
      medicalLicenseNumber: map['medicalLicenseNumber'] ?? '',
      experience: map['experience'] ?? '',
      hospitalClinic: map['hospitalClinic'] ?? '',
      qualification: map['qualification'] ?? '',
      consultationFee: map['consultationFee'] ?? '',
      workingDays: List<String>.from(map['workingDays'] ?? const []),
      startTime: map['startTime'] ?? '',
      endTime: map['endTime'] ?? '',
      isAvailable: map['isAvailable'] ?? true,
      authProvider: map['authProvider'] ?? 'password',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'profileImage': profileImage,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'specialization': specialization,
      'medicalLicenseNumber': medicalLicenseNumber,
      'experience': experience,
      'hospitalClinic': hospitalClinic,
      'qualification': qualification,
      'consultationFee': consultationFee,
      'workingDays': workingDays,
      'startTime': startTime,
      'endTime': endTime,
      'isAvailable': isAvailable,
      'authProvider': authProvider,
    };
  }

  AppUser copyWith({
    String? name,
    String? phone,
    String? profileImage,
    List<String>? workingDays,
    String? startTime,
    String? endTime,
    bool? isAvailable,
    String? consultationFee,
    String? specialization,
    String? hospitalClinic,
  }) {
    return AppUser(
      uid: uid,
      name: name ?? this.name,
      email: email,
      phone: phone ?? this.phone,
      role: role,
      profileImage: profileImage ?? this.profileImage,
      dateOfBirth: dateOfBirth,
      gender: gender,
      specialization: specialization ?? this.specialization,
      medicalLicenseNumber: medicalLicenseNumber,
      experience: experience,
      hospitalClinic: hospitalClinic ?? this.hospitalClinic,
      qualification: qualification,
      consultationFee: consultationFee ?? this.consultationFee,
      workingDays: workingDays ?? this.workingDays,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isAvailable: isAvailable ?? this.isAvailable,
      authProvider: authProvider,
    );
  }
}
