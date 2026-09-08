import 'dart:io';

import 'package:get/get.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/prefs_service.dart';
import '../../../models/user_model.dart';

class AuthController extends GetxController {
  final AuthService authService;
  final PrefsService prefsService;

  AuthController({
    required this.authService,
    required this.prefsService,
  });

  final isLoading = false.obs;
  final obscurePassword = true.obs;
  final rememberMe = false.obs;
  final currentUser = Rxn<AppUser>();

  final rememberedEmail = ''.obs;
  final rememberedPassword = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadRemembered();
  }

  Future<void> _loadRemembered() async {
    rememberMe.value = await prefsService.rememberMe();
    rememberedEmail.value = await prefsService.rememberedEmail();
    rememberedPassword.value = await prefsService.rememberedPassword();
  }

  Future<void> bootstrapSession() async {
    try {
      final firebaseUser = authService.currentUser;

      if (firebaseUser == null) {
        currentUser.value = null;
        return;
      }

      currentUser.value = await authService.fetchUser(firebaseUser.uid);
    } catch (e) {
      currentUser.value = null;
      rethrow;
    }
  }

  // ------------------------------------------------------------
  // LOGIN
  // ------------------------------------------------------------

  Future<void> login(
      String email,
      String password,
      ) async {
    if (email.trim().isEmpty || password.isEmpty) {
      Get.snackbar(
        'Missing details',
        'Please enter email and password.',
      );
      return;
    }

    try {
      isLoading.value = true;

      await authService.login(
        email: email.trim(),
        password: password,
      );

      await prefsService.saveCredentials(
        remember: rememberMe.value,
        email: email.trim(),
        password: password,
      );

      await bootstrapSession();

      _goHome();
    } catch (e) {
      Get.snackbar(
        'Login failed',
        authService.authErrorMessage(e),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ------------------------------------------------------------
  // GOOGLE LOGIN
  // ------------------------------------------------------------

  Future<void> googleLogin() async {
    try {
      isLoading.value = true;

      final result = await authService.signInWithGoogle();

      if (result.profile == null) {
        Get.offAllNamed(AppRoutes.googleRole);
        return;
      }

      currentUser.value = result.profile;

      _goHome();
    } catch (e) {
      Get.snackbar(
        'Google sign-in',
        authService.authErrorMessage(e),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ------------------------------------------------------------
  // GOOGLE PATIENT PROFILE
  // ------------------------------------------------------------

  Future<void> completeGooglePatient({
    required String phone,
    required String dateOfBirth,
    required String gender,
  }) async {
    try {
      isLoading.value = true;

      await authService.completeGoogleProfile(
        role: 'patient',
        phone: phone.trim(),
        dateOfBirth: dateOfBirth,
        gender: gender,
      );

      await bootstrapSession();

      _goHome();
    } catch (e) {
      Get.snackbar(
        'Profile',
        authService.authErrorMessage(e),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ------------------------------------------------------------
  // GOOGLE DOCTOR PROFILE
  // ------------------------------------------------------------

  Future<void> completeGoogleDoctor({
    required String phone,
    required String specialization,
    required String license,
    required String experience,
    required String hospital,
    required String qualification,
    required String fee,
    required List<String> workingDays,
    required String startTime,
    required String endTime,
    File? image,
  }) async {
    try {
      isLoading.value = true;

      await authService.completeGoogleProfile(
        role: 'doctor',
        phone: phone.trim(),
        specialization: specialization.trim(),
        medicalLicenseNumber: license.trim(),
        experience: experience.trim(),
        hospitalClinic: hospital.trim(),
        qualification: qualification.trim(),
        consultationFee: fee.trim(),
        workingDays: workingDays,
        startTime: startTime,
        endTime: endTime,
        profileImage: image,
      );

      // Read the newly-created/updated doctor document.
      await bootstrapSession();

      if (currentUser.value == null) {
        throw Exception(
          'Doctor profile was saved, but could not be loaded.',
        );
      }

      Get.snackbar(
        'Welcome',
        'Doctor profile created successfully.',
      );

      _goHome();
    } catch (e) {
      Get.snackbar(
        'Doctor profile failed',
        authService.authErrorMessage(e),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ------------------------------------------------------------
  // REGISTER PATIENT
  // ------------------------------------------------------------

  Future<void> registerPatient({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String dateOfBirth,
    required String gender,
    File? image,
  }) async {
    try {
      isLoading.value = true;

      await authService.registerPatient(
        name: name.trim(),
        email: email.trim(),
        password: password,
        phone: phone.trim(),
        dateOfBirth: dateOfBirth,
        gender: gender,
        profileImage: image,
      );

      await bootstrapSession();

      Get.snackbar(
        'Welcome',
        'Patient account created successfully.',
      );

      _goHome();
    } catch (e) {
      Get.snackbar(
        'Signup failed',
        authService.authErrorMessage(e),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ------------------------------------------------------------
  // REGISTER DOCTOR
  // ------------------------------------------------------------

  Future<void> registerDoctor({
    required String name,
    required String email,
    required String password,
    required String phone,
    File? image,
    required String specialization,
    required String license,
    required String experience,
    required String hospital,
    required String qualification,
    required String fee,
    required List<String> workingDays,
    required String startTime,
    required String endTime,
  }) async {
    try {
      isLoading.value = true;

      await authService.registerDoctor(
        name: name.trim(),
        email: email.trim(),
        password: password,
        phone: phone.trim(),
        profileImage: image,
        specialization: specialization.trim(),
        medicalLicenseNumber: license.trim(),
        experience: experience.trim(),
        hospitalClinic: hospital.trim(),
        qualification: qualification.trim(),
        consultationFee: fee.trim(),
        workingDays: workingDays,
        startTime: startTime,
        endTime: endTime,
      );

      // IMPORTANT:
      // After AuthService creates the Firebase account and
      // Firestore doctor document, load it again.
      await bootstrapSession();

      if (currentUser.value == null) {
        throw Exception(
          'Doctor account was created, but the doctor profile '
              'could not be loaded from Firestore.',
        );
      }

      Get.snackbar(
        'Welcome',
        'Doctor account created successfully.',
      );

      _goHome();
    } catch (e) {
      Get.snackbar(
        'Signup failed',
        authService.authErrorMessage(e),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ------------------------------------------------------------
  // FORGOT PASSWORD
  // ------------------------------------------------------------

  Future<void> forgotPassword(String email) async {
    if (email.trim().isEmpty) {
      Get.snackbar(
        'Email required',
        'Enter the email linked to your account.',
      );
      return;
    }

    try {
      isLoading.value = true;

      await authService.sendPasswordReset(
        email.trim(),
      );

      Get.snackbar(
        'Check your inbox',
        'A password reset link was sent to ${email.trim()}',
      );

      Get.back();
    } catch (e) {
      Get.snackbar(
        'Reset failed',
        authService.authErrorMessage(e),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ------------------------------------------------------------
  // LOGOUT
  // ------------------------------------------------------------

  Future<void> logout() async {
    try {
      await authService.logout();

      currentUser.value = null;

      Get.offAllNamed(
        AppRoutes.login,
      );
    } catch (e) {
      Get.snackbar(
        'Logout failed',
        e.toString(),
      );
    }
  }

  // ------------------------------------------------------------
  // NAVIGATION
  // ------------------------------------------------------------

  void _goHome() {
    final user = currentUser.value;

    if (user == null) {
      Get.offAllNamed(
        AppRoutes.login,
      );
      return;
    }

    if (user.isDoctor) {
      Get.offAllNamed(
        AppRoutes.doctorShell,
      );
    } else {
      Get.offAllNamed(
        AppRoutes.patientShell,
      );
    }
  }
}