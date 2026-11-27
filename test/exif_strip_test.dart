import 'dart:typed_data';

import 'package:flupix/core/exif/exif_strip.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('JPEG 移除 APP1/APP13，保留 JFIF 与图像数据', () {
    final source = _jpeg(withMetadata: true);
    final result = stripImageMetadata(source);

    expect(result.status, MetadataStripStatus.stripped);
    expect(result.removedSegments, 2);
    expect(_indexOf(result.bytes, [0xFF, 0xE1]), -1);
    expect(_indexOf(result.bytes, [0xFF, 0xED]), -1);
    expect(_indexOf(result.bytes, [0xFF, 0xE0]), 2);
    expect(_indexOf(result.bytes, [0xFF, 0xDB]), isNonNegative);
    expect(_indexOf(result.bytes, [0xFF, 0xDA]), isNonNegative);
    expect(_indexOf(result.bytes, [0xFF, 0xD9]), result.bytes.length - 2);
    expect(listEquals(result.bytes, _jpeg(withMetadata: false)), isTrue);
  });

  test('没有元数据的 JPEG 返回 nothingToStrip', () {
    final source = _jpeg(withMetadata: false);
    final result = stripImageMetadata(source);

    expect(result.status, MetadataStripStatus.nothingToStrip);
    expect(result.removedSegments, 0);
    expect(listEquals(result.bytes, source), isTrue);
  });

  test('PNG 移除 eXIf 与文本块，保留图像块', () {
    final source = _concat([
      _pngSignature,
      _pngChunk('IHDR', [0, 0, 0, 1, 0, 0, 0, 1, 8, 2, 0, 0, 0]),
      _pngChunk('eXIf', [0x49, 0x49, 0x2A, 0]),
      _pngChunk('tEXt', 'Comment\u0000hello'.codeUnits),
      _pngChunk('IDAT', [1, 2, 3, 4]),
      _pngChunk('IEND', const []),
    ]);

    final result = stripImageMetadata(source);

    expect(result.status, MetadataStripStatus.stripped);
    expect(result.removedSegments, 2);
    expect(_indexOf(result.bytes, 'eXIf'.codeUnits), -1);
    expect(_indexOf(result.bytes, 'tEXt'.codeUnits), -1);
    expect(_indexOf(result.bytes, 'IHDR'.codeUnits), isNonNegative);
    expect(_indexOf(result.bytes, 'IDAT'.codeUnits), isNonNegative);
    expect(_indexOf(result.bytes, 'IEND'.codeUnits), isNonNegative);
  });

  test('WebP 移除 EXIF/XMP 块并清理 VP8X 标志与 RIFF 长度', () {
    final source = _webp([
      _riffChunk('VP8X', [0x0C, 0, 0, 0, 0, 0, 0, 0, 0, 0]),
      _riffChunk('EXIF', [1, 2, 3]),
      _riffChunk('XMP ', [4, 5, 6, 7]),
      _riffChunk('VP8 ', [9, 9]),
    ]);

    final result = stripImageMetadata(source);

    expect(result.status, MetadataStripStatus.stripped);
    expect(result.removedSegments, 2);
    expect(_indexOf(result.bytes, 'EXIF'.codeUnits), -1);
    expect(_indexOf(result.bytes, 'XMP '.codeUnits), -1);
    expect(_indexOf(result.bytes, 'VP8 '.codeUnits), isNonNegative);
    // VP8X 载荷首字节位于 12（文件头）+ 8（块头）= 20。
    expect(result.bytes[20], 0);
    expect(_readU32Le(result.bytes, 4), result.bytes.length - 8);
    expect(result.bytes.length, source.length - 24);
  });

  test('TIFF 等不支持格式返回 unsupported 且不修改数据', () {
    final source = Uint8List.fromList([
      0x49, 0x49, 0x2A, 0x00, 0x08, 0x00, 0x00, 0x00,
    ]);
    final result = stripImageMetadata(source);

    expect(result.status, MetadataStripStatus.unsupported);
    expect(listEquals(result.bytes, source), isTrue);
  });
}

// ------------------------------------------------------------------ 构造数据

const List<int> _pngSignature = [
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A,
];

Uint8List _jpeg({required bool withMetadata}) {
  return _concat([
    [0xFF, 0xD8],
    [0xFF, 0xE0, 0x00, 0x04, 0x00, 0x00],
    if (withMetadata) ...[
      [0xFF, 0xE1, 0x00, 0x08, 0x45, 0x78, 0x69, 0x66, 0x00, 0x00],
      [0xFF, 0xED, 0x00, 0x04, 0x11, 0x22],
    ],
    [0xFF, 0xDB, 0x00, 0x04, 0x01, 0x02],
    [0xFF, 0xDA, 0x00, 0x04, 0x03, 0x04],
    [0x11, 0x22, 0x33],
    [0xFF, 0xD9],
  ]);
}

Uint8List _pngChunk(String type, List<int> data) {
  final length = data.length;
  return _concat([
    [
      (length >> 24) & 0xFF,
      (length >> 16) & 0xFF,
      (length >> 8) & 0xFF,
      length & 0xFF,
    ],
    type.codeUnits,
    data,
    [0, 0, 0, 0],
  ]);
}

Uint8List _webp(List<Uint8List> chunks) {
  final body = _concat([
    'WEBP'.codeUnits,
    ...chunks,
  ]);
  return _concat([
    'RIFF'.codeUnits,
    _u32Le(4 + body.length),
    body,
  ]);
}

Uint8List _riffChunk(String fourcc, List<int> payload) {
  return _concat([
    fourcc.codeUnits,
    _u32Le(payload.length),
    payload,
    if (payload.length.isOdd) [0],
  ]);
}

Uint8List _concat(List<List<int>> parts) {
  final builder = BytesBuilder();
  for (final part in parts) {
    builder.add(part);
  }
  return builder.toBytes();
}

Uint8List _u32Le(int value) {
  return Uint8List(4)
    ..[0] = value & 0xFF
    ..[1] = (value >> 8) & 0xFF
    ..[2] = (value >> 16) & 0xFF
    ..[3] = (value >> 24) & 0xFF;
}

int _readU32Le(Uint8List bytes, int offset) {
  return bytes[offset] |
      (bytes[offset + 1] << 8) |
      (bytes[offset + 2] << 16) |
      (bytes[offset + 3] << 24);
}

int _indexOf(Uint8List bytes, List<int> pattern) {
  if (pattern.isEmpty || pattern.length > bytes.length) return -1;
  for (var i = 0; i <= bytes.length - pattern.length; i++) {
    var matched = true;
    for (var j = 0; j < pattern.length; j++) {
      if (bytes[i + j] != pattern[j]) {
        matched = false;
        break;
      }
    }
    if (matched) return i;
  }
  return -1;
}
