import 'package:flutter_test/flutter_test.dart';

import 'package:fitcheck_app/models/capsule_model.dart';

void main() {
  group('CapsuleModel', () {
    test('parses availability and personalization metadata', () {
      final model = CapsuleModel.fromMap(<String, dynamic>{
        'id': 'capsule-test',
        'name': 'Test Capsule',
        'mood': 'Calm',
        'type': 'weekly',
        'startDate': '2025-03-01',
        'endDate': '2025-03-07',
        'description': 'A calm capsule for validation.',
        'colorway': <String>['#111111', '#222222'],
        'signatureDetail': 'calm-wave',
        'heroImage': 'assets/images/fashion/test.jpg',
        'accessibilityVariant': 'high-contrast',
        'tags': <String>['calm', 'reset'],
        'microcopy': <String, dynamic>{
          'prompt': 'Prompt text',
          'success': 'Success text',
          'error': 'Error text',
        },
        'availability': 'scheduled',
        'personalization': <String, dynamic>{
          'primaryIntent': 'weekday_reset',
          'supportsReducedMotion': true,
          'supportsHighContrast': false,
          'recommendedWardrobeIds': <String>['wardrobe-1', 'wardrobe-2'],
        },
        'wardrobeItemIds': <String>['wardrobe-1', 'wardrobe-3'],
      });

      expect(model.availability, CapsuleAvailability.scheduled);
      expect(model.isSelectable, isFalse);
      expect(model.personalization.primaryIntent, 'weekday_reset');
      expect(model.personalization.supportsReducedMotion, isTrue);
      expect(
        model.personalization.recommendedWardrobeIds,
        contains('wardrobe-2'),
      );
      expect(
        model.wardrobeItemIds,
        containsAll(<String>['wardrobe-1', 'wardrobe-3']),
      );

      final serialized = model.toMap();
      expect(serialized['availability'], 'scheduled');
      expect(serialized['personalization'], isA<Map<String, dynamic>>());
      expect(serialized['wardrobeItemIds'], isA<List<dynamic>>());
    });

    test('falls back to defaults when metadata missing', () {
      final model = CapsuleModel.fromMap(<String, dynamic>{
        'id': 'capsule-minimal',
        'name': 'Minimal Capsule',
        'mood': 'Bright',
        'type': 'weekly',
        'description': 'Minimal metadata for defaults.',
        'colorway': const <String>[],
        'signatureDetail': '',
        'heroImage': 'assets/images/fashion/minimal.jpg',
        'accessibilityVariant': 'high-contrast',
        'tags': const <String>[],
        'microcopy': const <String, dynamic>{},
      });

      expect(model.availability, CapsuleAvailability.live);
      expect(model.isSelectable, isTrue);
      expect(model.personalization.primaryIntent, isEmpty);
      expect(model.personalization.recommendedWardrobeIds, isEmpty);
      expect(model.wardrobeItemIds, isEmpty);
    });
  });
}
