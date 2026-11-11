import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../widgets/ui_kit.dart';

class _Hsl {
  const _Hsl(this.hue, this.saturation, this.lightness);

  final double hue;
  final double saturation;
  final double lightness;
}

class ColorPage extends StatefulWidget {
  const ColorPage({super.key});

  @override
  State<ColorPage> createState() => _ColorPageState();
}

class _ColorPageState extends State<ColorPage> {
  Color _color = const Color(0xFF00796B);
  final TextEditingController _hexInput =
      TextEditingController(text: '#00796B');
  String? _error;

  @override
  void dispose() {
    _hexInput.dispose();
    super.dispose();
  }

  int get _red => (_color.r * 255).round();

  int get _green => (_color.g * 255).round();

  int get _blue => (_color.b * 255).round();

  String get _hexValue =>
      '#${hexPair(_red)}${hexPair(_green)}${hexPair(_blue)}';

  String get _rgbValue => 'rgb($_red, $_green, $_blue)';

  String get _hslValue {
    final hsl = _toHsl(_color);
    return 'hsl(${hsl.hue.round()}, '
        '${(hsl.saturation * 100).round()}%, '
        '${(hsl.lightness * 100).round()}%)';
  }

  void _updateColor(Color color, {bool syncHexInput = true}) {
    setState(() {
      _color = color;
      _error = null;
      if (syncHexInput) {
        _hexInput.text = _hexValue;
      }
    });
  }

  void _onHexChanged(String raw) {
    final parsed = _parseHex(raw);
    if (parsed == null) {
      setState(() => _error = '请输入有效的 HEX 颜色，如 #3A7BD5');
      return;
    }
    setState(() {
      _color = parsed;
      _error = null;
    });
  }

  Color? _parseHex(String raw) {
    var value = raw.trim().replaceAll('#', '');
    if (value.isEmpty) return null;
    if (value.length == 3) {
      value = value.split('').map((char) => '$char$char').join();
    }
    if (value.length == 6) {
      value = 'FF$value';
    }
    if (value.length != 8) return null;
    final parsed = int.tryParse(value, radix: 16);
    return parsed == null ? null : Color(parsed);
  }

  _Hsl _toHsl(Color color) {
    final red = color.r;
    final green = color.g;
    final blue = color.b;
    final maxValue = math.max(red, math.max(green, blue));
    final minValue = math.min(red, math.min(green, blue));
    final lightness = (maxValue + minValue) / 2;
    if (maxValue == minValue) {
      return _Hsl(0, 0, lightness);
    }
    final delta = maxValue - minValue;
    final saturation = lightness > 0.5
        ? delta / (2 - maxValue - minValue)
        : delta / (maxValue + minValue);
    double hue;
    if (maxValue == red) {
      hue = ((green - blue) / delta + (green < blue ? 6 : 0)) / 6;
    } else if (maxValue == green) {
      hue = ((blue - red) / delta + 2) / 6;
    } else {
      hue = ((red - green) / delta + 4) / 6;
    }
    return _Hsl(hue * 360, saturation, lightness);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final previewScheme = ColorScheme.fromSeed(
      seedColor: _color,
      brightness: Theme.of(context).brightness,
    );
    final onColor = ThemeData.estimateBrightnessForColor(_color) ==
            Brightness.dark
        ? Colors.white
        : Colors.black;

    final previewSwatches = <({String label, Color color})>[
      (label: '主色', color: previewScheme.primary),
      (label: '次色', color: previewScheme.secondary),
      (label: '第三色', color: previewScheme.tertiary),
      (label: '容器色', color: previewScheme.primaryContainer),
      (label: '表面', color: previewScheme.surface),
      (label: '强调表面', color: previewScheme.surfaceContainerHigh),
    ];

    return ToolPage(
      title: '颜色工具',
      subtitle: 'HEX / RGB / HSL 互转与 Material You 配色',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Container(
            height: 140,
            decoration: BoxDecoration(
              color: _color,
              borderRadius: BorderRadius.circular(28),
            ),
            alignment: Alignment.center,
            child: Text(
              _hexValue,
              style: textTheme.headlineSmall?.copyWith(
                color: onColor,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _hexInput,
                  decoration: InputDecoration(
                    labelText: 'HEX 颜色',
                    hintText: '#RRGGBB',
                    errorText: _error,
                    suffixIcon: IconButton(
                      tooltip: '复制',
                      icon: const Icon(Icons.copy_rounded, size: 20),
                      onPressed: () => copyText(context, _hexValue),
                    ),
                  ),
                  onChanged: _onHexChanged,
                ),
                const SizedBox(height: 16),
                CopyableValue(label: 'RGB', value: _rgbValue, monospace: false),
                CopyableValue(label: 'HSL', value: _hslValue, monospace: false),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('调整通道', style: textTheme.titleSmall),
                const SizedBox(height: 8),
                _ChannelSlider(
                  label: 'R',
                  value: _red,
                  color: const Color(0xFFE53935),
                  onChanged: (value) => _updateColor(
                    Color.fromARGB(255, value, _green, _blue),
                  ),
                ),
                _ChannelSlider(
                  label: 'G',
                  value: _green,
                  color: const Color(0xFF43A047),
                  onChanged: (value) => _updateColor(
                    Color.fromARGB(255, _red, value, _blue),
                  ),
                ),
                _ChannelSlider(
                  label: 'B',
                  value: _blue,
                  color: const Color(0xFF1E88E5),
                  onChanged: (value) => _updateColor(
                    Color.fromARGB(255, _red, _green, value),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('配色预览', style: textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(
                  '基于当前颜色生成的 Material You 色调',
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 14,
                  runSpacing: 14,
                  children: [
                    for (final swatch in previewSwatches)
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: swatch.color,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: scheme.outlineVariant
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(swatch.label, style: textTheme.labelSmall),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChannelSlider extends StatelessWidget {
  const _ChannelSlider({
    required this.label,
    required this.value,
    required this.color,
    required this.onChanged,
  });

  final String label;
  final int value;
  final Color color;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        SizedBox(
          width: 24,
          child: Text(
            label,
            style: textTheme.labelLarge?.copyWith(color: color),
          ),
        ),
        Expanded(
          child: Slider(
            value: value.toDouble(),
            min: 0,
            max: 255,
            divisions: 255,
            activeColor: color,
            onChanged: (newValue) => onChanged(newValue.round()),
          ),
        ),
        SizedBox(
          width: 36,
          child: Text('$value', textAlign: TextAlign.end, style: textTheme.bodyMedium),
        ),
      ],
    );
  }
}
