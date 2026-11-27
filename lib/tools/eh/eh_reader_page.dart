import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../../core/eh/eh_exceptions.dart';
import '../../core/eh/eh_image.dart';
import '../../core/eh/eh_models.dart';
import '../../core/eh/eh_repository.dart';
import '../../core/platform_capabilities.dart';
import '../../l10n/l10n.dart';
import 'eh_reader_controller.dart';

/// 全屏阅读器：PhotoView 翻页、缩放、进度条与限流提示。
class EhReaderPage extends StatefulWidget {
  const EhReaderPage({
    super.key,
    required this.repository,
    required this.item,
    required this.detail,
    required this.totalPages,
    required this.initialIndex,
    this.localPagePath,
  });

  final EhRepository repository;
  final GalleryItem item;
  final GalleryDetail detail;
  final int totalPages;
  final int initialIndex;

  /// 已下载页面返回本地文件路径，优先于网络图片。
  final String? Function(int index)? localPagePath;

  @override
  State<EhReaderPage> createState() => _EhReaderPageState();
}

class _EhReaderPageState extends State<EhReaderPage> {
  late final EhReaderController _controller;
  late final PageController _pageController;
  bool _showBars = true;
  bool _rtl = false;
  double? _dragValue;
  Timer? _tickTimer;

  @override
  void initState() {
    super.initState();
    _controller = EhReaderController(
      repository: widget.repository,
      item: widget.item,
      detail: widget.detail,
      totalPages: widget.totalPages,
      initialIndex: widget.initialIndex,
      localPagePath: widget.localPagePath,
    );
    _controller.addListener(_onControllerChanged);
    _pageController = PageController(initialPage: widget.initialIndex);
    if (AppCapabilities.usesImmersiveSystemUi) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }
  }

  void _onControllerChanged() {
    if (!mounted) return;
    setState(() {});
    if (_controller.rateLimitedUntil != null && _tickTimer == null) {
      _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() {});
        if (_controller.rateLimitSeconds <= 0) {
          _tickTimer?.cancel();
          _tickTimer = null;
        }
      });
    }
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    _controller
      ..removeListener(_onControllerChanged)
      ..dispose();
    _pageController.dispose();
    if (AppCapabilities.usesImmersiveSystemUi) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
    super.dispose();
  }

  void _toggleBars() {
    setState(() => _showBars = !_showBars);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Stack(
            children: [
              Positioned.fill(child: _buildGallery()),
              _buildTopBar(),
              _buildBottomBar(),
              if (_controller.rateLimitSeconds > 0) _buildRateBanner(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGallery() {
    return PhotoViewGallery.builder(
      itemCount: widget.totalPages,
      pageController: _pageController,
      reverse: _rtl,
      gaplessPlayback: true,
      scrollPhysics: const BouncingScrollPhysics(),
      backgroundDecoration: const BoxDecoration(color: Colors.black),
      onPageChanged: _controller.setCurrentPage,
      loadingBuilder: (context, progress) {
        final value = progress?.expectedTotalBytes == null
            ? null
            : progress!.cumulativeBytesLoaded / progress.expectedTotalBytes!;
        return Center(
          child: SizedBox(
            width: 26,
            height: 26,
            child: CircularProgressIndicator(
              value: value,
              strokeWidth: 2,
              color: Colors.white70,
            ),
          ),
        );
      },
      builder: (context, index) {
        final localPath = widget.localPagePath?.call(index);
        if (localPath != null) {
          return PhotoViewGalleryPageOptions(
            imageProvider: FileImage(File(localPath)),
            initialScale: PhotoViewComputedScale.contained,
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.contained * 3,
            filterQuality: FilterQuality.medium,
            onTapUp: (context, details, controller) => _toggleBars(),
            errorBuilder: (context, error, stackTrace) {
              return _buildErrorPage(
                index,
                context.l10n.ehReaderLocalImageFailed,
              );
            },
          );
        }
        final page = _controller.pageAt(index);
        if (page != null && page.imageUrl.isNotEmpty) {
          return PhotoViewGalleryPageOptions(
            imageProvider: EhImageProvider(
              client: widget.repository.client,
              url: page.imageUrl,
              referer: page.pageUrl,
            ),
            initialScale: PhotoViewComputedScale.contained,
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.contained * 3,
            filterQuality: FilterQuality.medium,
            onTapUp: (context, details, controller) => _toggleBars(),
            errorBuilder: (context, error, stackTrace) {
              return _buildErrorPage(
                index,
                error is EhException
                    ? error.message
                    : context.l10n.ehReaderImageFailed,
              );
            },
          );
        }

        final error = _controller.errorAt(index);
        if (error != null) {
          return PhotoViewGalleryPageOptions.customChild(
            child: _buildErrorPage(index, error),
            onTapUp: (context, details, controller) => _toggleBars(),
          );
        }

        return PhotoViewGalleryPageOptions.customChild(
          child: const Center(
            child: SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white70,
              ),
            ),
          ),
          onTapUp: (context, details, controller) => _toggleBars(),
        );
      },
    );
  }

  Widget _buildErrorPage(int index, String message) {
    final l10n = context.l10n;
    final canRestart = message.contains('pToken') || message.contains('第一页');
    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.broken_image_outlined,
            color: Colors.white54,
            size: 44,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          FilledButton.tonal(
            onPressed: () => _controller.retry(index),
            child: Text(l10n.commonRetry),
          ),
          if (canRestart) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: _restartFromFirstPage,
              child: Text(l10n.ehReaderRestartFromFirstPage),
            ),
          ],
        ],
      ),
    );
  }

  /// pToken 补全失败时，回到第一页重新建立预览映射。
  void _restartFromFirstPage() {
    if (widget.totalPages <= 0) return;
    _pageController.jumpToPage(0);
    _controller.setCurrentPage(0);
  }

  Widget _buildTopBar() {
    final l10n = context.l10n;
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      top: _showBars ? 0 : -120,
      left: 0,
      right: 0,
      child: Container(
        color: Colors.black54,
        child: SafeArea(
          bottom: false,
          child: Row(
            children: [
              IconButton(
                tooltip: l10n.commonBack,
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              Expanded(
                child: Text(
                  widget.item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '${_controller.currentIndex + 1}/${widget.totalPages}',
                style: const TextStyle(color: Colors.white70),
              ),
              IconButton(
                tooltip: _rtl ? l10n.ehReaderLtr : l10n.ehReaderRtl,
                onPressed: () => setState(() => _rtl = !_rtl),
                icon: Icon(
                  Icons.swap_horiz,
                  color: _rtl ? Colors.white : Colors.white54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    final total = widget.totalPages;
    final current = _controller.currentIndex + 1;
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      bottom: _showBars ? 0 : -160,
      left: 0,
      right: 0,
      child: Container(
        color: Colors.black54,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (total > 1)
                  Row(
                    children: [
                      Text(
                        '$current',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      Expanded(
                        child: SliderTheme(
                          data: SliderThemeData(
                            activeTrackColor: Colors.white,
                            inactiveTrackColor: Colors.white24,
                            thumbColor: Colors.white,
                            overlayColor: Colors.white24,
                            trackHeight: 2,
                          ),
                          child: Slider(
                            value: (_dragValue ?? current.toDouble()).clamp(
                              1,
                              total.toDouble(),
                            ),
                            min: 1,
                            max: total.toDouble(),
                            divisions: total - 1,
                            onChanged: (value) {
                              setState(() => _dragValue = value);
                            },
                            onChangeEnd: (value) {
                              _dragValue = null;
                              final index = value.round() - 1;
                              _pageController.jumpToPage(index);
                              _controller.setCurrentPage(index);
                            },
                          ),
                        ),
                      ),
                      Text(
                        '$total',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  )
                else
                  const SizedBox(height: 8),
                Text(
                  context.l10n.ehReaderGestureHint,
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRateBanner() {
    final l10n = context.l10n;
    final seconds = _controller.rateLimitSeconds;
    return Positioned(
      top: 80,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.orange.shade900.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
          child: Row(
            children: [
              const Icon(Icons.hourglass_bottom, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.ehReaderRateLimited(seconds),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              TextButton(
                onPressed: seconds > 0
                    ? null
                    : () => _controller.retry(_controller.currentIndex),
                child: Text(l10n.commonRetry),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
