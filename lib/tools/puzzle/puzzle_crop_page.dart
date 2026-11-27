import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import 'puzzle_painters.dart';

/// 1:1 裁切页：拖动平移、双指/滚轮/滑块缩放，返回图片坐标系中的裁切矩形。
class PuzzleCropPage extends StatefulWidget {
  const PuzzleCropPage({
    super.key,
    required this.image,
    required this.sourceName,
  });

  final ui.Image image;
  final String sourceName;

  @override
  State<PuzzleCropPage> createState() => PuzzleCropPageState();
}

class PuzzleCropPageState extends State<PuzzleCropPage> {
  static const double _minZoom = 1;
  static const double _maxZoom = 4;

  double _zoom = 1;
  late Offset _center;
  Size _viewport = Size.zero;

  double _startZoom = 1;
  Offset _startCenter = Offset.zero;
  Offset _startFocal = Offset.zero;

  @override
  void initState() {
    super.initState();
    _center = Offset(widget.image.width / 2, widget.image.height / 2);
  }

  double get _baseScale {
    if (_viewport.width <= 0) return 1;
    final shortSide = math.min(
      widget.image.width.toDouble(),
      widget.image.height.toDouble(),
    );
    return _viewport.width / shortSide;
  }

  void _apply({Offset? center, double? zoom}) {
    final side = _viewport.width;
    if (side <= 0) return;
    final nextZoom = (zoom ?? _zoom).clamp(_minZoom, _maxZoom).toDouble();
    final cropSide = side / (_baseScale * nextZoom);
    final half = cropSide / 2;
    final iw = widget.image.width.toDouble();
    final ih = widget.image.height.toDouble();
    final target = center ?? _center;
    setState(() {
      _zoom = nextZoom;
      _center = Offset(
        target.dx.clamp(half, iw - half).toDouble(),
        target.dy.clamp(half, ih - half).toDouble(),
      );
    });
  }

  void _reset() {
    _apply(
      zoom: 1,
      center: Offset(widget.image.width / 2, widget.image.height / 2),
    );
  }

  void _confirm() {
    final side = _viewport.width;
    if (side <= 0) return;
    final cropSide = side / (_baseScale * _zoom);
    Navigator.of(
      context,
    ).pop(Rect.fromCenter(center: _center, width: cropSide, height: cropSide));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(context.l10n.puzzleSelectCrop, style: textTheme.titleLarge),
            Text(
              widget.sourceName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Center(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final side = math.max(
                        0.0,
                        math.min(constraints.maxWidth, constraints.maxHeight),
                      );
                      _viewport = Size.square(side);
                      if (side <= 0) return const SizedBox.shrink();
                      return Listener(
                        onPointerSignal: (event) {
                          if (event is PointerScrollEvent) {
                            final factor = event.scrollDelta.dy > 0
                                ? 0.94
                                : 1.06;
                            _apply(zoom: _zoom * factor);
                          }
                        },
                        child: GestureDetector(
                          onScaleStart: (details) {
                            _startZoom = _zoom;
                            _startCenter = _center;
                            _startFocal = details.localFocalPoint;
                          },
                          onScaleUpdate: (details) {
                            final viewCenter = Offset(side / 2, side / 2);
                            final startEff = _baseScale * _startZoom;
                            // 保持起始焦点下的像素位置跟随手指移动。
                            final focalImage =
                                _startCenter +
                                (_startFocal - viewCenter) / startEff;
                            final nextZoom = (_startZoom * details.scale)
                                .clamp(_minZoom, _maxZoom)
                                .toDouble();
                            final nextEff = _baseScale * nextZoom;
                            final nextCenter =
                                focalImage -
                                (details.localFocalPoint - viewCenter) /
                                    nextEff;
                            _apply(center: nextCenter, zoom: nextZoom);
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: CustomPaint(
                              size: Size.square(side),
                              painter: CropPainter(
                                image: widget.image,
                                center: _center,
                                zoom: _zoom,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            _buildControls(context),
          ],
        ),
      ),
    );
  }

  Widget _buildControls(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.photo_size_select_small,
                size: 18,
                color: scheme.onSurfaceVariant,
              ),
              Expanded(
                child: Slider(
                  value: _zoom,
                  min: _minZoom,
                  max: _maxZoom,
                  divisions: 30,
                  label: '${_zoom.toStringAsFixed(1)}×',
                  onChanged: (value) => _apply(zoom: value),
                ),
              ),
              Icon(
                Icons.photo_size_select_large,
                size: 18,
                color: scheme.onSurfaceVariant,
              ),
            ],
          ),
          Text(
            context.l10n.puzzleCropHint,
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(
              height: 1.4,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _reset,
                  icon: const Icon(Icons.restart_alt, size: 18),
                  label: Text(context.l10n.puzzleReset),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _confirm,
                  icon: const Icon(Icons.check, size: 18),
                  label: Text(context.l10n.puzzleUseArea),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
