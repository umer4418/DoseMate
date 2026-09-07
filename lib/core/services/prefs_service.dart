import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  static const _onboarding = 'onboarding_seen';
  static const _remember = 'remember_me';
  static const _email = 'remembered_email';
  static const _password = 'remembered_password';

  Future<bool> isOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboarding) ?? false;
  }

  Future<void> setOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboarding, true);
  }

  Future<void> saveCredentials({
    required bool remember,
    required String email,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_remember, remember);
    if (remember) {
      await prefs.setString(_email, email);
      await prefs.setString(_password, password);
    } else {
      await prefs.remove(_email);
      await prefs.remove(_password);
    }
  }

  Future<bool> rememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_remember) ?? false;
  }

  Future<String> rememberedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_email) ?? '';
  }

  Future<String> rememberedPassword() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_password) ?? '';
  }

  Future<void> clearCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_email);
    await prefs.remove(_password);
    await prefs.setBool(_remember, false);
  }
}
