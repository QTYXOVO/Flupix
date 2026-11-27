import 'package:flutter/material.dart';

import '../core/app_settings.dart';
import '../core/shizuku.dart';
import '../data/tool_registry.dart';
import '../l10n/l10n.dart';
import '../models/tool_item.dart';
import '../navigation/app_routes.dart';
import '../widgets/ui_kit.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.settings});

  final AppSettings settings;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ToolCategory? _filter;

  @override
  void initState() {
    super.initState();
    widget.settings.addListener(_handleSettingsChanged);
  }

  @override
  void didUpdateWidget(HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.settings != widget.settings) {
      oldWidget.settings.removeListener(_handleSettingsChanged);
      widget.settings.addListener(_handleSettingsChanged);
    }
  }

  @override
  void dispose() {
    widget.settings.removeListener(_handleSettingsChanged);
    super.dispose();
  }

  void _handleSettingsChanged() {
    if (mounted) setState(() {});
  }

  int _columnsFor(double width) {
    if (width >= 1320) return 5;
    if (width >= 1000) return 4;
    if (width >= 700) return 3;
    return 2;
  }

  void _pushTool(ToolItem tool) {
    Navigator.of(context).push(AppRoutes.tool(tool.builder));
  }

  Future<void> _openTool(ToolItem tool) async {
    if (!tool.requiresShizuku) {
      _pushTool(tool);
      return;
    }
    ShizukuStatus status;
    try {
      status = await ShizukuService().status();
    } catch (_) {
      if (!mounted) return;
      await _promptShizuku(context.l10n.homeShizukuCannotRead);
      return;
    }
    if (!mounted) return;
    if (status.ready) {
      _pushTool(tool);
      return;
    }
    await _promptShizuku(_shizukuHint(status));
  }

  String _shizukuHint(ShizukuStatus status) {
    final l10n = context.l10n;
    if (!status.shizukuInstalled) {
      return l10n.homeShizukuNotInstalled;
    }
    if (!status.shizukuRunning) {
      return l10n.homeShizukuNotRunning;
    }
    if (!status.permissionGranted) {
      return l10n.homeShizukuNotGranted;
    }
    if (!status.isRoot) {
      return l10n.homeShizukuNotRoot;
    }
    return l10n.homeShizukuGoSettingsHint;
  }

  Future<void> _promptShizuku(String message) async {
    final goSettings = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.homeShizukuPermissionTitle),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(context.l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(context.l10n.homeShizukuGoSettings),
          ),
        ],
      ),
    );
    if (goSettings != true || !mounted) return;
    await Navigator.of(context).push(AppRoutes.settings(widget.settings));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final showDisabled = widget.settings.showDisabledTools;
    final pool = allTools
        .where((tool) => showDisabled || tool.isAvailableOnCurrentPlatform)
        .toList();
    final categories = ToolCategory.values
        .where((category) => pool.any((tool) => tool.category == category))
        .toList();
    final filter = categories.contains(_filter) ? _filter : null;
    final tools = filter == null
        ? pool
        : pool.where((tool) => tool.category == filter).toList();

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final columns = _columnsFor(constraints.maxWidth);
          return CustomScrollView(
            slivers: [
              SliverAppBar.large(
                title: const Text('Flupix'),
                actions: [
                  IconButton(
                    tooltip: l10n.commonSettings,
                    icon: const Icon(Icons.settings_outlined),
                    onPressed: () {
                      Navigator.of(context)
                          .push(AppRoutes.settings(widget.settings));
                    },
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.homeSubtitle,
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.homeToolCount(tools.length),
                        style: textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 44,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      _FilterChip(
                        label: l10n.homeFilterAll,
                        selected: filter == null,
                        onSelected: () => setState(() => _filter = null),
                      ),
                      for (final category in categories)
                        _FilterChip(
                          label: category.label,
                          selected: filter == category,
                          onSelected: () => setState(() => _filter = category),
                        ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    mainAxisExtent: 152,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final tool = tools[index];
                    return _ToolCard(
                      tool: tool,
                      onTap: tool.isAvailableOnCurrentPlatform
                          ? () => _openTool(tool)
                          : null,
                    );
                  }, childCount: tools.length),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        showCheckmark: false,
        onSelected: (_) => onSelected(),
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  const _ToolCard({required this.tool, required this.onTap});

  final ToolItem tool;

  /// 为 null 表示当前系统不可用，卡片置灰且不可点击。
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final enabled = onTap != null;
    return Material(
      color: scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Opacity(
              opacity: enabled ? 1 : 0.45,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TonalIcon(
                      icon: tool.icon,
                      background: categoryContainer(tool.category, scheme),
                      foreground: categoryOnContainer(tool.category, scheme),
                    ),
                    const Spacer(),
                    Text(
                      tool.title(context.l10n),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tool.subtitle(context.l10n),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (!enabled)
              const Positioned(top: 12, right: 12, child: _DisabledBadge())
            else if (tool.requiresShizuku)
              const Positioned(top: 12, right: 12, child: _ShizukuBadge()),
          ],
        ),
      ),
    );
  }
}

class _DisabledBadge extends StatelessWidget {
  const _DisabledBadge();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        context.l10n.homeDisabledBadge,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: scheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ShizukuBadge extends StatelessWidget {
  const _ShizukuBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFFF9800),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        'Shizuku',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Colors.black.withValues(alpha: 0.87),
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
