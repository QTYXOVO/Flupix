import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../../l10n/l10n.dart';
import 'eh_exceptions.dart';
import 'eh_models.dart';
import 'eh_repository.dart';

/// 下载状态，参考 EhViewer `DownloadInfo` 的状态机。
enum EhDownloadStatus { queued, downloading, paused, completed, failed }

String ehDownloadStatusLabel(EhDownloadStatus status) {
  final l10n = AppL10n.current;
  switch (status) {
    case EhDownloadStatus.queued:
      return l10n.ehStatusQueued;
    case EhDownloadStatus.downloading:
      return l10n.ehStatusDownloading;
    case EhDownloadStatus.paused:
      return l10n.ehStatusPaused;
    case EhDownloadStatus.completed:
      return l10n.ehStatusCompleted;
    case EhDownloadStatus.failed:
      return l10n.ehStatusFailed;
  }
}

/// 单个图库的下载记录。已下载页号保存在 `done` 中，用于断点续传。
class EhDownload {
  EhDownload({
    required this.item,
    required this.totalPages,
    Set<int>? done,
    this.status = EhDownloadStatus.queued,
    this.error,
    DateTime? updatedAt,
  }) : done = done ?? <int>{},
       updatedAt = updatedAt ?? DateTime.now();

  final GalleryItem item;
  int totalPages;
  final Set<int> done;
  EhDownloadStatus status;
  String? error;
  DateTime updatedAt;

  int get gid => item.gid;

  int get downloaded => done.length;

  double get progress {
    if (totalPages <= 0) return 0;
    return (done.length / totalPages).clamp(0.0, 1.0);
  }

  bool get isCompleted => status == EhDownloadStatus.completed;

  bool get isActive =>
      status == EhDownloadStatus.downloading ||
      status == EhDownloadStatus.queued;

  Map<String, Object?> toJson() => {
    'gid': item.gid,
    'token': item.token,
    'title': item.title,
    'thumb': item.thumbUrl,
    'category': item.category,
    'rating': item.rating,
    'pages': item.pages,
    'uploader': item.uploader,
    'total': totalPages,
    'done': (done.toList()..sort()),
    'status': status.name,
    'error': error,
    'updatedAt': updatedAt.millisecondsSinceEpoch,
  };

  static EhDownload? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final gid = raw['gid'];
    final token = raw['token'];
    if (gid is! int || token is! String) return null;
    final item = GalleryItem(
      gid: gid,
      token: token,
      title: raw['title']?.toString() ?? '',
      thumbUrl: raw['thumb']?.toString() ?? '',
      category: raw['category']?.toString() ?? '',
      rating: raw['rating'] is num ? (raw['rating'] as num).toDouble() : -1,
      pages: raw['pages'] is int ? raw['pages'] as int : 0,
      uploader: raw['uploader']?.toString(),
    );
    final done = <int>{};
    final rawDone = raw['done'];
    if (rawDone is List) {
      for (final entry in rawDone) {
        if (entry is int && entry >= 0) done.add(entry);
      }
    }
    var total = raw['total'] is int ? raw['total'] as int : item.pages;
    if (total <= 0) total = item.pages;

    var status = EhDownloadStatus.values.firstWhere(
      (value) => value.name == raw['status'],
      orElse: () => EhDownloadStatus.paused,
    );
    // 上次进程退出时可能仍停留在下载中，统一恢复为暂停。
    if (status == EhDownloadStatus.downloading) {
      status = EhDownloadStatus.paused;
    }
    if (total > 0 && done.length >= total) status = EhDownloadStatus.completed;

    return EhDownload(
      item: item,
      totalPages: total,
      done: done,
      status: status,
      error: raw['error']?.toString(),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        raw['updatedAt'] is int ? raw['updatedAt'] as int : 0,
      ),
    );
  }
}

/// 下载索引与文件目录：`<support>/eh_downloads/index.json` + 每个图库一个目录。
class EhDownloadStore {
  static const _indexName = 'index.json';

  static Future<Directory> rootDir() async {
    final support = await getApplicationSupportDirectory();
    final dir = Directory(
      '${support.path}${Platform.pathSeparator}eh_downloads',
    );
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  static String pagePath(Directory root, int gid, int index) {
    return '${root.path}${Platform.pathSeparator}$gid'
        '${Platform.pathSeparator}$index.img';
  }

  static Future<File> pageFile(Directory root, int gid, int index) async {
    final dir = Directory('${root.path}${Platform.pathSeparator}$gid');
    if (!await dir.exists()) await dir.create(recursive: true);
    return File(pagePath(root, gid, index));
  }

  static Future<List<EhDownload>> load(Directory root) async {
    final file = File('${root.path}${Platform.pathSeparator}$_indexName');
    if (!await file.exists()) return [];
    try {
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! List) return [];
      final result = <EhDownload>[];
      for (final entry in decoded) {
        final download = EhDownload.fromJson(entry);
        if (download != null) result.add(download);
      }
      return result;
    } catch (_) {
      // 索引损坏时按空处理，已下载文件仍保留。
      return [];
    }
  }

  static Future<void> save(
    Directory root,
    List<Map<String, Object?>> items,
  ) async {
    try {
      final file = File('${root.path}${Platform.pathSeparator}$_indexName');
      await file.writeAsString(jsonEncode(items), flush: true);
    } catch (_) {
      // 索引写入失败不影响已下载文件。
    }
  }

  static Future<void> deleteGallery(Directory root, int gid) async {
    try {
      final dir = Directory('${root.path}${Platform.pathSeparator}$gid');
      if (await dir.exists()) await dir.delete(recursive: true);
    } catch (_) {
      // 删除失败忽略，下次进入下载管理时仍可重试。
    }
  }
}

/// 下载队列：同一时间只处理一个图库，图库内 2 页并发，支持暂停/继续/删除。
class EhDownloadManager extends ChangeNotifier {
  EhDownloadManager(this.repository);

  EhRepository repository;

  final List<EhDownload> _items = [];
  final Set<int> _active = {};
  final Set<int> _cancelled = {};
  Directory? _root;
  bool _loaded = false;
  bool _disposed = false;
  Future<void>? _loadFuture;
  Future<void> _persistFuture = Future<void>.value();

  bool get loaded => _loaded;

  List<EhDownload> get downloads => List<EhDownload>.unmodifiable(_items);

  void attach(EhRepository repository) {
    this.repository = repository;
  }

  EhDownload? find(int gid) {
    for (final item in _items) {
      if (item.gid == gid) return item;
    }
    return null;
  }

  /// 本地页文件存在时返回路径，供阅读器与详情页优先读取。
  String? localPagePath(int gid, int index) {
    final root = _root;
    if (root == null) return null;
    final file = File(EhDownloadStore.pagePath(root, gid, index));
    return file.existsSync() ? file.path : null;
  }

  Future<void> load() {
    if (_loaded) return Future<void>.value();
    final existing = _loadFuture;
    if (existing != null) return existing;
    final future = _load();
    _loadFuture = future;
    return future;
  }

  Future<void> _load() async {
    try {
      final root = await EhDownloadStore.rootDir();
      if (_disposed) return;
      final loaded = await EhDownloadStore.load(root);
      if (_disposed) return;
      _root = root;
      _items
        ..clear()
        ..addAll(loaded);
      _loaded = true;
      notifyListeners();
      _schedule();
    } catch (_) {
      if (_disposed) return;
      _loaded = true;
      notifyListeners();
    }
  }

  Future<void> start(GalleryItem item, {int totalPages = 0}) async {
    if (!_loaded) await load();
    if (_disposed) return;
    final existing = find(item.gid);
    if (existing != null) {
      if (existing.status == EhDownloadStatus.completed) return;
      if (existing.status == EhDownloadStatus.downloading ||
          existing.status == EhDownloadStatus.queued) {
        return;
      }
      if (totalPages > existing.totalPages) existing.totalPages = totalPages;
      existing.status = EhDownloadStatus.queued;
      existing.error = null;
      existing.updatedAt = DateTime.now();
    } else {
      _items.insert(0, EhDownload(item: item, totalPages: totalPages));
    }
    await _persist();
    if (!_disposed) notifyListeners();
    _schedule();
  }

  Future<void> pause(int gid) async {
    final download = find(gid);
    if (download == null || download.status == EhDownloadStatus.completed) {
      return;
    }
    download.status = EhDownloadStatus.paused;
    download.error = null;
    download.updatedAt = DateTime.now();
    await _persist();
    if (!_disposed) notifyListeners();
  }

  Future<void> resume(int gid) async {
    final download = find(gid);
    if (download == null ||
        download.status == EhDownloadStatus.completed ||
        download.status == EhDownloadStatus.downloading) {
      return;
    }
    download.status = EhDownloadStatus.queued;
    download.error = null;
    download.updatedAt = DateTime.now();
    await _persist();
    if (!_disposed) notifyListeners();
    _schedule();
  }

  Future<void> delete(int gid) async {
    final download = find(gid);
    if (download == null) return;
    download.status = EhDownloadStatus.paused;
    _cancelled.add(gid);
    _items.remove(download);
    await _persist();
    if (!_disposed) notifyListeners();
    if (!_active.contains(gid)) {
      _cancelled.remove(gid);
      final root = _root;
      if (root != null) await EhDownloadStore.deleteGallery(root, gid);
    }
  }

  void _schedule() {
    if (_disposed || _active.isNotEmpty || _root == null) return;
    for (final download in _items) {
      if (download.status == EhDownloadStatus.queued) {
        unawaited(_run(download));
        return;
      }
    }
  }

  Future<void> _run(EhDownload download) async {
    final gid = download.gid;
    if (_active.contains(gid)) return;
    _active.add(gid);
    if (_disposed) {
      _active.remove(gid);
      return;
    }
    await _updateStatus(download, EhDownloadStatus.downloading);

    try {
      if (download.totalPages <= 0) {
        final detail = await repository.fetchDetail(download.item, force: true);
        final total = detail.pages > 0 ? detail.pages : detail.previews.length;
        if (total <= 0) {
          throw EhParseException(AppL10n.current.ehDownloadPagesUnknown);
        }
        download.totalPages = total;
        await _persist();
      }

      final pending = <int>[
        for (var index = 0; index < download.totalPages; index++)
          if (!download.done.contains(index)) index,
      ];

      Future<void> worker() async {
        while (!_disposed &&
            !_cancelled.contains(gid) &&
            download.status == EhDownloadStatus.downloading) {
          if (pending.isEmpty) return;
          final index = pending.removeAt(0);
          if (download.done.contains(index)) continue;
          try {
            await _downloadPage(download, index);
            download.done.add(index);
            download.updatedAt = DateTime.now();
            await _persist();
            if (!_disposed) notifyListeners();
          } on EhRateLimited catch (error) {
            pending.clear();
            await _updateStatus(
              download,
              EhDownloadStatus.paused,
              error: error.message,
            );
            return;
          } on EhException catch (error) {
            pending.clear();
            await _updateStatus(
              download,
              EhDownloadStatus.failed,
              error: error.message,
            );
            return;
          } catch (error) {
            pending.clear();
            await _updateStatus(
              download,
              EhDownloadStatus.failed,
              error: AppL10n.current.ehDownloadFailedWith('$error'),
            );
            return;
          }
        }
      }

      await Future.wait([worker(), worker()]);

      if (_disposed || _cancelled.contains(gid)) return;
      if (download.status == EhDownloadStatus.downloading) {
        if (download.totalPages > 0 &&
            download.done.length >= download.totalPages) {
          await _updateStatus(download, EhDownloadStatus.completed);
        } else {
          await _updateStatus(
            download,
            EhDownloadStatus.paused,
            error: AppL10n.current.ehDownloadPartial,
          );
        }
      }
    } on EhException catch (error) {
      await _updateStatus(
        download,
        EhDownloadStatus.failed,
        error: error.message,
      );
    } catch (error) {
      await _updateStatus(
        download,
        EhDownloadStatus.failed,
        error: AppL10n.current.ehDownloadFailedWith('$error'),
      );
    } finally {
      _active.remove(gid);
      if (_cancelled.remove(gid)) {
        final root = _root;
        if (root != null) await EhDownloadStore.deleteGallery(root, gid);
      }
      _schedule();
    }
  }

  Future<void> _downloadPage(EhDownload download, int index) async {
    var attempt = 0;
    while (true) {
      try {
        final page = await repository.fetchPage(download.item, index);
        final bytes = await repository.client.getBytes(
          Uri.parse(page.imageUrl),
          referer: page.pageUrl,
        );
        if (bytes.isEmpty) {
          throw EhParseException(AppL10n.current.ehDownloadEmptyPage);
        }
        final root = _root;
        if (root == null) {
          throw EhNetworkException(AppL10n.current.ehDownloadDirUninitialized);
        }
        final file = await EhDownloadStore.pageFile(root, download.gid, index);
        await file.writeAsBytes(bytes, flush: true);
        return;
      } on EhRateLimited {
        rethrow;
      } on EhException {
        // 单页失败重试一次，仍失败则交给队列记录状态。
        if (attempt >= 1) rethrow;
        attempt++;
        await Future<void>.delayed(const Duration(milliseconds: 600));
      }
    }
  }

  Future<void> _updateStatus(
    EhDownload download,
    EhDownloadStatus status, {
    String? error,
  }) async {
    download.status = status;
    download.error = error;
    download.updatedAt = DateTime.now();
    await _persist();
    if (!_disposed) notifyListeners();
  }

  Future<void> _persist() {
    final root = _root;
    if (root == null) return Future<void>.value();
    final snapshot = [for (final download in _items) download.toJson()];
    _persistFuture = _persistFuture
        .then((_) => EhDownloadStore.save(root, snapshot))
        .catchError((Object _) {});
    return _persistFuture;
  }

  @override
  void dispose() {
    _disposed = true;
    for (final download in _items) {
      if (download.isActive) {
        download.status = EhDownloadStatus.paused;
        download.error = AppL10n.current.ehDownloadPausedInManager;
        download.updatedAt = DateTime.now();
      }
    }
    unawaited(_persist());
    super.dispose();
  }
}
