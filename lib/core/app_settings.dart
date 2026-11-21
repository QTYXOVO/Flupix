import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_theme.dart';

class AppSettings extends ChangeNotifier {
  AppSettings._(
    this._preferences,
    this._themeMode,
    this._seedColor,
    this._showDisabledTools,
    this._locale,
  );

  static const String _themeModeKey = 'theme_mode';
  static const String _seedColorKey = 'seed_color';
  static const String _showDisabledToolsKey = 'show_disabled_tools';
  static const String _languageKey = 'app_language';

  final SharedPreferences _preferences;
  ThemeMode _themeMode;
  Color _seedColor;
  bool _showDisabledTools;
  Locale? _locale;

  ThemeMode get themeMode => _themeMode;

  Color get seedColor => _seedColor;

  /// 用户指定的语言；为 null 时跟随系统。
  Locale? get locale => _locale;

  /// 是否在首页显示当前系统不可用的功能（置灰且不可点击）。
  bool get showDisabledTools => _showDisabledTools;

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
    final showDisabledTools =
        preferences.getBool(_showDisabledToolsKey) ?? false;
    final storedLanguage = preferences.getString(_languageKey);
    final locale = storedLanguage == null || storedLanguage == 'system'
        ? null
        : Locale(storedLanguage);
    return AppSettings._(
      preferences,
      themeMode,
      seedColor,
      showDisabledTools,
      locale,
    );
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

  void setShowDisabledTools(bool value) {
    if (_showDisabledTools == value) return;
    _showDisabledTools = value;
    notifyListeners();
    _preferences.setBool(_showDisabledToolsKey, value);
  }

  void setLocale(Locale? locale) {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
    _preferences.setString(_languageKey, locale?.languageCode ?? 'system');
  }
}

/// 向所有路由暴露 [AppSettings]，便于工具页跳转到设置页。
class SettingsScope extends InheritedWidget {
  const SettingsScope({
    super.key,
    required this.settings,
    required super.child,
  });

  final AppSettings settings;

  static AppSettings of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<SettingsScope>();
    assert(scope != null, 'SettingsScope not found in context');
    return scope!.settings;
  }

  @override
  bool updateShouldNotify(SettingsScope oldWidget) =>
      settings != oldWidget.settings;
}
