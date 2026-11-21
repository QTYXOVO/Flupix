import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../l10n/l10n.dart';
import 'eh_client.dart';
import 'eh_exceptions.dart';
import 'eh_models.dart';
import 'eh_parser.dart';
import 'eh_url.dart';

/// 串起网络与解析，并维护详情 LRU、pToken 映射。
class EhRepository {
  EhRepository(this.client);

  final EhClient client;

  final LinkedHashMap<int, GalleryDetail> _detailCache = LinkedHashMap();
  final Map<int, Map<int, String>> _pTokenMap = {};

  EhSite get site => client.site;
  EhUrls get urls => client.urls;
  EhCookie get cookie => client.cookies;

  Future<GalleryListResult> fetchList({
    int page = 0,
    String? next,
    String keyword = '',
    int excludedCategories = 0,
  }) async {
    if (site == EhSite.ex && !client.cookies.hasExAccess) {
      // 没有 igneous 时先走一次 EX 授权流程，避免直接拿到空页面。
      await client.ensureExAccess();
    }
    final html = await client.getHtml(
      urls.list(
        page: page,
        next: next,
        keyword: keyword,
        excludedCategories: excludedCategories,
      ),
    );
    final result = parseGalleryList(html, baseUrl: site.baseUrl);
    if (site == EhSite.ex &&
        result.items.isEmpty &&
        result.pages == 0 &&
        result.nextCursor == null &&
        !html.contains('No hits found')) {
      throw EhAuthRequired(AppL10n.current.ehAuthEmptyList);
    }
    final filled = await _fillMissing(result.items);
    return GalleryListResult(
      items: filled,
      pages: result.pages,
      nextPage: result.nextPage,
      nextCursor: result.nextCursor,
      totalResults: result.totalResults,
    );
  }

  Future<List<GalleryItem>> _fillMissing(List<GalleryItem> items) async {
    final missing = items
        .where((item) => item.rating < 0 || item.pages <= 0)
        .take(25)
        .toList();
    if (missing.isEmpty) return items;

    try {
      final json = await client.apiJson({
        'method': 'gdata',
        'gidlist': [
          for (final item in missing) [item.gid, item.token],
        ],
        'namespace': 1,
      });
      final metadata = json['gmetadata'];
      if (metadata is! List) return items;

      final byGid = <int, GalleryItem>{};
      for (final entry in metadata) {
        if (entry is! Map) continue;
        final parsed = parseGdataItem(Map<String, dynamic>.from(entry));
        if (parsed != null) byGid[parsed.gid] = parsed;
      }
      final result = <GalleryItem>[];
      for (final item in items) {
        final meta = byGid[item.gid];
        if (meta == null) {
          result.add(item);
          continue;
        }
        result.add(
          item.copyWith(
            title: meta.title.isEmpty ? null : meta.title,
            thumbUrl: meta.thumbUrl.isEmpty ? null : meta.thumbUrl,
            category: meta.category.isEmpty ? null : meta.category,
            rating: meta.rating >= 0 ? meta.rating : null,
            pages: meta.pages > 0 ? meta.pages : null,
            uploader: meta.uploader?.isNotEmpty == true ? meta.uploader : null,
          ),
        );
      }
      return result;
    } on EhException {
      // 补充信息失败不影响列表本身。
      return items;
    }
  }

  Future<GalleryDetail> fetchDetail(
    GalleryItem item, {
    int previewPage = 0,
    bool force = false,
  }) async {
    if (previewPage == 0 && !force) {
      final cached = _detailCache.remove(item.gid);
      if (cached != null) {
        _detailCache[item.gid] = cached;
        _rememberPreviews(cached);
        return cached;
      }
    }

    final html = await client.getHtml(
      urls.detail(item.gid, item.token, previewPage: previewPage),
      referer: urls.detail(item.gid, item.token).toString(),
    );
    final detail = parseGalleryDetail(html, item: item, baseUrl: site.baseUrl);
    _rememberPreviews(detail);

    if (previewPage == 0) {
      _detailCache.remove(item.gid);
      _detailCache[item.gid] = detail;
      while (_detailCache.length > 25) {
        _detailCache.remove(_detailCache.keys.first);
      }
    }
    return detail;
  }

  void _rememberPreviews(GalleryDetail detail) {
    final map = _pTokenMap.putIfAbsent(detail.gid, () => {});
    for (final preview in detail.previews) {
      map[preview.index] = preview.pToken;
    }
  }

  Future<String> ensurePToken(GalleryItem item, int index) async {
    final map = _pTokenMap.putIfAbsent(item.gid, () => {});
    final existing = map[index];
    if (existing != null) return existing;

    final previewPage = index ~/ 20;
    final html = await client.getHtml(
      urls.detail(item.gid, item.token, previewPage: previewPage),
      referer: urls.detail(item.gid, item.token).toString(),
    );
    final detail = parseGalleryDetail(html, item: item, baseUrl: site.baseUrl);
    _rememberPreviews(detail);

    final pToken = map[index];
    if (pToken == null) {
      throw EhParseException(AppL10n.current.ehParsePTokenMissing);
    }
    return pToken;
  }

  Future<GalleryPage> fetchPage(GalleryItem item, int index) async {
    final pToken = await ensurePToken(item, index);
    final pageUrl = urls.imagePage(pToken, item.gid, index);
    final html = await client.getHtml(
      pageUrl,
      referer: urls.detail(item.gid, item.token).toString(),
    );
    var parsed = parseImagePage(html);

    if (parsed.imageUrl == null || parsed.imageUrl!.isEmpty) {
      final showKey = parsed.showKey;
      if (showKey == null || showKey.isEmpty) {
        throw EhParseException(AppL10n.current.ehParseShowkeyMissing);
      }
      final json = await client.apiJson({
        'method': 'showpage',
        'gid': item.gid,
        'page': index + 1,
        'imgkey': pToken,
        'showkey': showKey,
      });
      final fragments = [
        json['i3']?.toString() ?? '',
        json['i6']?.toString() ?? '',
      ].join();
      parsed = parseImagePage(fragments);
    }

    final imageUrl = parsed.imageUrl;
    if (imageUrl == null || imageUrl.isEmpty) {
      throw EhParseException(AppL10n.current.ehParseImageUrlFailed);
    }

    return GalleryPage(
      index: index,
      pToken: pToken,
      pageUrl: pageUrl.toString(),
      imageUrl: imageUrl,
    );
  }

  void dispose() => client.dispose();
}

/// 阅读进度（MVP 存 SharedPreferences）。
class EhProgressStore {
  static String _key(int gid) => 'eh_progress_$gid';

  static Future<ReadingProgress?> load(int gid) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(gid));
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return ReadingProgress.fromJson(decoded);
      }
    } catch (_) {
      // 损坏的进度按未读处理。
    }
    return null;
  }

  /// 汇总所有图库的阅读进度，按最近阅读时间倒序。
  static Future<List<ReadingProgress>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final result = <ReadingProgress>[];
    for (final key in prefs.getKeys()) {
      if (!key.startsWith('eh_progress_')) continue;
      final raw = prefs.getString(key);
      if (raw == null || raw.isEmpty) continue;
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          final progress = ReadingProgress.fromJson(decoded);
          if (progress != null) result.add(progress);
        }
      } catch (_) {
        // 单条损坏不影响其它记录。
      }
    }
    result.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return result;
  }

  static Future<void> save({
    required GalleryItem item,
    required int lastPage,
    required int totalPages,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final progress = ReadingProgress(
      gid: item.gid,
      token: item.token,
      title: item.title,
      thumbUrl: item.thumbUrl,
      lastPage: lastPage,
      totalPages: totalPages,
      updatedAt: DateTime.now(),
    );
    await prefs.setString(_key(item.gid), jsonEncode(progress.toJson()));
  }

  static Future<void> clear(int gid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key(gid));
  }
}

/// 图片字节的统一入口：先磁盘缓存，再带 Referer 请求。
class EhImageLoader {
  const EhImageLoader._();

  static Future<Uint8List> loadBytes(
    EhClient client, {
    required String url,
    required String referer,
  }) async {
    final key = EhDiskCache.keyFor(url, referer);
    final cached = await EhDiskCache.instance.read(key);
    if (cached != null) return cached;
    final bytes = await client.getBytes(Uri.parse(url), referer: referer);
    await EhDiskCache.instance.write(key, bytes);
    return bytes;
  }
}

/// 简易磁盘 LRU：文件名是 URL + Referer 的 SHA-1。
class EhDiskCache {
  EhDiskCache._();

  static final EhDiskCache instance = EhDiskCache._();

  static const int _maxBytes = 512 * 1024 * 1024;

  Directory? _directory;
  int _writes = 0;
  bool _evicting = false;

  static String keyFor(String url, String referer) {
    return sha1.convert(utf8.encode('$url|$referer')).toString();
  }

  Future<Directory> _ensureDirectory() async {
    final cached = _directory;
    if (cached != null) return cached;
    final support = await getApplicationSupportDirectory();
    final dir = Directory(
      '${support.path}${Platform.pathSeparator}eh_image_cache',
    );
    if (!await dir.exists()) await dir.create(recursive: true);
    _directory = dir;
    return dir;
  }

  Future<Uint8List?> read(String key) async {
    try {
      final dir = await _ensureDirectory();
      final file = File('${dir.path}${Platform.pathSeparator}$key.img');
      if (!await file.exists()) return null;
      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) {
        await file.delete();
        return null;
      }
      await file.setLastModified(DateTime.now());
      return bytes;
    } catch (_) {
      return null;
    }
  }

  Future<void> write(String key, Uint8List bytes) async {
    if (bytes.isEmpty) return;
    try {
      final dir = await _ensureDirectory();
      final file = File('${dir.path}${Platform.pathSeparator}$key.img');
      await file.writeAsBytes(bytes, flush: true);
      _writes++;
      if (_writes % 20 == 0 && !_evicting) {
        _evicting = true;
        await _evict();
        _evicting = false;
      }
    } catch (_) {
      // 缓存失败不影响阅读。
    }
  }

  Future<void> _evict() async {
    try {
      final dir = await _ensureDirectory();
      final files = <File>[];
      var total = 0;
      await for (final entity in dir.list()) {
        if (entity is! File) continue;
        final stat = await entity.stat();
        total += stat.size;
        files.add(entity);
      }
      if (total <= _maxBytes) return;
      files.sort((a, b) {
        final aTime = a.statSync().modified;
        final bTime = b.statSync().modified;
        return aTime.compareTo(bTime);
      });
      for (final file in files) {
        if (total <= _maxBytes) break;
        final size = await file.length();
        await file.delete();
        total -= size;
      }
    } catch (_) {
      // 清理失败忽略。
    }
  }
}
