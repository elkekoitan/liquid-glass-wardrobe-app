import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:fitcheck_app/providers/fit_check_provider.dart';
import 'package:fitcheck_app/providers/navigation_provider.dart';
import 'package:fitcheck_app/providers/try_on_session_provider.dart';
import 'package:fitcheck_app/widgets/wardrobe_panel.dart';
import 'package:fitcheck_app/models/wardrobe_item.dart';

void main() {
  group('WardrobePanel', () {
    testWidgets('renders wardrobe metadata badges', (tester) async {
      final fitCheck = FitCheckProvider();
      fitCheck.addWardrobeItem(
        const WardrobeItem(
          id: 'coat-classic',
          name: 'Glass Trench',
          url:
              'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMBAFptFYsAAAAASUVORK5CYII=',
          tags: <String>['bright', 'capsule'],
          availability: WardrobeAvailability.available,
          personalization: WardrobePersonalization(
            primaryCapsuleId: 'spring-launch',
            supportsColorSwap: true,
            supportsLayering: true,
          ),
        ),
      );
      fitCheck.addWardrobeItem(
        const WardrobeItem(
          id: 'archived-knit',
          name: 'Legacy Knit',
          url:
              'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMBAFptFYsAAAAASUVORK5CYII=',
          tags: <String>['archive'],
          availability: WardrobeAvailability.archived,
        ),
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<FitCheckProvider>.value(value: fitCheck),
            ChangeNotifierProvider(create: (_) => NavigationProvider()),
            ChangeNotifierProvider(create: (_) => TryOnSessionProvider()),
          ],
          child: const MaterialApp(home: Scaffold(body: WardrobePanel())),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Glass Trench'), findsOneWidget);
      expect(find.text('SPRING-LAUNCH'), findsOneWidget);
      expect(find.text('BRIGHT'), findsOneWidget);
      expect(find.text('Archived'), findsOneWidget);
      expect(find.byIcon(Icons.palette_outlined), findsWidgets);
      expect(find.byIcon(Icons.layers_outlined), findsWidgets);
    });
  });
}
