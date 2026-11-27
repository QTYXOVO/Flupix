import 'dart:typed_data';

/// 承载 EXIF 的文件容器格式。
enum ExifContainer {
  jpeg,
  png,
  webp,
  tiff,
  gif,
  heic,
  unknown;

  String get label => switch (this) {
    ExifContainer.jpeg => 'JPEG',
    ExifContainer.png => 'PNG',
    ExifContainer.webp => 'WebP',
    ExifContainer.tiff => 'TIFF',
    ExifContainer.gif => 'GIF',
    ExifContainer.heic => 'HEIC',
    ExifContainer.unknown => 'Unknown',
  };
}

/// EXIF 的 IFD 分组。
enum ExifGroupKind { image, exif, gps, interop, thumbnail }

/// TIFF 中的有理数，保留分子分母便于换算快门、GPS 度分秒。
class ExifRational {
  const ExifRational(this.numerator, this.denominator);

  final int numerator;
  final int denominator;

  double get value => denominator == 0 ? double.nan : numerator / denominator;

  @override
  String toString() => '$numerator/$denominator';
}

/// 单个 EXIF 标签。
class ExifTag {
  const ExifTag({
    required this.id,
    required this.name,
    required this.value,
    required this.formatted,
  });

  final int id;

  /// 标签的可读名称，来自标准标签表。
  final String name;

  /// 原始解析值（int / String / ExifRational / 列表等）。
  final Object? value;

  /// 已格式化的展示文本。
  final String formatted;
}

/// 一组标签（对应一个 IFD）。
class ExifGroup {
  const ExifGroup({required this.kind, required this.tags});

  final ExifGroupKind kind;
  final List<ExifTag> tags;

  bool get isEmpty => tags.isEmpty;
}

/// 一次成功解析得到的 EXIF 数据。
class ExifData {
  const ExifData({
    required this.container,
    required this.littleEndian,
    required this.groups,
    this.thumbnail,
    this.hasXmp = false,
  });

  final ExifContainer container;
  final bool littleEndian;
  final List<ExifGroup> groups;

  /// IFD1 中内嵌的 JPEG 缩略图（如存在）。
  final Uint8List? thumbnail;

  /// 是否检测到 XMP 元数据。
  final bool hasXmp;

  ExifGroup? group(ExifGroupKind kind) {
    for (final group in groups) {
      if (group.kind == kind) return group;
    }
    return null;
  }

  ExifTag? tag(ExifGroupKind kind, int id) {
    for (final tag in group(kind)?.tags ?? const <ExifTag>[]) {
      if (tag.id == id) return tag;
    }
    return null;
  }

  Iterable<ExifTag> get allTags => groups.expand((group) => group.tags);
}

/// 解析结果：即使没有 EXIF，也会带上识别到的容器格式。
class ExifParseResult {
  const ExifParseResult({
    required this.container,
    this.data,
    this.unsupported = false,
  });

  final ExifContainer container;

  /// 为 null 表示容器有效但未找到 EXIF。
  final ExifData? data;

  /// 当前格式（例如 HEIC）暂不支持解析。
  final bool unsupported;
}
