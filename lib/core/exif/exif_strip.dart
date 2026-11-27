import 'dart:typed_data';

import 'exif_data.dart';
import 'exif_parser.dart';

/// 抹除结果的状态。
enum MetadataStripStatus {
  /// 已移除元数据。
  stripped,

  /// 文件有效，但没有需要移除的元数据。
  nothingToStrip,

  /// 当前格式暂不支持安全地抹除元数据。
  unsupported,
}

class MetadataStripResult {
  const MetadataStripResult({
    required this.bytes,
    required this.status,
    this.removedSegments = 0,
  });

  /// 处理后的字节；未做修改时即为原始字节。
  final Uint8List bytes;
  final MetadataStripStatus status;

  /// 被移除的元数据段 / 块数量。
  final int removedSegments;

  bool get changed => status == MetadataStripStatus.stripped;
}

/// 字节级抹除图片中的 EXIF / XMP / IPTC 等元数据。
///
/// 只重新拼接容器结构，不重新编码像素，因此不会损失画质。
/// 支持的格式：JPEG（移除 APP1/APP3-13/APP15 与注释，保留 JFIF、ICC、Adobe）、
/// PNG（移除 eXIf 与文本块）、WebP（移除 EXIF / XMP 块并清理 VP8X 标志位）。
MetadataStripResult stripImageMetadata(
  Uint8List bytes, {
  ExifContainer? container,
}) {
  final kind = container ?? detectExifContainer(bytes);
  try {
    return switch (kind) {
      ExifContainer.jpeg => _stripJpeg(bytes),
      ExifContainer.png => _stripPng(bytes),
      ExifContainer.webp => _stripWebp(bytes),
      _ => MetadataStripResult(
        bytes: bytes,
        status: MetadataStripStatus.unsupported,
      ),
    };
  } catch (_) {
    return MetadataStripResult(
      bytes: bytes,
      status: MetadataStripStatus.unsupported,
    );
  }
}

// ------------------------------------------------------------------ JPEG

/// APP1 与 APP3~APP13、APP15 属于元数据区；APP0（JFIF）、APP2（ICC）
/// 和 APP14（Adobe 色彩变换）需要保留，否则可能影响正常显示。
bool _isJpegMetadataMarker(int marker) {
  if (marker == 0xFE) return true; // COM
  if (marker < 0xE0 || marker > 0xEF) return false;
  return marker != 0xE0 && marker != 0xE2 && marker != 0xEE;
}

MetadataStripResult _stripJpeg(Uint8List bytes) {
  if (bytes.length < 4) return _unsupported(bytes);

  final output = BytesBuilder(copy: false);
  output
    ..addByte(bytes[0])
    ..addByte(bytes[1]);

  var offset = 2;
  var removed = 0;

  while (offset < bytes.length) {
    if (bytes[offset] != 0xFF) {
      // 结构异常，原样保留剩余数据，避免生成损坏的文件。
      output.add(Uint8List.sublistView(bytes, offset));
      break;
    }
    if (offset + 1 >= bytes.length) {
      output.add(Uint8List.sublistView(bytes, offset));
      break;
    }

    final marker = bytes[offset + 1];
    if (marker == 0xFF) {
      // 填充字节，保留一个 0xFF 后继续识别标记。
      output.addByte(0xFF);
      offset++;
      continue;
    }
    if (marker == 0xD8 ||
        marker == 0x01 ||
        (marker >= 0xD0 && marker <= 0xD7)) {
      output.add(Uint8List.sublistView(bytes, offset, offset + 2));
      offset += 2;
      continue;
    }
    if (marker == 0xD9) {
      output.add(Uint8List.sublistView(bytes, offset, offset + 2));
      offset += 2;
      break;
    }
    if (offset + 3 >= bytes.length) {
      output.add(Uint8List.sublistView(bytes, offset));
      break;
    }

    final length = (bytes[offset + 2] << 8) | bytes[offset + 3];
    if (length < 2) {
      output.add(Uint8List.sublistView(bytes, offset));
      break;
    }
    final end = offset + 2 + length;
    if (end > bytes.length) {
      output.add(Uint8List.sublistView(bytes, offset));
      break;
    }

    if (_isJpegMetadataMarker(marker)) {
      removed++;
    } else {
      output.add(Uint8List.sublistView(bytes, offset, end));
    }

    if (marker == 0xDA) {
      // SOS 之后是熵编码数据，整体保留到文件末尾。
      output.add(Uint8List.sublistView(bytes, end));
      offset = bytes.length;
      break;
    }
    offset = end;
  }

  return MetadataStripResult(
    bytes: output.toBytes(),
    status: removed == 0
        ? MetadataStripStatus.nothingToStrip
        : MetadataStripStatus.stripped,
    removedSegments: removed,
  );
}

// ------------------------------------------------------------------ PNG

const Set<String> _pngMetadataChunks = {'eXIf', 'tEXt', 'zTXt', 'iTXt', 'tIME'};

MetadataStripResult _stripPng(Uint8List bytes) {
  if (bytes.length < 8) return _unsupported(bytes);

  final output = BytesBuilder(copy: false)
    ..add(Uint8List.sublistView(bytes, 0, 8));
  var offset = 8;
  var removed = 0;
  var sawChunk = false;

  while (offset + 8 <= bytes.length) {
    final length = _readU32(bytes, offset);
    final end = offset + 12 + length;
    if (end > bytes.length) return _unsupported(bytes);

    final type = String.fromCharCodes(bytes.sublist(offset + 4, offset + 8));
    sawChunk = true;
    if (_pngMetadataChunks.contains(type)) {
      removed++;
    } else {
      output.add(Uint8List.sublistView(bytes, offset, end));
    }
    offset = end;
    if (type == 'IEND') break;
  }

  if (!sawChunk) return _unsupported(bytes);
  if (offset < bytes.length) {
    output.add(Uint8List.sublistView(bytes, offset));
  }

  return MetadataStripResult(
    bytes: output.toBytes(),
    status: removed == 0
        ? MetadataStripStatus.nothingToStrip
        : MetadataStripStatus.stripped,
    removedSegments: removed,
  );
}

// ------------------------------------------------------------------ WebP

const int _vp8xExifFlag = 0x08;
const int _vp8xXmpFlag = 0x04;

MetadataStripResult _stripWebp(Uint8List bytes) {
  if (bytes.length < 12) return _unsupported(bytes);
  if (!_matchesAscii(bytes, 0, bytes.length, 'RIFF') ||
      !_matchesAscii(bytes, 8, bytes.length, 'WEBP')) {
    return _unsupported(bytes);
  }

  final chunks = <Uint8List>[];
  var offset = 12;
  var removed = 0;

  while (offset + 8 <= bytes.length) {
    final fourcc = String.fromCharCodes(bytes.sublist(offset, offset + 4));
    final size = _readU32Le(bytes, offset + 4);
    final dataEnd = offset + 8 + size;
    if (size < 0 || dataEnd > bytes.length) return _unsupported(bytes);
    final end = dataEnd + (size & 1) <= bytes.length
        ? dataEnd + (size & 1)
        : dataEnd;

    if (fourcc == 'EXIF' || fourcc == 'XMP ') {
      removed++;
    } else if (fourcc == 'VP8X' && size >= 1) {
      final copy = Uint8List.fromList(
        Uint8List.sublistView(bytes, offset, end),
      );
      copy[8] &= ~(_vp8xExifFlag | _vp8xXmpFlag);
      chunks.add(copy);
    } else {
      chunks.add(Uint8List.sublistView(bytes, offset, end));
    }
    offset = end;
  }

  if (removed == 0) {
    return MetadataStripResult(
      bytes: bytes,
      status: MetadataStripStatus.nothingToStrip,
    );
  }

  var payloadLength = 0;
  for (final chunk in chunks) {
    payloadLength += chunk.length;
  }
  final totalLength = 12 + payloadLength;

  final output = BytesBuilder(copy: false)
    ..add(_ascii('RIFF'))
    ..add(_u32Le(totalLength - 8))
    ..add(_ascii('WEBP'));
  for (final chunk in chunks) {
    output.add(chunk);
  }

  return MetadataStripResult(
    bytes: output.toBytes(),
    status: MetadataStripStatus.stripped,
    removedSegments: removed,
  );
}

// ------------------------------------------------------------------ 工具

MetadataStripResult _unsupported(Uint8List bytes) {
  return MetadataStripResult(
    bytes: bytes,
    status: MetadataStripStatus.unsupported,
  );
}

int _readU32(Uint8List bytes, int offset) {
  return (bytes[offset] << 24) |
      (bytes[offset + 1] << 16) |
      (bytes[offset + 2] << 8) |
      bytes[offset + 3];
}

int _readU32Le(Uint8List bytes, int offset) {
  return bytes[offset] |
      (bytes[offset + 1] << 8) |
      (bytes[offset + 2] << 16) |
      (bytes[offset + 3] << 24);
}

Uint8List _u32Le(int value) {
  return Uint8List(4)
    ..[0] = value & 0xFF
    ..[1] = (value >> 8) & 0xFF
    ..[2] = (value >> 16) & 0xFF
    ..[3] = (value >> 24) & 0xFF;
}

Uint8List _ascii(String text) {
  return Uint8List.fromList(text.codeUnits);
}

bool _matchesAscii(Uint8List bytes, int start, int end, String text) {
  if (start < 0 || start + text.length > end) return false;
  for (var i = 0; i < text.length; i++) {
    if (bytes[start + i] != text.codeUnitAt(i)) return false;
  }
  return true;
}
