import 'package:flutter/material.dart';
import '../../screens/onboarding/onboarding_screen.dart';
import '../../screens/photo_upload/modern_photo_upload_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/auth/forgot_password_screen.dart';
import '../../screens/auth/profile_setup_screen.dart';
import '../../screens/auth/otp_verification_screen.dart';
import '../../screens/main/home_screen.dart';
import '../../screens/capsules/capsule_gallery_screen.dart';
import '../../screens/settings/personalization_settings_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String profileSetup = '/profile-setup';
  static const String otpVerification = '/otp';
  static const String main = '/main';
  static const String home = '/home';
  static const String photoUpload = '/photo-upload';
  static const String tryOn = '/try-on';
  static const String wardrobe = '/wardrobe';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String capsules = '/capsules';
  static const String personalization = '/settings/personalization';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _createRoute(
          const OnboardingScreen(),
          settings: settings,
          transitionType: _TransitionType.fade,
        );

      case onboarding:
        return _createRoute(
          const OnboardingScreen(),
          settings: settings,
          transitionType: _TransitionType.slideFromRight,
        );

      case login:
        return _createRoute(
          const LoginScreen(),
          settings: settings,
          transitionType: _TransitionType.slideFromRight,
        );

      case register:
        return _createRoute(
          const RegisterScreen(),
          settings: settings,
          transitionType: _TransitionType.slideFromRight,
        );

      case forgotPassword:
        return _createRoute(
          const ForgotPasswordScreen(),
          settings: settings,
          transitionType: _TransitionType.slideFromRight,
        );

      case profileSetup:
        return _createRoute(
          const ProfileSetupScreen(),
          settings: settings,
          transitionType: _TransitionType.slideFromRight,
        );

      case otpVerification:
        return _createRoute(
          const OtpVerificationScreen(),
          settings: settings,
          transitionType: _TransitionType.fade,
        );

      case capsules:
        return _createRoute(
          const CapsuleGalleryScreen(),
          settings: settings,
          transitionType: _TransitionType.fade,
        );

      case personalization:
        return _createRoute(
          const PersonalizationSettingsScreen(),
          settings: settings,
          transitionType: _TransitionType.slideFromRight,
        );

      case main:
      case home:
        return _createRoute(
          const HomeScreen(),
          settings: settings,
          transitionType: _TransitionType.fade,
        );

      case photoUpload:
        return _createRoute(
          const ModernPhotoUploadScreen(),
          settings: settings,
          transitionType: _TransitionType.slideFromBottom,
        );

      default:
        return _createRoute(
          const _NotFoundScreen(),
          settings: settings,
          transitionType: _TransitionType.fade,
        );
    }
  }

  static Route<dynamic> _createRoute(
    Widget destination, {
    required RouteSettings settings,
    _TransitionType transitionType = _TransitionType.slideFromRight,
  }) {
    switch (transitionType) {
      case _TransitionType.fade:
        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (context, animation, _) => destination,
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        );

      case _TransitionType.slideFromRight:
        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (context, animation, _) => destination,
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOutCubic;

            var tween = Tween(
              begin: begin,
              end: end,
            ).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );

      case _TransitionType.slideFromBottom:
        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (context, animation, _) => destination,
          transitionDuration: const Duration(milliseconds: 400),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.easeOutCubic;

            var tween = Tween(
              begin: begin,
              end: end,
            ).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );
    }
  }
}

enum _TransitionType { fade, slideFromRight, slideFromBottom }

class _NotFoundScreen extends StatelessWidget {
  const _NotFoundScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '404 - Page Not Found',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'The page you are looking for does not exist.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
