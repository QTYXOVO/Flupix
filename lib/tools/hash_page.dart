import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../widgets/ui_kit.dart';

class HashPage extends StatefulWidget {
  const HashPage({super.key});

  @override
  State<HashPage> createState() => _HashPageState();
}

class _HashPageState extends State<HashPage> {
  final TextEditingController _input = TextEditingController();
  final Map<String, String> _digests = {
    'MD5': '',
    'SHA-1': '',
    'SHA-256': '',
    'SHA-512': '',
  };

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _compute() {
    final bytes = utf8.encode(_input.text);
    setState(() {
      _digests['MD5'] = md5.convert(bytes).toString();
      _digests['SHA-1'] = sha1.convert(bytes).toString();
      _digests['SHA-256'] = sha256.convert(bytes).toString();
      _digests['SHA-512'] = sha512.convert(bytes).toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hasInput = _input.text.isNotEmpty;

    return ToolPage(
      title: l10n.hashTitle,
      subtitle: l10n.hashSubtitle,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _input,
                  minLines: 3,
                  maxLines: 8,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    labelText: l10n.hashInputLabel,
                    hintText: l10n.hashInputHint,
                    alignLabelWithHint: true,
                    suffixIcon: _input.text.isEmpty
                        ? null
                        : IconButton(
                            tooltip: l10n.commonClear,
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              _input.clear();
                              _compute();
                            },
                          ),
                  ),
                  onChanged: (_) => _compute(),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.hashByteCount(utf8.encode(_input.text).length),
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (!hasInput)
            SectionCard(
              color: scheme.surfaceContainerHigh,
              child: Text(
                l10n.hashEmptyHint,
                style: textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            )
          else
            for (final entry in _digests.entries) ...[
              SectionCard(
                child: CopyableValue(label: entry.key, value: entry.value),
              ),
              const SizedBox(height: 12),
            ],
        ],
      ),
    );
  }
}
