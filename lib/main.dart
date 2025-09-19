import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'providers/fit_check_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/personalization_provider.dart';
import 'providers/navigation_provider.dart';
import 'providers/trend_pulse_provider.dart';
import 'providers/try_on_session_provider.dart';
import 'services/auth_service.dart';
import 'services/analytics_service.dart';
import 'services/gemini_service.dart';
import 'core/theme/app_theme.dart';

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

        // Trend intelligence feed
        ChangeNotifierProvider(create: (_) => TrendPulseProvider()..load()),

        // Try-on session coordinator
        ChangeNotifierProxyProvider2<
          FitCheckProvider,
          PersonalizationProvider,
          TryOnSessionProvider
        >(
          create: (_) => TryOnSessionProvider(),
          update: (_, fitCheck, personalization, session) {
            final coordinator = session ?? TryOnSessionProvider();
            coordinator.updateDependencies(
              fitCheck: fitCheck,
              personalization: personalization,
              apiKey: dotenv.env['GEMINI_API_KEY'],
              config: GeminiServiceConfig.fromEnv(dotenv.env),
            );
            return coordinator;
          },
        ),

        // Navigation Provider with guard awareness
        ChangeNotifierProxyProvider2<
          AuthProvider,
          PersonalizationProvider,
          NavigationProvider
        >(
          create: (_) => NavigationProvider(),
          update: (_, auth, personalization, navigation) {
            final nav = navigation ?? NavigationProvider();
            nav.updateAuthState(
              isAuthenticated: auth.isAuthenticated,
              hasProfile: auth.user?.profile != null,
            );
            nav.updatePersonalizationState(personalization.hasLoaded);
            return nav;
          },
        ),
      ],
      child: Consumer2<ThemeProvider, NavigationProvider>(
        builder: (context, themeProvider, navigationProvider, child) {
          return MaterialApp(
            title: 'FitCheck - AI Virtual Try-On',
            debugShowCheckedModeBanner: false,

            // Theme Configuration
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,

            // App Configuration
            scaffoldMessengerKey: ErrorService.scaffoldMessengerKey,
            navigatorKey: navigationProvider.navigatorKey,
            onGenerateRoute: navigationProvider.onGenerateRoute,
            initialRoute: navigationProvider.initialRoute,

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
