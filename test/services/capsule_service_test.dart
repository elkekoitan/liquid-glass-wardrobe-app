import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitcheck_app/models/capsule_model.dart';
import 'package:fitcheck_app/services/capsule_service.dart';

void main() {
  group('CapsuleService', () {
    test('falls back to offline seed when asset missing', () async {
      final fallback = <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 'offline-one',
          'name': 'Offline Capsule',
          'mood': 'Relaxed',
          'type': 'weekly',
          'description': 'Fallback capsule for offline use.',
          'colorway': <String>['#010101'],
          'signatureDetail': 'fallback-detail',
          'heroImage': 'assets/images/fashion/offline.jpg',
          'accessibilityVariant': 'high-contrast',
          'tags': <String>['offline'],
          'microcopy': const <String, dynamic>{},
          'availability': 'live',
          'wardrobeItemIds': const <String>['offline-wardrobe'],
          'personalization': const <String, dynamic>{
            'primaryIntent': 'offline',
            'supportsReducedMotion': true,
          },
        },
      ];

      final service = CapsuleService(
        bundle: _FailingBundle(),
        fallbackData: fallback,
      );

      final capsules = await service.loadCapsules(forceRefresh: true);

      expect(capsules, hasLength(1));
      expect(capsules.first.id, 'offline-one');
      expect(capsules.first.personalization.primaryIntent, 'offline');
    });

    test('loads capsule by id from cached dataset', () async {
      final fallback = <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 'capsule-a',
          'name': 'Capsule A',
          'mood': 'Bold',
          'type': 'weekly',
          'description': 'Capsule A description.',
          'colorway': <String>['#FFFFFF'],
          'signatureDetail': 'detail-a',
          'heroImage': 'assets/images/fashion/a.jpg',
          'accessibilityVariant': 'high-contrast',
          'tags': const <String>[],
          'microcopy': const <String, dynamic>{},
          'availability': 'live',
        },
        <String, dynamic>{
          'id': 'capsule-b',
          'name': 'Capsule B',
          'mood': 'Sharp',
          'type': 'weekly',
          'description': 'Capsule B description.',
          'colorway': <String>['#000000'],
          'signatureDetail': 'detail-b',
          'heroImage': 'assets/images/fashion/b.jpg',
          'accessibilityVariant': 'high-contrast',
          'tags': const <String>[],
          'microcopy': const <String, dynamic>{},
          'availability': 'archived',
        },
      ];

      final service = CapsuleService(
        bundle: _FailingBundle(),
        fallbackData: fallback,
      );

      final capsule = await service.loadCapsuleById('capsule-b');

      expect(capsule, isNotNull);
      expect(capsule!.availability, CapsuleAvailability.archived);
      expect(capsule.isSelectable, isFalse);
    });
  });
}

class _FailingBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) {
    return Future<ByteData>.error(FlutterError('asset missing'));
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) {
    return Future<String>.error(FlutterError('asset missing'));
  }
}
