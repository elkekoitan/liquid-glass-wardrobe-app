import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  PreferencesService._();

  static final PreferencesService instance = PreferencesService._();

  static const _reducedMotionKey = 'prefs_reduced_motion';
  static const _highContrastKey = 'prefs_high_contrast';
  static const _soundEffectsKey = 'prefs_sound_effects';
  static const _hapticsKey = 'prefs_haptics';
  static const _defaultCapsuleKey = 'prefs_default_capsule';

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  Future<Map<String, dynamic>> loadPreferences() async {
    final prefs = await _prefs;
    return {
      'reducedMotion': prefs.getBool(_reducedMotionKey) ?? false,
      'highContrast': prefs.getBool(_highContrastKey) ?? false,
      'soundEffects': prefs.getBool(_soundEffectsKey) ?? true,
      'haptics': prefs.getBool(_hapticsKey) ?? true,
      'defaultCapsule':
          prefs.getString(_defaultCapsuleKey) ?? 'wk-monday-reset',
    };
  }

  Future<void> saveReducedMotion(bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(_reducedMotionKey, value);
  }

  Future<void> saveHighContrast(bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(_highContrastKey, value);
  }

  Future<void> saveSoundEffects(bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(_soundEffectsKey, value);
  }

  Future<void> saveHaptics(bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(_hapticsKey, value);
  }

  Future<void> saveDefaultCapsule(String capsuleId) async {
    final prefs = await _prefs;
    await prefs.setString(_defaultCapsuleKey, capsuleId);
  }
}
