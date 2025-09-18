import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitcheck_app/main.dart';
import 'package:fitcheck_app/services/analytics_service.dart';
import 'package:fitcheck_app/services/auth_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await AuthService.instance.initialize();
    await AnalyticsService.instance.initialize();
  });

  testWidgets('FitCheckApp boots without crashing', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const FitCheckApp());
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
