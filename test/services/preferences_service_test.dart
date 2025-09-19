import 'package:flutter_test/flutter_test.dart';

import 'package:fitcheck_app/services/preferences_service.dart';

void main() {
  group('PreferencesService', () {
    test('loadPreferences returns defaults from empty store', () async {
      final service = PreferencesService(store: InMemoryPreferencesStore());

      final result = await service.loadPreferences();

      expect(result['reducedMotion'], isFalse);
      expect(result['highContrast'], isFalse);
      expect(result['soundEffects'], isTrue);
      expect(result['haptics'], isTrue);
      expect(result['defaultCapsule'], 'wk-monday-reset');
    });

    test('persists values through custom store', () async {
      final store = InMemoryPreferencesStore();
      final service = PreferencesService(store: store);

      await service.saveReducedMotion(true);
      await service.saveHighContrast(true);
      await service.saveSoundEffects(false);
      await service.saveHaptics(false);
      await service.saveDefaultCapsule('capsule-test');

      final result = await service.loadPreferences();

      expect(result['reducedMotion'], isTrue);
      expect(result['highContrast'], isTrue);
      expect(result['soundEffects'], isFalse);
      expect(result['haptics'], isFalse);
      expect(result['defaultCapsule'], 'capsule-test');
    });
  });
}
