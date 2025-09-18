import 'package:shared_preferences/shared_preferences.dart';

class LoginPreferencesService {
  LoginPreferencesService._();

  static final LoginPreferencesService instance = LoginPreferencesService._();

  static const _rememberKey = 'login_remember_me';
  static const _emailKey = 'login_saved_email';

  Future<LoginCredentials> load() async {
    final prefs = await SharedPreferences.getInstance();
    final remember = prefs.getBool(_rememberKey) ?? false;
    final email = prefs.getString(_emailKey);
    return LoginCredentials(remember: remember, email: email);
  }

  Future<void> save({required bool remember, required String email}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberKey, remember);
    await prefs.setString(_emailKey, email);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_rememberKey);
    await prefs.remove(_emailKey);
  }
}

class LoginCredentials {
  const LoginCredentials({required this.remember, this.email});

  final bool remember;
  final String? email;
}
