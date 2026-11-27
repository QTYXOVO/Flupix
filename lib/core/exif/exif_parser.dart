import 'dart:convert';
import 'dart:typed_data';

import 'exif_data.dart';
import 'exif_tags.dart';

/// 防御性的解析上限，避免畸形文件导致内存爆炸。
const int _maxIfdEntries = 512;
const int _maxValueBytes = 8 * 1024 * 1024;
const int _maxIfds = 8;

/// TIFF 数据类型对应的字节宽度。
const Map<int, int> _typeSizes = {
  1: 1, // BYTE
  2: 1, // ASCII
  3: 2, // SHORT
  4: 4, // LONG
  5: 8, // RATIONAL
  6: 1, // SBYTE
  7: 1, // UNDEFINED
  8: 2, // SSHORT
  9: 4, // SLONG
  10: 8, // SRATIONAL
  11: 4, // FLOAT
  12: 8, // DOUBLE
  13: 4, // IFD
};

/// 结构性标签不展示给用户：它们是 IFD 指针或缩略图字节偏移。
const Set<int> _structuralTags = {
  0x8769, // Exif IFD Pointer
  0x8825, // GPS IFD Pointer
  0xA005, // Interop IFD Pointer
  0x014A, // Sub IFDs
  0x0201, // Thumbnail Offset
  0x0202, // Thumbnail Length
};

const List<int> _jpegXmpHeader = [
  0x68, 0x74, 0x74, 0x70, 0x3A, 0x2F, 0x2F, 0x6E, 0x73, 0x2E, 0x61, 0x64,
  0x6F, 0x62, 0x65, 0x2E, 0x63, 0x6F, 0x6D, 0x2F, 0x78, 0x61, 0x70, 0x2F,
  0x31, 0x2E, 0x30, 0x2F, 0x00,
];

/// 解析图片中的 EXIF。永不抛异常：无法识别 / 损坏时返回空数据。
ExifParseResult readExif(Uint8List bytes) {
  final container = detectExifContainer(bytes);
  try {
    switch (container) {
      case ExifContainer.jpeg:
        return _readJpeg(bytes);
      case ExifContainer.png:
        return _readPng(bytes);
      case ExifContainer.webp:
        return _readWebp(bytes);
      case ExifContainer.tiff:
        return _readTiff(bytes);
      case ExifContainer.gif:
        return const ExifParseResult(container: ExifContainer.gif);
      case ExifContainer.heic:
      case ExifContainer.unknown:
        return ExifParseResult(container: container, unsupported: true);
    }
  } catch (_) {
    return ExifParseResult(container: container);
  }
}

// ------------------------------------------------------------------ 容器识别

/// 根据文件头识别容器格式。
ExifContainer detectExifContainer(Uint8List bytes) {
  if (bytes.length >= 2 && bytes[0] == 0xFF && bytes[1] == 0xD8) {
    return ExifContainer.jpeg;
  }
  if (bytes.length >= 8 &&
      bytes[0] == 0x89 &&
      bytes[1] == 0x50 &&
      bytes[2] == 0x4E &&
      bytes[3] == 0x47 &&
      bytes[4] == 0x0D &&
      bytes[5] == 0x0A &&
      bytes[6] == 0x1A &&
      bytes[7] == 0x0A) {
    return ExifContainer.png;
  }
  if (bytes.length >= 12 &&
      _matchesAscii(bytes, 0, bytes.length, 'RIFF') &&
      _matchesAscii(bytes, 8, bytes.length, 'WEBP')) {
    return ExifContainer.webp;
  }
  if (bytes.length >= 4 &&
      ((bytes[0] == 0x49 &&
              bytes[1] == 0x49 &&
              bytes[2] == 0x2A &&
              bytes[3] == 0x00) ||
          (bytes[0] == 0x4D &&
              bytes[1] == 0x4D &&
              bytes[2] == 0x00 &&
              bytes[3] == 0x2A))) {
    return ExifContainer.tiff;
  }
  if (bytes.length >= 6 && _matchesAscii(bytes, 0, bytes.length, 'GIF8')) {
    return ExifContainer.gif;
  }
  if (bytes.length >= 12 && _matchesAscii(bytes, 4, bytes.length, 'ftyp')) {
    return ExifContainer.heic;
  }
  return ExifContainer.unknown;
}

// ------------------------------------------------------------------ JPEG

ExifParseResult _readJpeg(Uint8List bytes) {
  var offset = 2;
  var hasXmp = false;

  while (offset + 1 < bytes.length) {
    if (bytes[offset] != 0xFF) {
      offset++;
      continue;
    }
    final marker = bytes[offset + 1];
    if (marker == 0xFF) {
      offset++;
      continue;
    }
    // 无长度的标记。
    if (marker == 0xD8 ||
        marker == 0x01 ||
        (marker >= 0xD0 && marker <= 0xD7)) {
      offset += 2;
      continue;
    }
    if (marker == 0xD9 || marker == 0xDA) break;
    if (offset + 3 >= bytes.length) break;

    final length = (bytes[offset + 2] << 8) | bytes[offset + 3];
    if (length < 2) break;
    final start = offset + 4;
    final end = offset + 2 + length;
    if (end > bytes.length) break;

    if (marker == 0xE1) {
      if (_matchesAscii(bytes, start, end, 'Exif\u0000\u0000')) {
        final tiff = _parseTiff(bytes, start + 6, end);
        if (tiff != null) {
          return ExifParseResult(
            container: ExifContainer.jpeg,
            data: ExifData(
              container: ExifContainer.jpeg,
              littleEndian: tiff.littleEndian,
              groups: tiff.groups,
              thumbnail: tiff.thumbnail,
              hasXmp: hasXmp || tiff.hasXmp,
            ),
          );
        }
      } else if (_matchesHeader(bytes, start, end, _jpegXmpHeader)) {
        hasXmp = true;
      }
    }
    offset = end;
  }

  return const ExifParseResult(container: ExifContainer.jpeg);
}

// ------------------------------------------------------------------ PNG

ExifParseResult _readPng(Uint8List bytes) {
  var offset = 8;
  var hasXmp = false;

  while (offset + 8 <= bytes.length) {
    final length = _readU32(bytes, offset);
    final dataStart = offset + 8;
    final dataEnd = dataStart + length;
    if (length < 0 || dataEnd + 4 > bytes.length) break;

    final type = String.fromCharCodes(bytes.sublist(offset + 4, offset + 8));
    if (type == 'eXIf') {
      final tiff = _parseTiff(bytes, dataStart, dataEnd);
      if (tiff != null) {
        return ExifParseResult(
          container: ExifContainer.png,
          data: ExifData(
            container: ExifContainer.png,
            littleEndian: tiff.littleEndian,
            groups: tiff.groups,
            thumbnail: tiff.thumbnail,
            hasXmp: hasXmp || tiff.hasXmp,
          ),
        );
      }
    } else if (type == 'iTXt' &&
        _matchesAscii(bytes, dataStart, dataEnd, 'XML:com.adobe.xmp')) {
      hasXmp = true;
    }
    if (type == 'IEND') break;
    offset = dataEnd + 4;
  }

  return const ExifParseResult(container: ExifContainer.png);
}

// ------------------------------------------------------------------ WebP

ExifParseResult _readWebp(Uint8List bytes) {
  var offset = 12;
  var hasXmp = false;

  while (offset + 8 <= bytes.length) {
    final fourcc = String.fromCharCodes(bytes.sublist(offset, offset + 4));
    final size = _readU32Le(bytes, offset + 4);
    final dataStart = offset + 8;
    final dataEnd = dataStart + size;
    if (size < 0 || dataEnd > bytes.length) break;

    if (fourcc == 'EXIF') {
      var start = dataStart;
      if (_matchesAscii(bytes, start, dataEnd, 'Exif\u0000\u0000')) start += 6;
      final tiff = _parseTiff(bytes, start, dataEnd);
      if (tiff != null) {
        return ExifParseResult(
          container: ExifContainer.webp,
          data: ExifData(
            container: ExifContainer.webp,
            littleEndian: tiff.littleEndian,
            groups: tiff.groups,
            thumbnail: tiff.thumbnail,
            hasXmp: hasXmp || tiff.hasXmp,
          ),
        );
      }
    } else if (fourcc == 'XMP ') {
      hasXmp = true;
    }
    offset = dataEnd + (size & 1);
  }

  return const ExifParseResult(container: ExifContainer.webp);
}

// ------------------------------------------------------------------ TIFF

ExifParseResult _readTiff(Uint8List bytes) {
  final tiff = _parseTiff(bytes, 0, bytes.length);
  return ExifParseResult(
    container: ExifContainer.tiff,
    data: tiff == null
        ? null
        : ExifData(
            container: ExifContainer.tiff,
            littleEndian: tiff.littleEndian,
            groups: tiff.groups,
            thumbnail: tiff.thumbnail,
            hasXmp: tiff.hasXmp,
          ),
  );
}

// ------------------------------------------------------------------ TIFF 解析

class _TiffData {
  const _TiffData({
    required this.littleEndian,
    required this.groups,
    required this.hasXmp,
    this.thumbnail,
  });

  final bool littleEndian;
  final List<ExifGroup> groups;
  final bool hasXmp;
  final Uint8List? thumbnail;
}

_TiffData? _parseTiff(Uint8List bytes, int start, int end) {
  if (end - start < 8) return null;
  final first = bytes[start];
  final second = bytes[start + 1];
  final bool littleEndian;
  if (first == 0x49 && second == 0x49) {
    littleEndian = true;
  } else if (first == 0x4D && second == 0x4D) {
    littleEndian = false;
  } else {
    return null;
  }

  final reader = _TiffReader(bytes, start, end, littleEndian);
  if (reader.u16(2) != 0x2A) return null;

  final visited = <int>{};
  final ifd0 = _readIfd(reader, reader.u32(4), visited);
  if (ifd0 == null) return null;

  var hasXmp = false;
  for (final entry in ifd0.entries) {
    if (entry.tag == 0x02BC) hasXmp = true;
  }

  final imageTags = _buildTags(reader, ifd0.entries, ExifGroupKind.image);

  final exifOffset = _pointerValue(ifd0.entries, 0x8769);
  final exifIfd = exifOffset == null
      ? null
      : _readIfd(reader, exifOffset, visited);
  final exifTags = exifIfd == null
      ? const <ExifTag>[]
      : _buildTags(reader, exifIfd.entries, ExifGroupKind.exif);

  final interopOffset = exifIfd == null
      ? null
      : _pointerValue(exifIfd.entries, 0xA005);
  final interopIfd = interopOffset == null
      ? null
      : _readIfd(reader, interopOffset, visited);
  final interopTags = interopIfd == null
      ? const <ExifTag>[]
      : _buildTags(reader, interopIfd.entries, ExifGroupKind.interop);

  final gpsOffset = _pointerValue(ifd0.entries, 0x8825);
  final gpsIfd = gpsOffset == null ? null : _readIfd(reader, gpsOffset, visited);
  final gpsTags = gpsIfd == null
      ? const <ExifTag>[]
      : _buildTags(reader, gpsIfd.entries, ExifGroupKind.gps);

  Uint8List? thumbnail;
  var thumbnailTags = const <ExifTag>[];
  if (ifd0.nextOffset != 0) {
    final ifd1 = _readIfd(reader, ifd0.nextOffset, visited);
    if (ifd1 != null) {
      thumbnailTags = _buildTags(
        reader,
        ifd1.entries,
        ExifGroupKind.thumbnail,
      );
      final thumbOffset = _inlineLong(ifd1.entries, 0x0201);
      final thumbLength = _inlineLong(ifd1.entries, 0x0202);
      if (thumbOffset != null &&
          thumbLength != null &&
          thumbLength > 0 &&
          thumbLength <= _maxValueBytes &&
          reader.inBounds(thumbOffset, thumbLength)) {
        thumbnail = reader.slice(thumbOffset, thumbLength);
      }
    }
  }

  final groups = <ExifGroup>[];
  void add(ExifGroupKind kind, List<ExifTag> tags) {
    if (tags.isNotEmpty) groups.add(ExifGroup(kind: kind, tags: tags));
  }

  add(ExifGroupKind.image, imageTags);
  add(ExifGroupKind.exif, exifTags);
  add(ExifGroupKind.gps, gpsTags);
  add(ExifGroupKind.interop, interopTags);
  add(ExifGroupKind.thumbnail, thumbnailTags);

  if (groups.isEmpty && thumbnail == null) return null;

  return _TiffData(
    littleEndian: littleEndian,
    groups: groups,
    hasXmp: hasXmp,
    thumbnail: thumbnail,
  );
}

List<ExifTag> _buildTags(
  _TiffReader reader,
  List<_Entry> entries,
  ExifGroupKind kind,
) {
  final tags = <ExifTag>[];
  for (final entry in entries) {
    if (_structuralTags.contains(entry.tag)) continue;
    final value = _entryValue(reader, entry);
    if (value == null) continue;
    tags.add(
      ExifTag(
        id: entry.tag,
        name: exifTagName(kind, entry.tag),
        value: value,
        formatted: exifValueText(kind, entry.tag, value),
      ),
    );
  }
  return tags;
}

class _Ifd {
  const _Ifd(this.entries, this.nextOffset);

  final List<_Entry> entries;
  final int nextOffset;
}

class _Entry {
  const _Entry({
    required this.tag,
    required this.type,
    required this.count,
    required this.entryOffset,
    required this.valueOrOffset,
  });

  final int tag;
  final int type;
  final int count;
  final int entryOffset;
  final int valueOrOffset;
}

_Ifd? _readIfd(_TiffReader reader, int offset, Set<int> visited) {
  if (offset <= 0 || visited.length >= _maxIfds || !visited.add(offset)) {
    return null;
  }
  if (!reader.inBounds(offset, 2)) return null;

  final count = reader.u16(offset);
  if (count > _maxIfdEntries) return null;
  final bodyLength = count * 12;
  if (!reader.inBounds(offset + 2, bodyLength)) return null;

  final entries = <_Entry>[];
  for (var i = 0; i < count; i++) {
    final base = offset + 2 + i * 12;
    entries.add(
      _Entry(
        tag: reader.u16(base),
        type: reader.u16(base + 2),
        count: reader.u32(base + 4),
        entryOffset: base,
        valueOrOffset: reader.u32(base + 8),
      ),
    );
  }

  var nextOffset = 0;
  final nextField = offset + 2 + bodyLength;
  if (reader.inBounds(nextField, 4)) nextOffset = reader.u32(nextField);
  return _Ifd(entries, nextOffset);
}

Object? _entryValue(_TiffReader reader, _Entry entry) {
  final typeSize = _typeSizes[entry.type];
  if (typeSize == null || entry.count < 0 || entry.count > 0xFFFFF) {
    return null;
  }
  final total = typeSize * entry.count;
  if (total > _maxValueBytes) return null;

  // 不超过 4 字节的值直接内联在条目里。
  final offset = total <= 4 ? entry.entryOffset + 8 : entry.valueOrOffset;
  if (!reader.inBounds(offset, total)) return null;

  switch (entry.type) {
    case 1:
      return reader.slice(offset, entry.count);
    case 2:
      return _decodeAscii(reader.slice(offset, entry.count));
    case 3:
      return _readIntegers(
        entry.count,
        (index) => reader.u16(offset + index * 2),
      );
    case 4:
    case 13:
      return _readIntegers(
        entry.count,
        (index) => reader.u32(offset + index * 4),
      );
    case 5:
      return _readRationals(
        entry.count,
        (index) => ExifRational(
          reader.u32(offset + index * 8),
          reader.u32(offset + index * 8 + 4),
        ),
      );
    case 6:
      return _readIntegers(
        entry.count,
        (index) => reader.u8(offset + index).toSigned(8),
      );
    case 7:
      return reader.slice(offset, entry.count);
    case 8:
      return _readIntegers(
        entry.count,
        (index) => reader.u16(offset + index * 2).toSigned(16),
      );
    case 9:
      return _readIntegers(
        entry.count,
        (index) => reader.u32(offset + index * 4).toSigned(32),
      );
    case 10:
      return _readRationals(
        entry.count,
        (index) => ExifRational(
          reader.u32(offset + index * 8).toSigned(32),
          reader.u32(offset + index * 8 + 4).toSigned(32),
        ),
      );
    case 11:
      return _readDoubles(
        entry.count,
        (index) => reader.f32(offset + index * 4),
      );
    case 12:
      return _readDoubles(
        entry.count,
        (index) => reader.f64(offset + index * 8),
      );
  }
  return null;
}

Object _readIntegers(int count, int Function(int index) read) {
  if (count == 1) return read(0);
  return List<int>.generate(count, read);
}

Object _readRationals(int count, ExifRational Function(int index) read) {
  if (count == 1) return read(0);
  return List<ExifRational>.generate(count, read);
}

Object _readDoubles(int count, double Function(int index) read) {
  if (count == 1) return read(0);
  return List<double>.generate(count, read);
}

int? _pointerValue(List<_Entry> entries, int tag) {
  for (final entry in entries) {
    if (entry.tag == tag && entry.count == 1) return entry.valueOrOffset;
  }
  return null;
}

/// Thumbnail 偏移 / 长度固定是内联的 LONG。
int? _inlineLong(List<_Entry> entries, int tag) {
  for (final entry in entries) {
    if (entry.tag == tag && entry.count == 1) return entry.valueOrOffset;
  }
  return null;
}

String _decodeAscii(Uint8List bytes) {
  final terminator = bytes.indexOf(0);
  final content = terminator < 0
      ? bytes
      : Uint8List.sublistView(bytes, 0, terminator);
  String text;
  try {
    text = utf8.decode(content);
  } catch (_) {
    text = latin1.decode(content);
  }
  return text.trim();
}

// ------------------------------------------------------------------ TIFF 读取器

class _TiffReader {
  _TiffReader(this.bytes, this.start, this.end, this.littleEndian);

  final Uint8List bytes;
  final int start;
  final int end;
  final bool littleEndian;

  int get length => end - start;

  bool inBounds(int offset, int count) =>
      offset >= 0 && count >= 0 && offset + count <= length;

  int u8(int offset) => bytes[start + offset];

  int u16(int offset) {
    final index = start + offset;
    return littleEndian
        ? bytes[index] | (bytes[index + 1] << 8)
        : (bytes[index] << 8) | bytes[index + 1];
  }

  int u32(int offset) {
    final index = start + offset;
    return littleEndian
        ? bytes[index] |
              (bytes[index + 1] << 8) |
              (bytes[index + 2] << 16) |
              (bytes[index + 3] << 24)
        : (bytes[index] << 24) |
              (bytes[index + 1] << 16) |
              (bytes[index + 2] << 8) |
              bytes[index + 3];
  }

  double f32(int offset) {
    final view = ByteData.sublistView(bytes, start + offset, start + offset + 4);
    return view.getFloat32(0, littleEndian ? Endian.little : Endian.big);
  }

  double f64(int offset) {
    final view = ByteData.sublistView(bytes, start + offset, start + offset + 8);
    return view.getFloat64(0, littleEndian ? Endian.little : Endian.big);
  }

  Uint8List slice(int offset, int count) {
    return Uint8List.sublistView(bytes, start + offset, start + offset + count);
  }
}

// ------------------------------------------------------------------ 字节工具

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

bool _matchesAscii(Uint8List bytes, int start, int end, String text) {
  if (start < 0 || end > bytes.length || start + text.length > end) {
    return false;
  }
  for (var i = 0; i < text.length; i++) {
    if (bytes[start + i] != text.codeUnitAt(i)) return false;
  }
  return true;
}

bool _matchesHeader(Uint8List bytes, int start, int end, List<int> header) {
  if (start < 0 || start + header.length > end) return false;
  for (var i = 0; i < header.length; i++) {
    if (bytes[start + i] != header[i]) return false;
  }
  return true;
}
