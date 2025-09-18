import 'package:flutter/foundation.dart';

import '../services/preferences_service.dart';

class PersonalizationProvider extends ChangeNotifier {
  PersonalizationProvider({PreferencesService? service})
    : _service = service ?? PreferencesService.instance;

  final PreferencesService _service;

  bool _isLoading = false;
  bool _hasLoaded = false;
  bool _reducedMotion = false;
  bool _highContrast = false;
  bool _soundEffects = true;
  bool _haptics = true;
  String _defaultCapsule = 'wk-monday-reset';

  bool get isLoading => _isLoading;
  bool get hasLoaded => _hasLoaded;
  bool get reducedMotion => _reducedMotion;
  bool get highContrast => _highContrast;
  bool get soundEffects => _soundEffects;
  bool get haptics => _haptics;
  String get defaultCapsule => _defaultCapsule;

  Future<void> load() async {
    if (_isLoading || _hasLoaded) return;
    _isLoading = true;
    notifyListeners();

    final prefs = await _service.loadPreferences();
    _reducedMotion = prefs['reducedMotion'] as bool? ?? false;
    _highContrast = prefs['highContrast'] as bool? ?? false;
    _soundEffects = prefs['soundEffects'] as bool? ?? true;
    _haptics = prefs['haptics'] as bool? ?? true;
    _defaultCapsule = prefs['defaultCapsule'] as String? ?? 'wk-monday-reset';

    _hasLoaded = true;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleReducedMotion(bool value) async {
    _reducedMotion = value;
    notifyListeners();
    await _service.saveReducedMotion(value);
  }

  Future<void> toggleHighContrast(bool value) async {
    _highContrast = value;
    notifyListeners();
    await _service.saveHighContrast(value);
  }

  Future<void> toggleSoundEffects(bool value) async {
    _soundEffects = value;
    notifyListeners();
    await _service.saveSoundEffects(value);
  }

  Future<void> toggleHaptics(bool value) async {
    _haptics = value;
    notifyListeners();
    await _service.saveHaptics(value);
  }

  Future<void> updateDefaultCapsule(String capsuleId) async {
    _defaultCapsule = capsuleId;
    notifyListeners();
    await _service.saveDefaultCapsule(capsuleId);
  }
}
