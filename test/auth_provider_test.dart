import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fitcheck_app/providers/auth_provider.dart';
import 'package:fitcheck_app/services/auth_service.dart';
import 'package:fitcheck_app/services/login_preferences_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AuthService.instance.signOut();
  });

  test(
    'signInWithEmailAndPassword persists email when rememberMe is true',
    () async {
      final authService = AuthService.instance;

      await authService.registerWithEmailAndPassword(
        email: 'user@example.com',
        password: 'Secret1!',
      );
      await authService.signOut();

      final provider = AuthProvider();

      final success = await provider.signInWithEmailAndPassword(
        email: 'user@example.com',
        password: 'Secret1!',
        rememberMe: true,
      );

      expect(success, isTrue);

      final stored = await LoginPreferencesService.instance.load();
      expect(stored.remember, isTrue);
      expect(stored.email, 'user@example.com');
    },
  );

  test(
    'signInWithEmailAndPassword clears email when rememberMe is false',
    () async {
      final authService = AuthService.instance;

      await authService.registerWithEmailAndPassword(
        email: 'forget@example.com',
        password: 'Secret1!',
      );

      final service = LoginPreferencesService.instance;
      await service.save(
        remember: true,
        email: 'old@example.com',
        context: LoginContext.login,
      );

      await authService.signOut();

      final provider = AuthProvider();

      final success = await provider.signInWithEmailAndPassword(
        email: 'forget@example.com',
        password: 'Secret1!',
        rememberMe: false,
      );

      expect(success, isTrue);

      final stored = await service.load();
      expect(stored.remember, isFalse);
      expect(stored.email, isNull);
    },
  );
  test('signInWithGoogle persists email when rememberMe is true', () async {
    final provider = AuthProvider();

    final success = await provider.signInWithGoogle();

    expect(success, isTrue);

    final stored = await LoginPreferencesService.instance.load();
    expect(stored.remember, isTrue);
    expect(stored.email, 'user@gmail.com');
  });

  test(
    'signInWithGoogle clears stored email when rememberMe is false',
    () async {
      final service = LoginPreferencesService.instance;
      await service.save(
        remember: true,
        email: 'keep@old.com',
        context: LoginContext.login,
      );

      final provider = AuthProvider();

      final success = await provider.signInWithGoogle(rememberMe: false);

      expect(success, isTrue);

      final stored = await service.load();
      expect(stored.remember, isFalse);
      expect(stored.email, isNull);
    },
  );
}
