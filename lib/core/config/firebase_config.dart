import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Firebase Configuration Class
/// Contains platform-specific Firebase configurations
class FirebaseConfig {
  // Private constructor to prevent instantiation
  FirebaseConfig._();

  /// Firebase Options for different platforms
  /// These values will be replaced with actual Firebase project credentials
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDh7JQgS6qNdKrV8mN5XLZGwKE7YjOUcZs', // Replace with actual
    appId: '1:123456789:android:abcdef123456789', // Replace with actual
    messagingSenderId: '123456789', // Replace with actual
    projectId: 'liquid-glass-fit-check', // Replace with actual project ID
    storageBucket: 'liquid-glass-fit-check.appspot.com', // Replace with actual
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDh7JQgS6qNdKrV8mN5XLZGwKE7YjOUcZs', // Replace with actual
    appId: '1:123456789:ios:fedcba987654321', // Replace with actual
    messagingSenderId: '123456789', // Replace with actual
    projectId: 'liquid-glass-fit-check', // Replace with actual project ID
    storageBucket: 'liquid-glass-fit-check.appspot.com', // Replace with actual
    iosBundleId: 'com.liquidglass.fitcheck', // Replace with actual
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDh7JQgS6qNdKrV8mN5XLZGwKE7YjOUcZs', // Replace with actual
    appId: '1:123456789:web:1234567890abcdef', // Replace with actual
    messagingSenderId: '123456789', // Replace with actual
    projectId: 'liquid-glass-fit-check', // Replace with actual project ID
    storageBucket: 'liquid-glass-fit-check.appspot.com', // Replace with actual
    authDomain: 'liquid-glass-fit-check.firebaseapp.com', // Replace with actual
    measurementId: 'G-XXXXXXXXXX', // Replace with actual
  );

  /// Get current platform Firebase options
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return ios; // Use iOS config for macOS
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for this platform.',
        );
    }
  }

  /// Initialize Firebase with platform-specific options
  static Future<FirebaseApp> initialize() async {
    try {
      debugPrint('🔥 Initializing Firebase...');

      final app = await Firebase.initializeApp(
        name: 'liquid-glass-fit-check',
        options: currentPlatform,
      );

      debugPrint('🔥 Firebase initialized successfully: ${app.name}');
      return app;
    } catch (e) {
      debugPrint('❌ Firebase initialization failed: $e');
      rethrow;
    }
  }

  /// Development/Testing configuration
  static const bool useFirebaseEmulator =
      false; // Set to true for local testing
  static const String emulatorHost = 'localhost';
  static const int authEmulatorPort = 9099;
  static const int firestoreEmulatorPort = 8080;
  static const int storageEmulatorPort = 9199;

  /// Configure Firebase emulators for local development
  static Future<void> configureEmulators() async {
    if (!useFirebaseEmulator || kReleaseMode) return;

    try {
      debugPrint('🔧 Configuring Firebase Emulators...');

      // Note: Emulator configuration would be done here
      // This is a placeholder for future development

      debugPrint('🔧 Firebase Emulators configured');
    } catch (e) {
      debugPrint('❌ Failed to configure Firebase Emulators: $e');
    }
  }
}
