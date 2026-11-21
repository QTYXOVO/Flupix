import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/formatters.dart' show formatNumber;
import '../l10n/l10n.dart';
import '../widgets/ui_kit.dart';

class PasswordPage extends StatefulWidget {
  const PasswordPage({super.key});

  @override
  State<PasswordPage> createState() => _PasswordPageState();
}

class _PasswordPageState extends State<PasswordPage> {
  static const String _lower = 'abcdefghijklmnopqrstuvwxyz';
  static const String _upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const String _digits = '0123456789';
  static const String _symbols = r'!@#$%^&*()-_=+[]{}<>?/~`';
  static const String _ambiguous = 'O0oIl1|';

  int _length = 16;
  bool _useUpper = true;
  bool _useLower = true;
  bool _useDigits = true;
  bool _useSymbols = true;
  bool _excludeAmbiguous = true;
  String _password = '';
  String? _error;

  @override
  void initState() {
    super.initState();
    _generate();
  }

  String _pool(String characters) {
    if (!_excludeAmbiguous) return characters;
    return characters
        .split('')
        .where((char) => !_ambiguous.contains(char))
        .join();
  }

  void _generate() {
    final pools = <String>[];
    if (_useLower) pools.add(_pool(_lower));
    if (_useUpper) pools.add(_pool(_upper));
    if (_useDigits) pools.add(_pool(_digits));
    if (_useSymbols) pools.add(_pool(_symbols));

    final poolsInUse = pools.where((pool) => pool.isNotEmpty).toList();
    if (poolsInUse.isEmpty) {
      setState(() {
        _password = '';
        _error = AppL10n.current.passwordSelectAtLeastOne;
      });
      return;
    }

    final random = math.Random.secure();
    final combined = poolsInUse.join();
    final characters = <String>[];
    for (final pool in poolsInUse) {
      if (characters.length >= _length) break;
      characters.add(pool[random.nextInt(pool.length)]);
    }
    while (characters.length < _length) {
      characters.add(combined[random.nextInt(combined.length)]);
    }
    characters.shuffle(random);

    setState(() {
      _password = characters.join();
      _error = null;
    });
  }

  double get _entropyBits {
    final pools = <String>[
      if (_useLower) _pool(_lower),
      if (_useUpper) _pool(_upper),
      if (_useDigits) _pool(_digits),
      if (_useSymbols) _pool(_symbols),
    ].where((pool) => pool.isNotEmpty).toList();
    if (pools.isEmpty) return 0;
    final size = pools.join().length;
    return _length * (math.log(size) / math.ln2);
  }

  String get _strengthLabel {
    final l10n = context.l10n;
    final bits = _entropyBits;
    if (bits < 40) return l10n.passwordStrengthWeak;
    if (bits < 60) return l10n.passwordStrengthFair;
    if (bits < 80) return l10n.passwordStrengthStrong;
    return l10n.passwordStrengthVeryStrong;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final strengthColor = switch (_entropyBits) {
      < 40 => scheme.errorContainer,
      < 60 => scheme.tertiaryContainer,
      _ => scheme.primaryContainer,
    };
    final onStrengthColor = switch (_entropyBits) {
      < 40 => scheme.onErrorContainer,
      < 60 => scheme.onTertiaryContainer,
      _ => scheme.onPrimaryContainer,
    };

    return ToolPage(
      title: l10n.toolPasswordTitle,
      subtitle: l10n.passwordSubtitle,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          SectionCard(
            color: scheme.surfaceContainerHigh,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(l10n.passwordResult, style: textTheme.labelLarge),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: strengthColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _strengthLabel,
                        style: textTheme.labelMedium?.copyWith(
                          color: onStrengthColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SelectableText(
                  _password.isEmpty ? l10n.passwordEmptyHint : _password,
                  style: textTheme.headlineSmall?.copyWith(
                    fontFamily: 'monospace',
                    letterSpacing: 1.2,
                    color: _password.isEmpty
                        ? scheme.onSurfaceVariant
                        : scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _error ??
                      l10n.passwordEntropy(
                        formatNumber(_entropyBits, precision: 4),
                      ),
                  style: textTheme.bodySmall?.copyWith(
                    color: _error != null
                        ? scheme.error
                        : scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: _generate,
                      icon: const Icon(Icons.refresh),
                      label: Text(l10n.passwordRegenerate),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      tooltip: l10n.passwordCopyTooltip,
                      onPressed: _password.isEmpty
                          ? null
                          : () => copyText(context, _password),
                      icon: const Icon(Icons.copy_rounded),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(l10n.passwordLength, style: textTheme.titleSmall),
                    const Spacer(),
                    Text(
                      '$_length',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _length.toDouble(),
                  min: 6,
                  max: 64,
                  divisions: 58,
                  label: '$_length',
                  onChanged: (value) {
                    setState(() => _length = value.round());
                    _generate();
                  },
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilterChip(
                      label: Text(l10n.passwordUppercase),
                      selected: _useUpper,
                      onSelected: (value) {
                        setState(() => _useUpper = value);
                        _generate();
                      },
                    ),
                    FilterChip(
                      label: Text(l10n.passwordLowercase),
                      selected: _useLower,
                      onSelected: (value) {
                        setState(() => _useLower = value);
                        _generate();
                      },
                    ),
                    FilterChip(
                      label: Text(l10n.passwordDigits),
                      selected: _useDigits,
                      onSelected: (value) {
                        setState(() => _useDigits = value);
                        _generate();
                      },
                    ),
                    FilterChip(
                      label: Text(l10n.passwordSymbols),
                      selected: _useSymbols,
                      onSelected: (value) {
                        setState(() => _useSymbols = value);
                        _generate();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.passwordExcludeAmbiguous),
                  subtitle: Text(l10n.passwordExcludeAmbiguousHint),
                  value: _excludeAmbiguous,
                  onChanged: (value) {
                    setState(() => _excludeAmbiguous = value);
                    _generate();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
