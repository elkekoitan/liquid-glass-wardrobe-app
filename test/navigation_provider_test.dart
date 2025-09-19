import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitcheck_app/core/router/app_router.dart';
import 'package:fitcheck_app/providers/navigation_provider.dart';

void main() {
  group('NavigationProvider guards', () {
    test('redirects unauthenticated access to login', () {
      final navigation = NavigationProvider()
        ..updateAuthState(isAuthenticated: false, hasProfile: false)
        ..updatePersonalizationState(false);

      final resolved = navigation.resolveRoute(
        const RouteSettings(name: AppRouter.main),
      );

      expect(resolved.name, AppRouter.login);
    });

    test('redirects missing profile to profile setup', () {
      final navigation = NavigationProvider()
        ..updateAuthState(isAuthenticated: true, hasProfile: false)
        ..updatePersonalizationState(true);

      final resolved = navigation.resolveRoute(
        const RouteSettings(name: AppRouter.home),
      );

      expect(resolved.name, AppRouter.profileSetup);
    });

    test('redirects when personalization not ready', () {
      final navigation = NavigationProvider()
        ..updateAuthState(isAuthenticated: true, hasProfile: true)
        ..updatePersonalizationState(false);

      final resolved = navigation.resolveRoute(
        const RouteSettings(name: AppRouter.home),
      );

      expect(resolved.name, AppRouter.personalization);
    });

    test('allows route when all requirements satisfied', () {
      final navigation = NavigationProvider()
        ..updateAuthState(isAuthenticated: true, hasProfile: true)
        ..updatePersonalizationState(true);

      final resolved = navigation.resolveRoute(
        const RouteSettings(name: AppRouter.photoUpload),
      );

      expect(resolved.name, AppRouter.photoUpload);
    });
  });
}
