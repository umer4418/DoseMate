import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../models/user_model.dart';

class AuthService {
  // ============================================================
  // FIREBASE INSTANCES
  // ============================================================

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseStorage _storage =
      FirebaseStorage.instance;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
  );

  // ============================================================
  // CURRENT USER
  // ============================================================

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authState => _auth.authStateChanges();

  // ============================================================
  // UPLOAD PROFILE PICTURE
  // ============================================================

  Future<String?> uploadProfilePicture(
      File image,
      String uid,
      ) async {
    try {
      final ref = _storage
          .ref()
          .child('profile_pictures')
          .child('$uid.jpg');

      await ref.putFile(image).timeout(
        const Duration(seconds: 30),
      );

      final downloadUrl = await ref.getDownloadURL().timeout(
        const Duration(seconds: 15),
      );

      return downloadUrl;
    } on FirebaseException catch (e) {
      print(
        'Firebase Storage Error: '
            '${e.code} - ${e.message}',
      );

      return null;
    } on TimeoutException {
      print('Profile image upload timed out.');
      return null;
    } catch (e) {
      print('Profile image upload error: $e');
      return null;
    }
  }

  // ============================================================
  // FETCH USER
  // ============================================================

  Future<AppUser?> fetchUser(
      String uid,
      ) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .get()
          .timeout(
        const Duration(seconds: 15),
      );

      if (!doc.exists || doc.data() == null) {
        return null;
      }

      return AppUser.fromMap(
        doc.data()!,
      );
    } on FirebaseException catch (e) {
      throw Exception(
        'Unable to load profile: '
            '${e.message ?? e.code}',
      );
    } on TimeoutException {
      throw Exception(
        'Loading profile timed out. '
            'Check your internet connection.',
      );
    }
  }

  // ============================================================
  // LOGIN
  // ============================================================

  Future<UserCredential> login({
    required String email,
    required String password,
  }) {
    return _auth
        .signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    )
        .timeout(
      const Duration(seconds: 30),
    );
  }

  // ============================================================
  // PASSWORD RESET
  // ============================================================

  Future<void> sendPasswordReset(
      String email,
      ) {
    return _auth
        .sendPasswordResetEmail(
      email: email.trim(),
    )
        .timeout(
      const Duration(seconds: 30),
    );
  }

  // ============================================================
  // REGISTER PATIENT
  // ============================================================

  Future<UserCredential> registerPatient({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String dateOfBirth,
    required String gender,
    File? profileImage,
  }) async {
    // ----------------------------------------------------------
    // CREATE FIREBASE AUTH ACCOUNT
    // ----------------------------------------------------------

    final credential =
    await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = credential.user;

    if (user == null) {
      throw Exception(
        'Firebase did not return a user.',
      );
    }

    // ----------------------------------------------------------
    // UPDATE DISPLAY NAME
    // ----------------------------------------------------------

    await user.updateDisplayName(
      name.trim(),
    );

    // ----------------------------------------------------------
    // UPLOAD IMAGE
    // ----------------------------------------------------------

    String? imageUrl;

    if (profileImage != null) {
      imageUrl = await uploadProfilePicture(
        profileImage,
        user.uid,
      );
    }

    // ----------------------------------------------------------
    // PATIENT DATA
    // ----------------------------------------------------------

    final patientData = <String, dynamic>{
      'uid': user.uid,
      'name': name.trim(),
      'email': email.trim(),
      'phone': phone.trim(),
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'role': 'patient',
      'profileImage': imageUrl,
      'authProvider': 'password',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    // ----------------------------------------------------------
    // SAVE PATIENT
    // ----------------------------------------------------------

    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(
      patientData,
    )
        .timeout(
      const Duration(seconds: 30),
    );

    return credential;
  }

  // ============================================================
  // REGISTER DOCTOR
  // ============================================================

  Future<UserCredential> registerDoctor({
    required String name,
    required String email,
    required String password,
    required String phone,
    File? profileImage,
    required String specialization,
    required String medicalLicenseNumber,
    required String experience,
    required String hospitalClinic,
    required String qualification,
    required String consultationFee,
    required List<String> workingDays,
    required String startTime,
    required String endTime,
  }) async {
    // ----------------------------------------------------------
    // 1. CREATE FIREBASE AUTH ACCOUNT
    // ----------------------------------------------------------

    final credential =
    await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = credential.user;

    if (user == null) {
      throw Exception(
        'Firebase did not return a user.',
      );
    }

    // ----------------------------------------------------------
    // 2. UPDATE FIREBASE DISPLAY NAME
    // ----------------------------------------------------------

    await user.updateDisplayName(
      name.trim(),
    );

    // ----------------------------------------------------------
    // 3. UPLOAD PROFILE IMAGE
    // ----------------------------------------------------------

    String? imageUrl;

    if (profileImage != null) {
      imageUrl = await uploadProfilePicture(
        profileImage,
        user.uid,
      );
    }

    // ----------------------------------------------------------
    // 4. DOCTOR DATA
    // ----------------------------------------------------------

    final doctorData = <String, dynamic>{
      'uid': user.uid,

      // Basic information
      'name': name.trim(),
      'email': email.trim(),
      'phone': phone.trim(),

      // Role
      'role': 'doctor',

      // Profile image
      'profileImage': imageUrl,

      // Professional information
      'specialization': specialization.trim(),
      'medicalLicenseNumber':
      medicalLicenseNumber.trim(),
      'experience': experience.trim(),
      'hospitalClinic': hospitalClinic.trim(),
      'qualification': qualification.trim(),
      'consultationFee':
      consultationFee.trim(),

      // Availability
      'workingDays':
      List<String>.from(workingDays),

      'startTime': startTime,
      'endTime': endTime,

      'isAvailable': true,

      // Authentication
      'authProvider': 'password',

      // Dates
      'createdAt':
      FieldValue.serverTimestamp(),

      'updatedAt':
      FieldValue.serverTimestamp(),
    };

    // ----------------------------------------------------------
    // 5. SAVE TO USERS COLLECTION
    // ----------------------------------------------------------

    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(
      doctorData,
    )
        .timeout(
      const Duration(seconds: 30),
    );

    // ----------------------------------------------------------
    // 6. SAVE TO DOCTORS COLLECTION
    //
    // THIS IS THE IMPORTANT PART
    // ----------------------------------------------------------

    await _firestore
        .collection('doctors')
        .doc(user.uid)
        .set(
      doctorData,
    )
        .timeout(
      const Duration(seconds: 30),
    );

    print(
      'DOCTOR SAVED SUCCESSFULLY: ${user.uid}',
    );

    return credential;
  }

  // ============================================================
  // GOOGLE LOGIN
  // ============================================================

  Future<
      ({
      UserCredential credential,
      AppUser? profile
      })> signInWithGoogle() async {
    // ----------------------------------------------------------
    // SELECT GOOGLE ACCOUNT
    // ----------------------------------------------------------

    final googleUser =
    await _googleSignIn.signIn();

    if (googleUser == null) {
      throw Exception(
        'Google sign-in cancelled.',
      );
    }

    // ----------------------------------------------------------
    // GOOGLE AUTH
    // ----------------------------------------------------------

    final googleAuth =
    await googleUser.authentication;

    // ----------------------------------------------------------
    // FIREBASE CREDENTIAL
    // ----------------------------------------------------------

    final credential =
    GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // ----------------------------------------------------------
    // SIGN IN TO FIREBASE
    // ----------------------------------------------------------

    final userCredential =
    await _auth.signInWithCredential(
      credential,
    );

    // ----------------------------------------------------------
    // CHECK EXISTING PROFILE
    // ----------------------------------------------------------

    final profile = await fetchUser(
      userCredential.user!.uid,
    );

    return (
    credential: userCredential,
    profile: profile,
    );
  }

  // ============================================================
  // COMPLETE GOOGLE PROFILE
  // ============================================================

  Future<void> completeGoogleProfile({
    required String role,

    String phone = '',
    String dateOfBirth = '',
    String gender = '',

    String specialization = '',
    String medicalLicenseNumber = '',
    String experience = '',
    String hospitalClinic = '',
    String qualification = '',
    String consultationFee = '',

    List<String> workingDays = const [],

    String startTime = '',
    String endTime = '',

    File? profileImage,
  }) async {
    // ----------------------------------------------------------
    // GET CURRENT USER
    // ----------------------------------------------------------

    final user = _auth.currentUser;

    if (user == null) {
      throw Exception(
        'No authenticated user.',
      );
    }

    // ----------------------------------------------------------
    // PROFILE IMAGE
    // ----------------------------------------------------------

    String? imageUrl = user.photoURL;

    if (profileImage != null) {
      imageUrl = await uploadProfilePicture(
        profileImage,
        user.uid,
      );
    }

    // ----------------------------------------------------------
    // PROFILE DATA
    // ----------------------------------------------------------

    final data = <String, dynamic>{
      'uid': user.uid,

      'name':
      user.displayName ??
          'DoseMate User',

      'email':
      user.email ?? '',

      'phone': phone.trim(),

      'role': role,

      'profileImage': imageUrl,

      'dateOfBirth':
      dateOfBirth,

      'gender':
      gender,

      'specialization':
      specialization.trim(),

      'medicalLicenseNumber':
      medicalLicenseNumber.trim(),

      'experience':
      experience.trim(),

      'hospitalClinic':
      hospitalClinic.trim(),

      'qualification':
      qualification.trim(),

      'consultationFee':
      consultationFee.trim(),

      'workingDays':
      List<String>.from(
        workingDays,
      ),

      'startTime':
      startTime,

      'endTime':
      endTime,

      'isAvailable':
      role == 'doctor',

      'authProvider':
      'google',

      'updatedAt':
      FieldValue.serverTimestamp(),
    };

    // ----------------------------------------------------------
    // SAVE TO USERS
    // ----------------------------------------------------------

    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(
      {
        ...data,
        'createdAt':
        FieldValue.serverTimestamp(),
      },
      SetOptions(
        merge: true,
      ),
    )
        .timeout(
      const Duration(seconds: 30),
    );

    // ----------------------------------------------------------
    // SAVE GOOGLE DOCTOR TO DOCTORS COLLECTION
    // ----------------------------------------------------------

    if (role == 'doctor') {
      await _firestore
          .collection('doctors')
          .doc(user.uid)
          .set(
        {
          ...data,
          'createdAt':
          FieldValue.serverTimestamp(),
        },
        SetOptions(
          merge: true,
        ),
      )
          .timeout(
        const Duration(seconds: 30),
      );

      print(
        'GOOGLE DOCTOR SAVED SUCCESSFULLY: ${user.uid}',
      );
    }
  }

  // ============================================================
  // UPDATE USER
  // ============================================================

  Future<void> updateUser(
      String uid,
      Map<String, dynamic> data,
      ) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .update(data)
        .timeout(
      const Duration(seconds: 30),
    );

    // Keep doctor collection synchronized.
    final doctorDoc = await _firestore
        .collection('doctors')
        .doc(uid)
        .get();

    if (doctorDoc.exists) {
      await _firestore
          .collection('doctors')
          .doc(uid)
          .update(data)
          .timeout(
        const Duration(seconds: 30),
      );
    }
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> logout() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {
      // Ignore Google logout errors.
    }

    await _auth.signOut();
  }

  // ============================================================
  // FIREBASE ERROR MESSAGE
  // ============================================================

  String authErrorMessage(
      Object error,
      ) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
        case 'invalid-credential':
        case 'wrong-password':
          return 'Invalid email or password.';

        case 'email-already-in-use':
          return 'An account already exists with this email.';

        case 'invalid-email':
          return 'Please enter a valid email address.';

        case 'weak-password':
          return 'Password must be at least 6 characters.';

        case 'network-request-failed':
          return 'Network error. Check your internet connection.';

        case 'too-many-requests':
          return 'Too many attempts. Try again later.';

        case 'account-exists-with-different-credential':
          return 'This email is already used with another sign-in method.';

        case 'operation-not-allowed':
          return 'This sign-in method is not enabled in Firebase.';

        default:
          return error.message ??
              'Authentication failed.';
      }
    }

    if (error is FirebaseException) {
      return error.message ??
          'Firebase operation failed.';
    }

    return error
        .toString()
        .replaceFirst(
      'Exception: ',
      '',
    );
  }
}