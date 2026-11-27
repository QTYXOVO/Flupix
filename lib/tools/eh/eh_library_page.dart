import 'package:flutter/material.dart';

import '../../core/eh/eh_client.dart';
import '../../core/eh/eh_download.dart';
import '../../core/eh/eh_image.dart';
import '../../core/eh/eh_library.dart';
import '../../core/eh/eh_models.dart';
import '../../core/eh/eh_repository.dart';
import '../../core/eh/eh_session.dart';
import '../../l10n/l10n.dart';
import '../../navigation/app_routes.dart';
import '../../widgets/ui_kit.dart';

/// 我的图库：本地收藏与阅读历史。
class EhLibraryPage extends StatefulWidget {
  const EhLibraryPage({
    super.key,
    required this.session,
    required this.repository,
    this.downloadManager,
  });

  final EhSession session;
  final EhRepository repository;
  final EhDownloadManager? downloadManager;

  @override
  State<EhLibraryPage> createState() => _EhLibraryPageState();
}

class _EhLibraryPageState extends State<EhLibraryPage> {
  List<GalleryItem> _favorites = const [];
  List<ReadingProgress> _history = const [];
  bool _loading = true;
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final favorites = await EhFavoriteStore.load();
    final history = await EhProgressStore.loadAll();
    if (!mounted) return;
    setState(() {
      _favorites = favorites;
      _history = history;
      _loading = false;
    });
  }

  Future<void> _openDetail(GalleryItem item) async {
    await Navigator.of(context).push<void>(
      AppRoutes.ehDetail(
        session: widget.session,
        repository: widget.repository,
        item: item,
        downloadManager: widget.downloadManager,
      ),
    );
    if (mounted) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ToolPage(
      title: l10n.ehLibraryTitle,
      subtitle: l10n.ehLibrarySubtitle(
        widget.session.site.label,
        _favorites.length,
        _history.length,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: SegmentedButton<int>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: 0,
                  icon: const Icon(Icons.favorite_border, size: 18),
                  label: Text(
                    l10n.ehLibraryFavoritesSegment(_favorites.length),
                  ),
                ),
                ButtonSegment(
                  value: 1,
                  icon: const Icon(Icons.history, size: 18),
                  label: Text(l10n.ehLibraryHistorySegment(_history.length)),
                ),
              ],
              selected: {_tab},
              onSelectionChanged: (value) => setState(() => _tab = value.first),
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return _tab == 0 ? _buildFavorites() : _buildHistory();
  }

  Widget _buildFavorites() {
    final l10n = context.l10n;
    if (_favorites.isEmpty) {
      return _buildEmpty(
        Icons.favorite_border,
        l10n.ehLibraryNoFavorites,
        l10n.ehLibraryNoFavoritesHint,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: _favorites.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = _favorites[index];
        final rating = item.rating >= 0
            ? ' · ${item.rating.toStringAsFixed(1)}'
            : '';
        return _LibraryTile(
          client: widget.repository.client,
          thumbUrl: item.thumbUrl,
          referer: widget.repository.urls.thumbReferer.toString(),
          title: item.title,
          subtitle: l10n.ehLibraryTileSubtitle(
            ehCategoryLabel(item.category),
            item.pages,
            rating,
          ),
          removeIcon: Icons.favorite,
          removeTooltip: l10n.ehLibraryRemoveFavorite,
          onRemove: () async {
            await EhFavoriteStore.remove(item.gid);
            await _load();
          },
          onTap: () => _openDetail(item),
        );
      },
    );
  }

  Widget _buildHistory() {
    final l10n = context.l10n;
    if (_history.isEmpty) {
      return _buildEmpty(
        Icons.history,
        l10n.ehLibraryNoHistory,
        l10n.ehLibraryNoHistoryHint,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: _history.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final progress = _history[index];
        final item = GalleryItem(
          gid: progress.gid,
          token: progress.token,
          title: progress.title,
          thumbUrl: progress.thumbUrl,
        );
        return _LibraryTile(
          client: widget.repository.client,
          thumbUrl: progress.thumbUrl,
          referer: widget.repository.urls.thumbReferer.toString(),
          title: progress.title,
          subtitle: l10n.ehLibraryHistorySubtitle(
            progress.lastPage,
            progress.totalPages,
            _formatTime(progress.updatedAt),
          ),
          removeIcon: Icons.delete_outline,
          removeTooltip: l10n.ehLibraryRemoveHistory,
          onRemove: () async {
            await EhProgressStore.clear(progress.gid);
            await _load();
          },
          onTap: () => _openDetail(item),
        );
      },
    );
  }

  Widget _buildEmpty(IconData icon, String title, String message) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 42, color: scheme.outline),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final sameDay =
        time.year == now.year && time.month == now.month && time.day == now.day;
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    if (sameDay) return context.l10n.ehLibraryTodayTime('$hour:$minute');
    final month = time.month.toString().padLeft(2, '0');
    final day = time.day.toString().padLeft(2, '0');
    return '${time.year}-$month-$day';
  }
}

class _LibraryTile extends StatelessWidget {
  const _LibraryTile({
    required this.client,
    required this.thumbUrl,
    required this.referer,
    required this.title,
    required this.subtitle,
    required this.removeIcon,
    required this.removeTooltip,
    required this.onRemove,
    required this.onTap,
  });

  final EhClient client;
  final String thumbUrl;
  final String referer;
  final String title;
  final String subtitle;
  final IconData removeIcon;
  final String removeTooltip;
  final VoidCallback onRemove;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 64,
                  height: 84,
                  child: thumbUrl.isEmpty
                      ? Container(
                          color: scheme.surfaceContainerHighest,
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: scheme.outline,
                            size: 20,
                          ),
                        )
                      : Image(
                          image: EhImageProvider(
                            client: client,
                            url: thumbUrl,
                            referer: referer,
                          ),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: scheme.surfaceContainerHighest,
                              child: Icon(
                                Icons.broken_image_outlined,
                                color: scheme.outline,
                                size: 20,
                              ),
                            );
                          },
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: removeTooltip,
                onPressed: onRemove,
                icon: Icon(removeIcon, size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
