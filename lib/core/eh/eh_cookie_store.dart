import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'eh_models.dart';

/// Cookie 与站点相关的轻量持久化。
class EhCookieStore {
  static const _cookieKey = 'eh_cookie';
  static const _siteKey = 'eh_site';
  static const _proxyKey = 'eh_proxy';

  static Future<EhCookie> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cookieKey);
    if (raw == null || raw.isEmpty) return const EhCookie.empty();
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return EhCookie.fromJson(decoded);
    } catch (_) {
      // 旧数据损坏时按未登录处理。
    }
    return const EhCookie.empty();
  }

  static Future<void> save(EhCookie cookie) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cookieKey, jsonEncode(cookie.toJson()));
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cookieKey);
  }

  static Future<EhSite> loadSite() async {
    final prefs = await SharedPreferences.getInstance();
    return EhSite.fromName(prefs.getString(_siteKey));
  }

  static Future<void> saveSite(EhSite site) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_siteKey, site.name);
  }

  static Future<String?> loadProxy() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_proxyKey)?.trim();
    return value == null || value.isEmpty ? null : value;
  }

  static Future<void> saveProxy(String? proxy) async {
    final prefs = await SharedPreferences.getInstance();
    final value = proxy?.trim();
    if (value == null || value.isEmpty) {
      await prefs.remove(_proxyKey);
    } else {
      await prefs.setString(_proxyKey, value);
    }
  }
}
