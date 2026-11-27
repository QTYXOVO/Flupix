import 'package:flutter/material.dart';

import '../models/tool_item.dart';
import '../tools/audio_convert_page.dart';
import '../tools/calculator_page.dart';
import '../tools/color_page.dart';
import '../tools/eh/eh_browse_page.dart';
import '../tools/exif_page.dart';
import '../tools/hash_page.dart';
import '../tools/json_page.dart';
import '../tools/markdown_page.dart';
import '../tools/metronome_page.dart';
import '../tools/password_page.dart';
import '../tools/pixiv_token_page.dart';
import '../tools/qrcode_page.dart';
import '../tools/qq_sticker_page.dart';
import '../tools/sliding_puzzle_page.dart';
import '../tools/text_codec_page.dart';
import '../tools/timestamp_page.dart';
import '../tools/unit_converter_page.dart';

final List<ToolItem> allTools = [
  ToolItem(
    title: (l10n) => l10n.toolUnitConverterTitle,
    subtitle: (l10n) => l10n.toolUnitConverterDesc,
    icon: Icons.straighten,
    category: ToolCategory.convert,
    builder: (_) => const UnitConverterPage(),
  ),
  ToolItem(
    title: (l10n) => l10n.toolCalculatorTitle,
    subtitle: (l10n) => l10n.toolCalculatorDesc,
    icon: Icons.calculate,
    category: ToolCategory.convert,
    builder: (_) => const CalculatorPage(),
  ),
  ToolItem(
    title: (l10n) => l10n.toolTextCodecTitle,
    subtitle: (l10n) => l10n.toolTextCodecDesc,
    icon: Icons.code,
    category: ToolCategory.text,
    builder: (_) => const TextCodecPage(),
  ),
  ToolItem(
    title: (l10n) => l10n.toolJsonTitle,
    subtitle: (l10n) => l10n.toolJsonDesc,
    icon: Icons.data_object,
    category: ToolCategory.text,
    builder: (_) => const JsonPage(),
  ),
  ToolItem(
    title: (l10n) => l10n.toolMarkdownTitle,
    subtitle: (l10n) => l10n.toolMarkdownDesc,
    icon: Icons.edit_note,
    category: ToolCategory.text,
    builder: (_) => const MarkdownPage(),
  ),
  ToolItem(
    title: (l10n) => l10n.toolHashTitle,
    subtitle: (l10n) => l10n.toolHashDesc,
    icon: Icons.tag,
    category: ToolCategory.text,
    builder: (_) => const HashPage(),
  ),
  ToolItem(
    title: (l10n) => l10n.toolTimestampTitle,
    subtitle: (l10n) => l10n.toolTimestampDesc,
    icon: Icons.schedule,
    category: ToolCategory.convert,
    builder: (_) => const TimestampPage(),
  ),
  ToolItem(
    title: (l10n) => l10n.toolColorTitle,
    subtitle: (l10n) => l10n.toolColorDesc,
    icon: Icons.palette,
    category: ToolCategory.convert,
    builder: (_) => const ColorPage(),
  ),
  ToolItem(
    title: (l10n) => l10n.toolAudioConvertTitle,
    subtitle: (l10n) => l10n.toolAudioConvertDesc,
    icon: Icons.graphic_eq_rounded,
    category: ToolCategory.convert,
    builder: (_) => const AudioConvertPage(),
  ),
  ToolItem(
    title: (l10n) => l10n.toolPasswordTitle,
    subtitle: (l10n) => l10n.toolPasswordDesc,
    icon: Icons.password,
    category: ToolCategory.generate,
    builder: (_) => const PasswordPage(),
  ),
  ToolItem(
    title: (l10n) => l10n.toolQrTitle,
    subtitle: (l10n) => l10n.toolQrDesc,
    icon: Icons.qr_code_2,
    category: ToolCategory.generate,
    builder: (_) => const QrCodePage(),
  ),
  ToolItem(
    title: (l10n) => l10n.toolMetronomeTitle,
    subtitle: (l10n) => l10n.toolMetronomeDesc,
    icon: Icons.av_timer,
    category: ToolCategory.other,
    builder: (_) => const MetronomePage(),
  ),
  ToolItem(
    title: (l10n) => l10n.toolPuzzleTitle,
    subtitle: (l10n) => l10n.toolPuzzleDesc,
    icon: Icons.grid_view_rounded,
    category: ToolCategory.other,
    builder: (_) => const SlidingPuzzlePage(),
  ),
  ToolItem(
    title: (l10n) => l10n.toolExifTitle,
    subtitle: (l10n) => l10n.toolExifDesc,
    icon: Icons.camera_alt_outlined,
    category: ToolCategory.other,
    builder: (_) => const ExifPage(),
  ),
  ToolItem(
    title: (l10n) => l10n.toolQqStickerTitle,
    subtitle: (l10n) => l10n.toolQqStickerDesc,
    icon: Icons.emoji_emotions_outlined,
    category: ToolCategory.other,
    requiresShizuku: true,
    builder: (_) => const QqStickerPage(),
  ),
  ToolItem(
    title: (l10n) => l10n.toolEhTitle,
    subtitle: (l10n) => l10n.toolEhDesc,
    icon: Icons.collections_bookmark,
    category: ToolCategory.other,
    builder: (_) => const EhBrowsePage(),
  ),
  ToolItem(
    title: (l10n) => l10n.toolPixivTitle,
    subtitle: (l10n) => l10n.toolPixivDesc,
    icon: Icons.vpn_key,
    category: ToolCategory.other,
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
    case ToolCategory.generate:
      return scheme.tertiaryContainer;
    case ToolCategory.other:
      return scheme.surfaceContainerHighest;
  }
}

Color categoryOnContainer(ToolCategory category, ColorScheme scheme) {
  switch (category) {
    case ToolCategory.convert:
      return scheme.onPrimaryContainer;
    case ToolCategory.text:
      return scheme.onSecondaryContainer;
    case ToolCategory.generate:
      return scheme.onTertiaryContainer;
    case ToolCategory.other:
      return scheme.onSurfaceVariant;
  }
}
