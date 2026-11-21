import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'eh_models.dart';

/// 本地收藏：保存完整列表项，离线也能展示封面与基础信息。
class EhFavoriteStore {
  static const _key = 'eh_favorites';

  static Future<List<GalleryItem>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        final items = <GalleryItem>[];
        for (final entry in decoded) {
          final item = _fromJson(entry);
          if (item != null) items.add(item);
        }
        return items;
      }
    } catch (_) {
      // 损坏的收藏按空处理。
    }
    return [];
  }

  static Future<bool> contains(int gid) async {
    final items = await load();
    return items.any((item) => item.gid == gid);
  }

  /// 返回 true 表示本次操作加入了收藏。
  static Future<bool> toggle(GalleryItem item) async {
    final items = await load();
    final index = items.indexWhere((entry) => entry.gid == item.gid);
    final added = index < 0;
    if (added) {
      items.insert(0, item);
    } else {
      items.removeAt(index);
    }
    await _save(items);
    return added;
  }

  static Future<void> remove(int gid) async {
    final items = await load();
    items.removeWhere((item) => item.gid == gid);
    await _save(items);
  }

  static Future<void> _save(List<GalleryItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode([for (final item in items) _toJson(item)]),
    );
  }

  static Map<String, Object?> _toJson(GalleryItem item) => {
    'gid': item.gid,
    'token': item.token,
    'title': item.title,
    'thumb': item.thumbUrl,
    'category': item.category,
    'rating': item.rating,
    'pages': item.pages,
    'uploader': item.uploader,
  };

  static GalleryItem? _fromJson(Object? raw) {
    if (raw is! Map) return null;
    final gid = raw['gid'];
    final token = raw['token'];
    if (gid is! int || token is! String) return null;
    return GalleryItem(
      gid: gid,
      token: token,
      title: raw['title']?.toString() ?? '',
      thumbUrl: raw['thumb']?.toString() ?? '',
      category: raw['category']?.toString() ?? '',
      rating: raw['rating'] is num ? (raw['rating'] as num).toDouble() : -1,
      pages: raw['pages'] is int ? raw['pages'] as int : 0,
      uploader: raw['uploader']?.toString(),
    );
  }
}
