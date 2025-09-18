import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'providers/fit_check_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/personalization_provider.dart';
import 'services/auth_service.dart';
import 'services/analytics_service.dart';
import 'core/theme/app_theme.dart';

import 'core/router/app_router.dart';
import 'core/services/error_service.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Mock Auth Service
  await AuthService.instance.initialize();

  // Initialize analytics service placeholder
  await AnalyticsService.instance.initialize();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const FitCheckApp());
}

class FitCheckApp extends StatelessWidget {
  const FitCheckApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Theme Provider - Must be first for theme access
        ChangeNotifierProvider(create: (_) => ThemeProvider()..initialize()),

        // Personalization Provider
        ChangeNotifierProvider(
          create: (_) => PersonalizationProvider()..load(),
        ),

        // Authentication Provider
        ChangeNotifierProvider(create: (_) => AuthProvider()..initialize()),

        // Main App State Provider
        ChangeNotifierProvider(create: (_) => FitCheckProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'FitCheck - AI Virtual Try-On',
            debugShowCheckedModeBanner: false,

            // Theme Configuration
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,

            // App Configuration
            scaffoldMessengerKey: ErrorService.scaffoldMessengerKey,
            onGenerateRoute: AppRouter.generateRoute,
            initialRoute: AppRouter.login,

            // Performance optimizations
            builder: (context, child) {
              return MediaQuery(
                // Disable text scaling to maintain design consistency
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(1.0)),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}
