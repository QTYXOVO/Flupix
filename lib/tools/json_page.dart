import 'dart:convert';

import 'package:flutter/material.dart';

import '../widgets/ui_kit.dart';

class JsonPage extends StatefulWidget {
  const JsonPage({super.key});

  @override
  State<JsonPage> createState() => _JsonPageState();
}

class _JsonPageState extends State<JsonPage> {
  final TextEditingController _input = TextEditingController();
  String _output = '';
  String? _error;
  String? _meta;

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _transform({required bool pretty}) {
    final source = _input.text.trim();
    if (source.isEmpty) {
      setState(() {
        _output = '';
        _error = '请输入 JSON 内容';
        _meta = null;
      });
      return;
    }
    try {
      final decoded = jsonDecode(source);
      final result = pretty
          ? const JsonEncoder.withIndent('  ').convert(decoded)
          : jsonEncode(decoded);
      setState(() {
        _output = result;
        _error = null;
        _meta = 'JSON 有效 · ${result.length} 个字符';
      });
    } on FormatException catch (error) {
      setState(() {
        _output = '';
        _error = '解析失败：${error.message}';
        _meta = null;
      });
    }
  }

  void _clear() {
    _input.clear();
    setState(() {
      _output = '';
      _error = null;
      _meta = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ToolPage(
      title: 'JSON 格式化',
      subtitle: '校验、格式化与压缩 JSON 文本',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _input,
                  minLines: 5,
                  maxLines: 10,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                    labelText: 'JSON 内容',
                    hintText: '粘贴 JSON 文本，例如 {"name": "Flupix"}',
                    alignLabelWithHint: true,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: () => _transform(pretty: true),
                      icon: const Icon(Icons.format_align_left),
                      label: const Text('格式化'),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: () => _transform(pretty: false),
                      icon: const Icon(Icons.compress),
                      label: const Text('压缩'),
                    ),
                    TextButton.icon(
                      onPressed: _clear,
                      icon: const Icon(Icons.close),
                      label: const Text('清空'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            color: scheme.surfaceContainerHigh,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('输出结果', style: textTheme.labelLarge),
                    const Spacer(),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      tooltip: '复制结果',
                      onPressed: _output.isEmpty
                          ? null
                          : () => copyText(context, _output),
                      icon: const Icon(Icons.copy_rounded, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (_error != null)
                  Text(
                    _error!,
                    style: textTheme.bodyMedium?.copyWith(color: scheme.error),
                  )
                else if (_output.isEmpty)
                  Text(
                    '格式化后的 JSON 会显示在这里',
                    style: textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  )
                else
                  SelectableText(
                    _output,
                    style: textTheme.bodyMedium?.copyWith(
                      fontFamily: 'monospace',
                      height: 1.5,
                    ),
                  ),
                if (_meta != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _meta!,
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
