import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'puzzle_painters.dart';

class PuzzleTile extends StatelessWidget {
  const PuzzleTile({
    super.key,
    required this.value,
    required this.grid,
    required this.image,
    required this.crop,
    required this.showNumber,
  });

  final int value;
  final int grid;
  final ui.Image? image;
  final Rect? crop;
  final bool showNumber;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final source = image;
    final area = crop;
    final number = value + 1;
    final radius = BorderRadius.circular(12);

    final Widget content;
    if (source != null && area != null) {
      final tileWidth = area.width / grid;
      final tileHeight = area.height / grid;
      final src = Rect.fromLTWH(
        area.left + (value % grid) * tileWidth,
        area.top + (value ~/ grid) * tileHeight,
        tileWidth,
        tileHeight,
      );
      content = CustomPaint(
        painter: ImageSlicePainter(image: source, src: src),
      );
    } else {
      final total = grid * grid - 1;
      final t = total <= 1 ? 0.0 : value / (total - 1);
      final color = Color.lerp(
        scheme.primaryContainer,
        scheme.secondaryContainer,
        t,
      )!;
      content = DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color, Color.lerp(color, scheme.surface, 0.16)!],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: FittedBox(
              child: Text(
                '$number',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          content,
          if (source != null && showNumber)
            Positioned(
              left: 4,
              top: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$number',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class SquarePreview extends StatelessWidget {
  const SquarePreview({
    super.key,
    required this.image,
    required this.crop,
    this.size = 84,
  });

  final ui.Image? image;
  final Rect? crop;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final source = image;
    final area = crop;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
      ),
      clipBehavior: Clip.antiAlias,
      child: source == null || area == null
          ? Icon(
              Icons.image_outlined,
              size: size * 0.4,
              color: scheme.onSurfaceVariant,
            )
          : CustomPaint(
              painter: ImageSlicePainter(image: source, src: area),
            ),
    );
  }
}

class StatPill extends StatelessWidget {
  const StatPill({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: scheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
