import 'package:flutter/material.dart';

import '../core/expression.dart';
import '../core/formatters.dart';
import '../widgets/ui_kit.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalcRecord {
  const _CalcRecord(this.expression, this.result);

  final String expression;
  final String result;
}

class _CalculatorPageState extends State<CalculatorPage> {
  final TextEditingController _controller = TextEditingController();
  final List<_CalcRecord> _history = [];
  String _preview = '0';
  String? _error;
  bool _justEvaluated = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _refreshPreview() {
    final text = _controller.text;
    if (text.trim().isEmpty) {
      _preview = '0';
      _error = null;
      return;
    }
    try {
      _preview = formatNumber(evaluateExpression(text));
      _error = null;
    } on ExpressionException {
      // 输入过程中的中间状态不提示错误，按下等号时再显示。
    }
  }

  void _setExpression(String text, {int? cursor}) {
    final offset = cursor ?? text.length;
    _controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: offset),
    );
    setState(_refreshPreview);
  }

  void _handleKey(String key) {
    final text = _controller.text;
    if (key == 'C') {
      setState(() {
        _justEvaluated = false;
        _error = null;
        _preview = '0';
      });
      _controller.clear();
      return;
    }
    if (key == '⌫') {
      if (_justEvaluated) {
        _setExpression('');
      } else {
        final selection = _controller.selection;
        final start = selection.isValid ? selection.start : text.length;
        final end = selection.isValid ? selection.end : text.length;
        if (start == end && start > 0) {
          _setExpression(
            text.replaceRange(start - 1, start, ''),
            cursor: start - 1,
          );
        } else {
          _setExpression(
            text.replaceRange(start, end, ''),
            cursor: start,
          );
        }
      }
      return;
    }

    const operators = ['+', '−', '×', '÷', '^', '%'];
    final isOperator = operators.contains(key);

    if (_justEvaluated) {
      _justEvaluated = false;
      if (isOperator) {
        _setExpression('$_preview$key');
        return;
      }
      _setExpression('');
    }

    final selection = _controller.selection;
    final start = selection.isValid ? selection.start : text.length;
    final end = selection.isValid ? selection.end : text.length;
    _setExpression(
      text.replaceRange(start, end, key),
      cursor: start + key.length,
    );
  }

  void _calculate() {
    final text = _controller.text;
    if (text.trim().isEmpty) {
      setState(() => _error = '请输入表达式');
      return;
    }
    try {
      final value = evaluateExpression(text);
      final result = formatNumber(value);
      setState(() {
        _preview = result;
        _error = null;
        _justEvaluated = true;
        _history.insert(0, _CalcRecord(text, result));
        if (_history.length > 6) {
          _history.removeLast();
        }
      });
    } on ExpressionException catch (error) {
      setState(() => _error = error.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final numberColor = scheme.surfaceContainerHigh;
    final functionColor = scheme.secondaryContainer;
    final operatorColor = scheme.tertiaryContainer;

    Widget key({
      required String label,
      required Color background,
      required Color foreground,
      required VoidCallback onPressed,
      int flex = 1,
      double fontSize = 20,
    }) {
      return Expanded(
        flex: flex,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Material(
            color: background,
            borderRadius: BorderRadius.circular(18),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onPressed,
              child: SizedBox(
                height: 58,
                child: Center(
                  child: Text(
                    label,
                    style: textTheme.titleLarge?.copyWith(
                      color: foreground,
                      fontSize: fontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    Widget row(List<Widget> children) => Row(children: children);

    return ToolPage(
      title: '表达式计算',
      subtitle: '支持括号、幂与四则混合运算',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextField(
                  controller: _controller,
                  textAlign: TextAlign.end,
                  style: textTheme.headlineSmall,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    hintText: '输入表达式，如 (3+5)×2^3',
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _justEvaluated = false;
                      _refreshPreview();
                    });
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  _error ?? '= $_preview',
                  style: (_error != null
                          ? textTheme.titleMedium?.copyWith(color: scheme.error)
                          : textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            )) ??
                      const TextStyle(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 540),
              child: Column(
                children: [
                  row([
                    key(
                      label: 'C',
                      background: functionColor,
                      foreground: scheme.onSecondaryContainer,
                      onPressed: () => _handleKey('C'),
                    ),
                    key(
                      label: '(',
                      background: functionColor,
                      foreground: scheme.onSecondaryContainer,
                      onPressed: () => _handleKey('('),
                    ),
                    key(
                      label: ')',
                      background: functionColor,
                      foreground: scheme.onSecondaryContainer,
                      onPressed: () => _handleKey(')'),
                    ),
                    key(
                      label: '⌫',
                      background: functionColor,
                      foreground: scheme.onSecondaryContainer,
                      onPressed: () => _handleKey('⌫'),
                    ),
                  ]),
                  row([
                    key(
                      label: '7',
                      background: numberColor,
                      foreground: scheme.onSurface,
                      onPressed: () => _handleKey('7'),
                    ),
                    key(
                      label: '8',
                      background: numberColor,
                      foreground: scheme.onSurface,
                      onPressed: () => _handleKey('8'),
                    ),
                    key(
                      label: '9',
                      background: numberColor,
                      foreground: scheme.onSurface,
                      onPressed: () => _handleKey('9'),
                    ),
                    key(
                      label: '÷',
                      background: operatorColor,
                      foreground: scheme.onTertiaryContainer,
                      onPressed: () => _handleKey('÷'),
                    ),
                  ]),
                  row([
                    key(
                      label: '4',
                      background: numberColor,
                      foreground: scheme.onSurface,
                      onPressed: () => _handleKey('4'),
                    ),
                    key(
                      label: '5',
                      background: numberColor,
                      foreground: scheme.onSurface,
                      onPressed: () => _handleKey('5'),
                    ),
                    key(
                      label: '6',
                      background: numberColor,
                      foreground: scheme.onSurface,
                      onPressed: () => _handleKey('6'),
                    ),
                    key(
                      label: '×',
                      background: operatorColor,
                      foreground: scheme.onTertiaryContainer,
                      onPressed: () => _handleKey('×'),
                    ),
                  ]),
                  row([
                    key(
                      label: '1',
                      background: numberColor,
                      foreground: scheme.onSurface,
                      onPressed: () => _handleKey('1'),
                    ),
                    key(
                      label: '2',
                      background: numberColor,
                      foreground: scheme.onSurface,
                      onPressed: () => _handleKey('2'),
                    ),
                    key(
                      label: '3',
                      background: numberColor,
                      foreground: scheme.onSurface,
                      onPressed: () => _handleKey('3'),
                    ),
                    key(
                      label: '−',
                      background: operatorColor,
                      foreground: scheme.onTertiaryContainer,
                      onPressed: () => _handleKey('−'),
                    ),
                  ]),
                  row([
                    key(
                      label: '0',
                      background: numberColor,
                      foreground: scheme.onSurface,
                      onPressed: () => _handleKey('0'),
                    ),
                    key(
                      label: '.',
                      background: numberColor,
                      foreground: scheme.onSurface,
                      onPressed: () => _handleKey('.'),
                    ),
                    key(
                      label: '%',
                      background: operatorColor,
                      foreground: scheme.onTertiaryContainer,
                      onPressed: () => _handleKey('%'),
                    ),
                    key(
                      label: '+',
                      background: operatorColor,
                      foreground: scheme.onTertiaryContainer,
                      onPressed: () => _handleKey('+'),
                    ),
                  ]),
                  row([
                    key(
                      label: '^',
                      background: functionColor,
                      foreground: scheme.onSecondaryContainer,
                      onPressed: () => _handleKey('^'),
                    ),
                    key(
                      label: '=',
                      background: scheme.primary,
                      foreground: scheme.onPrimary,
                      onPressed: _calculate,
                      flex: 3,
                      fontSize: 24,
                    ),
                  ]),
                ],
              ),
            ),
          ),
          if (_history.isNotEmpty) ...[
            const SizedBox(height: 16),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '历史记录',
                        style: textTheme.titleSmall,
                      ),
                      const Spacer(),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        tooltip: '清空历史',
                        onPressed: () => setState(_history.clear),
                        icon: const Icon(Icons.delete_outline, size: 20),
                      ),
                    ],
                  ),
                  for (final record in _history)
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _setExpression(record.expression),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                record.expression,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '= ${record.result}',
                              style: textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
