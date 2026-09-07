import 'dart:io';

import 'package:get/get.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/services/prefs_service.dart';
import '../../../models/user_model.dart';
import '../../../core/routes/app_routes.dart';

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
    final firebaseUser = authService.currentUser;
    if (firebaseUser == null) {
      currentUser.value = null;
      return;
    }
    currentUser.value = await authService.fetchUser(firebaseUser.uid);
  }

  Future<void> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      Get.snackbar('Missing details', 'Please enter email and password.');
      return;
    }

    try {
      isLoading.value = true;
      await authService.login(email: email, password: password);
      await prefsService.saveCredentials(
        remember: rememberMe.value,
        email: email,
        password: password,
      );
      await bootstrapSession();
      _goHome();
    } catch (e) {
      Get.snackbar('Login failed', authService.authErrorMessage(e));
    } finally {
      isLoading.value = false;
    }
  }

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
      Get.snackbar('Google sign-in', authService.authErrorMessage(e));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> completeGooglePatient({
    required String phone,
    required String dateOfBirth,
    required String gender,
  }) async {
    try {
      isLoading.value = true;
      await authService.completeGoogleProfile(
        role: 'patient',
        phone: phone,
        dateOfBirth: dateOfBirth,
        gender: gender,
      );
      await bootstrapSession();
      _goHome();
    } catch (e) {
      Get.snackbar('Profile', authService.authErrorMessage(e));
    } finally {
      isLoading.value = false;
    }
  }

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
        phone: phone,
        specialization: specialization,
        medicalLicenseNumber: license,
        experience: experience,
        hospitalClinic: hospital,
        qualification: qualification,
        consultationFee: fee,
        workingDays: workingDays,
        startTime: startTime,
        endTime: endTime,
        profileImage: image,
      );
      await bootstrapSession();
      _goHome();
    } catch (e) {
      Get.snackbar('Profile', authService.authErrorMessage(e));
    } finally {
      isLoading.value = false;
    }
  }

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
        name: name,
        email: email,
        password: password,
        phone: phone,
        dateOfBirth: dateOfBirth,
        gender: gender,
        profileImage: image,
      );
      await bootstrapSession();
      Get.snackbar('Welcome', 'Patient account created successfully.');
      _goHome();
    } catch (e) {
      Get.snackbar('Signup failed', authService.authErrorMessage(e));
    } finally {
      isLoading.value = false;
    }
  }

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
        name: name,
        email: email,
        password: password,
        phone: phone,
        profileImage: image,
        specialization: specialization,
        medicalLicenseNumber: license,
        experience: experience,
        hospitalClinic: hospital,
        qualification: qualification,
        consultationFee: fee,
        workingDays: workingDays,
        startTime: startTime,
        endTime: endTime,
      );
      await bootstrapSession();
      Get.snackbar('Welcome', 'Doctor account created successfully.');
      _goHome();
    } catch (e) {
      Get.snackbar('Signup failed', authService.authErrorMessage(e));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> forgotPassword(String email) async {
    if (email.trim().isEmpty) {
      Get.snackbar('Email required', 'Enter the email linked to your account.');
      return;
    }
    try {
      isLoading.value = true;
      await authService.sendPasswordReset(email);
      Get.snackbar(
        'Check your inbox',
        'A password reset link was sent to $email',
      );
      Get.back();
    } catch (e) {
      Get.snackbar('Reset failed', authService.authErrorMessage(e));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await authService.logout();
    currentUser.value = null;
    Get.offAllNamed(AppRoutes.login);
  }

  void _goHome() {
    final user = currentUser.value;
    if (user == null) {
      Get.offAllNamed(AppRoutes.login);
      return;
    }
    if (user.isDoctor) {
      Get.offAllNamed(AppRoutes.doctorShell);
    } else {
      Get.offAllNamed(AppRoutes.patientShell);
    }
  }
}
