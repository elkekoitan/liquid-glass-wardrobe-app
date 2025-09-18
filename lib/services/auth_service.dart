import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

/// Result class for auth operations
class AuthResult {
  final bool success;
  final UserModel? user;
  final String? error;
  final String? errorCode;

  const AuthResult({
    required this.success,
    this.user,
    this.error,
    this.errorCode,
  });

  factory AuthResult.success(UserModel? user) {
    return AuthResult(success: true, user: user);
  }

  factory AuthResult.failure(String error, [String? errorCode]) {
    return AuthResult(success: false, error: error, errorCode: errorCode);
  }
}

/// Mock Authentication Service for Development
/// Simulates Firebase authentication without real Firebase dependency
class AuthService {
  // Private constructor for singleton
  AuthService._();
  static final AuthService instance = AuthService._();

  // Mock user storage
  UserModel? _currentUser;
  final StreamController<UserModel?> _userController =
      StreamController<UserModel?>.broadcast();

  // Mock user stream
  Stream<UserModel?> get userStream => _userController.stream;

  // Check if user is authenticated
  bool get isAuthenticated => _currentUser != null;

  // Current user
  UserModel? get currentUser => _currentUser;

  // Current user ID
  String? get currentUserId => _currentUser?.uid;

  /// Get current user as UserModel
  Future<UserModel?> getCurrentUser() async {
    return _currentUser;
  }

  /// Initialize mock user from stored preferences
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      final userData = prefs.getString('userData');
      if (userData != null) {
        try {
          final userMap = json.decode(userData) as Map<String, dynamic>;
          _currentUser = UserModel.fromMap(userMap);
          _userController.add(_currentUser);
        } catch (e) {
          debugPrint('Error loading user data: $e');
        }
      }
    }
  }

  /// Register with email and password (Mock)
  Future<AuthResult> registerWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
    String? firstName,
    String? lastName,
  }) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // Basic validation
      if (email.isEmpty || password.isEmpty) {
        return AuthResult.failure('Email and password are required');
      }

      if (password.length < 6) {
        return AuthResult.failure('Password must be at least 6 characters');
      }

      // Check if user already exists (mock)
      final prefs = await SharedPreferences.getInstance();
      final existingUsers = prefs.getStringList('mock_users') ?? [];
      if (existingUsers.contains(email)) {
        return AuthResult.failure('User already exists with this email');
      }

      // Create mock user
      final userId = 'mock_user_${DateTime.now().millisecondsSinceEpoch}';
      final userModel = UserModel(
        uid: userId,
        email: email,
        displayName: displayName ?? email.split('@')[0],
        photoURL: null,
        phoneNumber: null,
        createdAt: DateTime.now(),
        lastSignIn: DateTime.now(),
        isEmailVerified: true,
        profile: UserProfile(firstName: firstName, lastName: lastName),
        preferences: const UserPreferences(),
        socialData: const UserSocialData(),
        subscription: null,
      );

      // Save user data
      existingUsers.add(email);
      await prefs.setStringList('mock_users', existingUsers);
      await prefs.setString('userData', json.encode(userModel.toMap()));
      await prefs.setBool('isLoggedIn', true);

      _currentUser = userModel;
      _userController.add(_currentUser);

      return AuthResult.success(userModel);
    } catch (e) {
      return AuthResult.failure(
        'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  /// Sign in with email and password (Mock)
  Future<AuthResult> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // Basic validation
      if (email.isEmpty || password.isEmpty) {
        return AuthResult.failure('Email and password are required');
      }

      // Check if user exists (mock)
      final prefs = await SharedPreferences.getInstance();
      final existingUsers = prefs.getStringList('mock_users') ?? [];

      if (!existingUsers.contains(email)) {
        return AuthResult.failure('No user found with this email');
      }

      // Create mock user for sign in
      final userModel = UserModel(
        uid: 'mock_user_${email.hashCode}',
        email: email,
        displayName: email.split('@')[0],
        photoURL: null,
        phoneNumber: null,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        lastSignIn: DateTime.now(),
        isEmailVerified: true,
        profile: UserProfile(firstName: null, lastName: null),
        preferences: const UserPreferences(),
        socialData: const UserSocialData(),
        subscription: null,
      );

      // Save user session
      await prefs.setString('userData', json.encode(userModel.toMap()));
      await prefs.setBool('isLoggedIn', true);

      _currentUser = userModel;
      _userController.add(_currentUser);

      return AuthResult.success(userModel);
    } catch (e) {
      return AuthResult.failure('Failed to sign in: ${e.toString()}');
    }
  }

  /// Sign out (Mock)
  Future<AuthResult> signOut() async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Clear user data
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('userData');
      await prefs.setBool('isLoggedIn', false);

      _currentUser = null;
      _userController.add(null);

      return AuthResult.success(null);
    } catch (e) {
      return AuthResult.failure('Failed to sign out: ${e.toString()}');
    }
  }

  /// Reset password (Mock)
  Future<AuthResult> resetPassword(String email) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      if (email.isEmpty) {
        return AuthResult.failure('Email is required');
      }

      // Mock successful password reset
      return AuthResult.success(null);
    } catch (e) {
      return AuthResult.failure('Failed to send reset email: ${e.toString()}');
    }
  }

  /// Send email verification (Mock)
  Future<AuthResult> sendEmailVerification() async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      return AuthResult.success(null);
    } catch (e) {
      return AuthResult.failure(
        'Failed to send verification email: ${e.toString()}',
      );
    }
  }

  /// Send password reset email (Mock)
  Future<AuthResult> sendPasswordResetEmail(String email) async {
    return resetPassword(email);
  }

  /// Reload user data (Mock)
  Future<AuthResult> reloadUser() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _userController.add(_currentUser);
      return AuthResult.success(_currentUser);
    } catch (e) {
      return AuthResult.failure('Failed to reload user: ${e.toString()}');
    }
  }

  /// Update user profile (Mock)
  Future<AuthResult> updateUserProfile({
    String? displayName,
    String? photoURL,
    String? firstName,
    String? lastName,
    UserProfile? profile,
    UserPreferences? preferences,
  }) async {
    try {
      if (_currentUser == null) {
        return AuthResult.failure('No user logged in');
      }

      final updatedProfile =
          profile ??
          _currentUser!.profile?.copyWith(
            firstName: firstName,
            lastName: lastName,
          );

      final updatedUser = _currentUser!.copyWith(
        displayName: displayName,
        photoURL: photoURL,
        profile: updatedProfile,
        preferences: preferences ?? _currentUser!.preferences,
      );

      _currentUser = updatedUser;
      _userController.add(_currentUser);

      // Save to preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userData', json.encode(updatedUser.toMap()));

      return AuthResult.success(updatedUser);
    } catch (e) {
      return AuthResult.failure('Failed to update profile: ${e.toString()}');
    }
  }

  /// Change password (Mock)
  Future<AuthResult> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      // Simulate password change
      await Future.delayed(const Duration(seconds: 1));

      if (newPassword.length < 6) {
        return AuthResult.failure('New password must be at least 6 characters');
      }

      return AuthResult.success(_currentUser);
    } catch (e) {
      return AuthResult.failure('Failed to change password: ${e.toString()}');
    }
  }

  /// Delete account (Mock)
  Future<AuthResult> deleteAccount(String password) async {
    try {
      // Simulate account deletion
      await Future.delayed(const Duration(seconds: 1));

      // Clear user data
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('userData');
      await prefs.setBool('isLoggedIn', false);

      _currentUser = null;
      _userController.add(null);

      return AuthResult.success(null);
    } catch (e) {
      return AuthResult.failure('Failed to delete account: ${e.toString()}');
    }
  }

  /// Verify a one-time passcode (mock implementation)
  Future<AuthResult> verifyOtpCode({required String code}) async {
    try {
      await Future.delayed(const Duration(milliseconds: 900));

      if (code == '123456') {
        return AuthResult.success(_currentUser);
      }

      return AuthResult.failure(
        'The verification code is incorrect. Please try again.',
        'invalid-otp',
      );
    } catch (e) {
      return AuthResult.failure('Failed to verify code: ${e.toString()}');
    }
  }

  /// Sign in with Google (Mock)
  Future<AuthResult> signInWithGoogle() async {
    try {
      // Simulate Google sign in
      await Future.delayed(const Duration(seconds: 1));

      // Create mock Google user
      final userModel = UserModel(
        uid: 'google_mock_user_${DateTime.now().millisecondsSinceEpoch}',
        email: 'user@gmail.com',
        displayName: 'Google User',
        photoURL: 'https://via.placeholder.com/150',
        phoneNumber: null,
        createdAt: DateTime.now(),
        lastSignIn: DateTime.now(),
        isEmailVerified: true,
        profile: UserProfile(firstName: 'Google', lastName: 'User'),
        preferences: const UserPreferences(),
        socialData: const UserSocialData(),
        subscription: null,
      );

      // Save user session
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userData', json.encode(userModel.toMap()));
      await prefs.setBool('isLoggedIn', true);

      _currentUser = userModel;
      _userController.add(_currentUser);

      return AuthResult.success(userModel);
    } catch (e) {
      return AuthResult.failure(
        'Failed to sign in with Google: ${e.toString()}',
      );
    }
  }

  /// Dispose of resources
  void dispose() {
    _userController.close();
  }
}
