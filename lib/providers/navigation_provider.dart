import 'package:flutter/material.dart';

import '../core/router/app_router.dart';

/// Central navigation coordinator that enforces authentication and personalization guards.
class NavigationProvider extends ChangeNotifier {
  NavigationProvider();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  String _currentRoute = AppRouter.splash;
  bool _isAuthenticated = false;
  bool _hasCompletedProfile = false;
  bool _personalizationReady = false;

  String get currentRoute => _currentRoute;
  String get initialRoute => AppRouter.onboarding;

  void updateAuthState({
    required bool isAuthenticated,
    required bool hasProfile,
  }) {
    if (_isAuthenticated == isAuthenticated &&
        _hasCompletedProfile == hasProfile) {
      return;
    }
    _isAuthenticated = isAuthenticated;
    _hasCompletedProfile = hasProfile;
    notifyListeners();
  }

  void updatePersonalizationState(bool isReady) {
    if (_personalizationReady == isReady) return;
    _personalizationReady = isReady;
    notifyListeners();
  }

  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final resolvedSettings = resolveRoute(settings);
    _currentRoute = resolvedSettings.name ?? _currentRoute;
    return AppRouter.generateRoute(resolvedSettings);
  }

  RouteSettings resolveRoute(RouteSettings settings) {
    final targetName = settings.name ?? AppRouter.splash;

    if (_requiresAuthentication(targetName) && !_isAuthenticated) {
      return const RouteSettings(name: AppRouter.login);
    }

    if (_requiresProfileCompletion(targetName) && !_hasCompletedProfile) {
      return const RouteSettings(name: AppRouter.profileSetup);
    }

    if (_requiresPersonalization(targetName) && !_personalizationReady) {
      return const RouteSettings(name: AppRouter.personalization);
    }

    return settings;
  }

  Future<void> push(String route, {Object? arguments}) async {
    final navigator = navigatorKey.currentState;
    if (navigator == null) return;

    final resolved = resolveRoute(
      RouteSettings(name: route, arguments: arguments),
    );
    await navigator.pushNamed(resolved.name!, arguments: resolved.arguments);
  }

  Future<void> replace(String route, {Object? arguments}) async {
    final navigator = navigatorKey.currentState;
    if (navigator == null) return;

    final resolved = resolveRoute(
      RouteSettings(name: route, arguments: arguments),
    );
    await navigator.pushReplacementNamed(
      resolved.name!,
      arguments: resolved.arguments,
    );
  }

  Future<void> goHome() => replace(AppRouter.main);

  void popToRoot() {
    navigatorKey.currentState?.popUntil((route) => route.isFirst);
  }

  void pop<T extends Object?>([T? result]) {
    navigatorKey.currentState?.pop<T>(result);
  }

  Future<bool> maybePop<T extends Object?>([T? result]) async {
    final navigator = navigatorKey.currentState;
    if (navigator == null) return false;
    return navigator.maybePop<T>(result);
  }

  bool canPop() {
    return navigatorKey.currentState?.canPop() ?? false;
  }

  bool _requiresAuthentication(String name) {
    return !_publicRoutes.contains(name);
  }

  bool _requiresProfileCompletion(String name) {
    if (!_requiresAuthentication(name)) return false;
    return !_profileExemptRoutes.contains(name);
  }

  bool _requiresPersonalization(String name) {
    if (!_requiresAuthentication(name)) return false;
    return _personalizationLockedRoutes.contains(name);
  }

  static const Set<String> _publicRoutes = {
    AppRouter.splash,
    AppRouter.onboarding,
    AppRouter.login,
    AppRouter.register,
    AppRouter.forgotPassword,
    AppRouter.otpVerification,
  };

  static const Set<String> _profileExemptRoutes = {
    AppRouter.profileSetup,
    ..._publicRoutes,
  };

  static const Set<String> _personalizationLockedRoutes = {
    AppRouter.main,
    AppRouter.home,
    AppRouter.photoUpload,
    AppRouter.tryOn,
    AppRouter.wardrobe,
    AppRouter.profile,
    AppRouter.settings,
    AppRouter.capsules,
  };
}
