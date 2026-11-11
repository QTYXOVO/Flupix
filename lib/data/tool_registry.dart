import 'package:flutter/material.dart';

import '../models/tool_item.dart';
import '../tools/calculator_page.dart';
import '../tools/color_page.dart';
import '../tools/hash_page.dart';
import '../tools/json_page.dart';
import '../tools/markdown_page.dart';
import '../tools/password_page.dart';
import '../tools/pixiv_token_page.dart';
import '../tools/qrcode_page.dart';
import '../tools/text_codec_page.dart';
import '../tools/timestamp_page.dart';
import '../tools/unit_converter_page.dart';

final List<ToolItem> allTools = [
  ToolItem(
    title: '单位换算',
    subtitle: '长度、面积、体积、质量、温度、速度、数据存储',
    icon: Icons.straighten,
    category: ToolCategory.convert,
    builder: (_) => const UnitConverterPage(),
  ),
  ToolItem(
    title: '表达式计算',
    subtitle: '支持括号、幂运算与四则混合计算',
    icon: Icons.calculate,
    category: ToolCategory.convert,
    builder: (_) => const CalculatorPage(),
  ),
  ToolItem(
    title: '文本编解码',
    subtitle: 'Base64 与 URL 编码、解码',
    icon: Icons.code,
    category: ToolCategory.text,
    builder: (_) => const TextCodecPage(),
  ),
  ToolItem(
    title: 'JSON 格式化',
    subtitle: '校验、格式化与压缩 JSON 文本',
    icon: Icons.data_object,
    category: ToolCategory.text,
    builder: (_) => const JsonPage(),
  ),
  ToolItem(
    title: 'Markdown 编辑',
    subtitle: '实时预览、语法快捷插入与草稿保存',
    icon: Icons.edit_note,
    category: ToolCategory.text,
    builder: (_) => const MarkdownPage(),
  ),
  ToolItem(
    title: '哈希计算',
    subtitle: 'MD5、SHA-1、SHA-256、SHA-512',
    icon: Icons.tag,
    category: ToolCategory.text,
    builder: (_) => const HashPage(),
  ),
  ToolItem(
    title: '时间戳转换',
    subtitle: 'Unix 时间戳与日期时间互转',
    icon: Icons.schedule,
    category: ToolCategory.time,
    builder: (_) => const TimestampPage(),
  ),
  ToolItem(
    title: '颜色工具',
    subtitle: 'HEX / RGB / HSL 互转与配色预览',
    icon: Icons.palette,
    category: ToolCategory.color,
    builder: (_) => const ColorPage(),
  ),
  ToolItem(
    title: '密码生成',
    subtitle: '安全随机密码与强度评估',
    icon: Icons.password,
    category: ToolCategory.generate,
    builder: (_) => const PasswordPage(),
  ),
  ToolItem(
    title: '二维码生成',
    subtitle: '将文本生成可扫描的二维码',
    icon: Icons.qr_code_2,
    category: ToolCategory.generate,
    builder: (_) => const QrCodePage(),
  ),
  ToolItem(
    title: 'Pixiv Token',
    subtitle: 'OAuth 登录获取 access_token 与 PHPSESSID',
    icon: Icons.vpn_key,
    category: ToolCategory.network,
    builder: (_) => const PixivTokenPage(),
  ),
];

/// 工具卡片统一使用的配色角色，让不同分类有可辨识的色调。
Color categoryContainer(ToolCategory category, ColorScheme scheme) {
  switch (category) {
    case ToolCategory.convert:
      return scheme.primaryContainer;
    case ToolCategory.text:
      return scheme.secondaryContainer;
    case ToolCategory.time:
      return scheme.tertiaryContainer;
    case ToolCategory.color:
      return scheme.primaryContainer;
    case ToolCategory.generate:
      return scheme.secondaryContainer;
    case ToolCategory.network:
      return scheme.tertiaryContainer;
  }
}

Color categoryOnContainer(ToolCategory category, ColorScheme scheme) {
  switch (category) {
    case ToolCategory.convert:
      return scheme.onPrimaryContainer;
    case ToolCategory.text:
      return scheme.onSecondaryContainer;
    case ToolCategory.time:
      return scheme.onTertiaryContainer;
    case ToolCategory.color:
      return scheme.onPrimaryContainer;
    case ToolCategory.generate:
      return scheme.onSecondaryContainer;
    case ToolCategory.network:
      return scheme.onTertiaryContainer;
  }
}

