import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_theme.dart';

class AppSettings extends ChangeNotifier {
  AppSettings._(this._preferences, this._themeMode, this._seedColor);

  static const String _themeModeKey = 'theme_mode';
  static const String _seedColorKey = 'seed_color';

  final SharedPreferences _preferences;
  ThemeMode _themeMode;
  Color _seedColor;

  ThemeMode get themeMode => _themeMode;

  Color get seedColor => _seedColor;

  static Future<AppSettings> load() async {
    final preferences = await SharedPreferences.getInstance();
    final storedMode = preferences.getString(_themeModeKey);
    final themeMode = ThemeMode.values.firstWhere(
      (mode) => mode.name == storedMode,
      orElse: () => ThemeMode.system,
    );
    final storedSeed = preferences.getInt(_seedColorKey);
    final seedColor = storedSeed == null
        ? kSeedPresets.first.color
        : Color(storedSeed);
    return AppSettings._(preferences, themeMode, seedColor);
  }

  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    _preferences.setString(_themeModeKey, mode.name);
  }

  void setSeedColor(Color color) {
    if (_seedColor.toARGB32() == color.toARGB32()) return;
    _seedColor = color;
    notifyListeners();
    _preferences.setInt(_seedColorKey, color.toARGB32());
  }
}
