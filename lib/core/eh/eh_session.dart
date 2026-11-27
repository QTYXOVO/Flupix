import 'dart:async';

import 'package:flutter/foundation.dart';

import '../pixiv_auth.dart';
import '../platform_capabilities.dart';
import 'eh_client.dart';
import 'eh_cookie_store.dart';
import 'eh_models.dart';
import 'eh_url.dart';

/// 登录态、站点与代理的会话容器，页面间通过构造参数共享。
class EhSession extends ChangeNotifier {
  EhSite _site = EhSite.e;
  EhCookie _cookie = const EhCookie.empty();
  String? _proxy;
  bool _loaded = false;
  EhClient? _client;

  EhSite get site => _site;
  EhCookie get cookie => _cookie;
  String? get proxy => _proxy;
  bool get loaded => _loaded;
  bool get isLoggedIn => _cookie.isLoggedIn;
  EhUrls get urls => EhUrls(_site);

  EhClient get client {
    return _client ??= EhClient(
      site: _site,
      cookie: _cookie,
      proxy: _proxy,
      onCookiesChanged: _handleCookiesChanged,
    );
  }

  /// 站点下发新 Cookie（igneous、ipb_session_id 等）时立即更新并持久化。
  void _handleCookiesChanged(EhCookie cookie) {
    _cookie = cookie;
    unawaited(EhCookieStore.save(cookie));
    notifyListeners();
  }

  Future<void> load() async {
    if (_loaded) return;
    final results = await Future.wait([
      EhCookieStore.loadSite(),
      EhCookieStore.load(),
      EhCookieStore.loadProxy(),
    ]);
    _site = results[0] as EhSite;
    var cookie = results[1] as EhCookie;
    if (cookie.values.containsKey('yay')) {
      // yay=louder 会让 ExHentai 跳过重新签发 igneous，加载时清理。
      cookie = EhCookie({...cookie.values}..remove('yay'));
      unawaited(EhCookieStore.save(cookie));
    }
    _cookie = cookie;
    final savedProxy = results[2] as String?;
    if (savedProxy == null && AppCapabilities.supportsSystemProxy) {
      _proxy = await readSystemProxy();
    } else {
      _proxy = savedProxy;
    }
    _loaded = true;
    notifyListeners();
  }

  /// 用候选 Cookie 创建临时客户端，用于手动粘贴后校验登录态。
  EhClient clientWith(EhCookie cookie) {
    return EhClient(site: _site, cookie: cookie, proxy: _proxy);
  }

  Future<void> saveCookie(EhCookie cookie) async {
    _cookie = cookie;
    await EhCookieStore.save(cookie);
    _resetClient();
    notifyListeners();
  }

  /// 用当前 Cookie 向 ExHentai 换取 igneous，成功后新 Cookie 会一并持久化。
  Future<void> refreshExAccess() async {
    await client.ensureExAccess();
    await EhCookieStore.save(_cookie);
    notifyListeners();
  }

  Future<void> clearCookie() async {
    _cookie = const EhCookie.empty();
    await EhCookieStore.clear();
    _resetClient();
    notifyListeners();
  }

  Future<void> setSite(EhSite site) async {
    if (_site == site) return;
    _site = site;
    await EhCookieStore.saveSite(site);
    _resetClient();
    notifyListeners();
  }

  void _resetClient() {
    _client?.dispose();
    _client = null;
  }

  @override
  void dispose() {
    _resetClient();
    super.dispose();
  }
}
