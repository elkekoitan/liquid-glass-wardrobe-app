import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fitcheck_app/services/login_preferences_service.dart';

void main() {
  late LoginPreferencesService service;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    service = LoginPreferencesService.instance;
  });

  test('load returns defaults when nothing saved', () async {
    final creds = await service.load();
    expect(creds.remember, isFalse);
    expect(creds.email, isNull);
  });

  test('save and load persist login email', () async {
    await service.save(remember: true, email: 'user@example.com');
    final creds = await service.load();
    expect(creds.remember, isTrue);
    expect(creds.email, 'user@example.com');
  });

  test('register context persists independently', () async {
    await service.save(
      remember: true,
      email: 'signup@example.com',
      context: LoginContext.register,
    );

    final loginCreds = await service.load();
    expect(loginCreds.remember, isFalse);

    final registerCreds = await service.load(context: LoginContext.register);
    expect(registerCreds.remember, isTrue);
    expect(registerCreds.email, 'signup@example.com');
  });

  test('clear removes stored values for context', () async {
    await service.save(remember: true, email: 'keep@example.com');
    await service.clear();
    final creds = await service.load();
    expect(creds.remember, isFalse);
    expect(creds.email, isNull);
  });
}
