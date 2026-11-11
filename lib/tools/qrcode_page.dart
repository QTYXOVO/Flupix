import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

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
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final content = _input.text.trim();
    final tooLong = utf8.encode(content).length > 1800;
    final candidate = scheme.primary;
    final themeForeground =
        ThemeData.estimateBrightnessForColor(candidate) == Brightness.dark
            ? candidate
            : scheme.onPrimary;
    final foreground = _useThemeColor ? themeForeground : const Color(0xFF101010);

    return ToolPage(
      title: '二维码生成',
      subtitle: '输入文本即可生成可扫描的二维码',
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
                labelText: '二维码内容',
                hintText: '支持文本、网址、联系方式等',
                alignLabelWithHint: true,
                suffixIcon: _input.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: '清空',
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
                              ? '输入内容后生成二维码'
                              : '内容过长（${utf8.encode(content).length} 字节），请精简到约 1800 字节以内',
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
                        final qrSize =
                            _size > maxWidth ? maxWidth : _size;
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
                content.isEmpty ? '暂无内容' : '${content.runes.length} 个字符',
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 8),
              if (content.isNotEmpty)
                TextButton.icon(
                  onPressed: () => copyText(context, content, message: '内容已复制'),
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  label: const Text('复制内容'),
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
                    Text('二维码尺寸', style: textTheme.titleSmall),
                    const Spacer(),
                    Text(
                      '${_size.round()} px',
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
                  title: const Text('使用主题色'),
                  subtitle: const Text('开启后二维码模块使用当前主题主色'),
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
