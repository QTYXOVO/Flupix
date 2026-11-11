import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../widgets/ui_kit.dart';

class _Unit {
  const _Unit(
    this.name,
    this.symbol, {
    this.factor = 1,
    this.toBase,
    this.fromBase,
  });

  final String name;
  final String symbol;
  final double factor;
  final double Function(double)? toBase;
  final double Function(double)? fromBase;

  double baseValue(double value) => toBase?.call(value) ?? value * factor;

  double convertedValue(double value) => fromBase?.call(value) ?? value / factor;
}

class _Category {
  const _Category(
    this.name,
    this.icon,
    this.units, {
    required this.defaultFrom,
    required this.defaultTo,
  });

  final String name;
  final IconData icon;
  final List<_Unit> units;
  final int defaultFrom;
  final int defaultTo;
}

final List<_Category> _categories = [
  _Category(
    '长度',
    Icons.straighten,
    const [
      _Unit('千米', 'km', factor: 1000),
      _Unit('米', 'm'),
      _Unit('分米', 'dm', factor: 0.1),
      _Unit('厘米', 'cm', factor: 0.01),
      _Unit('毫米', 'mm', factor: 0.001),
      _Unit('微米', 'μm', factor: 0.000001),
      _Unit('纳米', 'nm', factor: 0.000000001),
      _Unit('英里', 'mi', factor: 1609.344),
      _Unit('码', 'yd', factor: 0.9144),
      _Unit('英尺', 'ft', factor: 0.3048),
      _Unit('英寸', 'in', factor: 0.0254),
      _Unit('海里', 'nmi', factor: 1852),
      _Unit('里', '里', factor: 500),
      _Unit('丈', '丈', factor: 10 / 3),
      _Unit('尺', '尺', factor: 1 / 3),
      _Unit('寸', '寸', factor: 0.1 / 3),
    ],
    defaultFrom: 1,
    defaultTo: 3,
  ),
  _Category(
    '面积',
    Icons.crop_square,
    const [
      _Unit('平方千米', 'km²', factor: 1000000),
      _Unit('公顷', 'ha', factor: 10000),
      _Unit('亩', '亩', factor: 2000 / 3),
      _Unit('平方米', 'm²'),
      _Unit('平方分米', 'dm²', factor: 0.01),
      _Unit('平方厘米', 'cm²', factor: 0.0001),
      _Unit('英亩', 'ac', factor: 4046.8564224),
      _Unit('平方英尺', 'ft²', factor: 0.09290304),
      _Unit('平方英寸', 'in²', factor: 0.00064516),
    ],
    defaultFrom: 3,
    defaultTo: 5,
  ),
  _Category(
    '体积',
    Icons.local_drink,
    const [
      _Unit('立方米', 'm³', factor: 1000),
      _Unit('升', 'L'),
      _Unit('毫升', 'mL', factor: 0.001),
      _Unit('立方厘米', 'cm³', factor: 0.001),
      _Unit('加仑（美）', 'gal', factor: 3.785411784),
      _Unit('夸脱（美）', 'qt', factor: 0.946352946),
      _Unit('立方英尺', 'ft³', factor: 28.316846592),
      _Unit('立方英寸', 'in³', factor: 0.016387064),
    ],
    defaultFrom: 1,
    defaultTo: 2,
  ),
  _Category(
    '质量',
    Icons.scale,
    const [
      _Unit('吨', 't', factor: 1000),
      _Unit('千克', 'kg'),
      _Unit('克', 'g', factor: 0.001),
      _Unit('毫克', 'mg', factor: 0.000001),
      _Unit('斤', '斤', factor: 0.5),
      _Unit('两', '两', factor: 0.05),
      _Unit('磅', 'lb', factor: 0.45359237),
      _Unit('盎司', 'oz', factor: 0.028349523125),
      _Unit('克拉', 'ct', factor: 0.0002),
    ],
    defaultFrom: 1,
    defaultTo: 2,
  ),
  _Category(
    '温度',
    Icons.thermostat,
    const [
      _Unit(
        '摄氏度',
        '°C',
        toBase: _celsiusToKelvin,
        fromBase: _kelvinToCelsius,
      ),
      _Unit(
        '华氏度',
        '°F',
        toBase: _fahrenheitToKelvin,
        fromBase: _kelvinToFahrenheit,
      ),
      _Unit('开尔文', 'K'),
    ],
    defaultFrom: 0,
    defaultTo: 1,
  ),
  _Category(
    '速度',
    Icons.speed,
    const [
      _Unit('米/秒', 'm/s'),
      _Unit('千米/时', 'km/h', factor: 1 / 3.6),
      _Unit('米/分', 'm/min', factor: 1 / 60),
      _Unit('英里/时', 'mph', factor: 0.44704),
      _Unit('节', 'kn', factor: 0.5144444444),
      _Unit('英尺/秒', 'ft/s', factor: 0.3048),
    ],
    defaultFrom: 0,
    defaultTo: 1,
  ),
  _Category(
    '数据存储',
    Icons.storage,
    const [
      _Unit('位', 'bit', factor: 0.125),
      _Unit('字节', 'B'),
      _Unit('千字节', 'KB', factor: 1024),
      _Unit('兆字节', 'MB', factor: 1048576),
      _Unit('吉字节', 'GB', factor: 1073741824),
      _Unit('太字节', 'TB', factor: 1099511627776),
    ],
    defaultFrom: 2,
    defaultTo: 3,
  ),
];

double _celsiusToKelvin(double value) => value + 273.15;

double _kelvinToCelsius(double value) => value - 273.15;

double _fahrenheitToKelvin(double value) => (value + 459.67) * 5 / 9;

double _kelvinToFahrenheit(double value) => value * 9 / 5 - 459.67;

class UnitConverterPage extends StatefulWidget {
  const UnitConverterPage({super.key});

  @override
  State<UnitConverterPage> createState() => _UnitConverterPageState();
}

class _UnitConverterPageState extends State<UnitConverterPage> {
  int _categoryIndex = 0;
  int _fromIndex = 1;
  int _toIndex = 3;
  final TextEditingController _controller = TextEditingController(text: '1');

  _Category get _category => _categories[_categoryIndex];

  _Unit get _fromUnit => _category.units[_fromIndex];

  _Unit get _toUnit => _category.units[_toIndex];

  double? get _inputValue => double.tryParse(_controller.text.trim());

  double? get _result {
    final value = _inputValue;
    if (value == null) return null;
    return _toUnit.convertedValue(_fromUnit.baseValue(value));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _selectCategory(int index) {
    setState(() {
      _categoryIndex = index;
      _fromIndex = _categories[index].defaultFrom;
      _toIndex = _categories[index].defaultTo;
    });
  }

  void _swapUnits() {
    setState(() {
      final previousFrom = _fromIndex;
      _fromIndex = _toIndex;
      _toIndex = previousFrom;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final result = _result;
    final oneUnit = _toUnit.convertedValue(_fromUnit.baseValue(1));

    return ToolPage(
      title: '单位换算',
      subtitle: '选择分类后输入数值，实时换算',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = _categories[index];
                return ChoiceChip(
                  showCheckmark: false,
                  avatar: Icon(category.icon, size: 18),
                  label: Text(category.name),
                  selected: index == _categoryIndex,
                  onSelected: (_) => _selectCategory(index),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '输入',
                  style: textTheme.labelLarge?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        key: ValueKey('from-$_categoryIndex-$_fromIndex'),
                        initialValue: _fromIndex,
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: '单位'),
                        items: [
                          for (var index = 0;
                              index < _category.units.length;
                              index++)
                            DropdownMenuItem(
                              value: index,
                              child: Text(
                                '${_category.units[index].name}'
                                '  ${_category.units[index].symbol}',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() => _fromIndex = value);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        decoration: const InputDecoration(labelText: '数值'),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Center(
                  child: IconButton.filledTonal(
                    tooltip: '交换单位',
                    onPressed: _swapUnits,
                    icon: const Icon(Icons.swap_vert),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  key: ValueKey('to-$_categoryIndex-$_toIndex'),
                  initialValue: _toIndex,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: '换算为'),
                  items: [
                    for (var index = 0; index < _category.units.length; index++)
                      DropdownMenuItem(
                        value: index,
                        child: Text(
                          '${_category.units[index].name}'
                          '  ${_category.units[index].symbol}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _toIndex = value);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            color: scheme.primaryContainer,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '换算结果',
                      style: textTheme.labelLarge?.copyWith(
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      tooltip: '复制结果',
                      color: scheme.onPrimaryContainer,
                      onPressed: result == null
                          ? null
                          : () => copyText(
                              context,
                              '${formatNumber(result)} ${_toUnit.symbol}',
                            ),
                      icon: const Icon(Icons.copy_rounded, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  result == null ? '—' : formatNumber(result),
                  style: textTheme.displaySmall?.copyWith(
                    color: scheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  result == null ? '请输入有效数值' : _toUnit.name,
                  style: textTheme.bodyMedium?.copyWith(
                    color: scheme.onPrimaryContainer.withValues(alpha: 0.85),
                  ),
                ),
                const Divider(height: 28),
                Text(
                  '1 ${_fromUnit.name} = ${formatNumber(oneUnit)} ${_toUnit.name}',
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onPrimaryContainer.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
