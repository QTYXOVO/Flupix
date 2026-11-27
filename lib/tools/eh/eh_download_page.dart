import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/eh/eh_download.dart';
import '../../core/eh/eh_image.dart';
import '../../core/eh/eh_models.dart';
import '../../core/eh/eh_session.dart';
import '../../l10n/l10n.dart';
import '../../navigation/app_routes.dart';
import '../../widgets/ui_kit.dart';

/// 下载管理：查看进度、暂停/继续、删除与离线阅读。
class EhDownloadPage extends StatefulWidget {
  const EhDownloadPage({
    super.key,
    required this.session,
    required this.manager,
  });

  final EhSession session;
  final EhDownloadManager manager;

  @override
  State<EhDownloadPage> createState() => _EhDownloadPageState();
}

class _EhDownloadPageState extends State<EhDownloadPage> {
  @override
  void initState() {
    super.initState();
    widget.manager.addListener(_refresh);
    if (!widget.manager.loaded) unawaited(widget.manager.load());
  }

  @override
  void dispose() {
    widget.manager.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final downloads = widget.manager.downloads;
    final completed = downloads.where((item) => item.isCompleted).length;
    return ToolPage(
      title: l10n.ehDownloadTitle,
      subtitle:
          '${widget.session.site.label} · ${l10n.ehDownloadSummary(downloads.length, completed)}',
      child: _buildBody(downloads),
    );
  }

  Widget _buildBody(List<EhDownload> downloads) {
    if (!widget.manager.loaded) {
      return const Center(child: CircularProgressIndicator());
    }
    if (downloads.isEmpty) {
      return _buildEmpty();
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: downloads.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) => _buildTile(downloads[index]),
    );
  }

  Widget _buildEmpty() {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.download_outlined, size: 42, color: scheme.outline),
            const SizedBox(height: 12),
            Text(
              l10n.ehDownloadEmpty,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 6),
            Text(
              l10n.ehDownloadEmptyHint,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTile(EhDownload download) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openReader(download),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 64,
                      height: 84,
                      child: _buildThumb(download.item),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          download.item.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _statusText(download),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodySmall?.copyWith(
                            color: download.status == EhDownloadStatus.failed
                                ? scheme.error
                                : scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildAction(download),
                  PopupMenuButton<String>(
                    tooltip: l10n.commonMore,
                    onSelected: (value) {
                      if (value == 'delete') _confirmDelete(download);
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'delete',
                        child: Text(l10n.ehDownloadDelete),
                      ),
                    ],
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
        ),
      ),
    );
  }

  Widget _buildThumb(GalleryItem item) {
    final scheme = Theme.of(context).colorScheme;
    if (item.thumbUrl.isEmpty) {
      return Container(
        color: scheme.surfaceContainerHighest,
        child: Icon(
          Icons.image_not_supported_outlined,
          color: scheme.outline,
          size: 20,
        ),
      );
    }
    return Image(
      image: EhImageProvider(
        client: widget.manager.repository.client,
        url: item.thumbUrl,
        referer: widget.manager.repository.urls.thumbReferer.toString(),
      ),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: scheme.surfaceContainerHighest,
          child: Icon(Icons.broken_image_outlined, size: 20),
        );
      },
    );
  }

  Widget _buildAction(EhDownload download) {
    final l10n = context.l10n;
    switch (download.status) {
      case EhDownloadStatus.downloading:
      case EhDownloadStatus.queued:
        return IconButton(
          tooltip: l10n.commonPause,
          onPressed: () => widget.manager.pause(download.gid),
          icon: const Icon(Icons.pause_circle_outline),
        );
      case EhDownloadStatus.completed:
        return IconButton(
          tooltip: l10n.ehDownloadDownloaded,
          onPressed: null,
          icon: const Icon(Icons.download_done),
        );
      case EhDownloadStatus.paused:
      case EhDownloadStatus.failed:
        return IconButton(
          tooltip: download.status == EhDownloadStatus.failed
              ? l10n.commonRetry
              : l10n.commonResume,
          onPressed: () => widget.manager.resume(download.gid),
          icon: const Icon(Icons.play_circle_outline),
        );
    }
  }

  String _statusText(EhDownload download) {
    final l10n = context.l10n;
    final progress = l10n.ehDownloadPagesProgress(
      download.downloaded,
      download.totalPages,
    );
    switch (download.status) {
      case EhDownloadStatus.queued:
        return l10n.ehDownloadStatusQueued(progress);
      case EhDownloadStatus.downloading:
        return l10n.ehDownloadStatusDownloading(progress);
      case EhDownloadStatus.paused:
        final error = download.error;
        return error == null
            ? l10n.ehDownloadStatusPaused(progress)
            : l10n.ehDownloadStatusPausedError(error);
      case EhDownloadStatus.completed:
        return l10n.ehDownloadStatusCompleted(progress);
      case EhDownloadStatus.failed:
        return l10n.ehDownloadStatusFailed(
          download.error ?? l10n.ehDownloadUnknownError,
        );
    }
  }

  Future<void> _openReader(EhDownload download) async {
    if (download.totalPages <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.ehDownloadNoPages)));
      return;
    }
    if (download.downloaded == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.ehDownloadNoDownloadedPages)),
      );
      return;
    }
    final detail = GalleryDetail(
      gid: download.item.gid,
      token: download.item.token,
      title: download.item.title,
      thumbUrl: download.item.thumbUrl,
      category: download.item.category,
      rating: download.item.rating,
      pages: download.totalPages,
    );
    await Navigator.of(context).push<void>(
      AppRoutes.ehReader(
        repository: widget.manager.repository,
        item: download.item,
        detail: detail,
        totalPages: download.totalPages,
        initialIndex: 0,
        localPagePath: (index) =>
            widget.manager.localPagePath(download.gid, index),
      ),
    );
  }

  Future<void> _confirmDelete(EhDownload download) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.ehDownloadDelete),
        content: Text(
          context.l10n.ehDownloadDeleteConfirm(download.item.title),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(context.l10n.commonDelete),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await widget.manager.delete(download.gid);
    }
  }
}
