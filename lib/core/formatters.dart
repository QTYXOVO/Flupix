String twoDigits(int value) => value.toString().padLeft(2, '0');

String formatDateTime(DateTime time, {bool withSeconds = true}) {
  final base =
      '${time.year}-${twoDigits(time.month)}-${twoDigits(time.day)} '
      '${twoDigits(time.hour)}:${twoDigits(time.minute)}';
  return withSeconds ? '$base:${twoDigits(time.second)}' : base;
}

const List<String> _weekdayNames = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];

String weekdayLabel(DateTime time) => _weekdayNames[time.weekday - 1];

/// 将数字格式化为便于阅读的字符串，去掉多余的尾随零。
String formatNumber(double value, {int precision = 12}) {
  if (value.isNaN || value.isInfinite) return '—';
  if (value == 0) return '0';
  final magnitude = value.abs();
  if (magnitude >= 1e15 || magnitude < 1e-9) {
    return value.toStringAsExponential(6);
  }
  var text = value.toStringAsPrecision(precision);
  if (text.contains('e')) return text;
  if (text.contains('.')) {
    text = text.replaceFirst(RegExp(r'0+$'), '');
    text = text.replaceFirst(RegExp(r'\.$'), '');
  }
  return text;
}

/// 格式化为两位小写十六进制，用于颜色输出。
String hexPair(int value) => value.toRadixString(16).padLeft(2, '0').toUpperCase();
