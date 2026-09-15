import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../models/user_model.dart';

class AuthService {
  // ============================================================
  // FIREBASE INSTANCES
  // ============================================================

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
  );

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authState => _auth.authStateChanges();

  Future<Blob?> prepareProfilePicture(File image) async {
    try {
      final bytes = await image.readAsBytes();
      if (bytes.length > 700 * 1024) {
        throw Exception(
          'Profile image is too large. '
              'Please select a smaller image.',
        );
      }

      return Blob(bytes);
    } catch (e) {
      debugPrint('Profile image error: $e');
      return null;
    }
  }

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

  Future<UserCredential> registerPatient({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String dateOfBirth,
    required String gender,
    File? profileImage,
  }) async {

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
    // 2. UPDATE DISPLAY NAME
    // ----------------------------------------------------------

    await user.updateDisplayName(
      name.trim(),
    );
    Blob? imageBlob;

    if (profileImage != null) {
      imageBlob = await prepareProfilePicture(
        profileImage,
      );

      if (imageBlob == null) {
        throw Exception(
          'Unable to process profile image.',
        );
      }
    }

    final patientData = <String, dynamic>{
      'uid': user.uid,
      'name': name.trim(),
      'email': email.trim(),
      'phone': phone.trim(),
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'role': 'patient',

      // Actual image stored in Firestore
      'profileImage': imageBlob,

      'authProvider': 'password',

      'createdAt':
      FieldValue.serverTimestamp(),

      'updatedAt':
      FieldValue.serverTimestamp(),
    };

    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(patientData)
        .timeout(
      const Duration(seconds: 30),
    );

    return credential;
  }

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
    await user.updateDisplayName(
      name.trim(),
    );

    Blob? imageBlob;

    if (profileImage != null) {
      imageBlob = await prepareProfilePicture(
        profileImage,
      );

      if (imageBlob == null) {
        throw Exception(
          'Unable to process profile image.',
        );
      }
    }

    final doctorData = <String, dynamic>{
      'uid': user.uid,

      // Basic information
      'name': name.trim(),
      'email': email.trim(),
      'phone': phone.trim(),
      'role': 'doctor',
      'profileImage': imageBlob,
      'specialization': specialization.trim(),
      'medicalLicenseNumber': medicalLicenseNumber.trim(),
      'experience': experience.trim(),
      'hospitalClinic': hospitalClinic.trim(),
      'qualification': qualification.trim(),
      'consultationFee': consultationFee.trim(),

      // Availability
      'workingDays':
      List<String>.from(workingDays),
      'startTime': startTime,
      'endTime': endTime,
      'isAvailable': true,
      // Authentication
      'authProvider': 'password',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(doctorData)
        .timeout(
      const Duration(seconds: 30),
    );

    await _firestore
        .collection('doctors')
        .doc(user.uid)
        .set(doctorData)
        .timeout(
      const Duration(seconds: 30),
    );

    print(
      'DOCTOR SAVED SUCCESSFULLY: ${user.uid}',
    );

    return credential;
  }

  Future<
      ({
      UserCredential credential,
      AppUser? profile
      })> signInWithGoogle() async {

    final googleUser =
    await _googleSignIn.signIn();

    if (googleUser == null) {
      throw Exception(
        'Google sign-in cancelled.',
      );
    }

    final googleAuth =
    await googleUser.authentication;
    final credential =
    GoogleAuthProvider.credential(
      accessToken:
      googleAuth.accessToken,
      idToken:
      googleAuth.idToken,
    );

    final userCredential =
    await _auth.signInWithCredential(
      credential,
    );

    final profile = await fetchUser(
      userCredential.user!.uid,
    );

    return (
    credential: userCredential,
    profile: profile,
    );
  }

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

    final user = _auth.currentUser;
    if (user == null) {
      throw Exception(
        'No authenticated user.',
      );
    }
    Blob? imageBlob;

    if (profileImage != null) {
      imageBlob =
      await prepareProfilePicture(
        profileImage,
      );

      if (imageBlob == null) {
        throw Exception(
          'Unable to process profile image.',
        );
      }
    }
    final data = <String, dynamic>{
      'uid': user.uid,

      'name':
      user.displayName ??
          'DoseMate User',

      'email':
      user.email ?? '',

      'phone': phone.trim(),

      'role': role,

      'profileImage': imageBlob,

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

      debugPrint(
        'GOOGLE DOCTOR SAVED SUCCESSFULLY: ${user.uid}',
      );
    }
  }
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
  Future<void> logout() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {
      // Ignore Google logout errors.
    }

    await _auth.signOut();
  }
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