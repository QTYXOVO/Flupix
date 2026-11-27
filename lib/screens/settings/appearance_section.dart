import 'package:flutter/material.dart';

import '../../core/app_settings.dart';
import '../../core/app_theme.dart';
import '../../l10n/l10n.dart';
import '../../widgets/ui_kit.dart';

class AppearanceSection extends StatelessWidget {
  const AppearanceSection({super.key, required this.settings});

  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.settingsAppearanceMode, style: textTheme.titleSmall),
              const SizedBox(height: 12),
              SegmentedButton<ThemeMode>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(
                    value: ThemeMode.system,
                    icon: const Icon(Icons.brightness_auto),
                    label: Text(l10n.settingsThemeSystem),
                  ),
                  ButtonSegment(
                    value: ThemeMode.light,
                    icon: const Icon(Icons.light_mode),
                    label: Text(l10n.settingsThemeLight),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    icon: const Icon(Icons.dark_mode),
                    label: Text(l10n.settingsThemeDark),
                  ),
                ],
                selected: {settings.themeMode},
                onSelectionChanged: (selection) =>
                    settings.setThemeMode(selection.first),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.settingsLanguage, style: textTheme.titleSmall),
              const SizedBox(height: 12),
              SegmentedButton<String>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(
                    value: 'system',
                    icon: const Icon(Icons.language),
                    label: Text(l10n.settingsLanguageSystem),
                  ),
                  ButtonSegment(
                    value: 'zh',
                    label: Text(l10n.settingsLanguageChinese),
                  ),
                  ButtonSegment(
                    value: 'en',
                    label: Text(l10n.settingsLanguageEnglish),
                  ),
                ],
                selected: {settings.locale?.languageCode ?? 'system'},
                onSelectionChanged: (selection) {
                  final code = selection.first;
                  settings.setLocale(code == 'system' ? null : Locale(code));
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.settingsSeedColor, style: textTheme.titleSmall),
              const SizedBox(height: 4),
              Text(
                l10n.settingsSeedColorHint,
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  for (final preset in kSeedPresets)
                    SeedSwatch(
                      preset: preset,
                      selected:
                          settings.seedColor.toARGB32() ==
                          preset.color.toARGB32(),
                      onTap: () => settings.setSeedColor(preset.color),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class SeedSwatch extends StatelessWidget {
  const SeedSwatch({
    super.key,
    required this.preset,
    required this.selected,
    required this.onTap,
  });

  final SeedPreset preset;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final onSwatch =
        ThemeData.estimateBrightnessForColor(preset.color) == Brightness.dark
        ? Colors.white
        : Colors.black;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: preset.color,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected ? scheme.onSurface : Colors.transparent,
                width: 2.5,
              ),
            ),
            child: selected
                ? Icon(Icons.check, color: onSwatch, size: 24)
                : null,
          ),
          const SizedBox(height: 6),
          Text(
            preset.label,
            style: textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
