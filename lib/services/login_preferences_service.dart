import 'package:shared_preferences/shared_preferences.dart';

class LoginPreferencesService {
  LoginPreferencesService._();

  static final LoginPreferencesService instance = LoginPreferencesService._();

  static const _rememberKey = 'login_remember_me';
  static const _emailKey = 'login_saved_email';
  static const _registerRememberKey = 'register_remember_me';
  static const _registerEmailKey = 'register_saved_email';
  static const _rememberOnboardingKey = 'onboarding_remember_me';
  static const _onboardingEmailKey = 'onboarding_saved_email';

  Future<LoginCredentials> load({
    LoginContext context = LoginContext.login,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    switch (context) {
      case LoginContext.register:
        final remember = prefs.getBool(_registerRememberKey) ?? false;
        final email = prefs.getString(_registerEmailKey);
        return LoginCredentials(remember: remember, email: email);
      case LoginContext.onboarding:
        final remember = prefs.getBool(_rememberOnboardingKey) ?? false;
        final email = prefs.getString(_onboardingEmailKey);
        return LoginCredentials(remember: remember, email: email);
      case LoginContext.login:
        final remember = prefs.getBool(_rememberKey) ?? false;
        final email = prefs.getString(_emailKey);
        return LoginCredentials(remember: remember, email: email);
    }
  }

  Future<void> save({
    required bool remember,
    required String email,
    LoginContext context = LoginContext.login,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    switch (context) {
      case LoginContext.register:
        await prefs.setBool(_registerRememberKey, remember);
        await prefs.setString(_registerEmailKey, email);
        break;
      case LoginContext.onboarding:
        await prefs.setBool(_rememberOnboardingKey, remember);
        await prefs.setString(_onboardingEmailKey, email);
        break;
      case LoginContext.login:
        await prefs.setBool(_rememberKey, remember);
        await prefs.setString(_emailKey, email);
        break;
    }
  }

  Future<void> clear({LoginContext context = LoginContext.login}) async {
    final prefs = await SharedPreferences.getInstance();
    switch (context) {
      case LoginContext.register:
        await prefs.remove(_registerRememberKey);
        await prefs.remove(_registerEmailKey);
        break;
      case LoginContext.onboarding:
        await prefs.remove(_rememberOnboardingKey);
        await prefs.remove(_onboardingEmailKey);
        break;
      case LoginContext.login:
        await prefs.remove(_rememberKey);
        await prefs.remove(_emailKey);
        break;
    }
  }
}

class LoginCredentials {
  const LoginCredentials({required this.remember, this.email});

  final bool remember;
  final String? email;
}

enum LoginContext { login, register, onboarding }
