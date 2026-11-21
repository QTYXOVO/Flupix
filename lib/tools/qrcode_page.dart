import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../l10n/l10n.dart';
import '../widgets/ui_kit.dart';

class QrCodePage extends StatefulWidget {
  const QrCodePage({super.key});

  @override
  State<QrCodePage> createState() => _QrCodePageState();
}

class _QrCodePageState extends State<QrCodePage> {
  final TextEditingController _input = TextEditingController(
    text: 'https://flutter.dev',
  );
  double _size = 240;
  bool _useThemeColor = false;

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final content = _input.text.trim();
    final tooLong = utf8.encode(content).length > 1800;
    final candidate = scheme.primary;
    final themeForeground =
        ThemeData.estimateBrightnessForColor(candidate) == Brightness.dark
        ? candidate
        : scheme.onPrimary;
    final foreground = _useThemeColor
        ? themeForeground
        : const Color(0xFF101010);

    return ToolPage(
      title: l10n.toolQrTitle,
      subtitle: l10n.qrSubtitle,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          SectionCard(
            child: TextField(
              controller: _input,
              minLines: 2,
              maxLines: 5,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                labelText: l10n.qrContentLabel,
                hintText: l10n.qrContentHint,
                alignLabelWithHint: true,
                suffixIcon: _input.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: l10n.commonClear,
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _input.clear();
                          setState(() {});
                        },
                      ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
            ),
            child: content.isEmpty || tooLong
                ? SizedBox(
                    height: 240,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          content.isEmpty
                              ? Icons.qr_code_2
                              : Icons.error_outline,
                          size: 64,
                          color: Colors.black.withValues(alpha: 0.25),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          content.isEmpty
                              ? l10n.qrEmptyTip
                              : l10n.qrTooLong(utf8.encode(content).length),
                          textAlign: TextAlign.center,
                          style: textTheme.bodyMedium?.copyWith(
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  )
                : Center(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final maxWidth = constraints.maxWidth - 8;
                        final qrSize = _size > maxWidth ? maxWidth : _size;
                        return QrImageView(
                          data: content,
                          version: QrVersions.auto,
                          size: qrSize,
                          backgroundColor: Colors.white,
                          eyeStyle: QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: foreground,
                          ),
                          dataModuleStyle: QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.square,
                            color: foreground,
                          ),
                        );
                      },
                    ),
                  ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                content.isEmpty
                    ? l10n.commonEmpty
                    : l10n.qrCharCount(content.runes.length),
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 8),
              if (content.isNotEmpty)
                TextButton.icon(
                  onPressed: () =>
                      copyText(context, content, message: l10n.qrCopiedContent),
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  label: Text(l10n.qrCopyContent),
                ),
            ],
          ),
          const SizedBox(height: 8),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(l10n.qrSize, style: textTheme.titleSmall),
                    const Spacer(),
                    Text(
                      l10n.qrSizePx(_size.round()),
                      style: textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _size,
                  min: 160,
                  max: 360,
                  divisions: 10,
                  label: '${_size.round()}',
                  onChanged: (value) => setState(() => _size = value),
                ),
                const Divider(height: 20),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.qrUseThemeColor),
                  subtitle: Text(l10n.qrUseThemeColorHint),
                  value: _useThemeColor,
                  onChanged: (value) => setState(() => _useThemeColor = value),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
