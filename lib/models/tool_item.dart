import 'package:flutter/material.dart';

import '../core/platform_capabilities.dart';
import '../l10n/l10n.dart';

enum ToolCategory {
  convert,
  text,
  generate,
  other;

  String get label => switch (this) {
    ToolCategory.convert => AppL10n.current.categoryConvert,
    ToolCategory.text => AppL10n.current.categoryText,
    ToolCategory.generate => AppL10n.current.categoryGenerate,
    ToolCategory.other => AppL10n.current.categoryOther,
  };
}

class ToolItem {
  const ToolItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.category,
    required this.builder,
    this.requiresShizuku = false,
  });

  final String Function(AppLocalizations l10n) title;
  final String Function(AppLocalizations l10n) subtitle;
  final IconData icon;
  final ToolCategory category;
  final WidgetBuilder builder;

  /// 是否需要 Shizuku Root 权限，首页卡片会展示对应标记。
  final bool requiresShizuku;

  /// 当前系统是否可以使用该工具，Shizuku 相关能力仅 Android 支持。
  bool get isAvailableOnCurrentPlatform =>
      !requiresShizuku || AppCapabilities.supportsShizuku;
}
