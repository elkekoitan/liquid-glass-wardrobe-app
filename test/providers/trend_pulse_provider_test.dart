import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitcheck_app/features/trend_pulse/domain/trend_pulse_models.dart';
import 'package:fitcheck_app/providers/trend_pulse_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TrendPulseProvider', () {
    late TrendPulseBundle bundle;

    setUp(() {
      bundle = TrendPulseBundle(
        lastUpdated: DateTime.utc(2025, 9, 19, 5),
        dailyDrop: TrendDrop(
          id: 'drop-test',
          title: 'Test Drop',
          tagline: 'A curated energy burst',
          startUtc: DateTime.utc(2025, 9, 19, 5),
          endUtc: DateTime.utc(2025, 9, 20, 5),
          heroImageUrl: 'https://example.com/drop.jpg',
          pinterestBoardId: 'board/test',
          pinterestCurator: 'Club Test',
          pinterestHeroPinId: '123',
          accentColors: const [Color(0xFF111111)],
          callToActions: const [
            TrendCallToAction(
              label: 'View',
              route: '/capsules',
              analyticsTag: 'capsule_test',
            ),
          ],
          badges: const ['Limited'],
        ),
        weeklySaga: [
          TrendSaga(
            id: 'saga-1',
            title: 'Saga',
            subtitle: 'Subtitle',
            pinterestBoardId: 'board/saga',
            coverImageUrl: 'https://example.com/saga.jpg',
            accentColor: const Color(0xFF000000),
            beats: [
              TrendSagaBeat(
                stage: 1,
                label: 'Stage',
                description: 'Desc',
                windowUtc: DateTime.utc(2025, 9, 19, 18),
              ),
            ],
          ),
        ],
        eventTicker: [
          TrendTickerEvent(
            id: 'ticker',
            message: 'Message',
            accentColor: const Color(0xFFFFFFFF),
            startUtc: DateTime.utc(2025, 9, 19, 5),
            endUtc: DateTime.utc(2025, 9, 20, 5),
          ),
        ],
      );
    });

    test('load populates bundle and status', () async {
      var callCount = 0;
      Future<TrendPulseBundle> loader({bool forceRefresh = false}) async {
        callCount++;
        return bundle;
      }

      final provider = TrendPulseProvider(loader: loader);

      await provider.load();

      expect(provider.status, TrendPulseStatus.ready);
      expect(provider.bundle, isNotNull);
      expect(provider.dailyDrop?.id, 'drop-test');
      expect(callCount, 1);
    });

    test('load without refresh does not re-fetch', () async {
      var callCount = 0;
      Future<TrendPulseBundle> loader({bool forceRefresh = false}) async {
        callCount++;
        return bundle;
      }

      final provider = TrendPulseProvider(loader: loader);

      await provider.load();
      await provider.load();

      expect(callCount, 1);
    });

    test('load with refresh forces re-fetch', () async {
      var callCount = 0;
      Future<TrendPulseBundle> loader({bool forceRefresh = false}) async {
        callCount++;
        return bundle;
      }

      final provider = TrendPulseProvider(loader: loader);

      await provider.load();
      await provider.load(refresh: true);

      expect(callCount, 2);
    });

    test('load surfaces error state when loader throws', () async {
      Future<TrendPulseBundle> loader({bool forceRefresh = false}) async {
        throw Exception('network');
      }

      final provider = TrendPulseProvider(loader: loader);

      await provider.load();

      expect(provider.status, TrendPulseStatus.error);
      expect(provider.error, contains('Exception'));
    });

    test('record helpers execute without throwing', () {
      final provider = TrendPulseProvider(
        loader: ({forceRefresh = false}) async => bundle,
      );

      provider.recordCtaTap(bundle.dailyDrop.callToActions.first);
      provider.recordSagaFocus(bundle.weeklySaga.first);
      provider.recordTickerInteraction(bundle.eventTicker.first);

      expect(provider.status, TrendPulseStatus.initial);
    });
  });
}
