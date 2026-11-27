import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../navigation/app_routes.dart';
import '../widgets/ui_kit.dart';
import 'puzzle/puzzle_engine.dart';
import 'puzzle/puzzle_painters.dart';
import 'puzzle/puzzle_widgets.dart';

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
      final crop = await Navigator.of(
        context,
      ).push<Rect>(AppRoutes.puzzleCrop(image: decoded, sourceName: file.name));
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

  void _startGame() {
    final board = generateShuffledBoard(_grid, math.Random());

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
    if (blank < 0 || !puzzleNeighbors(blank, _grid).contains(target)) return;

    setState(() {
      _board[blank] = _board[target];
      _board[target] = blankValue;
      _moves++;
    });
    if (isSolvedBoard(_board, blankValue)) _finishGame();
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
                      painter: ImageSlicePainter(image: image, src: crop),
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
              SquarePreview(image: _image, crop: _crop, size: 84),
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
                StatPill(
                  icon: Icons.touch_app_outlined,
                  label: context.l10n.puzzleMoves,
                  value: '$_moves',
                ),
                const SizedBox(width: 8),
                StatPill(
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
      child: PuzzleTile(
        value: value,
        grid: _grid,
        image: _image,
        crop: _crop,
        showNumber: _showNumbers,
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
