import 'dart:convert';

import 'package:flutter/services.dart';

import '../domain/trend_pulse_models.dart';

class TrendPulseService {
  TrendPulseService._();

  static final TrendPulseService instance = TrendPulseService._();

  TrendPulseBundle? _cache;

  Future<TrendPulseBundle> loadPulse({bool forceRefresh = false}) async {
    if (!forceRefresh && _cache != null) {
      return _cache!;
    }

    final rawJson = await rootBundle.loadString(
      'assets/data/trend_pulses.json',
    );
    final decoded = json.decode(rawJson) as Map<String, dynamic>;
    _cache = TrendPulseBundle.fromMap(decoded);
    return _cache!;
  }
}
