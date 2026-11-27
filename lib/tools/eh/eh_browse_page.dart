import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/eh/eh_client.dart';
import '../../core/eh/eh_download.dart';
import '../../core/eh/eh_exceptions.dart';
import '../../core/eh/eh_image.dart';
import '../../core/eh/eh_models.dart';
import '../../core/eh/eh_repository.dart';
import '../../core/eh/eh_session.dart';
import '../../l10n/l10n.dart';
import '../../navigation/app_routes.dart';
import '../../widgets/ui_kit.dart';

/// E-Hentai 浏览页：搜索、分类筛选、下拉刷新与滚动分页。
class EhBrowsePage extends StatefulWidget {
  const EhBrowsePage({super.key, this.initialKeyword = ''});

  /// 从标签检索或详情页跳转时预填的搜索词。
  final String initialKeyword;

  @override
  State<EhBrowsePage> createState() => _EhBrowsePageState();
}

class _EhBrowsePageState extends State<EhBrowsePage> {
  final _session = EhSession();
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  final List<GalleryItem> _items = [];
  final Set<int> _known = {};
  final Set<int> _excludedCategories = {};

  EhRepository? _repository;
  EhDownloadManager? _downloads;
  String _keyword = '';
  String? _nextCursor;
  int _nextPage = 0;
  int _pages = 0;
  int _totalResults = 0;
  int _requestToken = 0;
  bool _loading = false;
  bool _initialLoading = true;
  bool _hasMore = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _keyword = widget.initialKeyword.trim();
    _searchController.text = _keyword;
    _scrollController.addListener(_onScroll);
    _bootstrap();
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _searchController.dispose();
    _downloads?.dispose();
    _session.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    try {
      await _session.load();
      if (!mounted) return;
      _rebuildRepository();
      await _reload();
    } on EhException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.message;
        _initialLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = context.l10n.ehBrowseInitFailed('$error');
        _initialLoading = false;
      });
    }
  }

  void _rebuildRepository() {
    _repository?.dispose();
    _repository = EhRepository(_session.client);
    final downloads = _downloads;
    if (downloads == null) {
      _downloads = EhDownloadManager(_repository!);
      unawaited(_downloads!.load());
    } else {
      downloads.attach(_repository!);
    }
  }

  int get _categoryMask {
    var mask = 0;
    for (final filter in ehCategoryFilters) {
      if (_excludedCategories.contains(filter.bit)) mask |= filter.bit;
    }
    return mask;
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.extentAfter < 700) {
      _loadMore();
    }
  }

  Future<void> _reload() async {
    final repository = _repository;
    if (repository == null) return;
    final token = ++_requestToken;
    setState(() {
      _items.clear();
      _known.clear();
      _nextCursor = null;
      _nextPage = 0;
      _pages = 0;
      _totalResults = 0;
      _hasMore = true;
      _error = null;
      _initialLoading = true;
      _loading = false;
    });
    await _loadMore(token);
  }

  Future<void> _loadMore([int? requestToken]) async {
    final repository = _repository;
    if (repository == null || _loading || !_hasMore) return;
    final token = requestToken ?? _requestToken;
    _loading = true;
    try {
      final result = await repository.fetchList(
        page: _nextPage,
        next: _nextCursor,
        keyword: _keyword,
        excludedCategories: _categoryMask,
      );
      if (!mounted || token != _requestToken) return;
      setState(() {
        for (final item in result.items) {
          if (_known.add(item.gid)) _items.add(item);
        }
        _pages = result.pages;
        _nextPage = result.nextPage;
        _nextCursor = result.nextCursor;
        _totalResults = result.totalResults;
        _hasMore = result.nextCursor != null || result.nextPage >= 0;
        _error = null;
      });
    } on EhException catch (error) {
      if (!mounted || token != _requestToken) return;
      setState(() {
        _error = error.message;
        _hasMore = false;
      });
    } finally {
      if (mounted && token == _requestToken) {
        setState(() {
          _loading = false;
          _initialLoading = false;
        });
      }
    }
  }

  Future<void> _openLogin() async {
    final result = await Navigator.of(context)
        .push<bool>(AppRoutes.ehLogin(_session));
    if (result == true && mounted) {
      _rebuildRepository();
      await _reload();
    }
  }

  Future<void> _openLibrary() async {
    final repository = _repository;
    if (repository == null) return;
    await Navigator.of(context).push<void>(
      AppRoutes.ehLibrary(
        session: _session,
        repository: repository,
        downloadManager: _downloads,
      ),
    );
  }

  Future<void> _openDownloads() async {
    final downloads = _downloads;
    if (downloads == null) return;
    await Navigator.of(
      context,
    ).push<void>(AppRoutes.ehDownloads(session: _session, manager: downloads));
  }

  Future<void> _openTagSearch() async {
    final query = await Navigator.of(context)
        .push<String>(AppRoutes.ehTagSearch());
    if (query == null || query.trim().isEmpty || !mounted) return;
    _searchController.text = query;
    _keyword = query;
    await _reload();
  }

  Future<void> _switchSite(EhSite site) async {
    if (site == _session.site) return;
    await _session.setSite(site);
    if (!mounted) return;
    _rebuildRepository();
    await _reload();
  }

  Future<void> _logout() async {
    await _session.clearCookie();
    if (!mounted) return;
    _rebuildRepository();
    await _reload();
  }

  void _submitSearch() {
    _keyword = _searchController.text.trim();
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return ToolPage(
      title: l10n.toolEhTitle,
      subtitle:
          '${_session.site.label} · ${_session.isLoggedIn ? l10n.ehBrowseLoggedIn : l10n.ehBrowseGuest}',
      actions: [
        IconButton(
          tooltip: l10n.ehTagTitle,
          onPressed: _openTagSearch,
          icon: const Icon(Icons.sell_outlined),
        ),
        PopupMenuButton<EhSite>(
          tooltip: l10n.ehBrowseSwitchSite,
          icon: const Icon(Icons.public),
          onSelected: _switchSite,
          itemBuilder: (context) => [
            for (final site in EhSite.values)
              PopupMenuItem(
                value: site,
                child: Row(
                  children: [
                    if (site == _session.site)
                      const Icon(Icons.check, size: 18)
                    else
                      const SizedBox(width: 18),
                    const SizedBox(width: 8),
                    Text(site.label),
                  ],
                ),
              ),
          ],
        ),
        IconButton(
          tooltip: _session.isLoggedIn
              ? l10n.ehBrowseRelogin
              : l10n.ehBrowseLogin,
          onPressed: _openLogin,
          icon: const Icon(Icons.person_outline),
        ),
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'library') _openLibrary();
            if (value == 'downloads') _openDownloads();
            if (value == 'logout') _logout();
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'library',
              child: Text(l10n.ehBrowseMyLibrary),
            ),
            PopupMenuItem(
              value: 'downloads',
              child: Text(l10n.ehBrowseDownloads),
            ),
            PopupMenuItem(value: 'logout', child: Text(l10n.ehBrowseLogout)),
          ],
        ),
      ],
      child: Column(
        children: [
          _buildSearchBar(scheme),
          _buildCategoryBar(scheme),
          if (!_session.isLoggedIn) _buildGuestBanner(scheme),
          Expanded(child: _buildContent(scheme)),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ColorScheme scheme) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        onSubmitted: (_) => _submitSearch(),
        decoration: InputDecoration(
          hintText: l10n.ehBrowseSearchHint,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            tooltip: l10n.commonSearch,
            onPressed: _submitSearch,
            icon: const Icon(Icons.arrow_forward),
          ),
          filled: true,
          fillColor: scheme.surfaceContainerLow,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryBar(ColorScheme scheme) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          for (final filter in ehCategoryFilters)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(filter.label),
                tooltip: context.l10n.ehFilterExcludeHint,
                selected: _excludedCategories.contains(filter.bit),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _excludedCategories.add(filter.bit);
                    } else {
                      _excludedCategories.remove(filter.bit);
                    }
                  });
                  _reload();
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGuestBanner(ColorScheme scheme) {
    final l10n = context.l10n;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 18,
            color: scheme.onSecondaryContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.ehBrowseGuestBanner,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: scheme.onSecondaryContainer),
            ),
          ),
          TextButton(onPressed: _openLogin, child: Text(l10n.ehBrowseLogin)),
        ],
      ),
    );
  }

  Widget _buildContent(ColorScheme scheme) {
    if (_initialLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_items.isEmpty) {
      if (_error != null) {
        return _buildError(scheme, _error!);
      }
      return Center(child: Text(context.l10n.ehBrowseNoResults));
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 720;
        return RefreshIndicator(
          onRefresh: _reload,
          child: wide
              ? _buildGrid(constraints.maxWidth, scheme)
              : _buildList(scheme),
        );
      },
    );
  }

  Widget _buildError(ColorScheme scheme, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, size: 40, color: scheme.error),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: _reload,
              child: Text(context.l10n.commonRetry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(double width, ColorScheme scheme) {
    final columns = width >= 1100 ? 5 : 4;
    return GridView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.64,
      ),
      itemCount: _items.length + 1,
      itemBuilder: (context, index) {
        if (index == _items.length) return _buildFooter(scheme);
        return _buildGridItem(_items[index], scheme);
      },
    );
  }

  Widget _buildGridItem(GalleryItem item, ColorScheme scheme) {
    return Material(
      color: scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openDetail(item),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: _Thumb(
                  client: _repository!.client,
                  item: item,
                  referer: _repository!.urls.thumbReferer.toString(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600, height: 1.25),
                  ),
                  const SizedBox(height: 6),
                  _MetaRow(item: item),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(ColorScheme scheme) {
    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: _items.length + 1,
      itemBuilder: (context, index) {
        if (index == _items.length) return _buildFooter(scheme);
        final item = _items[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Material(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(14),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => _openDetail(item),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        width: 92,
                        height: 120,
                        child: _Thumb(
                          client: _repository!.client,
                          item: item,
                          referer: _repository!.urls.thumbReferer.toString(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  height: 1.25,
                                ),
                          ),
                          const SizedBox(height: 8),
                          _MetaRow(item: item),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFooter(ColorScheme scheme) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: TextButton.icon(
            onPressed: () {
              setState(() => _hasMore = true);
              _loadMore();
            },
            icon: const Icon(Icons.refresh),
            label: Text(_error!),
          ),
        ),
      );
    }
    if (!_hasMore) {
      final l10n = context.l10n;
      final label = _totalResults > 0
          ? l10n.ehBrowseTotalResults(_totalResults)
          : (_pages > 0
                ? l10n.ehBrowseReachedPage(_pages)
                : l10n.ehBrowseNoMore);
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ),
      );
    }
    return const SizedBox(height: 24);
  }

  Future<void> _openDetail(GalleryItem item) async {
    await Navigator.of(context).push<void>(
      AppRoutes.ehDetail(
        session: _session,
        repository: _repository!,
        item: item,
        downloadManager: _downloads,
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({
    required this.client,
    required this.item,
    required this.referer,
  });

  final EhClient client;
  final GalleryItem item;
  final String referer;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (item.thumbUrl.isEmpty) {
      return Container(
        color: scheme.surfaceContainerHighest,
        child: Icon(Icons.image_not_supported, color: scheme.outline),
      );
    }
    return Image(
      image: EhImageProvider(
        client: client,
        url: item.thumbUrl,
        referer: referer,
      ),
      fit: BoxFit.cover,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) return child;
        return Container(
          color: scheme.surfaceContainerHighest,
          child: const Center(
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: scheme.surfaceContainerHighest,
          child: Icon(Icons.broken_image_outlined, color: scheme.outline),
        );
      },
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.item});

  final GalleryItem item;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Flexible(
          child: Text(
            ehCategoryLabel(item.category),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.labelSmall?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (item.pages > 0) ...[
          const SizedBox(width: 8),
          Text(
            '${item.pages}P',
            style: textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
        const Spacer(),
        if (item.rating >= 0) ...[
          Icon(Icons.star_rounded, size: 14, color: scheme.tertiary),
          const SizedBox(width: 2),
          Text(
            item.rating.toStringAsFixed(1),
            style: textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}
