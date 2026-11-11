import 'dart:convert';

import 'package:flutter/material.dart';

import '../widgets/ui_kit.dart';

enum _CodecType { base64, url }

enum _CodecDirection { encode, decode }

class TextCodecPage extends StatefulWidget {
  const TextCodecPage({super.key});

  @override
  State<TextCodecPage> createState() => _TextCodecPageState();
}

class _TextCodecPageState extends State<TextCodecPage> {
  final TextEditingController _input = TextEditingController();
  final TextEditingController _output = TextEditingController();
  _CodecType _type = _CodecType.base64;
  _CodecDirection _direction = _CodecDirection.encode;
  String? _error;

  @override
  void dispose() {
    _input.dispose();
    _output.dispose();
    super.dispose();
  }

  void _convert() {
    final source = _input.text;
    if (source.isEmpty) {
      _output.text = '';
      _error = null;
      return;
    }

    try {
      String result;
      if (_type == _CodecType.base64) {
        if (_direction == _CodecDirection.encode) {
          result = base64Encode(utf8.encode(source));
        } else {
          final normalized = source.replaceAll(RegExp(r'\s'), '');
          result = utf8.decode(base64Decode(normalized));
        }
      } else {
        if (_direction == _CodecDirection.encode) {
          result = Uri.encodeComponent(source);
        } else {
          result = Uri.decodeComponent(source.trim());
        }
      }
      _output.text = result;
      _error = null;
    } catch (_) {
      _output.text = '';
      _error = _direction == _CodecDirection.decode
          ? (_type == _CodecType.base64
              ? 'Base64 内容无效，无法解码'
              : 'URL 编码格式无效，无法解码')
          : '转换失败，请检查输入内容';
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ToolPage(
      title: '文本编解码',
      subtitle: 'Base64 与 URL 编码互转',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SegmentedButton<_CodecType>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(
                      value: _CodecType.base64,
                      label: Text('Base64'),
                      icon: Icon(Icons.data_object),
                    ),
                    ButtonSegment(
                      value: _CodecType.url,
                      label: Text('URL'),
                      icon: Icon(Icons.link),
                    ),
                  ],
                  selected: {_type},
                  onSelectionChanged: (selection) {
                    setState(() {
                      _type = selection.first;
                      _convert();
                    });
                  },
                ),
                const SizedBox(height: 10),
                SegmentedButton<_CodecDirection>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(
                      value: _CodecDirection.encode,
                      label: Text('编码'),
                    ),
                    ButtonSegment(
                      value: _CodecDirection.decode,
                      label: Text('解码'),
                    ),
                  ],
                  selected: {_direction},
                  onSelectionChanged: (selection) {
                    setState(() {
                      _direction = selection.first;
                      _convert();
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _input,
                  minLines: 3,
                  maxLines: 6,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    labelText: '输入内容',
                    hintText: _direction == _CodecDirection.encode
                        ? '输入需要编码的文本'
                        : '粘贴需要解码的内容',
                    suffixIcon: _input.text.isEmpty
                        ? null
                        : IconButton(
                            tooltip: '清空',
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              _input.clear();
                              setState(_convert);
                            },
                          ),
                  ),
                  onChanged: (value) => setState(_convert),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_input.text.runes.length} 个字符',
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
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
                    Text('转换结果', style: textTheme.labelLarge),
                    const Spacer(),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      tooltip: '复制结果',
                      onPressed: _output.text.isEmpty
                          ? null
                          : () => copyText(context, _output.text),
                      icon: const Icon(Icons.copy_rounded, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                SelectableText(
                  _output.text.isEmpty ? '结果会显示在这里' : _output.text,
                  style: textTheme.bodyLarge?.copyWith(
                    fontFamily: 'monospace',
                    color: _output.text.isEmpty
                        ? scheme.onSurfaceVariant
                        : scheme.onSurface,
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: textTheme.bodySmall?.copyWith(color: scheme.error),
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
