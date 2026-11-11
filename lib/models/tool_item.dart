import 'package:flutter/material.dart';

enum ToolCategory {
  convert('换算'),
  text('文本'),
  time('时间'),
  color('色彩'),
  generate('生成'),
  network('网络');

  const ToolCategory(this.label);

  final String label;
}

class ToolItem {
  const ToolItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.category,
    required this.builder,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final ToolCategory category;
  final WidgetBuilder builder;
}
