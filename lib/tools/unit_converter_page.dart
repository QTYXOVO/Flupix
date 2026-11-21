import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../l10n/l10n.dart';
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

  double convertedValue(double value) =>
      fromBase?.call(value) ?? value / factor;
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
    AppL10n.current.unitCategoryLength,
    Icons.straighten,
    [
      _Unit(AppL10n.current.unitKilometer, 'km', factor: 1000),
      _Unit(AppL10n.current.unitMeter, 'm'),
      _Unit(AppL10n.current.unitDecimeter, 'dm', factor: 0.1),
      _Unit(AppL10n.current.unitCentimeter, 'cm', factor: 0.01),
      _Unit(AppL10n.current.unitMillimeter, 'mm', factor: 0.001),
      _Unit(AppL10n.current.unitMicrometer, 'μm', factor: 0.000001),
      _Unit(AppL10n.current.unitNanometer, 'nm', factor: 0.000000001),
      _Unit(AppL10n.current.unitMile, 'mi', factor: 1609.344),
      _Unit(AppL10n.current.unitYard, 'yd', factor: 0.9144),
      _Unit(AppL10n.current.unitFoot, 'ft', factor: 0.3048),
      _Unit(AppL10n.current.unitInch, 'in', factor: 0.0254),
      _Unit(AppL10n.current.unitNauticalMile, 'nmi', factor: 1852),
      _Unit(AppL10n.current.unitLi, '里', factor: 500),
      _Unit(AppL10n.current.unitZhang, '丈', factor: 10 / 3),
      _Unit(AppL10n.current.unitChi, '尺', factor: 1 / 3),
      _Unit(AppL10n.current.unitCun, '寸', factor: 0.1 / 3),
    ],
    defaultFrom: 1,
    defaultTo: 3,
  ),
  _Category(
    AppL10n.current.unitCategoryArea,
    Icons.crop_square,
    [
      _Unit(AppL10n.current.unitSquareKilometer, 'km²', factor: 1000000),
      _Unit(AppL10n.current.unitHectare, 'ha', factor: 10000),
      _Unit(AppL10n.current.unitMu, '亩', factor: 2000 / 3),
      _Unit(AppL10n.current.unitSquareMeter, 'm²'),
      _Unit(AppL10n.current.unitSquareDecimeter, 'dm²', factor: 0.01),
      _Unit(AppL10n.current.unitSquareCentimeter, 'cm²', factor: 0.0001),
      _Unit(AppL10n.current.unitAcre, 'ac', factor: 4046.8564224),
      _Unit(AppL10n.current.unitSquareFoot, 'ft²', factor: 0.09290304),
      _Unit(AppL10n.current.unitSquareInch, 'in²', factor: 0.00064516),
    ],
    defaultFrom: 3,
    defaultTo: 5,
  ),
  _Category(
    AppL10n.current.unitCategoryVolume,
    Icons.local_drink,
    [
      _Unit(AppL10n.current.unitCubicMeter, 'm³', factor: 1000),
      _Unit(AppL10n.current.unitLiter, 'L'),
      _Unit(AppL10n.current.unitMilliliter, 'mL', factor: 0.001),
      _Unit(AppL10n.current.unitCubicCentimeter, 'cm³', factor: 0.001),
      _Unit(AppL10n.current.unitGallonUs, 'gal', factor: 3.785411784),
      _Unit(AppL10n.current.unitQuartUs, 'qt', factor: 0.946352946),
      _Unit(AppL10n.current.unitCubicFoot, 'ft³', factor: 28.316846592),
      _Unit(AppL10n.current.unitCubicInch, 'in³', factor: 0.016387064),
    ],
    defaultFrom: 1,
    defaultTo: 2,
  ),
  _Category(
    AppL10n.current.unitCategoryMass,
    Icons.scale,
    [
      _Unit(AppL10n.current.unitTonne, 't', factor: 1000),
      _Unit(AppL10n.current.unitKilogram, 'kg'),
      _Unit(AppL10n.current.unitGram, 'g', factor: 0.001),
      _Unit(AppL10n.current.unitMilligram, 'mg', factor: 0.000001),
      _Unit(AppL10n.current.unitJin, '斤', factor: 0.5),
      _Unit(AppL10n.current.unitLiang, '两', factor: 0.05),
      _Unit(AppL10n.current.unitPound, 'lb', factor: 0.45359237),
      _Unit(AppL10n.current.unitOunce, 'oz', factor: 0.028349523125),
      _Unit(AppL10n.current.unitCarat, 'ct', factor: 0.0002),
    ],
    defaultFrom: 1,
    defaultTo: 2,
  ),
  _Category(
    AppL10n.current.unitCategoryTemperature,
    Icons.thermostat,
    [
      _Unit(
        AppL10n.current.unitCelsius,
        '°C',
        toBase: _celsiusToKelvin,
        fromBase: _kelvinToCelsius,
      ),
      _Unit(
        AppL10n.current.unitFahrenheit,
        '°F',
        toBase: _fahrenheitToKelvin,
        fromBase: _kelvinToFahrenheit,
      ),
      _Unit(AppL10n.current.unitKelvin, 'K'),
    ],
    defaultFrom: 0,
    defaultTo: 1,
  ),
  _Category(
    AppL10n.current.unitCategorySpeed,
    Icons.speed,
    [
      _Unit(AppL10n.current.unitMeterPerSecond, 'm/s'),
      _Unit(AppL10n.current.unitKilometerPerHour, 'km/h', factor: 1 / 3.6),
      _Unit(AppL10n.current.unitMeterPerMinute, 'm/min', factor: 1 / 60),
      _Unit(AppL10n.current.unitMilePerHour, 'mph', factor: 0.44704),
      _Unit(AppL10n.current.unitKnot, 'kn', factor: 0.5144444444),
      _Unit(AppL10n.current.unitFootPerSecond, 'ft/s', factor: 0.3048),
    ],
    defaultFrom: 0,
    defaultTo: 1,
  ),
  _Category(
    AppL10n.current.unitCategoryDataStorage,
    Icons.storage,
    [
      _Unit(AppL10n.current.unitBit, 'bit', factor: 0.125),
      _Unit(AppL10n.current.unitByte, 'B'),
      _Unit(AppL10n.current.unitKilobyte, 'KB', factor: 1024),
      _Unit(AppL10n.current.unitMegabyte, 'MB', factor: 1048576),
      _Unit(AppL10n.current.unitGigabyte, 'GB', factor: 1073741824),
      _Unit(AppL10n.current.unitTerabyte, 'TB', factor: 1099511627776),
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
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final result = _result;
    final oneUnit = _toUnit.convertedValue(_fromUnit.baseValue(1));

    return ToolPage(
      title: l10n.unitPageTitle,
      subtitle: l10n.unitPageSubtitle,
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
                  l10n.unitInputLabel,
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
                        decoration: InputDecoration(
                          labelText: l10n.unitFromLabel,
                        ),
                        items: [
                          for (
                            var index = 0;
                            index < _category.units.length;
                            index++
                          )
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
                        decoration: InputDecoration(
                          labelText: l10n.unitValueLabel,
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Center(
                  child: IconButton.filledTonal(
                    tooltip: l10n.unitSwapTooltip,
                    onPressed: _swapUnits,
                    icon: const Icon(Icons.swap_vert),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  key: ValueKey('to-$_categoryIndex-$_toIndex'),
                  initialValue: _toIndex,
                  isExpanded: true,
                  decoration: InputDecoration(labelText: l10n.unitToLabel),
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
                      l10n.unitResultTitle,
                      style: textTheme.labelLarge?.copyWith(
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      tooltip: l10n.unitCopyResultTooltip,
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
                  result == null ? l10n.unitEnterValidValue : _toUnit.name,
                  style: textTheme.bodyMedium?.copyWith(
                    color: scheme.onPrimaryContainer.withValues(alpha: 0.85),
                  ),
                ),
                const Divider(height: 28),
                Text(
                  l10n.unitConversionFormula(
                    _fromUnit.name,
                    formatNumber(oneUnit),
                    _toUnit.name,
                  ),
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
