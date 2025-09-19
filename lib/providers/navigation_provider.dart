import 'package:flutter/material.dart';

import '../core/router/app_router.dart';
import '../services/analytics_service.dart';

/// Central navigation coordinator that enforces authentication/personalization
/// guards and records analytics events for every transition.
class NavigationProvider extends ChangeNotifier {
  NavigationProvider();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final AnalyticsService _analytics = AnalyticsService.instance;

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

  RouteSettings resolveRoute(
    RouteSettings settings, {
    bool fromDeepLink = false,
  }) {
    final targetName = settings.name ?? AppRouter.splash;

    if (_requiresAuthentication(targetName) && !_isAuthenticated) {
      _analytics.logEvent(
        'navigation_guard_redirect',
        parameters: {
          'requested_route': targetName,
          'redirect_target': AppRouter.login,
          'reason': 'auth',
          'from_deeplink': fromDeepLink,
        },
      );
      _analytics.logEvent(
        'navigation_resolved',
        parameters: {
          'requested_route': targetName,
          'resolved_route': AppRouter.login,
          'from_deeplink': fromDeepLink,
        },
      );
      return const RouteSettings(name: AppRouter.login);
    }

    if (_requiresProfileCompletion(targetName) && !_hasCompletedProfile) {
      _analytics.logEvent(
        'navigation_guard_redirect',
        parameters: {
          'requested_route': targetName,
          'redirect_target': AppRouter.profileSetup,
          'reason': 'profile',
          'from_deeplink': fromDeepLink,
        },
      );
      _analytics.logEvent(
        'navigation_resolved',
        parameters: {
          'requested_route': targetName,
          'resolved_route': AppRouter.profileSetup,
          'from_deeplink': fromDeepLink,
        },
      );
      return const RouteSettings(name: AppRouter.profileSetup);
    }

    if (_requiresPersonalization(targetName) && !_personalizationReady) {
      _analytics.logEvent(
        'navigation_guard_redirect',
        parameters: {
          'requested_route': targetName,
          'redirect_target': AppRouter.personalization,
          'reason': 'personalization',
          'from_deeplink': fromDeepLink,
        },
      );
      _analytics.logEvent(
        'navigation_resolved',
        parameters: {
          'requested_route': targetName,
          'resolved_route': AppRouter.personalization,
          'from_deeplink': fromDeepLink,
        },
      );
      return const RouteSettings(name: AppRouter.personalization);
    }

    _analytics.logEvent(
      'navigation_resolved',
      parameters: {
        'requested_route': targetName,
        'resolved_route': targetName,
        'from_deeplink': fromDeepLink,
      },
    );
    return settings;
  }

  Future<void> push(String route, {Object? arguments}) async {
    await _navigate(
      action: 'push',
      requestedRoute: route,
      arguments: arguments,
      fromDeepLink: false,
      executor: (navigator, resolved) =>
          navigator.pushNamed(resolved.name!, arguments: resolved.arguments),
    );
  }

  Future<void> replace(String route, {Object? arguments}) async {
    await _navigate(
      action: 'replace',
      requestedRoute: route,
      arguments: arguments,
      fromDeepLink: false,
      executor: (navigator, resolved) => navigator.pushReplacementNamed(
        resolved.name!,
        arguments: resolved.arguments,
      ),
    );
  }

  Future<void> goHome() => replace(AppRouter.main);

  void popToRoot() {
    final navigator = navigatorKey.currentState;
    if (navigator == null) return;
    navigator.popUntil((route) => route.isFirst);
    _analytics.logEvent(
      'navigation_pop_to_root',
      parameters: {
        'previous_route': _currentRoute,
        'can_pop_after': navigator.canPop(),
      },
    );
  }

  void pop<T extends Object?>([T? result]) {
    final navigator = navigatorKey.currentState;
    if (navigator == null) return;
    navigator.pop<T>(result);
    _analytics.logEvent(
      'navigation_pop',
      parameters: {
        'previous_route': _currentRoute,
        'result_provided': result != null,
        'can_pop_after': navigator.canPop(),
      },
    );
  }

  Future<bool> maybePop<T extends Object?>([T? result]) async {
    final navigator = navigatorKey.currentState;
    if (navigator == null) return false;
    final didPop = await navigator.maybePop<T>(result);
    if (didPop) {
      _analytics.logEvent(
        'navigation_maybe_pop',
        parameters: {
          'previous_route': _currentRoute,
          'result_provided': result != null,
        },
      );
    }
    return didPop;
  }

  bool canPop() {
    return navigatorKey.currentState?.canPop() ?? false;
  }

  Future<void> handleDeepLink(String route, {Object? arguments}) async {
    await _navigate(
      action: 'deeplink',
      requestedRoute: route,
      arguments: arguments,
      fromDeepLink: true,
      executor: (navigator, resolved) =>
          navigator.pushNamed(resolved.name!, arguments: resolved.arguments),
    );
  }

  Future<void> _navigate({
    required String action,
    required String requestedRoute,
    Object? arguments,
    required bool fromDeepLink,
    required Future<void> Function(
      NavigatorState navigator,
      RouteSettings resolved,
    )
    executor,
  }) async {
    final navigator = navigatorKey.currentState;
    if (navigator == null) return;

    final resolved = resolveRoute(
      RouteSettings(name: requestedRoute, arguments: arguments),
      fromDeepLink: fromDeepLink,
    );

    await executor(navigator, resolved);
    _currentRoute = resolved.name ?? _currentRoute;

    _analytics.logEvent(
      'navigation_$action',
      parameters: {
        'requested_route': requestedRoute,
        'resolved_route': resolved.name,
        'redirected': resolved.name != requestedRoute,
        'from_deeplink': fromDeepLink,
        'arguments_present': resolved.arguments != null,
      },
    );
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
    AppRouter.trendPulse,
  };
}
