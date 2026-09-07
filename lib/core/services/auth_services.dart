import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../models/patient_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ============================================================
  // UPLOAD PROFILE PICTURE
  // ============================================================

  Future<String?> uploadProfilePicture(
      File image,
      String uid,
      ) async {
    try {
      print('Uploading profile picture...');

      final Reference ref = _storage
          .ref()
          .child('profile_pictures')
          .child('$uid.jpg');

      await ref.putFile(image);

      final String downloadUrl = await ref.getDownloadURL();

      print('Profile picture uploaded successfully.');

      return downloadUrl;
    } on FirebaseException catch (e) {
      print('====================================');
      print('PROFILE IMAGE STORAGE ERROR');
      print('Code: ${e.code}');
      print('Message: ${e.message}');
      print('====================================');

      // IMPORTANT:
      // Profile picture is optional.
      // If upload fails, return null instead of stopping registration.
      return null;
    } catch (e) {
      print('Profile image upload error: $e');

      // Continue registration without profile picture.
      return null;
    }
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
    try {
      print('====================================');
      print('PATIENT REGISTRATION STARTED');
      print('====================================');

      // ========================================================
      // STEP 1: CREATE FIREBASE AUTH ACCOUNT
      // ========================================================

      print('STEP 1: Creating Firebase Auth user...');

      final UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final User? user = userCredential.user;

      if (user == null) {
        throw Exception(
          'Firebase Authentication user was not created.',
        );
      }

      print('STEP 1 SUCCESS');
      print('Firebase UID: ${user.uid}');

      // ========================================================
      // STEP 2: UPLOAD PROFILE IMAGE - OPTIONAL
      // ========================================================

      String? profileImageUrl;

      if (profileImage != null) {
        print('STEP 2: Profile image selected.');
        print('STEP 2: Uploading profile image...');

        profileImageUrl = await uploadProfilePicture(
          profileImage,
          user.uid,
        );

        if (profileImageUrl != null) {
          print('STEP 2 SUCCESS: Profile image uploaded.');
        } else {
          print(
            'STEP 2 WARNING: Profile image upload failed.',
          );
          print(
            'Continuing registration without profile image.',
          );
        }
      } else {
        print(
          'STEP 2: No profile image selected.',
        );
        print(
          'Continuing registration without profile image.',
        );
      }

      // ========================================================
      // STEP 3: CREATE PATIENT MODEL
      // ========================================================

      print('STEP 3: Creating PatientModel...');

      final PatientModel patient = PatientModel(
        uid: user.uid,
        name: name.trim(),
        email: email.trim(),
        phone: phone.trim(),
        dateOfBirth: dateOfBirth,
        gender: gender,
        role: 'patient',
        profileImage: profileImageUrl,
        createdAt: DateTime.now(),
      );

      print('STEP 3 SUCCESS: PatientModel created.');

      // ========================================================
      // STEP 4: SAVE PATIENT TO FIRESTORE
      // ========================================================

      print('STEP 4: Saving patient to Firestore...');

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set({
        ...patient.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('STEP 4 SUCCESS: Patient saved to Firestore.');

      print('====================================');
      print('PATIENT REGISTRATION SUCCESSFUL');
      print('UID: ${user.uid}');
      print('====================================');

      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('====================================');
      print('FIREBASE AUTH ERROR');
      print('Code: ${e.code}');
      print('Message: ${e.message}');
      print('====================================');

      rethrow;
    } on FirebaseException catch (e) {
      print('====================================');
      print('FIREBASE ERROR');
      print('Code: ${e.code}');
      print('Message: ${e.message}');
      print('====================================');

      rethrow;
    } catch (e) {
      print('====================================');
      print('PATIENT REGISTRATION ERROR');
      print('Error: $e');
      print('====================================');

      rethrow;
    }
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
    try {
      print('====================================');
      print('DOCTOR REGISTRATION STARTED');
      print('====================================');

      // ========================================================
      // STEP 1: CREATE FIREBASE AUTH ACCOUNT
      // ========================================================

      print('STEP 1: Creating Firebase Auth doctor...');

      final UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final User? user = userCredential.user;

      if (user == null) {
        throw Exception(
          'Unable to create doctor account.',
        );
      }

      print('STEP 1 SUCCESS');
      print('Doctor UID: ${user.uid}');

      // ========================================================
      // STEP 2: PROFILE IMAGE - OPTIONAL
      // ========================================================

      String? profileImageUrl;

      if (profileImage != null) {
        print('STEP 2: Uploading doctor profile image...');

        profileImageUrl = await uploadProfilePicture(
          profileImage,
          user.uid,
        );

        if (profileImageUrl != null) {
          print(
            'STEP 2 SUCCESS: Doctor image uploaded.',
          );
        } else {
          print(
            'STEP 2 WARNING: Image upload failed.',
          );
          print(
            'Continuing without profile image.',
          );
        }
      } else {
        print(
          'STEP 2: No doctor profile image selected.',
        );
      }

      // ========================================================
      // STEP 3: SAVE DOCTOR TO FIRESTORE
      // ========================================================

      print('STEP 3: Saving doctor to Firestore...');

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set({
        'uid': user.uid,
        'name': name.trim(),
        'email': email.trim(),
        'phone': phone.trim(),
        'role': 'doctor',
        'profileImage': profileImageUrl,

        'specialization': specialization.trim(),
        'medicalLicenseNumber':
        medicalLicenseNumber.trim(),
        'experience': experience.trim(),
        'hospitalClinic': hospitalClinic.trim(),
        'qualification': qualification.trim(),
        'consultationFee': consultationFee.trim(),

        'workingDays': workingDays,
        'startTime': startTime,
        'endTime': endTime,

        'createdAt': FieldValue.serverTimestamp(),
      });

      print('STEP 3 SUCCESS: Doctor saved.');

      print('====================================');
      print('DOCTOR REGISTRATION SUCCESSFUL');
      print('UID: ${user.uid}');
      print('====================================');

      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('====================================');
      print('DOCTOR AUTH ERROR');
      print('Code: ${e.code}');
      print('Message: ${e.message}');
      print('====================================');

      rethrow;
    } on FirebaseException catch (e) {
      print('====================================');
      print('DOCTOR FIREBASE ERROR');
      print('Code: ${e.code}');
      print('Message: ${e.message}');
      print('====================================');

      rethrow;
    } catch (e) {
      print('====================================');
      print('DOCTOR REGISTRATION ERROR');
      print('Error: $e');
      print('====================================');

      rethrow;
    }
  }
}