import 'package:flutter/material.dart';

import '../../core/app_settings.dart';
import '../../l10n/l10n.dart';
import '../../widgets/ui_kit.dart';

class FeatureVisibilitySection extends StatelessWidget {
  const FeatureVisibilitySection({super.key, required this.settings});

  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return SectionCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        value: settings.showDisabledTools,
        onChanged: settings.setShowDisabledTools,
        title: Text(l10n.settingsShowDisabled, style: textTheme.titleSmall),
        subtitle: Text(
          l10n.settingsShowDisabledHint,
          style: textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}
