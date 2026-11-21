import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../../core/eh/eh_exceptions.dart';
import '../../core/eh/eh_models.dart';
import '../../core/eh/eh_repository.dart';
import '../../l10n/l10n.dart';

/// 阅读器状态：按页加载、预读、限流暂停与进度落盘。
class EhReaderController extends ChangeNotifier {
  EhReaderController({
    required this.repository,
    required this.item,
    required this.detail,
    required this.totalPages,
    required int initialIndex,
    this.localPagePath,
  }) : _currentIndex = initialIndex.clamp(0, math.max(0, totalPages - 1)) {
    setCurrentPage(_currentIndex);
  }

  final EhRepository repository;
  final GalleryItem item;
  final GalleryDetail detail;
  final int totalPages;

  /// 已下载页面返回本地路径，阅读器据此跳过网络请求。
  final String? Function(int index)? localPagePath;

  final Map<int, GalleryPage> _pages = {};
  final Map<int, Future<GalleryPage>> _futures = {};
  final Map<int, String> _errors = {};
  final Set<int> _loading = {};
  final Set<int> _prefetched = {};
  final List<int> _queue = [];
  int _activePrefetch = 0;
  int _currentIndex = 0;
  DateTime? _rateLimitedUntil;
  Timer? _saveTimer;

  int get currentIndex => _currentIndex;

  DateTime? get rateLimitedUntil => _rateLimitedUntil;

  int get rateLimitSeconds {
    final until = _rateLimitedUntil;
    if (until == null) return 0;
    final seconds = until.difference(DateTime.now()).inSeconds;
    return seconds < 0 ? 0 : seconds;
  }

  GalleryPage? pageAt(int index) => _pages[index];

  String? errorAt(int index) => _errors[index];

  bool isLoading(int index) => _loading.contains(index);

  void setCurrentPage(int index) {
    if (index < 0 || index >= totalPages) return;
    _currentIndex = index;
    _load(index);
    _scheduleSave();
    for (var i = index + 1; i <= math.min(index + 3, totalPages - 1); i++) {
      _enqueue(i);
    }
    notifyListeners();
  }

  void retry(int index) {
    _errors.remove(index);
    _futures.remove(index);
    _prefetched.remove(index);
    _load(index);
    notifyListeners();
  }

  void _load(int index) {
    if (_pages.containsKey(index) || _futures.containsKey(index)) return;
    unawaited(loadPage(index).then<void>((_) {}, onError: (_, _) {}));
  }

  Future<GalleryPage> loadPage(int index) {
    final cached = _pages[index];
    if (cached != null) return Future<GalleryPage>.value(cached);
    if (localPagePath?.call(index) != null) {
      final page = GalleryPage(
        index: index,
        pToken: '',
        pageUrl: '',
        imageUrl: '',
      );
      _pages[index] = page;
      return Future<GalleryPage>.value(page);
    }
    final existing = _futures[index];
    if (existing != null) return existing;
    final future = _fetch(index);
    _futures[index] = future;
    return future;
  }

  Future<GalleryPage> _fetch(int index) async {
    _errors.remove(index);
    _loading.add(index);
    notifyListeners();
    try {
      final page = await repository.fetchPage(item, index);
      _pages[index] = page;
      notifyListeners();
      return page;
    } on EhException catch (error) {
      _errors[index] = error.message;
      if (error is EhRateLimited) {
        _rateLimitedUntil = DateTime.now().add(error.retryAfter);
        _queue.clear();
      }
      rethrow;
    } catch (_) {
      _errors[index] = AppL10n.current.ehReaderPageLoadFailed;
      rethrow;
    } finally {
      _loading.remove(index);
      _futures.remove(index);
      notifyListeners();
    }
  }

  void _enqueue(int index) {
    if (index < 0 || index >= totalPages) return;
    if (_pages.containsKey(index) || _prefetched.contains(index)) return;
    if (_queue.contains(index)) return;
    _queue.add(index);
    _pump();
  }

  void _pump() {
    if (rateLimitSeconds > 0) return;
    while (_activePrefetch < 2 && _queue.isNotEmpty) {
      final index = _queue.removeAt(0);
      _activePrefetch++;
      _prefetchOne(index).whenComplete(() {
        _activePrefetch--;
        _pump();
      });
    }
  }

  Future<void> _prefetchOne(int index) async {
    if (localPagePath?.call(index) != null) {
      _prefetched.add(index);
      return;
    }
    try {
      final page = await loadPage(index);
      await EhImageLoader.loadBytes(
        repository.client,
        url: page.imageUrl,
        referer: page.pageUrl,
      );
      _prefetched.add(index);
    } on EhRateLimited catch (error) {
      _rateLimitedUntil = DateTime.now().add(error.retryAfter);
      _queue.clear();
      notifyListeners();
    } catch (_) {
      // 预读失败不打断当前页，用户翻到该页时会再次请求。
    }
  }

  void _scheduleSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 500), _flushProgress);
  }

  void _flushProgress() {
    unawaited(
      EhProgressStore.save(
        item: item,
        lastPage: _currentIndex + 1,
        totalPages: totalPages,
      ),
    );
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    _flushProgress();
    super.dispose();
  }
}
