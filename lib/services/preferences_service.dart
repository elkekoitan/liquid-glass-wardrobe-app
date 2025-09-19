import 'package:shared_preferences/shared_preferences.dart';

abstract class PreferencesStore {
  Future<bool?> getBool(String key);
  Future<String?> getString(String key);
  Future<void> setBool(String key, bool value);
  Future<void> setString(String key, String value);
}

class SharedPreferencesStore implements PreferencesStore {
  const SharedPreferencesStore();

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  @override
  Future<bool?> getBool(String key) async {
    final prefs = await _prefs;
    return prefs.getBool(key);
  }

  @override
  Future<String?> getString(String key) async {
    final prefs = await _prefs;
    return prefs.getString(key);
  }

  @override
  Future<void> setBool(String key, bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(key, value);
  }

  @override
  Future<void> setString(String key, String value) async {
    final prefs = await _prefs;
    await prefs.setString(key, value);
  }
}

class InMemoryPreferencesStore implements PreferencesStore {
  InMemoryPreferencesStore([Map<String, Object?>? seed])
    : _data = Map<String, Object?>.from(seed ?? const <String, Object?>{});

  final Map<String, Object?> _data;

  @override
  Future<bool?> getBool(String key) async => _data[key] as bool?;

  @override
  Future<String?> getString(String key) async => _data[key] as String?;

  @override
  Future<void> setBool(String key, bool value) async {
    _data[key] = value;
  }

  @override
  Future<void> setString(String key, String value) async {
    _data[key] = value;
  }
}

class PreferencesService {
  PreferencesService({PreferencesStore? store})
    : _store = store ?? const SharedPreferencesStore();

  PreferencesService._internal() : _store = const SharedPreferencesStore();

  static final PreferencesService instance = PreferencesService._internal();

  final PreferencesStore _store;

  static const _reducedMotionKey = 'prefs_reduced_motion';
  static const _highContrastKey = 'prefs_high_contrast';
  static const _soundEffectsKey = 'prefs_sound_effects';
  static const _hapticsKey = 'prefs_haptics';
  static const _defaultCapsuleKey = 'prefs_default_capsule';

  Future<Map<String, dynamic>> loadPreferences() async {
    return <String, dynamic>{
      'reducedMotion': await _store.getBool(_reducedMotionKey) ?? false,
      'highContrast': await _store.getBool(_highContrastKey) ?? false,
      'soundEffects': await _store.getBool(_soundEffectsKey) ?? true,
      'haptics': await _store.getBool(_hapticsKey) ?? true,
      'defaultCapsule':
          await _store.getString(_defaultCapsuleKey) ?? 'wk-monday-reset',
    };
  }

  Future<void> saveReducedMotion(bool value) =>
      _store.setBool(_reducedMotionKey, value);

  Future<void> saveHighContrast(bool value) =>
      _store.setBool(_highContrastKey, value);

  Future<void> saveSoundEffects(bool value) =>
      _store.setBool(_soundEffectsKey, value);

  Future<void> saveHaptics(bool value) => _store.setBool(_hapticsKey, value);

  Future<void> saveDefaultCapsule(String capsuleId) =>
      _store.setString(_defaultCapsuleKey, capsuleId);
}
