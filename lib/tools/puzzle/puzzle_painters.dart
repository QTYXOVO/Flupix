import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class CropPainter extends CustomPainter {
  const CropPainter({
    required this.image,
    required this.center,
    required this.zoom,
  });

  final ui.Image image;
  final Offset center;
  final double zoom;

  @override
  void paint(Canvas canvas, Size size) {
    final iw = image.width.toDouble();
    final ih = image.height.toDouble();
    final base = size.width / math.min(iw, ih);
    final eff = base * zoom;
    final dst = Rect.fromLTWH(
      size.width / 2 - center.dx * eff,
      size.height / 2 - center.dy * eff,
      iw * eff,
      ih * eff,
    );

    canvas.save();
    canvas.clipRect(Offset.zero & size);
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, iw, ih),
      dst,
      Paint()..filterQuality = FilterQuality.high,
    );

    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..strokeWidth = 1;
    for (var i = 1; i < 3; i++) {
      final offset = size.width * i / 3;
      canvas.drawLine(
        Offset(offset, 0),
        Offset(offset, size.height),
        linePaint,
      );
      canvas.drawLine(Offset(0, offset), Offset(size.width, offset), linePaint);
    }

    final framePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRect(
      Rect.fromLTWH(0.75, 0.75, size.width - 1.5, size.height - 1.5),
      framePaint,
    );

    final cornerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    const inset = 12.0;
    const length = 22.0;
    final w = size.width;
    final h = size.height;
    final corners = <List<Offset>>[
      [
        Offset(inset, inset + length),
        Offset(inset, inset),
        Offset(inset + length, inset),
      ],
      [
        Offset(w - inset - length, inset),
        Offset(w - inset, inset),
        Offset(w - inset, inset + length),
      ],
      [
        Offset(inset, h - inset - length),
        Offset(inset, h - inset),
        Offset(inset + length, h - inset),
      ],
      [
        Offset(w - inset - length, h - inset),
        Offset(w - inset, h - inset),
        Offset(w - inset, h - inset - length),
      ],
    ];
    for (final path in corners) {
      canvas.drawPath(
        Path()
          ..moveTo(path[0].dx, path[0].dy)
          ..lineTo(path[1].dx, path[1].dy)
          ..lineTo(path[2].dx, path[2].dy),
        cornerPaint,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CropPainter oldDelegate) =>
      oldDelegate.image != image ||
      oldDelegate.center != center ||
      oldDelegate.zoom != zoom;
}

class ImageSlicePainter extends CustomPainter {
  const ImageSlicePainter({required this.image, required this.src});

  final ui.Image image;
  final Rect src;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImageRect(
      image,
      src,
      Offset.zero & size,
      Paint()..filterQuality = FilterQuality.medium,
    );
  }

  @override
  bool shouldRepaint(covariant ImageSlicePainter oldDelegate) =>
      oldDelegate.image != image || oldDelegate.src != src;
}
