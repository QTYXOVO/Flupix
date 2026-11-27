import 'package:flutter/material.dart';

import '../core/app_settings.dart';
import '../core/platform_capabilities.dart';
import '../l10n/l10n.dart';
import '../widgets/ui_kit.dart';
import 'settings/about_update_card.dart';
import 'settings/appearance_section.dart';
import 'settings/feature_visibility_section.dart';
import 'settings/proxy_card.dart';
import 'settings/shizuku_card.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.settings});

  final AppSettings settings;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.settings,
      builder: (context, _) {
        final l10n = context.l10n;
        return ToolPage(
          title: l10n.settingsTitle,
          subtitle: AppCapabilities.isAndroid
              ? l10n.settingsSubtitleAndroid
              : l10n.settingsSubtitleDesktop,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              AppearanceSection(settings: widget.settings),
              const SizedBox(height: 16),
              FeatureVisibilitySection(settings: widget.settings),
              if (AppCapabilities.isWindows) ...[
                const SizedBox(height: 16),
                const ProxyCard(),
              ],
              if (AppCapabilities.isAndroid) ...[
                const SizedBox(height: 16),
                const ShizukuCard(),
              ],
              const SizedBox(height: 16),
              const AboutUpdateCard(),
            ],
          ),
        );
      },
    );
  }
}
