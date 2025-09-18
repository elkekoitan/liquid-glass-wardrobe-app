import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/login_preferences_service.dart';

/// Authentication Provider for managing user authentication state
/// Provides reactive authentication state management across the app
class AuthProvider extends ChangeNotifier {
  // Private fields
  UserModel? _user;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _error;

  // Subscriptions
  StreamSubscription<UserModel?>? _userSubscription;

  // Getters
  UserModel? get user => _user;
  UserModel? get currentUser => _user;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get error => _error;
  String? get errorMessage => _error;

  // Authentication status getters
  bool get isAuthenticated => _user != null;
  bool get isEmailVerified => _user?.isEmailVerified ?? false;
  String? get userId => _user?.uid;
  String? get userEmail => _user?.email;
  String? get userName => _user?.displayName ?? _user?.profile?.fullName;

  /// Initialize authentication provider
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _setLoading(true);

      // Listen to authentication state changes
      _userSubscription = AuthService.instance.userStream.listen(
        (user) {
          _user = user;
          _setError(null);
          notifyListeners();

          debugPrint(
            'AuthProvider: User state changed - ${user != null ? 'Authenticated' : 'Unauthenticated'}',
          );
        },
        onError: (error) {
          _setError('Authentication stream error: ${error.toString()}');
          debugPrint('AuthProvider: Stream error - $error');
        },
      );

      // Get initial user state
      _user = await AuthService.instance.getCurrentUser();
      _isInitialized = true;
    } catch (e) {
      _setError('Failed to initialize authentication: ${e.toString()}');
      debugPrint('AuthProvider: Initialization error - $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Sign in with email and password
  Future<bool> signInWithEmailAndPassword({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final result = await AuthService.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.success) {
        _user = result.user;

        final service = LoginPreferencesService.instance;
        if (rememberMe) {
          await service.save(
            remember: true,
            email: email.trim(),
            context: LoginContext.login,
          );
        } else {
          await service.clear(context: LoginContext.login);
        }

        debugPrint('AuthProvider: Sign in successful for $email');
        return true;
      } else {
        _setError(result.error);
        debugPrint('AuthProvider: Sign in failed - ${result.error}');
        return false;
      }
    } catch (e) {
      _setError('Sign in failed: ${e.toString()}');
      debugPrint('AuthProvider: Sign in exception - $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Sign in with Google and optionally remember credentials
  Future<bool> signInWithGoogle({bool rememberMe = true}) async {
    try {
      _setLoading(true);
      _setError(null);

      final result = await AuthService.instance.signInWithGoogle();

      if (result.success) {
        _user = result.user;

        final email = result.user?.email?.trim();
        if (email != null && email.isNotEmpty) {
          final service = LoginPreferencesService.instance;
          if (rememberMe) {
            await service.save(
              remember: true,
              email: email,
              context: LoginContext.login,
            );
          } else {
            await service.clear(context: LoginContext.login);
          }
        }

        debugPrint('AuthProvider: Google sign in successful');
        return true;
      } else {
        _setError(result.error);
        debugPrint('AuthProvider: Google sign in failed - ${result.error}');
        return false;
      }
    } on PlatformException catch (e) {
      final code = e.code;
      String message;
      if (code.contains('sign_in_failed')) {
        if (e.message?.contains('10') == true) {
          message =
              'Google Sign-In yapılandırması eksik. Lütfen daha sonra tekrar deneyin.';
        } else {
          message =
              'Google ile giriş başarısız. İnternet bağlantınızı kontrol edin.';
        }
      } else if (code.contains('sign_in_canceled')) {
        message = 'Google ile giriş iptal edildi.';
      } else {
        message = 'Google Sign-In hatası: ${e.message ?? 'Bilinmeyen hata'}';
      }
      _setError(message);
      debugPrint(
        'AuthProvider: Google sign in platform exception - ${e.toString()}',
      );
      return false;
    } catch (e) {
      _setError('Google sign in failed: ${e.toString()}');
      debugPrint('AuthProvider: Google sign in exception - ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Sign in with Apple and optionally remember credentials
  Future<bool> signInWithApple({bool rememberMe = true}) async {
    try {
      _setLoading(true);
      _setError(null);

      final result = await AuthService.instance.signInWithApple();

      if (result.success) {
        _user = result.user;

        final email = result.user?.email?.trim();
        if (email != null && email.isNotEmpty) {
          final service = LoginPreferencesService.instance;
          if (rememberMe) {
            await service.save(
              remember: true,
              email: email,
              context: LoginContext.login,
            );
          } else {
            await service.clear(context: LoginContext.login);
          }
        }

        debugPrint('AuthProvider: Apple sign in successful');
        return true;
      } else {
        _setError(result.error);
        debugPrint('AuthProvider: Apple sign in failed - ${result.error}');
        return false;
      }
    } on PlatformException catch (e) {
      final code = e.code;
      String message;
      if (code.contains('sign_in_failed')) {
        message =
            'Apple Sign-In yapılandırması eksik. Lütfen daha sonra tekrar deneyin.';
      } else if (code.contains('sign_in_canceled')) {
        message = 'Apple ile giriş iptal edildi.';
      } else {
        message = 'Apple Sign-In hatası: ${e.message ?? 'Bilinmeyen hata'}';
      }
      _setError(message);
      debugPrint(
        'AuthProvider: Apple sign in platform exception - ${e.toString()}',
      );
      return false;
    } catch (e) {
      _setError('Apple sign in failed: ${e.toString()}');
      debugPrint('AuthProvider: Apple sign in exception - ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Register new user with email and password
  Future<bool> registerWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
    String? firstName,
    String? lastName,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final result = await AuthService.instance.registerWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName,
        firstName: firstName,
        lastName: lastName,
      );

      if (result.success) {
        _user = result.user;
        debugPrint('AuthProvider: Registration successful for $email');
        return true;
      } else {
        _setError(result.error);
        debugPrint('AuthProvider: Registration failed - ${result.error}');
        return false;
      }
    } catch (e) {
      _setError('Registration failed: ${e.toString()}');
      debugPrint('AuthProvider: Registration exception - $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Register with email and password - simplified signature
  Future<bool> register({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
  }) async {
    return registerWithEmailAndPassword(
      email: email,
      password: password,
      displayName: firstName != null && lastName != null
          ? '$firstName $lastName'
          : null,
      firstName: firstName,
      lastName: lastName,
    );
  }

  /// Reset password - simplified signature
  Future<bool> resetPassword(String email) async {
    return sendPasswordResetEmail(email);
  }

  /// Update profile - simplified signature
  Future<bool> updateProfile({
    String? displayName,
    String? photoURL,
    UserProfile? profile,
    UserPreferences? preferences,
  }) async {
    return updateUserProfile(
      displayName: displayName,
      photoURL: photoURL,
      profile: profile,
      preferences: preferences,
    );
  }

  /// Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      _setLoading(true);
      _setError(null);

      final result = await AuthService.instance.sendPasswordResetEmail(email);

      if (result.success) {
        debugPrint('AuthProvider: Password reset email sent to $email');
        return true;
      } else {
        _setError(result.error);
        debugPrint('AuthProvider: Password reset failed - ${result.error}');
        return false;
      }
    } catch (e) {
      _setError('Password reset failed: ${e.toString()}');
      debugPrint('AuthProvider: Password reset exception - $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      _setLoading(true);

      await AuthService.instance.signOut();

      _user = null;
      _setError(null);

      debugPrint('AuthProvider: User signed out successfully');
    } catch (e) {
      _setError('Sign out failed: ${e.toString()}');
      debugPrint('AuthProvider: Sign out exception - $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Reload current user data
  Future<void> reloadUser() async {
    if (!isAuthenticated) return;

    try {
      _setLoading(true);

      await AuthService.instance.reloadUser();
      _user = await AuthService.instance.getCurrentUser();

      debugPrint('AuthProvider: User data reloaded');
    } catch (e) {
      _setError('Failed to reload user data: ${e.toString()}');
      debugPrint('AuthProvider: Reload user exception - $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Update user profile
  Future<bool> updateUserProfile({
    String? displayName,
    String? photoURL,
    UserProfile? profile,
    UserPreferences? preferences,
  }) async {
    if (!isAuthenticated) return false;

    try {
      _setLoading(true);
      _setError(null);

      final result = await AuthService.instance.updateUserProfile(
        displayName: displayName,
        photoURL: photoURL,
        profile: profile,
        preferences: preferences,
      );

      if (result.success) {
        _user = result.user;
        debugPrint('AuthProvider: Profile updated successfully');
        return true;
      } else {
        _setError(result.error);
        debugPrint('AuthProvider: Profile update failed - ${result.error}');
        return false;
      }
    } catch (e) {
      _setError('Profile update failed: ${e.toString()}');
      debugPrint('AuthProvider: Profile update exception - $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Send email verification
  Future<bool> sendEmailVerification() async {
    if (!isAuthenticated) return false;

    try {
      _setLoading(true);
      _setError(null);

      final result = await AuthService.instance.sendEmailVerification();

      if (result.success) {
        debugPrint('AuthProvider: Email verification sent');
        return true;
      } else {
        _setError(result.error);
        debugPrint('AuthProvider: Email verification failed - ${result.error}');
        return false;
      }
    } catch (e) {
      _setError('Email verification failed: ${e.toString()}');
      debugPrint('AuthProvider: Email verification exception - $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Change user password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (!isAuthenticated) return false;

    try {
      _setLoading(true);
      _setError(null);

      final result = await AuthService.instance.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      if (result.success) {
        debugPrint('AuthProvider: Password changed successfully');
        return true;
      } else {
        _setError(result.error);
        debugPrint('AuthProvider: Password change failed - ${result.error}');
        return false;
      }
    } catch (e) {
      _setError('Password change failed: ${e.toString()}');
      debugPrint('AuthProvider: Password change exception - $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete user account
  Future<bool> deleteAccount(String password) async {
    if (!isAuthenticated) return false;

    try {
      _setLoading(true);
      _setError(null);

      final result = await AuthService.instance.deleteAccount(password);

      if (result.success) {
        _user = null;
        debugPrint('AuthProvider: Account deleted successfully');
        return true;
      } else {
        _setError(result.error);
        debugPrint('AuthProvider: Account deletion failed - ${result.error}');
        return false;
      }
    } catch (e) {
      _setError('Account deletion failed: ${e.toString()}');
      debugPrint('AuthProvider: Account deletion exception - $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Clear error state
  void clearError() {
    _setError(null);
  }

  /// Set loading state
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  /// Set error state
  void _setError(String? error) {
    if (_error != error) {
      _error = error;
      notifyListeners();
    }
  }

  /// Check if user needs to complete profile setup
  bool get needsProfileSetup {
    if (!isAuthenticated) return false;

    final profile = _user?.profile;
    return profile == null ||
        (profile.firstName?.isEmpty ?? true) ||
        (profile.lastName?.isEmpty ?? true);
  }

  /// Check if user needs email verification
  bool get needsEmailVerification {
    return isAuthenticated && !isEmailVerified;
  }

  /// Get user initials for avatar
  String get userInitials {
    if (!isAuthenticated) return '';

    final name = userName;
    if (name == null || name.isEmpty) {
      return userEmail?.substring(0, 1).toUpperCase() ?? '';
    }

    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0].substring(0, 1)}${parts[1].substring(0, 1)}'
          .toUpperCase();
    } else {
      return parts[0].substring(0, 1).toUpperCase();
    }
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }
}
