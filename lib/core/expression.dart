import 'dart:math' as math;

class ExpressionException implements Exception {
  ExpressionException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// 解析并计算四则表达式，支持括号、幂运算与一元正负号。
double evaluateExpression(String source) {
  final expression = source.trim();
  if (expression.isEmpty) {
    throw ExpressionException('请输入表达式');
  }
  final tokens = _tokenize(expression);
  final values = <double>[];
  final operators = <String>[];

  for (final token in tokens) {
    final number = double.tryParse(token);
    if (number != null) {
      values.add(number);
    } else if (token == '(') {
      operators.add(token);
    } else if (token == ')') {
      while (operators.isNotEmpty && operators.last != '(') {
        _apply(operators.removeLast(), values);
      }
      if (operators.isEmpty) {
        throw ExpressionException('括号不匹配');
      }
      operators.removeLast();
    } else {
      while (operators.isNotEmpty &&
          operators.last != '(' &&
          _shouldPop(operators.last, token)) {
        _apply(operators.removeLast(), values);
      }
      operators.add(token);
    }
  }

  while (operators.isNotEmpty) {
    final operator = operators.removeLast();
    if (operator == '(') {
      throw ExpressionException('括号不匹配');
    }
    _apply(operator, values);
  }

  if (values.length != 1) {
    throw ExpressionException('表达式不完整');
  }
  final result = values.single;
  if (result.isNaN || result.isInfinite) {
    throw ExpressionException('结果无效');
  }
  return result;
}

int _precedence(String operator) {
  switch (operator) {
    case '~':
      return 4;
    case '^':
      return 3;
    case '*':
    case '/':
    case '%':
      return 2;
    case '+':
    case '-':
      return 1;
    default:
      return 0;
  }
}

bool _shouldPop(String top, String current) {
  final topPrecedence = _precedence(top);
  final currentPrecedence = _precedence(current);
  // 幂运算与负号从右向左结合，其余运算符从左向右结合。
  if (current == '^' || current == '~') {
    return topPrecedence > currentPrecedence;
  }
  return topPrecedence >= currentPrecedence;
}

void _apply(String operator, List<double> values) {
  if (operator == '~') {
    if (values.isEmpty) {
      throw ExpressionException('表达式不完整');
    }
    values[values.length - 1] = -values.last;
    return;
  }
  if (values.length < 2) {
    throw ExpressionException('表达式不完整');
  }
  final right = values.removeLast();
  final left = values.removeLast();
  switch (operator) {
    case '+':
      values.add(left + right);
    case '-':
      values.add(left - right);
    case '*':
      values.add(left * right);
    case '/':
      if (right == 0) {
        throw ExpressionException('除数不能为 0');
      }
      values.add(left / right);
    case '%':
      if (right == 0) {
        throw ExpressionException('除数不能为 0');
      }
      values.add(left % right);
    case '^':
      values.add(math.pow(left, right).toDouble());
    default:
      throw ExpressionException('未知运算符 $operator');
  }
}

List<String> _tokenize(String input) {
  final tokens = <String>[];
  var expectOperand = true;
  var index = 0;

  while (index < input.length) {
    final char = input[index];
    if (char == ' ') {
      index++;
      continue;
    }
    if (char == '×' || char == '·') {
      tokens.add('*');
      index++;
      expectOperand = true;
      continue;
    }
    if (char == '÷') {
      tokens.add('/');
      index++;
      expectOperand = true;
      continue;
    }
    if (char == '−') {
      tokens.add('-');
      index++;
      expectOperand = true;
      continue;
    }
    if (_isDigit(char) || char == '.') {
      final start = index;
      var dots = 0;
      while (index < input.length &&
          (_isDigit(input[index]) || input[index] == '.')) {
        if (input[index] == '.') {
          dots++;
        }
        index++;
      }
      final number = input.substring(start, index);
      if (dots > 1 || number == '.') {
        throw ExpressionException('数字格式有误: $number');
      }
      tokens.add(number);
      expectOperand = false;
      continue;
    }
    if ('+-*/^%'.contains(char)) {
      if ((char == '-' || char == '+') && expectOperand) {
        if (char == '-') {
          tokens.add('~');
        }
        index++;
        continue;
      }
      tokens.add(char);
      index++;
      expectOperand = true;
      continue;
    }
    if (char == '(') {
      tokens.add('(');
      index++;
      expectOperand = true;
      continue;
    }
    if (char == ')') {
      tokens.add(')');
      index++;
      expectOperand = false;
      continue;
    }
    throw ExpressionException('无法识别字符 "$char"');
  }

  return tokens;
}

bool _isDigit(String char) => char.codeUnitAt(0) >= 48 && char.codeUnitAt(0) <= 57;
