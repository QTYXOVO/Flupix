import 'package:flutter/material.dart';

import '../core/app_settings.dart';
import '../core/app_theme.dart';
import '../widgets/ui_kit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, required this.settings});

  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        final scheme = Theme.of(context).colorScheme;
        final textTheme = Theme.of(context).textTheme;
        return ToolPage(
          title: '设置',
          subtitle: '外观与主题',
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('外观模式', style: textTheme.titleSmall),
                    const SizedBox(height: 12),
                    SegmentedButton<ThemeMode>(
                      showSelectedIcon: false,
                      segments: const [
                        ButtonSegment(
                          value: ThemeMode.system,
                          icon: Icon(Icons.brightness_auto),
                          label: Text('系统'),
                        ),
                        ButtonSegment(
                          value: ThemeMode.light,
                          icon: Icon(Icons.light_mode),
                          label: Text('浅色'),
                        ),
                        ButtonSegment(
                          value: ThemeMode.dark,
                          icon: Icon(Icons.dark_mode),
                          label: Text('深色'),
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
                    Text('主题色', style: textTheme.titleSmall),
                    const SizedBox(height: 4),
                    Text(
                      'Material You 会由主题色生成整套色调',
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
                          _SeedSwatch(
                            preset: preset,
                            selected: settings.seedColor.toARGB32() ==
                                preset.color.toARGB32(),
                            onTap: () => settings.setSeedColor(preset.color),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SectionCard(
                child: Row(
                  children: [
                    TonalIcon(
                      icon: Icons.widgets,
                      size: 52,
                      background: scheme.primaryContainer,
                      foreground: scheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Flupix',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '版本 1.0.0 · Flutter + Material You',
                            style: textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '所有工具均在本地运行，不收集任何数据。',
                            style: textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SeedSwatch extends StatelessWidget {
  const _SeedSwatch({
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
