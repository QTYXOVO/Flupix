import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import '../formatters.dart';
import 'exif_data.dart';

/// 标准 TIFF / Exif 标签名（IFD0、Exif、Interop 共用）。
const Map<int, String> _tiffTagNames = {
  0x0100: 'Image Width',
  0x0101: 'Image Height',
  0x0102: 'Bits per Sample',
  0x0103: 'Compression',
  0x0106: 'Photometric Interpretation',
  0x010E: 'Image Description',
  0x010F: 'Make',
  0x0110: 'Model',
  0x0111: 'Strip Offsets',
  0x0112: 'Orientation',
  0x0115: 'Samples per Pixel',
  0x0116: 'Rows per Strip',
  0x0117: 'Strip Byte Counts',
  0x011A: 'X Resolution',
  0x011B: 'Y Resolution',
  0x011C: 'Planar Configuration',
  0x0128: 'Resolution Unit',
  0x012D: 'Transfer Function',
  0x0131: 'Software',
  0x0132: 'Date Time',
  0x013B: 'Artist',
  0x013E: 'White Point',
  0x013F: 'Primary Chromaticities',
  0x014A: 'Sub IFDs',
  0x0156: 'Transfer Function',
  0x0201: 'Thumbnail Offset',
  0x0202: 'Thumbnail Length',
  0x0211: 'YCbCr Coefficients',
  0x0212: 'YCbCr Sub Sampling',
  0x0213: 'YCbCr Positioning',
  0x0214: 'Reference Black White',
  0x02BC: 'XML Packet (XMP)',
  0x8298: 'Copyright',
  0x829A: 'Exposure Time',
  0x829D: 'F Number',
  0x8769: 'Exif IFD Pointer',
  0x8822: 'Exposure Program',
  0x8825: 'GPS IFD Pointer',
  0x8827: 'ISO Speed Ratings',
  0x8830: 'Sensitivity Type',
  0x8831: 'Standard Output Sensitivity',
  0x8832: 'Recommended Exposure Index',
  0x8833: 'ISO Speed',
  0x8834: 'ISO Speed Latitude yyy',
  0x8835: 'ISO Speed Latitude zzz',
  0x9000: 'Exif Version',
  0x9003: 'Date Time Original',
  0x9004: 'Date Time Digitized',
  0x9010: 'Offset Time',
  0x9011: 'Offset Time Original',
  0x9012: 'Offset Time Digitized',
  0x9101: 'Components Configuration',
  0x9102: 'Compressed Bits per Pixel',
  0x9201: 'Shutter Speed Value',
  0x9202: 'Aperture Value',
  0x9203: 'Brightness Value',
  0x9204: 'Exposure Bias Value',
  0x9205: 'Max Aperture Value',
  0x9206: 'Subject Distance',
  0x9207: 'Metering Mode',
  0x9208: 'Light Source',
  0x9209: 'Flash',
  0x920A: 'Focal Length',
  0x9214: 'Subject Area',
  0x927C: 'Maker Note',
  0x9286: 'User Comment',
  0x9290: 'Sub-second Time',
  0x9291: 'Sub-second Time Original',
  0x9292: 'Sub-second Time Digitized',
  0x9C9B: 'XPTitle',
  0x9C9C: 'XPComment',
  0x9C9D: 'XPAuthor',
  0x9C9E: 'XPKeywords',
  0x9C9F: 'XPSubject',
  0xA000: 'Flashpix Version',
  0xA001: 'Color Space',
  0xA002: 'Pixel X Dimension',
  0xA003: 'Pixel Y Dimension',
  0xA004: 'Related Sound File',
  0xA005: 'Interop IFD Pointer',
  0xA20B: 'Flash Energy',
  0xA20E: 'Focal Plane X Resolution',
  0xA20F: 'Focal Plane Y Resolution',
  0xA210: 'Focal Plane Resolution Unit',
  0xA214: 'Subject Location',
  0xA215: 'Exposure Index',
  0xA217: 'Sensing Method',
  0xA300: 'File Source',
  0xA301: 'Scene Type',
  0xA302: 'CFA Pattern',
  0xA401: 'Custom Rendered',
  0xA402: 'Exposure Mode',
  0xA403: 'White Balance',
  0xA404: 'Digital Zoom Ratio',
  0xA405: 'Focal Length in 35 mm Film',
  0xA406: 'Scene Capture Type',
  0xA407: 'Gain Control',
  0xA408: 'Contrast',
  0xA409: 'Saturation',
  0xA40A: 'Sharpness',
  0xA40B: 'Device Setting Description',
  0xA40C: 'Subject Distance Range',
  0xA420: 'Image Unique ID',
  0xA430: 'Camera Owner Name',
  0xA431: 'Body Serial Number',
  0xA432: 'Lens Specification',
  0xA433: 'Lens Make',
  0xA434: 'Lens Model',
  0xA435: 'Lens Serial Number',
  0xA460: 'Composite Image',
  0xA461: 'Source Image Number of Composite Image',
  0xA462: 'Source Exposure Times of Composite Image',
  0xA500: 'Gamma',
  0x0001: 'Interoperability Index',
  0x0002: 'Interoperability Version',
  0x1000: 'Related Image File Format',
  0x1001: 'Related Image Width',
  0x1002: 'Related Image Length',
};

const Map<int, String> _gpsTagNames = {
  0x0000: 'GPS Version ID',
  0x0001: 'GPS Latitude Ref',
  0x0002: 'GPS Latitude',
  0x0003: 'GPS Longitude Ref',
  0x0004: 'GPS Longitude',
  0x0005: 'GPS Altitude Ref',
  0x0006: 'GPS Altitude',
  0x0007: 'GPS Time Stamp',
  0x0008: 'GPS Satellites',
  0x0009: 'GPS Status',
  0x000A: 'GPS Measure Mode',
  0x000B: 'GPS DOP',
  0x000C: 'GPS Speed Ref',
  0x000D: 'GPS Speed',
  0x000E: 'GPS Track Ref',
  0x000F: 'GPS Track',
  0x0010: 'GPS Image Direction Ref',
  0x0011: 'GPS Image Direction',
  0x0012: 'GPS Map Datum',
  0x0013: 'GPS Destination Latitude Ref',
  0x0014: 'GPS Destination Latitude',
  0x0015: 'GPS Destination Longitude Ref',
  0x0016: 'GPS Destination Longitude',
  0x0017: 'GPS Destination Bearing Ref',
  0x0018: 'GPS Destination Bearing',
  0x0019: 'GPS Destination Distance Ref',
  0x001A: 'GPS Destination Distance',
  0x001B: 'GPS Processing Method',
  0x001C: 'GPS Area Information',
  0x001D: 'GPS Date Stamp',
  0x001E: 'GPS Differential',
  0x001F: 'GPS H Positioning Error',
};

String exifTagName(ExifGroupKind kind, int id) {
  final names = kind == ExifGroupKind.gps ? _gpsTagNames : _tiffTagNames;
  return names[id] ?? 'Tag 0x${id.toRadixString(16).padLeft(4, '0').toUpperCase()}';
}

/// 把原始值格式化成便于阅读的文本。
String exifValueText(ExifGroupKind kind, int id, Object? value) {
  if (value == null) return '—';

  if (value is String) return value.isEmpty ? '—' : value;

  if (value is Uint8List) {
    if (_isUtf16TextTag(id)) return _decodeUtf16Le(value);
    if (id == 0x9286 ||
        ((id == 0x001B || id == 0x001C) && kind == ExifGroupKind.gps)) {
      return _decodeUserComment(value);
    }
    if (id == 0x9000 || id == 0xA000) return _decodeAsciiBytes(value);
    if (id == 0x9101) return _decodeComponents(value);
    if (id == 0x0000 && kind == ExifGroupKind.gps) {
      return value.map((byte) => byte.toString()).join('.');
    }
    if (id == 0xA300 || id == 0xA301 || id == 0xA302) {
      return _hexBytes(value);
    }
    if (id == 0x927C) return '${value.length} bytes (binary)';
    return _hexBytes(value, maxBytes: 32);
  }

  if (kind == ExifGroupKind.gps) return _formatGpsValue(id, value);
  if (kind == ExifGroupKind.exif) return _formatExifValue(id, value);
  if (kind == ExifGroupKind.image || kind == ExifGroupKind.thumbnail) {
    return _formatImageValue(id, value);
  }
  return _formatPlain(value);
}

// ------------------------------------------------------------------ 图像 / Exif

String _formatImageValue(int id, Object? value) {
  final number = _singleInt(value);
  switch (id) {
    case 0x0112:
      return _orientation[number] ?? _formatPlain(value);
    case 0x0128:
      return _resolutionUnit[number] ?? _formatPlain(value);
    case 0x0103:
      return _compression[number] ?? _formatPlain(value);
    case 0x0106:
      return _photometric[number] ?? _formatPlain(value);
    case 0x0213:
      return _ycbcrPositioning[number] ?? _formatPlain(value);
    case 0x0102:
      return _formatNumbers(value);
    case 0x0115:
    case 0x0116:
      return _formatPlain(value);
  }
  return _formatPlain(value);
}

String _formatExifValue(int id, Object? value) {
  final number = _singleInt(value);
  switch (id) {
    case 0x829A:
      return _formatShutter(_singleDouble(value));
    case 0x829D:
      return _formatAperture(_singleDouble(value));
    case 0x9201:
      return _formatShutterFromApex(_singleDouble(value));
    case 0x9202:
    case 0x9205:
      return _formatApertureFromApex(_singleDouble(value));
    case 0x9203:
      final brightness = _singleDouble(value);
      return brightness == null || !brightness.isFinite
          ? '—'
          : '${_num(brightness, digits: 2)} EV';
    case 0x9204:
      return _formatBias(_singleDouble(value));
    case 0x9206:
      return _formatMeters(_singleDouble(value));
    case 0x9207:
      return _meteringMode[number] ?? _formatPlain(value);
    case 0x9208:
      return _lightSource[number] ?? _formatPlain(value);
    case 0x9209:
      return number == null ? _formatPlain(value) : _flash(number);
    case 0x920A:
      return _formatMillimeters(_singleDouble(value));
    case 0x8822:
      return _exposureProgram[number] ?? _formatPlain(value);
    case 0xA001:
      return _colorSpace[number] ?? _formatPlain(value);
    case 0xA405:
      return number == null ? _formatPlain(value) : '$number mm';
    case 0xA404:
      final ratio = _singleDouble(value);
      return ratio == null || !ratio.isFinite
          ? '—'
          : '${_num(ratio, digits: 2)}×';
    case 0xA217:
      return _sensingMethod[number] ?? _formatPlain(value);
    case 0xA401:
      return _customRendered[number] ?? _formatPlain(value);
    case 0xA402:
      return _exposureMode[number] ?? _formatPlain(value);
    case 0xA403:
      return _whiteBalance[number] ?? _formatPlain(value);
    case 0xA406:
      return _sceneCapture[number] ?? _formatPlain(value);
    case 0xA407:
      return _gainControl[number] ?? _formatPlain(value);
    case 0xA408:
    case 0xA409:
    case 0xA40A:
      return _normalLowHigh[number] ?? _formatPlain(value);
    case 0xA40C:
      return _subjectDistanceRange[number] ?? _formatPlain(value);
    case 0x9101:
      return value is Uint8List ? _decodeComponents(value) : _formatPlain(value);
    case 0x9214:
    case 0xA214:
      return _formatNumbers(value);
  }
  return _formatPlain(value);
}

String _formatGpsValue(int id, Object? value) {
  final number = _singleInt(value);
  switch (id) {
    case 0x0002:
    case 0x0004:
    case 0x0014:
    case 0x0016:
      return _formatDms(value);
    case 0x0005:
      return switch (number) {
        0 => 'Above sea level',
        1 => 'Below sea level',
        _ => _formatPlain(value),
      };
    case 0x0006:
      return _formatMeters(_singleDouble(value));
    case 0x0007:
      return _formatGpsTime(value);
    case 0x0009:
      return switch (_stringValue(value)) {
        'A' => 'Measurement in progress',
        'V' => 'Measurement interrupted',
        _ => _formatPlain(value),
      };
    case 0x000A:
      return switch (_stringValue(value)) {
        '2' => '2-D measurement',
        '3' => '3-D measurement',
        _ => _formatPlain(value),
      };
    case 0x000C:
      return _gpsSpeedRef[_stringValue(value)] ?? _formatPlain(value);
    case 0x000E:
    case 0x0010:
    case 0x0017:
      return switch (_stringValue(value)) {
        'T' => 'True direction',
        'M' => 'Magnetic direction',
        _ => _formatPlain(value),
      };
    case 0x0019:
      return switch (_stringValue(value)) {
        'K' => 'Kilometers',
        'M' => 'Miles',
        'N' => 'Nautical miles',
        _ => _formatPlain(value),
      };
    case 0x001B:
    case 0x001C:
      return value is Uint8List
          ? _decodeUserComment(value)
          : _formatPlain(value);
    case 0x001E:
      return switch (number) {
        0 => 'No correction',
        1 => 'Differential corrected',
        _ => _formatPlain(value),
      };
    case 0x001F:
      return _formatMeters(_singleDouble(value));
  }
  return _formatPlain(value);
}

// -------------------------------------------------------------------- 数值格式化

String _formatPlain(Object? value) {
  if (value is ExifRational) return _num(value.value, digits: 4);
  if (value is int) return '$value';
  if (value is double) return _num(value, digits: 4);
  if (value is List<ExifRational>) {
    return value.map((item) => _num(item.value, digits: 4)).join(', ');
  }
  if (value is List<double>) {
    return value.map((item) => _num(item, digits: 4)).join(', ');
  }
  if (value is Uint8List) return _hexBytes(value, maxBytes: 32);
  if (value is List<int>) return value.join(', ');
  return '$value';
}

String _formatNumbers(Object? value) {
  if (value is int) return '$value';
  if (value is List<int>) return value.join(', ');
  return _formatPlain(value);
}

String _formatShutter(double? seconds) {
  if (seconds == null || !seconds.isFinite || seconds <= 0) return '—';
  if (seconds >= 1) return '${_num(seconds, digits: 3)} s';
  return '1/${(1 / seconds).round()} s';
}

String _formatShutterFromApex(double? apex) {
  if (apex == null || !apex.isFinite) return '—';
  return _formatShutter(math.pow(2, -apex).toDouble());
}

String _formatAperture(double? fNumber) {
  if (fNumber == null || !fNumber.isFinite) return '—';
  return 'f/${_num(fNumber, digits: 2)}';
}

String _formatApertureFromApex(double? apex) {
  if (apex == null || !apex.isFinite) return '—';
  return _formatAperture(math.pow(2, apex / 2).toDouble());
}

String _formatBias(double? value) {
  if (value == null || !value.isFinite) return '—';
  final text = _num(value, digits: 2);
  if (value > 0) return '+$text EV';
  return '$text EV';
}

String _formatMillimeters(double? value) {
  if (value == null || !value.isFinite) return '—';
  return '${_num(value, digits: 2)} mm';
}

String _formatMeters(double? value) {
  if (value == null || !value.isFinite) return '—';
  return '${_num(value, digits: 2)} m';
}

String _formatDms(Object? value) {
  if (value is! List<ExifRational> || value.isEmpty) return _formatPlain(value);
  final degrees = value[0].value;
  final minutes = value.length > 1 ? value[1].value : 0.0;
  final seconds = value.length > 2 ? value[2].value : 0.0;
  final buffer = StringBuffer('${_num(degrees, digits: 6)}°');
  if (value.length > 1) buffer.write(' ${_num(minutes, digits: 2)}′');
  if (value.length > 2) buffer.write(' ${_num(seconds, digits: 2)}″');
  return buffer.toString();
}

String _formatGpsTime(Object? value) {
  if (value is! List<ExifRational> || value.length < 3) {
    return _formatPlain(value);
  }
  final hour = value[0].value.floor();
  final minute = value[1].value.floor();
  final second = value[2].value.floor();
  return '${twoDigits(hour)}:${twoDigits(minute)}:${twoDigits(second)} UTC';
}

String _num(double value, {int digits = 4}) {
  if (!value.isFinite) return '—';
  return formatNumber(value, precision: digits + 2);
}

int? _singleInt(Object? value) {
  if (value is int) return value;
  if (value is Uint8List && value.length == 1) return value.first;
  if (value is List<int> && value.length == 1) return value.first;
  return null;
}

double? _singleDouble(Object? value) {
  if (value is ExifRational) return value.value;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is List<ExifRational> && value.length == 1) return value.first.value;
  if (value is List<double> && value.length == 1) return value.first;
  return null;
}

String? _stringValue(Object? value) => value is String ? value : null;

// ------------------------------------------------------------------ 二进制文本

bool _isUtf16TextTag(int id) =>
    id == 0x9C9B || id == 0x9C9C || id == 0x9C9D || id == 0x9C9E || id == 0x9C9F;

String _decodeAsciiBytes(Uint8List bytes) {
  final text = String.fromCharCodes(bytes).replaceAll('\u0000', '').trim();
  return text.isEmpty ? '—' : text;
}

String _decodeUtf16Le(Uint8List bytes) {
  final buffer = StringBuffer();
  for (var i = 0; i + 1 < bytes.length; i += 2) {
    final code = bytes[i] | (bytes[i + 1] << 8);
    if (code == 0) continue;
    buffer.writeCharCode(code);
  }
  final text = buffer.toString().trim();
  return text.isEmpty ? '—' : text;
}

/// UserComment / GPSProcessingMethod 带有 8 字节字符集前缀。
String _decodeUserComment(Uint8List bytes) {
  if (bytes.isEmpty) return '—';
  final prefixLength = math.min(8, bytes.length);
  final prefix = latin1.decode(bytes.sublist(0, prefixLength));
  final body = bytes.length > 8 ? bytes.sublist(8) : Uint8List(0);
  String text;
  if (prefix.startsWith('UNICODE')) {
    final buffer = StringBuffer();
    for (var i = 0; i + 1 < body.length; i += 2) {
      final code = (body[i] << 8) | body[i + 1];
      if (code == 0) continue;
      buffer.writeCharCode(code);
    }
    text = buffer.toString();
  } else if (prefix.startsWith('JIS')) {
    text = latin1.decode(body, allowInvalid: true);
  } else {
    text = utf8.decode(body, allowMalformed: true);
  }
  text = text.replaceAll('\u0000', '').trim();
  return text.isEmpty ? '—' : text;
}

String _decodeComponents(Uint8List bytes) {
  const names = {0: '-', 1: 'Y', 2: 'Cb', 3: 'Cr', 4: 'R', 5: 'G', 6: 'B'};
  final parts = bytes.map((byte) => names[byte] ?? '$byte').toList();
  return parts.join(', ');
}

String _hexBytes(Uint8List bytes, {int maxBytes = 16}) {
  final shown = bytes.length <= maxBytes ? bytes : bytes.sublist(0, maxBytes);
  final hex = shown
      .map((byte) => byte.toRadixString(16).padLeft(2, '0').toUpperCase())
      .join(' ');
  return bytes.length > maxBytes ? '$hex … (${bytes.length} bytes)' : hex;
}

// ---------------------------------------------------------------------- 枚举表

const Map<int, String> _orientation = {
  1: 'Horizontal (normal)',
  2: 'Mirror horizontal',
  3: 'Rotate 180°',
  4: 'Mirror vertical',
  5: 'Mirror horizontal, rotate 270° CW',
  6: 'Rotate 90° CW',
  7: 'Mirror horizontal, rotate 90° CW',
  8: 'Rotate 270° CW',
};

const Map<int, String> _resolutionUnit = {1: 'None', 2: 'Inch', 3: 'Centimeter'};

const Map<int, String> _compression = {
  1: 'Uncompressed',
  2: 'CCITT 1D',
  3: 'T4 / Group 3 Fax',
  4: 'T6 / Group 4 Fax',
  5: 'LZW',
  6: 'JPEG (old-style)',
  7: 'JPEG',
  8: 'Deflate',
  32773: 'PackBits',
  34892: 'Lossy JPEG',
};

const Map<int, String> _photometric = {
  0: 'White is zero',
  1: 'Black is zero',
  2: 'RGB',
  3: 'Palette color',
  4: 'Transparency mask',
  5: 'CMYK',
  6: 'YCbCr',
};

const Map<int, String> _ycbcrPositioning = {1: 'Centered', 2: 'Co-sited'};

const Map<int, String> _exposureProgram = {
  0: 'Not defined',
  1: 'Manual',
  2: 'Normal program',
  3: 'Aperture priority',
  4: 'Shutter priority',
  5: 'Creative program',
  6: 'Action program',
  7: 'Portrait mode',
  8: 'Landscape mode',
};

const Map<int, String> _meteringMode = {
  0: 'Unknown',
  1: 'Average',
  2: 'Center-weighted average',
  3: 'Spot',
  4: 'Multi-spot',
  5: 'Multi-segment',
  6: 'Partial',
  255: 'Other',
};

const Map<int, String> _lightSource = {
  0: 'Unknown',
  1: 'Daylight',
  2: 'Fluorescent',
  3: 'Tungsten (incandescent)',
  4: 'Flash',
  9: 'Fine weather',
  10: 'Cloudy',
  11: 'Shade',
  12: 'Daylight fluorescent',
  13: 'Day white fluorescent',
  14: 'Cool white fluorescent',
  15: 'White fluorescent',
  17: 'Standard light A',
  18: 'Standard light B',
  19: 'Standard light C',
  20: 'D55',
  21: 'D65',
  22: 'D75',
  23: 'D50',
  24: 'ISO studio tungsten',
  255: 'Other',
};

const Map<int, String> _colorSpace = {1: 'sRGB', 65535: 'Uncalibrated'};

const Map<int, String> _sensingMethod = {
  1: 'Not defined',
  2: 'One-chip color area',
  3: 'Two-chip color area',
  4: 'Three-chip color area',
  5: 'Color sequential area',
  7: 'Trilinear',
  8: 'Color sequential linear',
};

const Map<int, String> _customRendered = {0: 'Normal', 1: 'Custom'};

const Map<int, String> _exposureMode = {
  0: 'Auto',
  1: 'Manual',
  2: 'Auto bracket',
};

const Map<int, String> _whiteBalance = {0: 'Auto', 1: 'Manual'};

const Map<int, String> _sceneCapture = {
  0: 'Standard',
  1: 'Landscape',
  2: 'Portrait',
  3: 'Night scene',
};

const Map<int, String> _gainControl = {
  0: 'None',
  1: 'Low gain up',
  2: 'High gain up',
  3: 'Low gain down',
  4: 'High gain down',
};

const Map<int, String> _normalLowHigh = {0: 'Normal', 1: 'Low', 2: 'High'};

const Map<int, String> _subjectDistanceRange = {
  0: 'Unknown',
  1: 'Macro',
  2: 'Close',
  3: 'Distant',
};

const Map<String, String> _gpsSpeedRef = {
  'K': 'Kilometers per hour',
  'M': 'Miles per hour',
  'N': 'Knots',
};

/// Flash 是位标志，按规范逐位解释。
String _flash(int value) {
  final parts = <String>[(value & 0x01) != 0 ? 'Fired' : 'Did not fire'];
  switch ((value >> 1) & 0x03) {
    case 2:
      parts.add('Return light not detected');
    case 3:
      parts.add('Return light detected');
  }
  switch ((value >> 3) & 0x03) {
    case 1:
      parts.add('On');
    case 2:
      parts.add('Off');
    case 3:
      parts.add('Auto');
  }
  if ((value & 0x20) != 0) parts.add('No flash function');
  if ((value & 0x40) != 0) parts.add('Red-eye reduction');
  return parts.join(', ');
}
