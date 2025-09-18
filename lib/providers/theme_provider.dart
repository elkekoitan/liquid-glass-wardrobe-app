import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme Provider for managing light/dark mode state
/// Provides persistent theme storage and dynamic theme switching
class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'app_theme_mode';
  static const String _systemThemeKey = 'follow_system_theme';

  ThemeMode _themeMode = ThemeMode.system;
  bool _followSystemTheme = true;
  SharedPreferences? _prefs;

  // Getters
  ThemeMode get themeMode => _themeMode;
  bool get followSystemTheme => _followSystemTheme;
  bool get isDarkMode {
    switch (_themeMode) {
      case ThemeMode.dark:
        return true;
      case ThemeMode.light:
        return false;
      case ThemeMode.system:
        return _isSystemDark();
    }
  }

  bool get isLightMode => !isDarkMode;

  /// Initialize theme provider with stored preferences
  Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      await _loadThemePreferences();
      notifyListeners();
    } catch (e) {
      debugPrint('ThemeProvider: Failed to initialize - $e');
      // Use default theme if initialization fails
    }
  }

  /// Load theme preferences from local storage
  Future<void> _loadThemePreferences() async {
    if (_prefs == null) return;

    try {
      // Load follow system theme preference
      _followSystemTheme = _prefs!.getBool(_systemThemeKey) ?? true;

      // Load theme mode
      final themeModeIndex = _prefs!.getInt(_themeKey);
      if (themeModeIndex != null) {
        _themeMode = ThemeMode.values[themeModeIndex];
      } else {
        _themeMode = ThemeMode.system;
      }

      debugPrint(
        'ThemeProvider: Loaded theme - mode: $_themeMode, followSystem: $_followSystemTheme',
      );
    } catch (e) {
      debugPrint('ThemeProvider: Failed to load preferences - $e');
      // Use defaults if loading fails
      _themeMode = ThemeMode.system;
      _followSystemTheme = true;
    }
  }

  /// Save theme preferences to local storage
  Future<void> _saveThemePreferences() async {
    if (_prefs == null) return;

    try {
      await _prefs!.setInt(_themeKey, _themeMode.index);
      await _prefs!.setBool(_systemThemeKey, _followSystemTheme);
      debugPrint(
        'ThemeProvider: Saved theme - mode: $_themeMode, followSystem: $_followSystemTheme',
      );
    } catch (e) {
      debugPrint('ThemeProvider: Failed to save preferences - $e');
    }
  }

  /// Toggle between light and dark mode
  Future<void> toggleTheme() async {
    if (_followSystemTheme) {
      // If following system, switch to manual control
      _followSystemTheme = false;
      _themeMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    } else {
      // Toggle between light and dark
      switch (_themeMode) {
        case ThemeMode.light:
          _themeMode = ThemeMode.dark;
          break;
        case ThemeMode.dark:
          _themeMode = ThemeMode.light;
          break;
        case ThemeMode.system:
          _themeMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
          break;
      }
    }

    await _saveThemePreferences();
    notifyListeners();
  }

  /// Set specific theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    _followSystemTheme = mode == ThemeMode.system;

    await _saveThemePreferences();
    notifyListeners();
  }

  /// Set to light mode
  Future<void> setLightMode() async {
    await setThemeMode(ThemeMode.light);
  }

  /// Set to dark mode
  Future<void> setDarkMode() async {
    await setThemeMode(ThemeMode.dark);
  }

  /// Set to follow system theme
  Future<void> setSystemMode() async {
    await setThemeMode(ThemeMode.system);
  }

  /// Update follow system theme preference
  Future<void> setFollowSystemTheme(bool follow) async {
    if (_followSystemTheme == follow) return;

    _followSystemTheme = follow;

    if (follow) {
      _themeMode = ThemeMode.system;
    }

    await _saveThemePreferences();
    notifyListeners();
  }

  /// Check if system is in dark mode
  bool _isSystemDark() {
    // In a real app, this would check MediaQuery.of(context).platformBrightness
    // For now, we'll use a simple time-based approach as fallback
    final hour = DateTime.now().hour;
    return hour < 7 || hour >= 19; // Dark between 7 PM and 7 AM
  }

  /// Get theme description for UI display
  String get themeDescription {
    if (_followSystemTheme) {
      return 'System (${isDarkMode ? 'Dark' : 'Light'})';
    }

    switch (_themeMode) {
      case ThemeMode.light:
        return 'Light Mode';
      case ThemeMode.dark:
        return 'Dark Mode';
      case ThemeMode.system:
        return 'System (${isDarkMode ? 'Dark' : 'Light'})';
    }
  }

  /// Get appropriate icon for current theme
  IconData get themeIcon {
    if (isDarkMode) {
      return Icons.dark_mode;
    } else {
      return Icons.light_mode;
    }
  }

  /// Reset to default theme settings
  Future<void> resetToDefault() async {
    _themeMode = ThemeMode.system;
    _followSystemTheme = true;

    await _saveThemePreferences();
    notifyListeners();
  }

  /// Get all available theme options for UI
  List<ThemeOption> get availableThemes => [
    ThemeOption(
      mode: ThemeMode.light,
      title: 'Light Mode',
      subtitle: 'Always use light theme',
      icon: Icons.light_mode,
      isSelected: !_followSystemTheme && _themeMode == ThemeMode.light,
    ),
    ThemeOption(
      mode: ThemeMode.dark,
      title: 'Dark Mode',
      subtitle: 'Always use dark theme',
      icon: Icons.dark_mode,
      isSelected: !_followSystemTheme && _themeMode == ThemeMode.dark,
    ),
    ThemeOption(
      mode: ThemeMode.system,
      title: 'System',
      subtitle: 'Follow system setting',
      icon: Icons.settings_brightness,
      isSelected: _followSystemTheme,
    ),
  ];

  @override
  void dispose() {
    // Clean up if needed
    super.dispose();
  }
}

/// Theme option model for UI display
class ThemeOption {
  final ThemeMode mode;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;

  const ThemeOption({
    required this.mode,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ThemeOption &&
        other.mode == mode &&
        other.title == title &&
        other.subtitle == subtitle &&
        other.icon == icon &&
        other.isSelected == isSelected;
  }

  @override
  int get hashCode {
    return mode.hashCode ^
        title.hashCode ^
        subtitle.hashCode ^
        icon.hashCode ^
        isSelected.hashCode;
  }
}
