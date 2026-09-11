class AppUser {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String role;

  final String? profileImage;

  final String dateOfBirth;
  final String gender;

  // Doctor information
  final String specialization;
  final String medicalLicenseNumber;
  final String experience;
  final String hospitalClinic;
  final String qualification;
  final String consultationFee;

  // Doctor availability
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

  // ------------------------------------------------------------
  // ROLE HELPERS
  // ------------------------------------------------------------

  bool get isDoctor => role == 'doctor';

  bool get isPatient => role == 'patient';

  // ------------------------------------------------------------
  // FIRESTORE / MAP -> APPUSER
  // ------------------------------------------------------------

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid']?.toString() ?? '',

      name: map['name']?.toString() ?? '',

      email: map['email']?.toString() ?? '',

      phone: map['phone']?.toString() ?? '',

      role: map['role']?.toString() ?? 'patient',

      profileImage:
      map['profileImage']?.toString(),

      dateOfBirth:
      map['dateOfBirth']?.toString() ?? '',

      gender:
      map['gender']?.toString() ?? '',

      // Doctor information
      specialization:
      map['specialization']?.toString() ?? '',

      medicalLicenseNumber:
      map['medicalLicenseNumber']?.toString() ?? '',

      experience:
      map['experience']?.toString() ?? '',

      hospitalClinic:
      map['hospitalClinic']?.toString() ?? '',

      qualification:
      map['qualification']?.toString() ?? '',

      consultationFee:
      map['consultationFee']?.toString() ?? '',

      // Working days
      workingDays:
      map['workingDays'] is List
          ? List<String>.from(
        map['workingDays'],
      )
          : const [],

      startTime:
      map['startTime']?.toString() ?? '',

      endTime:
      map['endTime']?.toString() ?? '',

      isAvailable:
      map['isAvailable'] is bool
          ? map['isAvailable'] as bool
          : true,

      authProvider:
      map['authProvider']?.toString() ?? 'password',
    );
  }

  // ------------------------------------------------------------
  // APPUSER -> FIRESTORE / MAP
  // ------------------------------------------------------------

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

      // Doctor information
      'specialization': specialization,

      'medicalLicenseNumber':
      medicalLicenseNumber,

      'experience': experience,

      'hospitalClinic':
      hospitalClinic,

      'qualification':
      qualification,

      'consultationFee':
      consultationFee,

      // Availability
      'workingDays':
      workingDays,

      'startTime':
      startTime,

      'endTime':
      endTime,

      'isAvailable':
      isAvailable,

      'authProvider':
      authProvider,
    };
  }

  // ------------------------------------------------------------
  // COPY WITH
  // ------------------------------------------------------------

  AppUser copyWith({
    String? name,
    String? phone,
    String? profileImage,

    String? dateOfBirth,
    String? gender,

    String? specialization,
    String? medicalLicenseNumber,
    String? experience,
    String? hospitalClinic,
    String? qualification,
    String? consultationFee,

    List<String>? workingDays,

    String? startTime,
    String? endTime,

    bool? isAvailable,

    String? authProvider,
  }) {
    return AppUser(
      // These don't change
      uid: uid,
      email: email,
      role: role,

      // Basic information
      name: name ?? this.name,

      phone: phone ?? this.phone,

      profileImage:
      profileImage ?? this.profileImage,

      dateOfBirth:
      dateOfBirth ?? this.dateOfBirth,

      gender:
      gender ?? this.gender,

      // Doctor information
      specialization:
      specialization ?? this.specialization,

      medicalLicenseNumber:
      medicalLicenseNumber ??
          this.medicalLicenseNumber,

      experience:
      experience ?? this.experience,

      hospitalClinic:
      hospitalClinic ??
          this.hospitalClinic,

      qualification:
      qualification ??
          this.qualification,

      consultationFee:
      consultationFee ??
          this.consultationFee,

      // Availability
      workingDays:
      workingDays ?? this.workingDays,

      startTime:
      startTime ?? this.startTime,

      endTime:
      endTime ?? this.endTime,

      isAvailable:
      isAvailable ?? this.isAvailable,

      authProvider:
      authProvider ?? this.authProvider,
    );
  }
}