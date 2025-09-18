import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/capsule_model.dart';

class CapsuleService {
  CapsuleService._();

  static final CapsuleService instance = CapsuleService._();

  List<CapsuleModel>? _cache;

  Future<List<CapsuleModel>> loadCapsules({bool forceRefresh = false}) async {
    if (!forceRefresh && _cache != null) {
      return _cache!;
    }

    final rawJson = await rootBundle.loadString('assets/data/capsules.json');
    final list = json.decode(rawJson) as List<dynamic>;
    _cache = list
        .map((item) => CapsuleModel.fromMap(item as Map<String, dynamic>))
        .toList(growable: false);
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
}
