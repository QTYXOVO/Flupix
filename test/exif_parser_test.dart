import 'dart:typed_data';

import 'package:flupix/core/exif/exif_data.dart';
import 'package:flupix/core/exif/exif_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('解析 JPEG APP1 中的 EXIF（小端）', () {
    final result = readExif(_wrapJpeg(_buildTiff()));

    expect(result.container, ExifContainer.jpeg);
    expect(result.data, isNotNull);
    final data = result.data!;
    expect(data.littleEndian, isTrue);
    expect(data.tag(ExifGroupKind.image, 0x010F)?.formatted, 'TestCam');
    expect(data.tag(ExifGroupKind.image, 0x0112)?.formatted, 'Rotate 90° CW');
    expect(data.tag(ExifGroupKind.exif, 0x829A)?.formatted, '1/250 s');
    expect(data.tag(ExifGroupKind.exif, 0x829D)?.formatted, 'f/2.8');
    expect(data.tag(ExifGroupKind.exif, 0x8827)?.formatted, '100');
    expect(
      data.tag(ExifGroupKind.exif, 0x9003)?.formatted,
      '2024:05:01 12:00:00',
    );
    expect(data.tag(ExifGroupKind.exif, 0xA434)?.formatted, 'TestLens');
    expect(data.tag(ExifGroupKind.gps, 0x0002)?.formatted, '31° 13′ 41.5″');
    expect(data.tag(ExifGroupKind.gps, 0x0004)?.formatted, '121° 28′ 20″');
    expect(data.tag(ExifGroupKind.gps, 0x0006)?.formatted, '10.5 m');
    expect(data.groups.map((group) => group.kind), [
      ExifGroupKind.image,
      ExifGroupKind.exif,
      ExifGroupKind.gps,
    ]);
  });

  test('大端 TIFF 也能正确解析', () {
    final result = readExif(_buildTiff(littleEndian: false));

    expect(result.container, ExifContainer.tiff);
    final data = result.data;
    expect(data, isNotNull);
    expect(data!.littleEndian, isFalse);
    expect(data.tag(ExifGroupKind.image, 0x0110), isNull);
    expect(data.tag(ExifGroupKind.exif, 0x829A)?.formatted, '1/250 s');
    expect(data.tag(ExifGroupKind.gps, 0x0002)?.formatted, '31° 13′ 41.5″');
  });

  test('解析 PNG eXIf 块', () {
    final result = readExif(_wrapPng(_buildTiff()));

    expect(result.container, ExifContainer.png);
    expect(result.data?.tag(ExifGroupKind.image, 0x010F)?.formatted, 'TestCam');
  });

  test('解析 WebP EXIF 块', () {
    final result = readExif(_wrapWebp(_buildTiff()));

    expect(result.container, ExifContainer.webp);
    expect(result.data?.tag(ExifGroupKind.exif, 0x829D)?.formatted, 'f/2.8');
  });

  test('没有 EXIF 的 JPEG 返回空数据', () {
    final result = readExif(_wrapJpeg(_buildTiff(), withExif: false));

    expect(result.container, ExifContainer.jpeg);
    expect(result.data, isNull);
    expect(result.unsupported, isFalse);
  });

  test('损坏或未知的输入不会抛异常', () {
    final garbage = Uint8List.fromList(List<int>.generate(64, (i) => i * 7));
    final result = readExif(garbage);

    expect(result.container, ExifContainer.unknown);
    expect(result.data, isNull);
    expect(result.unsupported, isTrue);
  });
}

// ------------------------------------------------------------------ 构造测试数据

Uint8List _buildTiff({bool littleEndian = true}) {
  final writer = _ByteWriter(littleEndian: littleEndian);
  final first = littleEndian ? 0x49 : 0x4D;
  writer
    ..u8(first)
    ..u8(first)
    ..u16(42)
    ..u32(8);

  // IFD0
  writer.u16(4);
  final makeEntry = writer.length;
  writer
    ..u16(0x010F)
    ..u16(2)
    ..u32(8)
    ..u32(0);
  writer
    ..u16(0x0112)
    ..u16(3)
    ..u32(1)
    ..u16(6)
    ..u16(0);
  final exifPointer = writer.length;
  writer
    ..u16(0x8769)
    ..u16(4)
    ..u32(1)
    ..u32(0);
  final gpsPointer = writer.length;
  writer
    ..u16(0x8825)
    ..u16(4)
    ..u32(1)
    ..u32(0);
  writer.u32(0);

  final makeData = writer.length;
  writer
    ..ascii('TestCam')
    ..u8(0);

  // Exif IFD
  final exifIfd = writer.length;
  writer.u16(5);
  final exposureEntry = writer.length;
  writer
    ..u16(0x829A)
    ..u16(5)
    ..u32(1)
    ..u32(0);
  final fNumberEntry = writer.length;
  writer
    ..u16(0x829D)
    ..u16(5)
    ..u32(1)
    ..u32(0);
  writer
    ..u16(0x8827)
    ..u16(3)
    ..u32(1)
    ..u16(100)
    ..u16(0);
  final dateEntry = writer.length;
  writer
    ..u16(0x9003)
    ..u16(2)
    ..u32(20)
    ..u32(0);
  final lensEntry = writer.length;
  writer
    ..u16(0xA434)
    ..u16(2)
    ..u32(9)
    ..u32(0);
  writer.u32(0);

  final exposureData = writer.length;
  _rational(writer, 1, 250);
  final fNumberData = writer.length;
  _rational(writer, 28, 10);
  final dateData = writer.length;
  writer
    ..ascii('2024:05:01 12:00:00')
    ..u8(0);
  final lensData = writer.length;
  writer
    ..ascii('TestLens')
    ..u8(0);

  // GPS IFD
  final gpsIfd = writer.length;
  writer.u16(6);
  writer
    ..u16(0x0001)
    ..u16(2)
    ..u32(2)
    ..u8(0x4E)
    ..u8(0)
    ..u8(0)
    ..u8(0);
  final latitudeEntry = writer.length;
  writer
    ..u16(0x0002)
    ..u16(5)
    ..u32(3)
    ..u32(0);
  writer
    ..u16(0x0003)
    ..u16(2)
    ..u32(2)
    ..u8(0x45)
    ..u8(0)
    ..u8(0)
    ..u8(0);
  final longitudeEntry = writer.length;
  writer
    ..u16(0x0004)
    ..u16(5)
    ..u32(3)
    ..u32(0);
  writer
    ..u16(0x0005)
    ..u16(1)
    ..u32(1)
    ..u8(0)
    ..u8(0)
    ..u8(0)
    ..u8(0);
  final altitudeEntry = writer.length;
  writer
    ..u16(0x0006)
    ..u16(5)
    ..u32(1)
    ..u32(0);
  writer.u32(0);

  final latitudeData = writer.length;
  _rational(writer, 31, 1);
  _rational(writer, 13, 1);
  _rational(writer, 415, 10);
  final longitudeData = writer.length;
  _rational(writer, 121, 1);
  _rational(writer, 28, 1);
  _rational(writer, 200, 10);
  final altitudeData = writer.length;
  _rational(writer, 105, 10);

  writer
    ..patchU32(makeEntry + 8, makeData)
    ..patchU32(exifPointer + 8, exifIfd)
    ..patchU32(gpsPointer + 8, gpsIfd)
    ..patchU32(exposureEntry + 8, exposureData)
    ..patchU32(fNumberEntry + 8, fNumberData)
    ..patchU32(dateEntry + 8, dateData)
    ..patchU32(lensEntry + 8, lensData)
    ..patchU32(latitudeEntry + 8, latitudeData)
    ..patchU32(longitudeEntry + 8, longitudeData)
    ..patchU32(altitudeEntry + 8, altitudeData);

  return writer.toBytes();
}

void _rational(_ByteWriter writer, int numerator, int denominator) {
  writer
    ..u32(numerator)
    ..u32(denominator);
}

Uint8List _wrapJpeg(Uint8List tiff, {bool withExif = true}) {
  final writer = _ByteWriter(littleEndian: false)..u8(0xFF)..u8(0xD8);
  if (withExif) {
    writer
      ..u8(0xFF)
      ..u8(0xE1)
      ..u16(tiff.length + 8)
      ..ascii('Exif')
      ..u8(0)
      ..u8(0)
      ..raw(tiff);
  }
  writer
    ..u8(0xFF)
    ..u8(0xDA)
    ..u8(0)
    ..u8(2);
  return writer.toBytes();
}

Uint8List _wrapPng(Uint8List tiff) {
  final writer = _ByteWriter(littleEndian: false)
    ..u8(0x89)
    ..ascii('PNG')
    ..u8(0x0D)
    ..u8(0x0A)
    ..u8(0x1A)
    ..u8(0x0A)
    ..u32(tiff.length)
    ..ascii('eXIf')
    ..raw(tiff)
    ..u32(0);
  return writer.toBytes();
}

Uint8List _wrapWebp(Uint8List tiff) {
  final padded = tiff.length + (tiff.length & 1);
  final writer = _ByteWriter()
    ..ascii('RIFF')
    ..u32(4 + 8 + padded)
    ..ascii('WEBP')
    ..ascii('EXIF')
    ..u32(tiff.length)
    ..raw(tiff);
  if (tiff.length.isOdd) writer.u8(0);
  return writer.toBytes();
}

class _ByteWriter {
  _ByteWriter({this.littleEndian = true});

  final bool littleEndian;
  final List<int> _bytes = [];

  int get length => _bytes.length;

  void u8(int value) => _bytes.add(value & 0xFF);

  void u16(int value) {
    if (littleEndian) {
      u8(value);
      u8(value >> 8);
    } else {
      u8(value >> 8);
      u8(value);
    }
  }

  void u32(int value) {
    for (var i = 0; i < 4; i++) {
      final shift = littleEndian ? 8 * i : 8 * (3 - i);
      u8(value >> shift);
    }
  }

  void ascii(String text) {
    for (final code in text.codeUnits) {
      u8(code);
    }
  }

  void raw(List<int> bytes) => _bytes.addAll(bytes);

  void patchU32(int offset, int value) {
    for (var i = 0; i < 4; i++) {
      final shift = littleEndian ? 8 * i : 8 * (3 - i);
      _bytes[offset + i] = (value >> shift) & 0xFF;
    }
  }

  Uint8List toBytes() => Uint8List.fromList(_bytes);
}
