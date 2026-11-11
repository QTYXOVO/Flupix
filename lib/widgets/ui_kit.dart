import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Material You 风格的圆角卡片容器。
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: child,
    );
  }
}

class TonalIcon extends StatelessWidget {
  const TonalIcon({
    super.key,
    required this.icon,
    this.size = 44,
    this.background,
    this.foreground,
  });

  final IconData icon;
  final double size;
  final Color? background;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background ?? scheme.primaryContainer,
        borderRadius: BorderRadius.circular(size * 0.32),
      ),
      child: Icon(
        icon,
        size: size * 0.5,
        color: foreground ?? scheme.onPrimaryContainer,
      ),
    );
  }
}

/// 带复制按钮的只读数值行。
class CopyableValue extends StatelessWidget {
  const CopyableValue({
    super.key,
    required this.label,
    required this.value,
    this.monospace = true,
  });

  final String label;
  final String value;
  final bool monospace;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 3),
              SelectableText(
                value,
                style: textTheme.bodyMedium?.copyWith(
                  fontFamily: monospace ? 'monospace' : null,
                  letterSpacing: monospace ? 0.3 : null,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          visualDensity: VisualDensity.compact,
          tooltip: '复制',
          icon: Icon(Icons.copy_rounded, size: 18, color: scheme.onSurfaceVariant),
          onPressed: () => copyText(context, value),
        ),
      ],
    );
  }
}

Future<void> copyText(
  BuildContext context,
  String text, {
  String message = '已复制到剪贴板',
}) async {
  await Clipboard.setData(ClipboardData(text: text));
  if (!context.mounted) return;
  final messenger = ScaffoldMessenger.of(context);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
}

/// 所有工具页统一的脚手架。
class ToolPage extends StatelessWidget {
  const ToolPage({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    this.actions,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: textTheme.titleLarge),
            if (subtitle != null)
              Text(
                subtitle!,
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
        actions: actions,
      ),
      body: SafeArea(
        top: false,
        child: child,
      ),
    );
  }
}
