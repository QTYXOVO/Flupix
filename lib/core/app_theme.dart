import 'package:flutter/material.dart';

class SeedPreset {
  const SeedPreset(this.label, this.color);

  final String label;
  final Color color;
}

const List<SeedPreset> kSeedPresets = [
  SeedPreset('松绿', Color(0xFF00796B)),
  SeedPreset('靛蓝', Color(0xFF3949AB)),
  SeedPreset('紫罗兰', Color(0xFF6750A4)),
  SeedPreset('天青', Color(0xFF00639B)),
  SeedPreset('苔绿', Color(0xFF4C662B)),
  SeedPreset('琥珀', Color(0xFF8A5100)),
  SeedPreset('玫红', Color(0xFF9C4146)),
  SeedPreset('石墨', Color(0xFF4F5B62)),
];

ThemeData buildLightTheme(Color seed) => _buildTheme(seed, Brightness.light);

ThemeData buildDarkTheme(Color seed) => _buildTheme(seed, Brightness.dark);

ThemeData _buildTheme(Color seed, Brightness brightness) {
  final scheme = ColorScheme.fromSeed(seedColor: seed, brightness: brightness);
  final base = ThemeData(colorScheme: scheme, brightness: brightness);

  OutlineInputBorder border(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: color, width: width),
      );

  return base.copyWith(
    scaffoldBackgroundColor: scheme.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.55),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      border: border(Colors.transparent),
      enabledBorder: border(Colors.transparent),
      focusedBorder: border(scheme.primary, 1.6),
      errorBorder: border(scheme.error),
      focusedErrorBorder: border(scheme.error, 1.6),
      hintStyle: TextStyle(color: scheme.onSurfaceVariant.withValues(alpha: 0.8)),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: scheme.inverseSurface,
      contentTextStyle: TextStyle(color: scheme.onInverseSurface, fontSize: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    dividerTheme: DividerThemeData(
      color: scheme.outlineVariant.withValues(alpha: 0.6),
      thickness: 1,
      space: 1,
    ),
    textTheme: base.textTheme.apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    ),
    splashFactory: InkRipple.splashFactory,
  );
}
