import 'dart:convert';

import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
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
                ? context.l10n.textCodecInvalidBase64
                : context.l10n.textCodecInvalidUrl)
          : context.l10n.textCodecConvertFailed;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ToolPage(
      title: l10n.textCodecTitle,
      subtitle: l10n.textCodecSubtitle,
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
                  segments: [
                    ButtonSegment(
                      value: _CodecDirection.encode,
                      label: Text(l10n.textCodecEncode),
                    ),
                    ButtonSegment(
                      value: _CodecDirection.decode,
                      label: Text(l10n.textCodecDecode),
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
                    labelText: l10n.textCodecInputLabel,
                    hintText: _direction == _CodecDirection.encode
                        ? l10n.textCodecInputEncodeHint
                        : l10n.textCodecInputDecodeHint,
                    suffixIcon: _input.text.isEmpty
                        ? null
                        : IconButton(
                            tooltip: l10n.commonClear,
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
                  l10n.textCodecCharCount(_input.text.runes.length),
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
                    Text(
                      l10n.textCodecResultTitle,
                      style: textTheme.labelLarge,
                    ),
                    const Spacer(),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      tooltip: l10n.textCodecCopyResult,
                      onPressed: _output.text.isEmpty
                          ? null
                          : () => copyText(context, _output.text),
                      icon: const Icon(Icons.copy_rounded, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                SelectableText(
                  _output.text.isEmpty
                      ? l10n.textCodecResultPlaceholder
                      : _output.text,
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
