import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/eh/eh_client.dart';
import '../../core/eh/eh_download.dart';
import '../../core/eh/eh_exceptions.dart';
import '../../core/eh/eh_image.dart';
import '../../core/eh/eh_library.dart';
import '../../core/eh/eh_models.dart';
import '../../core/eh/eh_repository.dart';
import '../../core/eh/eh_session.dart';
import '../../core/eh/eh_tags.dart';
import '../../l10n/l10n.dart';
import '../../navigation/app_routes.dart';
import '../../widgets/ui_kit.dart';

/// 图库详情：封面、标签、预览缩略图与阅读入口。
class EhDetailPage extends StatefulWidget {
  const EhDetailPage({
    super.key,
    required this.session,
    required this.repository,
    required this.item,
    this.downloadManager,
  });

  final EhSession session;
  final EhRepository repository;
  final GalleryItem item;
  final EhDownloadManager? downloadManager;

  @override
  State<EhDetailPage> createState() => _EhDetailPageState();
}

class _EhDetailPageState extends State<EhDetailPage> {
  GalleryDetail? _detail;
  ReadingProgress? _progress;
  Map<String, String> _translations = const {};
  bool _favorite = false;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    widget.downloadManager?.addListener(_onDownloadChanged);
    _load();
  }

  @override
  void dispose() {
    widget.downloadManager?.removeListener(_onDownloadChanged);
    super.dispose();
  }

  void _onDownloadChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final progress = await EhProgressStore.load(widget.item.gid);
      final translations = await EhTagStore.loadTranslations();
      final favorite = await EhFavoriteStore.contains(widget.item.gid);
      final detail = await widget.repository.fetchDetail(widget.item);
      unawaited(EhTagStore.record(detail.tags));
      if (!mounted) return;
      setState(() {
        _progress = progress;
        _translations = translations;
        _favorite = favorite;
        _detail = detail;
        _loading = false;
      });
    } on EhException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.message;
        _loading = false;
      });
    }
  }

  int get _totalPages {
    final detail = _detail;
    if (detail == null) return widget.item.pages;
    if (detail.pages > 0) return detail.pages;
    return detail.previews.length;
  }

  int get _startIndex {
    final total = _totalPages;
    if (total <= 0) return 0;
    final lastPage = _progress?.lastPage ?? 1;
    return (lastPage - 1).clamp(0, total - 1);
  }

  Future<void> _openReader([int? index]) async {
    final detail = _detail;
    if (detail == null) return;
    final total = _totalPages;
    if (total <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.ehDetailCannotRead)));
      return;
    }
    final start = index ?? _startIndex;
    final manager = widget.downloadManager;
    await Navigator.of(context).push<void>(
      AppRoutes.ehReader(
        repository: widget.repository,
        item: widget.item,
        detail: detail,
        totalPages: total,
        initialIndex: start.clamp(0, total - 1),
        localPagePath: manager == null
            ? null
            : (page) => manager.localPagePath(widget.item.gid, page),
      ),
    );
    if (!mounted) return;
    final progress = await EhProgressStore.load(widget.item.gid);
    if (!mounted) return;
    setState(() => _progress = progress);
  }

  Future<void> _toggleFavorite() async {
    final added = await EhFavoriteStore.toggle(_detail ?? widget.item);
    if (!mounted) return;
    setState(() => _favorite = added);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            added
                ? context.l10n.ehDetailFavoriteAdded
                : context.l10n.ehDetailFavoriteRemoved,
          ),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  Widget _buildDownloadAction() {
    final l10n = context.l10n;
    final manager = widget.downloadManager!;
    final download = manager.find(widget.item.gid);
    if (download == null) {
      return IconButton(
        tooltip: l10n.ehDetailDownloadToLocal,
        onPressed: _startDownload,
        icon: const Icon(Icons.download_outlined),
      );
    }
    switch (download.status) {
      case EhDownloadStatus.completed:
        return IconButton(
          tooltip: l10n.ehDetailDownloaded,
          onPressed: null,
          icon: const Icon(Icons.download_done),
        );
      case EhDownloadStatus.downloading:
        return IconButton(
          tooltip: l10n.ehDetailPauseDownload,
          onPressed: () => manager.pause(widget.item.gid),
          icon: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              value: download.totalPages > 0 ? download.progress : null,
              strokeWidth: 2,
            ),
          ),
        );
      case EhDownloadStatus.queued:
        return IconButton(
          tooltip: l10n.ehDetailCancelQueue,
          onPressed: () => manager.pause(widget.item.gid),
          icon: const Icon(Icons.schedule),
        );
      case EhDownloadStatus.paused:
      case EhDownloadStatus.failed:
        return IconButton(
          tooltip: download.status == EhDownloadStatus.failed
              ? l10n.ehDetailRetryDownload
              : l10n.ehDetailResumeDownload,
          onPressed: () => manager.resume(widget.item.gid),
          icon: Icon(
            download.status == EhDownloadStatus.failed
                ? Icons.refresh
                : Icons.play_circle_outline,
          ),
        );
    }
  }

  Future<void> _startDownload() async {
    final manager = widget.downloadManager;
    if (manager == null) return;
    final detail = _detail;
    final total = detail == null
        ? widget.item.pages
        : (detail.pages > 0 ? detail.pages : detail.previews.length);
    await manager.start(widget.item, totalPages: total);
    if (!mounted) return;
    final l10n = context.l10n;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            total > 0
                ? l10n.ehDetailQueuedWithPages(total)
                : l10n.ehDetailQueued,
          ),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  Widget _buildDownloadBanner(ColorScheme scheme) {
    final manager = widget.downloadManager!;
    final download = manager.find(widget.item.gid);
    if (download == null) return const SizedBox.shrink();
    final failed = download.status == EhDownloadStatus.failed;
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _downloadIcon(download.status),
                size: 18,
                color: failed ? scheme.error : scheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _downloadText(download),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: failed ? scheme.error : scheme.onSurfaceVariant,
                  ),
                ),
              ),
              if (download.status == EhDownloadStatus.downloading ||
                  download.status == EhDownloadStatus.queued)
                TextButton(
                  onPressed: () => manager.pause(widget.item.gid),
                  child: Text(l10n.commonPause),
                )
              else if (download.status != EhDownloadStatus.completed)
                TextButton(
                  onPressed: () => manager.resume(widget.item.gid),
                  child: Text(failed ? l10n.commonRetry : l10n.commonResume),
                ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: download.totalPages > 0 ? download.progress : null,
              minHeight: 4,
              backgroundColor: scheme.surfaceContainerHighest,
            ),
          ),
        ],
      ),
    );
  }

  IconData _downloadIcon(EhDownloadStatus status) {
    switch (status) {
      case EhDownloadStatus.queued:
        return Icons.schedule;
      case EhDownloadStatus.downloading:
        return Icons.downloading;
      case EhDownloadStatus.paused:
        return Icons.pause_circle_outline;
      case EhDownloadStatus.completed:
        return Icons.download_done;
      case EhDownloadStatus.failed:
        return Icons.error_outline;
    }
  }

  String _downloadText(EhDownload download) {
    final l10n = context.l10n;
    final progress = l10n.ehDetailDownloadProgress(
      download.downloaded,
      download.totalPages,
    );
    switch (download.status) {
      case EhDownloadStatus.queued:
        return l10n.ehDetailQueuedProgress(progress);
      case EhDownloadStatus.downloading:
        return l10n.ehDetailDownloadingProgress(progress);
      case EhDownloadStatus.paused:
        return download.error == null
            ? l10n.ehDetailPausedProgress(progress)
            : l10n.ehDetailPausedError(download.error!);
      case EhDownloadStatus.completed:
        return l10n.ehDetailCompletedProgress(progress);
      case EhDownloadStatus.failed:
        return l10n.ehDetailFailedError(
          download.error ?? l10n.ehDetailUnknownError,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ToolPage(
      title: l10n.ehDetailTitle,
      subtitle: '${widget.session.site.label} · ${widget.item.gid}',
      actions: [
        if (widget.downloadManager != null) _buildDownloadAction(),
        IconButton(
          tooltip: _favorite ? l10n.ehDetailUnfavorite : l10n.ehDetailFavorite,
          onPressed: _toggleFavorite,
          icon: Icon(_favorite ? Icons.favorite : Icons.favorite_border),
        ),
        IconButton(
          tooltip: l10n.commonRefresh,
          onPressed: _loading
              ? null
              : () async {
                  try {
                    final detail = await widget.repository.fetchDetail(
                      widget.item,
                      force: true,
                    );
                    if (!mounted) return;
                    setState(() => _detail = detail);
                  } on EhException catch (error) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(error.message)));
                  }
                },
          icon: const Icon(Icons.refresh),
        ),
      ],
      child: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    final error = _error;
    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 42,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 12),
              Text(error, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton.tonal(
                onPressed: _load,
                child: Text(context.l10n.commonRetry),
              ),
            ],
          ),
        ),
      );
    }

    final detail = _detail!;
    final scheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            children: [
              _buildHeader(detail, scheme),
              if (widget.downloadManager?.find(widget.item.gid) != null) ...[
                const SizedBox(height: 14),
                _buildDownloadBanner(scheme),
              ],
              if (detail.tags.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(
                  l10n.ehDetailTags,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                _buildTags(detail.tags, scheme),
              ],
              if (detail.previews.isNotEmpty) ...[
                const SizedBox(height: 20),
                Row(
                  children: [
                    Text(
                      l10n.commonPreview,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Spacer(),
                    Text(
                      l10n.ehDetailTapToJump,
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Builder(
                  builder: (context) {
                    final spriteWidth = detail.previews
                        .where((preview) => preview.isSprite)
                        .fold<double>(
                          0,
                          (width, preview) => math.max(
                            width,
                            preview.thumbOffsetX + preview.thumbWidth,
                          ),
                        );
                    return SizedBox(
                      height: 164,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: detail.previews.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final preview = detail.previews[index];
                          return GestureDetector(
                            onTap: () => _openReader(preview.index),
                            child: _PreviewTile(
                              client: widget.repository.client,
                              preview: preview,
                              spriteWidth: spriteWidth,
                              referer: widget.repository.urls
                                  .detail(widget.item.gid, widget.item.token)
                                  .toString(),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _openReader(),
                icon: const Icon(Icons.menu_book),
                label: Text(
                  _progress == null
                      ? l10n.ehDetailStartReading
                      : l10n.ehDetailContinueReading(_progress!.lastPage),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(GalleryDetail detail, ColorScheme scheme) {
    final textTheme = Theme.of(context).textTheme;
    final rating = detail.rating >= 0 ? detail.rating.toStringAsFixed(2) : '—';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 120,
                height: 168,
                child: detail.thumbUrl.isEmpty
                    ? Container(
                        color: scheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          color: scheme.outline,
                        ),
                      )
                    : Image(
                        image: EhImageProvider(
                          client: widget.repository.client,
                          url: detail.thumbUrl,
                          referer: widget.repository.urls.thumbReferer
                              .toString(),
                        ),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: scheme.surfaceContainerHighest,
                            child: Icon(
                              Icons.broken_image_outlined,
                              color: scheme.outline,
                            ),
                          );
                        },
                      ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    detail.title,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                  if (detail.titleJpn != null &&
                      detail.titleJpn!.isNotEmpty &&
                      detail.titleJpn != detail.title) ...[
                    const SizedBox(height: 6),
                    Text(
                      detail.titleJpn!,
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _StatChip(
                        icon: Icons.category_outlined,
                        label: ehCategoryLabel(detail.category),
                      ),
                      _StatChip(
                        icon: Icons.photo_library_outlined,
                        label: context.l10n.ehDetailPagesCount(detail.pages),
                      ),
                      _StatChip(icon: Icons.star_rounded, label: rating),
                    ],
                  ),
                  if (detail.uploader != null &&
                      detail.uploader!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      context.l10n.ehDetailUploader(detail.uploader!),
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTags(Map<String, List<String>> tags, ColorScheme scheme) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final entry in tags.entries)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Tooltip(
                  message: entry.key,
                  child: Text(
                    ehTagNamespaceLabel(entry.key),
                    style: textTheme.labelMedium?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final tag in entry.value)
                      Tooltip(
                        message: tag,
                        child: Material(
                          color: scheme.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(8),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () => _openTag(entry.key, tag),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    ehTagDisplay(entry.key, tag, _translations),
                                    style: textTheme.labelSmall,
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.search,
                                    size: 12,
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _openTag(String namespace, String tag) {
    Navigator.of(context).push<void>(
      AppRoutes.ehBrowse(initialKeyword: ehTagQuery(namespace, tag)),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: scheme.primary),
          const SizedBox(width: 4),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}

/// 详情页预览：普通缩略图直接显示，雪碧图按偏移裁出当前页。
class _PreviewTile extends StatelessWidget {
  const _PreviewTile({
    required this.client,
    required this.preview,
    required this.spriteWidth,
    required this.referer,
  });

  final EhClient client;
  final GalleryPreview preview;
  final double spriteWidth;
  final String referer;

  @override
  Widget build(BuildContext context) {
    const targetWidth = 104.0;
    final scheme = Theme.of(context).colorScheme;
    final ratio = preview.isSprite && preview.thumbWidth > 0
        ? preview.thumbHeight / preview.thumbWidth
        : 146 / 104;
    final targetHeight = targetWidth * ratio;
    final provider = EhImageProvider(
      client: client,
      url: preview.thumbUrl,
      referer: referer,
    );
    final fallback = Container(
      color: scheme.surfaceContainerHighest,
      child: Icon(Icons.broken_image_outlined, color: scheme.outline),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: targetWidth,
        height: targetHeight,
        child: preview.isSprite
            ? LayoutBuilder(
                builder: (context, constraints) {
                  final scale = constraints.maxWidth / preview.thumbWidth;
                  final width = spriteWidth > 0
                      ? spriteWidth * scale
                      : constraints.maxWidth;
                  return Stack(
                    clipBehavior: Clip.hardEdge,
                    children: [
                      Positioned(
                        left: -preview.thumbOffsetX * scale,
                        top: 0,
                        width: width,
                        height: preview.thumbHeight * scale,
                        child: Image(
                          image: provider,
                          fit: BoxFit.fill,
                          errorBuilder: (context, error, stackTrace) =>
                              fallback,
                        ),
                      ),
                    ],
                  );
                },
              )
            : Image(
                image: provider,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => fallback,
              ),
      ),
    );
  }
}
