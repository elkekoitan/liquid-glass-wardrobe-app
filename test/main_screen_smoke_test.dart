import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:fitcheck_app/design_system/design_tokens.dart' as ds;
import 'package:fitcheck_app/providers/fit_check_provider.dart';
import 'package:fitcheck_app/providers/personalization_provider.dart';
import 'package:fitcheck_app/providers/try_on_session_provider.dart';
import 'package:fitcheck_app/services/gemini_service.dart';
import 'package:fitcheck_app/screens/main_app_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    dotenv.testLoad(fileInput: 'GEMINI_API_KEY=test-key');
  });

  testWidgets(
    'MainAppScreen renders start flow and responds to personalization controls',
    (tester) async {
      final personalization = PersonalizationProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: personalization),
            ChangeNotifierProvider(create: (_) => FitCheckProvider()),
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
          ],
          child: const MaterialApp(home: MainAppScreen()),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Create Your Model'), findsOneWidget);

      AnimatedContainer surface = tester.widget(
        find.byKey(const ValueKey('personalized-surface')),
      );
      final gradient =
          (surface.decoration as BoxDecoration).gradient as LinearGradient;
      expect(gradient.colors.first, const Color(0xFF101828));
      expect(surface.duration, equals(ds.DesignTokens.durationSlow));

      await personalization.toggleHighContrast(true);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      surface = tester.widget(
        find.byKey(const ValueKey('personalized-surface')),
      );
      final highGradient =
          (surface.decoration as BoxDecoration).gradient as LinearGradient;
      expect(highGradient.colors.first, ds.AppColors.neutral900);

      await personalization.toggleReducedMotion(true);
      await tester.pump();

      surface = tester.widget(
        find.byKey(const ValueKey('personalized-surface')),
      );
      expect(surface.duration, Duration.zero);
    },
  );
}
