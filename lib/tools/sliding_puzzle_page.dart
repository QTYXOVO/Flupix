import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../widgets/ui_kit.dart';

/// 解码图片时的最大边长，避免超大照片占用过多内存。
const int _kMaxImageSide = 2400;

/// 数字华容道：经典数字模式，或导入自定义图片（手动选择 1:1 裁切区域）。
class SlidingPuzzlePage extends StatefulWidget {
  const SlidingPuzzlePage({super.key});

  @override
  State<SlidingPuzzlePage> createState() => _SlidingPuzzlePageState();
}

class _SlidingPuzzlePageState extends State<SlidingPuzzlePage> {
  ui.Image? _image;
  Rect? _crop;
  String? _imageName;

  int _grid = 4;
  List<int> _board = const <int>[];
  int _gameId = 0;
  int _moves = 0;
  bool _playing = false;
  bool _solved = false;
  bool _showNumbers = true;
  bool _busy = false;

  final Stopwatch _stopwatch = Stopwatch();
  Timer? _ticker;

  @override
  void dispose() {
    _ticker?.cancel();
    _stopwatch.stop();
    _image?.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------- 图片导入

  Future<void> _pickImage() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final file = await FilePicker.pickFile(
        dialogTitle: context.l10n.puzzleSelectImage,
        type: FileType.image,
      );
      if (file == null) return;
      final decoded = await _decodeImage(await file.readAsBytes());
      if (!mounted) {
        decoded.dispose();
        return;
      }
      final crop = await Navigator.of(context).push<Rect>(
        MaterialPageRoute<Rect>(
          builder: (_) => _CropPage(image: decoded, sourceName: file.name),
        ),
      );
      if (!mounted) {
        decoded.dispose();
        return;
      }
      if (crop == null) {
        decoded.dispose();
        return;
      }
      setState(() {
        _image?.dispose();
        _image = decoded;
        _crop = crop;
        _imageName = file.name;
        _playing = false;
        _solved = false;
      });
    } catch (error) {
      if (mounted) _notify(context.l10n.puzzleImportFailed('$error'));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _removeImage() {
    setState(() {
      _image?.dispose();
      _image = null;
      _crop = null;
      _imageName = null;
    });
  }

  // ------------------------------------------------------------------ 游戏逻辑

  List<int> _neighbors(int index, int grid) {
    final row = index ~/ grid;
    final col = index % grid;
    return <int>[
      if (row > 0) index - grid,
      if (row < grid - 1) index + grid,
      if (col > 0) index - 1,
      if (col < grid - 1) index + 1,
    ];
  }

  bool _isSolvedBoard(List<int> board, int blankValue) {
    for (var i = 0; i < board.length - 1; i++) {
      if (board[i] != i) return false;
    }
    return board.isNotEmpty && board.last == blankValue;
  }

  void _startGame() {
    final total = _grid * _grid;
    final blankValue = total - 1;
    final random = math.Random();
    final board = List<int>.generate(total, (index) => index);

    // 从已完成状态出发随机滑动，保证生成的局面一定有解。
    var blank = blankValue;
    var previous = -1;
    for (var i = 0; i < total * 40; i++) {
      final candidates = _neighbors(blank, _grid);
      if (previous >= 0) candidates.remove(previous);
      if (candidates.isEmpty) {
        previous = -1;
        continue;
      }
      final next = candidates[random.nextInt(candidates.length)];
      board[blank] = board[next];
      board[next] = blankValue;
      previous = blank;
      blank = next;
    }
    if (_isSolvedBoard(board, blankValue)) {
      final next = _neighbors(blank, _grid).first;
      board[blank] = board[next];
      board[next] = blankValue;
    }

    _ticker?.cancel();
    setState(() {
      _board = board;
      _gameId++;
      _moves = 0;
      _solved = false;
      _playing = true;
    });
    _stopwatch
      ..reset()
      ..start();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  void _handleTap(Offset position, double boardSize) {
    if (!_playing || _solved) return;
    final cell = boardSize / _grid;
    final col = math.min(_grid - 1, math.max(0, (position.dx / cell).floor()));
    final row = math.min(_grid - 1, math.max(0, (position.dy / cell).floor()));
    final target = row * _grid + col;
    final blankValue = _grid * _grid - 1;
    final blank = _board.indexOf(blankValue);
    if (blank < 0 || !_neighbors(blank, _grid).contains(target)) return;

    setState(() {
      _board[blank] = _board[target];
      _board[target] = blankValue;
      _moves++;
    });
    if (_isSolvedBoard(_board, blankValue)) _finishGame();
  }

  void _finishGame() {
    _ticker?.cancel();
    _ticker = null;
    _stopwatch.stop();
    setState(() => _solved = true);
    WidgetsBinding.instance.addPostFrameCallback((_) => _showWinDialog());
  }

  Future<void> _showWinDialog() async {
    if (!mounted) return;
    final elapsed = _formatDuration(_stopwatch.elapsed);
    final moves = _moves;
    final again = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.auto_awesome),
        title: Text(context.l10n.puzzleSolvedTitle),
        content: Text(context.l10n.puzzleSolvedStats(elapsed, moves)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(context.l10n.puzzleBackToSetup),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(context.l10n.puzzlePlayAgain),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (again == true) {
      _startGame();
    } else {
      _stopGame();
      setState(() => _playing = false);
    }
  }

  void _stopGame() {
    _ticker?.cancel();
    _ticker = null;
    _stopwatch.stop();
  }

  void _quitToSetup() {
    _stopGame();
    setState(() {
      _playing = false;
      _solved = false;
    });
  }

  Future<void> _showOriginal() async {
    final image = _image;
    final crop = _crop;
    if (image == null || crop == null) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 320,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CustomPaint(
                      painter: _ImageSlicePainter(image: image, src: crop),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(context.l10n.commonClose),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _notify(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  // -------------------------------------------------------------------- UI

  @override
  Widget build(BuildContext context) {
    return ToolPage(
      title: context.l10n.puzzleTitle,
      subtitle: _playing
          ? context.l10n.puzzleSubtitlePlaying
          : context.l10n.puzzleSubtitleSetup,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: _playing ? _buildGame(context) : _buildSetup(context),
      ),
    );
  }

  Widget _buildSetup(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      key: const ValueKey<String>('setup'),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        SectionCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SquarePreview(image: _image, crop: _crop, size: 84),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _image == null
                          ? context.l10n.puzzleClassicMode
                          : (_imageName ?? context.l10n.puzzleCustomImage),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _image == null
                          ? context.l10n.puzzlePickImageHint
                          : context.l10n.puzzleCropSavedHint,
                      style: textTheme.bodySmall?.copyWith(
                        height: 1.4,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilledButton.tonalIcon(
                          onPressed: _busy ? null : _pickImage,
                          icon: _busy
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(
                                  Icons.add_photo_alternate_outlined,
                                  size: 18,
                                ),
                          label: Text(
                            _busy
                                ? context.l10n.puzzleImporting
                                : (_image == null
                                      ? context.l10n.puzzleSelectImage
                                      : context.l10n.puzzleChangeImage),
                          ),
                        ),
                        if (_image != null)
                          TextButton.icon(
                            onPressed: _removeImage,
                            icon: const Icon(Icons.delete_outline, size: 18),
                            label: Text(context.l10n.commonRemove),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.l10n.puzzleDifficulty, style: textTheme.titleSmall),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<int>(
                  segments: const [
                    ButtonSegment<int>(value: 3, label: Text('3 × 3')),
                    ButtonSegment<int>(value: 4, label: Text('4 × 4')),
                    ButtonSegment<int>(value: 5, label: Text('5 × 5')),
                  ],
                  selected: <int>{_grid},
                  showSelectedIcon: false,
                  onSelectionChanged: (values) =>
                      setState(() => _grid = values.first),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                context.l10n.puzzleDifficultyHint,
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SectionCard(
          color: scheme.secondaryContainer,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.lightbulb_outline,
                size: 20,
                color: scheme.onSecondaryContainer,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  context.l10n.puzzleHowToPlay,
                  style: textTheme.bodySmall?.copyWith(
                    height: 1.5,
                    color: scheme.onSecondaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: _startGame,
          icon: const Icon(Icons.play_arrow_rounded),
          label: Text(context.l10n.puzzleStartGame),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            textStyle: textTheme.titleMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildGame(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return LayoutBuilder(
      key: const ValueKey<String>('game'),
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final boardSize = math.max(180.0, math.min(width - 40, 520.0));
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Row(
              children: [
                _StatPill(
                  icon: Icons.touch_app_outlined,
                  label: context.l10n.puzzleMoves,
                  value: '$_moves',
                ),
                const SizedBox(width: 8),
                _StatPill(
                  icon: Icons.timer_outlined,
                  label: context.l10n.puzzleTime,
                  value: _formatDuration(_stopwatch.elapsed),
                ),
                const Spacer(),
                if (_image != null)
                  IconButton.filledTonal(
                    tooltip: context.l10n.puzzleViewOriginal,
                    onPressed: _showOriginal,
                    icon: const Icon(Icons.image_outlined),
                  ),
                const SizedBox(width: 4),
                IconButton.filledTonal(
                  tooltip: context.l10n.puzzleShuffle,
                  onPressed: _startGame,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: SizedBox(
                width: boardSize,
                height: boardSize,
                child: _buildBoard(boardSize),
              ),
            ),
            const SizedBox(height: 16),
            SectionCard(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              child: Row(
                children: [
                  Expanded(
                    child: SwitchListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                      title: Text(context.l10n.puzzleShowNumbers),
                      value: _showNumbers,
                      onChanged: (value) =>
                          setState(() => _showNumbers = value),
                    ),
                  ),
                  TextButton(
                    onPressed: _quitToSetup,
                    child: Text(
                      _image == null
                          ? context.l10n.puzzleBackToSetup
                          : context.l10n.puzzleChangeImage,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _solved
                  ? context.l10n.puzzleSolvedHint
                  : context.l10n.puzzleSlideHint,
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBoard(double size) {
    final scheme = Theme.of(context).colorScheme;
    const gap = 4.0;
    final cell = size / _grid;
    final blankValue = _grid * _grid - 1;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapUp: (details) => _handleTap(details.localPosition, size),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(18),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          key: ValueKey<int>(_gameId),
          children: [
            for (var value = 0; value < blankValue; value++)
              _buildTile(value, cell, gap),
          ],
        ),
      ),
    );
  }

  Widget _buildTile(int value, double cell, double gap) {
    final position = _board.indexOf(value);
    final row = position ~/ _grid;
    final col = position % _grid;
    return AnimatedPositioned(
      key: ValueKey<int>(value),
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOutCubic,
      left: col * cell + gap / 2,
      top: row * cell + gap / 2,
      width: cell - gap,
      height: cell - gap,
      child: _PuzzleTile(
        value: value,
        grid: _grid,
        image: _image,
        crop: _crop,
        showNumber: _showNumbers,
      ),
    );
  }
}

// ---------------------------------------------------------------------- 裁剪页

/// 1:1 裁切页：拖动平移、双指/滚轮/滑块缩放，返回图片坐标系中的裁切矩形。
class _CropPage extends StatefulWidget {
  const _CropPage({required this.image, required this.sourceName});

  final ui.Image image;
  final String sourceName;

  @override
  State<_CropPage> createState() => _CropPageState();
}

class _CropPageState extends State<_CropPage> {
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
                              painter: _CropPainter(
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

// ---------------------------------------------------------------------- 绘制

class _CropPainter extends CustomPainter {
  const _CropPainter({
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
  bool shouldRepaint(covariant _CropPainter oldDelegate) =>
      oldDelegate.image != image ||
      oldDelegate.center != center ||
      oldDelegate.zoom != zoom;
}

class _ImageSlicePainter extends CustomPainter {
  const _ImageSlicePainter({required this.image, required this.src});

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
  bool shouldRepaint(covariant _ImageSlicePainter oldDelegate) =>
      oldDelegate.image != image || oldDelegate.src != src;
}

// ---------------------------------------------------------------------- 组件

class _PuzzleTile extends StatelessWidget {
  const _PuzzleTile({
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
        painter: _ImageSlicePainter(image: source, src: src),
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

class _SquarePreview extends StatelessWidget {
  const _SquarePreview({
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
              painter: _ImageSlicePainter(image: source, src: area),
            ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
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

// ---------------------------------------------------------------------- 工具函数

String _formatDuration(Duration duration) {
  final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  if (duration.inHours > 0) {
    return '${duration.inHours}:$minutes:$seconds';
  }
  return '$minutes:$seconds';
}

/// 使用 ImageDescriptor 先读取尺寸再按比例解码，避免超大图片占满内存。
Future<ui.Image> _decodeImage(Uint8List bytes) async {
  final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
  final descriptor = await ui.ImageDescriptor.encoded(buffer);
  final maxSide = math.max(descriptor.width, descriptor.height);
  final scale = maxSide > _kMaxImageSide ? _kMaxImageSide / maxSide : 1.0;
  final codec = await descriptor.instantiateCodec(
    targetWidth: math.max(1, (descriptor.width * scale).round()),
    targetHeight: math.max(1, (descriptor.height * scale).round()),
  );
  final frame = await codec.getNextFrame();
  codec.dispose();
  descriptor.dispose();
  buffer.dispose();
  return frame.image;
}
