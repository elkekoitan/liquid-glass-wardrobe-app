import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/capsule_model.dart';

class CapsuleService {
  CapsuleService({
    AssetBundle? bundle,
    List<Map<String, dynamic>>? fallbackData,
  }) : _bundle = bundle ?? rootBundle,
       _fallbackData = fallbackData ?? _offlineCapsuleSeed;

  CapsuleService._internal()
    : _bundle = rootBundle,
      _fallbackData = _offlineCapsuleSeed;

  static final CapsuleService instance = CapsuleService._internal();

  final AssetBundle _bundle;
  final List<Map<String, dynamic>> _fallbackData;
  List<CapsuleModel>? _cache;

  Future<List<CapsuleModel>> loadCapsules({bool forceRefresh = false}) async {
    if (!forceRefresh && _cache != null) {
      return _cache!;
    }

    List<dynamic> rawList;

    try {
      final rawJson = await _bundle.loadString('assets/data/capsules.json');
      rawList = json.decode(rawJson) as List<dynamic>;
    } on FlutterError {
      rawList = _fallbackData;
    } on FormatException {
      rawList = _fallbackData;
    }

    final capsules = rawList
        .map((dynamic item) {
          final map = item is Map<String, dynamic>
              ? item
              : Map<String, dynamic>.from(item as Map);
          return CapsuleModel.fromMap(map);
        })
        .toList(growable: false);

    if (capsules.isEmpty && _fallbackData.isNotEmpty) {
      _cache = _fallbackData
          .map((Map<String, dynamic> map) => CapsuleModel.fromMap(map))
          .toList(growable: false);
    } else {
      _cache = capsules;
    }

    return _cache!;
  }

  Future<CapsuleModel?> loadCapsuleById(String id) async {
    final capsules = await loadCapsules();
    for (final capsule in capsules) {
      if (capsule.id == id) {
        return capsule;
      }
    }
    return capsules.isNotEmpty ? capsules.first : null;
  }

  void clearCache() {
    _cache = null;
  }
}

const List<Map<String, dynamic>> _offlineCapsuleSeed = <Map<String, dynamic>>[
  <String, dynamic>{
    'id': 'capsule-dawn-bright',
    'name': 'Dawn Bright Capsule',
    'mood': 'Optimistic',
    'type': 'weekly',
    'startDate': '2025-01-08',
    'endDate': '2025-01-08',
    'description':
        'Sunrise-inspired silhouettes layered with breathable mesh and misted chiffon.',
    'colorway': <String>['#FFEBCD', '#FF6F91', '#FFD93D'],
    'signatureDetail': 'sun-strata',
    'heroImage': 'assets/images/fashion/capsule_dawn.jpg',
    'accessibilityVariant': 'high-contrast',
    'tags': <String>['sunrise', 'lightweight', 'warmth'],
    'microcopy': <String, dynamic>{
      'prompt': 'Dawn Bright cues your routine for an optimistic reset.',
      'success': 'Verified. Step into the new light.',
      'error': 'Digits blurred - retry to sync with sunrise.',
    },
    'availability': 'live',
    'wardrobeItemIds': <String>['coat-classic-trench', 'dress-daylight-slip'],
    'personalization': <String, dynamic>{
      'primaryIntent': 'weekday_reset',
      'supportsReducedMotion': true,
      'supportsHighContrast': true,
      'recommendedWardrobeIds': <String>['coat-classic-trench'],
    },
  },
  <String, dynamic>{
    'id': 'capsule-midnight-current',
    'name': 'Midnight Current Capsule',
    'mood': 'Dynamic',
    'type': 'special',
    'description':
        'Electric indigo suits with reactive piping and modular layers.',
    'colorway': <String>['#0E0B1F', '#233DFF', '#7A00E6'],
    'signatureDetail': 'current-flare',
    'heroImage': 'assets/images/fashion/capsule_midnight.jpg',
    'accessibilityVariant': 'reduced-motion',
    'tags': <String>['neon', 'evening', 'statement'],
    'microcopy': <String, dynamic>{
      'prompt': 'Midnight Current streams energy through every layer.',
      'success': 'Verified. Glide with the current.',
      'error': 'Signal lost - rescan the digits.',
    },
    'availability': 'scheduled',
    'wardrobeItemIds': <String>['jacket-lumina-bomber', 'pants-circuit-flare'],
    'personalization': <String, dynamic>{
      'primaryIntent': 'evening_showcase',
      'supportsReducedMotion': false,
      'supportsHighContrast': true,
      'recommendedWardrobeIds': <String>['jacket-lumina-bomber'],
    },
  },
  <String, dynamic>{
    'id': 'capsule-ember-harvest',
    'name': 'Ember Harvest Capsule',
    'mood': 'Grounded',
    'type': 'seasonal',
    'description':
        'Earth-toned knits blended with copper threading and tactile quilting.',
    'colorway': <String>['#3A1F0B', '#8C5A36', '#F0A868'],
    'signatureDetail': 'ember-weave',
    'heroImage': 'assets/images/fashion/capsule_ember.jpg',
    'accessibilityVariant': 'high-contrast',
    'tags': <String>['seasonal', 'cozy', 'textured'],
    'microcopy': <String, dynamic>{
      'prompt': 'Ember Harvest roots into grounded rituals.',
      'success': 'Verified. Slow into the warmth.',
      'error': 'Digits cooled - rekindle and retry.',
    },
    'availability': 'archived',
    'wardrobeItemIds': <String>['coat-hearth-parka', 'scarf-grove-wool'],
    'personalization': <String, dynamic>{
      'primaryIntent': 'weekend_roam',
      'supportsReducedMotion': true,
      'supportsHighContrast': false,
      'recommendedWardrobeIds': <String>[
        'coat-hearth-parka',
        'scarf-grove-wool',
      ],
    },
  },
];

