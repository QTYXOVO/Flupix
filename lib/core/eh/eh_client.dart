import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import '../../l10n/l10n.dart';
import 'eh_cookie_jar.dart';
import 'eh_exceptions.dart';
import 'eh_models.dart';
import 'eh_url.dart';

class _EhResponse {
  const _EhResponse(this.statusCode, this.bodyBytes, this.contentType);

  final int statusCode;
  final Uint8List bodyBytes;
  final String contentType;

  String get text => utf8.decode(bodyBytes, allowMalformed: true);
}

/// E-Hentai 网络访问：Cookie、Referer、Windows 代理、重定向与异常分类。
class EhClient {
  EhClient({
    required this.site,
    required EhCookie cookie,
    this.proxy,
    this.onCookiesChanged,
    HttpClient? httpClient,
    this.retryDelay = const Duration(milliseconds: 400),
  }) : _jar = EhCookieJar.fromCookie(cookie),
       _inner = httpClient ?? _createClient(proxy);

  static HttpClient _createClient(String? proxy) {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 20);
    final address = proxy?.trim();
    if (address != null && address.isNotEmpty) {
      client.findProxy = (_) => 'PROXY $address';
    }
    return client;
  }

  static const _userAgent =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) '
      'AppleWebKit/537.36 (KHTML, like Gecko) '
      'Chrome/131.0.0.0 Safari/537.36';

  static const _timeout = Duration(seconds: 30);
  static const _maxRedirects = 6;

  final EhSite site;
  final String? proxy;

  /// 重试退避基数，第 n 次重试等待 `retryDelay * n`。
  final Duration retryDelay;

  /// 站点下发新 Cookie（如 igneous、ipb_session_id）后回调，便于上层持久化。
  final void Function(EhCookie cookies)? onCookiesChanged;

  final HttpClient _inner;
  final EhCookieJar _jar;

  /// 当前完整的 Cookie 集合（含站点新下发的部分）。
  EhCookie get cookies => _jar.toCookie();

  EhUrls get urls => EhUrls(site);

  Future<String> getHtml(Uri url, {String? referer}) async {
    final response = await _send(url, referer: referer, includeCookie: true);
    _checkHtml(response);
    return response.text;
  }

  /// 图片请求只带 Referer，不把账号 Cookie 发给图片 CDN。
  Future<Uint8List> getBytes(Uri url, {required String referer}) async {
    final response = await _send(
      url,
      referer: referer,
      includeCookie: false,
      accept: 'image/avif,image/webp,image/apng,image/*,*/*;q=0.8',
    );
    _checkImage(response);
    return response.bodyBytes;
  }

  Future<Map<String, dynamic>> apiJson(Map<String, Object?> body) async {
    final response = await _send(
      urls.api,
      referer: '${site.baseUrl}/',
      includeCookie: true,
      method: 'POST',
      jsonBody: body,
    );
    _checkHtml(response);
    try {
      final decoded = jsonDecode(response.text);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {
      // 统一在下面抛出。
    }
    throw EhParseException(AppL10n.current.ehParseApiInvalid);
  }

  /// 登录校验：uconfig 页需要登录，未登录时会返回专门的提示页。
  Future<bool> validateLogin() async {
    final html = await getHtml(Uri.parse('https://e-hentai.org/uconfig.php'));
    return !html.contains('requires you to log on');
  }

  /// 用当前登录 Cookie 换取 ExHentai 的 igneous。
  ///
  /// 与 EhPanda 的做法一致：先移除 yay，再访问 exhentai.org，
  /// 站点会经 forums 的 remoteapi 校验登录并下发 igneous；随后按
  /// `igneous` 是否存在（以及是否为 mystery）判断里站权限。
  Future<void> ensureExAccess() async {
    // yay=louder 是“已看过 Sad Panda”的标记，保留它会让站点跳过重新签发；
    // igneous=mystery 是被站点拒绝的值，也要清掉后重新换取。
    _jar.remove('yay');
    if (_jar.valueOf('igneous', 'exhentai.org') == 'mystery') {
      _jar.remove('igneous');
    }

    final base = Uri.parse(EhSite.ex.baseUrl);
    final response = await _send(
      base,
      includeCookie: true,
      referer: '${EhSite.ex.baseUrl}/',
    );
    final text = response.text;

    if (_looksLikeCloudflare(response.statusCode, text)) {
      throw EhCloudflare();
    }
    if (_looksLikeBan(text)) {
      throw _banException(text);
    }

    final igneous = _jar.valueOf('igneous', 'exhentai.org');
    if (igneous == 'mystery') {
      throw EhAuthRequired(AppL10n.current.ehAuthIgneousMystery);
    }
    if (igneous == null || igneous.isEmpty) {
      final loggedIn = await validateLogin();
      throw EhAuthRequired(
        loggedIn
            ? AppL10n.current.ehAuthMissingCredential
            : AppL10n.current.ehAuthGetExExpired,
      );
    }
    if (text.trim().isEmpty || _looksLikeSadPanda(text)) {
      throw EhAuthRequired(AppL10n.current.ehAuthIgneousNoContent);
    }
  }

  Future<_EhResponse> _send(
    Uri url, {
    required bool includeCookie,
    String? referer,
    String? accept,
    String method = 'GET',
    Map<String, Object?>? jsonBody,
  }) async {
    final jsonText = jsonBody == null ? null : jsonEncode(jsonBody);
    var attempt = 0;
    while (true) {
      try {
        return await _follow(
          url,
          includeCookie: includeCookie,
          referer: referer,
          accept: accept,
          method: method,
          jsonText: jsonText,
        );
      } on EhException {
        rethrow;
      } on TimeoutException {
        if (attempt >= 2) {
          throw EhNetworkException(AppL10n.current.ehNetTimeout);
        }
      } on SocketException catch (error) {
        if (attempt >= 2) {
          throw EhNetworkException(
            AppL10n.current.ehNetConnectFailed(error.message),
          );
        }
      } on IOException catch (error) {
        if (attempt >= 2) {
          throw EhNetworkException(
            AppL10n.current.ehNetRequestFailed('$error'),
          );
        }
      }
      attempt++;
      await Future<void>.delayed(retryDelay * attempt);
    }
  }

  Future<_EhResponse> _follow(
    Uri url, {
    required bool includeCookie,
    String? referer,
    String? accept,
    required String method,
    String? jsonText,
  }) async {
    var currentUrl = url;
    var currentMethod = method;
    var currentBody = jsonText;

    for (var hop = 0; hop <= _maxRedirects; hop++) {
      final request = await _inner.openUrl(currentMethod, currentUrl);
      request.followRedirects = false;
      request.headers.set(HttpHeaders.userAgentHeader, _userAgent);
      request.headers.set(
        HttpHeaders.acceptHeader,
        accept ??
            'text/html,application/xhtml+xml,application/json;q=0.9,*/*;q=0.8',
      );
      request.headers.set('Accept-Language', 'en-US,en;q=0.9');
      if (referer != null) {
        request.headers.set(HttpHeaders.refererHeader, referer);
      }
      if (includeCookie) {
        final header = _jar.headerFor(currentUrl.host);
        if (header.isNotEmpty) {
          request.headers.set(HttpHeaders.cookieHeader, header);
        }
      }
      if (currentBody != null) {
        request.headers.contentType = ContentType.json;
        request.headers.set('Origin', site.baseUrl);
        request.add(utf8.encode(currentBody));
      }

      final response = await request.close().timeout(_timeout);
      _captureCookies(response, currentUrl);

      final location = response.headers.value(HttpHeaders.locationHeader);
      if (_isRedirect(response.statusCode)) {
        // 重定向响应体没有用处，读完以便复用连接。
        await response.drain<void>();
        if (location != null && location.isNotEmpty && hop < _maxRedirects) {
          final next = currentUrl.resolve(location);
          if (response.statusCode == HttpStatus.movedPermanently ||
              response.statusCode == HttpStatus.found ||
              response.statusCode == HttpStatus.seeOther) {
            currentMethod = 'GET';
            currentBody = null;
          }
          currentUrl = next;
          continue;
        }
      }

      final buffer = BytesBuilder(copy: false);
      await for (final chunk in response) {
        buffer.add(chunk);
      }
      final bytes = buffer.takeBytes();
      _flushCookies();
      return _EhResponse(
        response.statusCode,
        bytes,
        response.headers.contentType?.mimeType ?? '',
      );
    }
    throw EhNetworkException(AppL10n.current.ehNetTooManyRedirects);
  }

  void _captureCookies(HttpClientResponse response, Uri url) {
    response.headers.forEach((name, values) {
      if (name.toLowerCase() != HttpHeaders.setCookieHeader) return;
      for (final value in values) {
        _jar.applySetCookie(value, url);
      }
    });
  }

  void _flushCookies() {
    if (!_jar.dirty) return;
    _jar.markClean();
    onCookiesChanged?.call(_jar.toCookie());
  }

  bool _isRedirect(int status) {
    return status == HttpStatus.movedPermanently ||
        status == HttpStatus.found ||
        status == HttpStatus.seeOther ||
        status == HttpStatus.temporaryRedirect ||
        status == HttpStatus.permanentRedirect;
  }

  void _checkHtml(_EhResponse response) {
    final text = response.text;
    if (response.statusCode == 509 || text.contains('Exceeded allowed hits')) {
      throw EhRateLimited();
    }
    if (_looksLikeCloudflare(response.statusCode, text)) {
      throw EhCloudflare();
    }
    if (_looksLikeBan(text)) {
      throw _banException(text);
    }
    if (text.trim().isEmpty) {
      if (site == EhSite.ex) {
        throw EhAuthRequired(AppL10n.current.ehAuthEmptyExPage);
      }
      throw EhNetworkException(AppL10n.current.ehNetEmptyPage);
    }
    if (_looksLikeSadPanda(text)) {
      throw EhAuthRequired(AppL10n.current.ehAuthSadPanda);
    }
    if (text.contains('You are not logged in') ||
        text.contains('not logged in')) {
      throw EhAuthRequired(AppL10n.current.ehAuthLoginExpired);
    }
    if (response.statusCode >= 500) {
      throw EhNetworkException(
        AppL10n.current.ehNetServerError(response.statusCode),
      );
    }
    if (response.statusCode >= 400) {
      throw EhNetworkException(
        AppL10n.current.ehNetRequestStatusError(response.statusCode),
      );
    }
  }

  void _checkImage(_EhResponse response) {
    final text = response.text;
    if (response.statusCode == 509 || text.contains('Exceeded allowed hits')) {
      throw EhRateLimited();
    }
    if (_looksLikeCloudflare(response.statusCode, text)) {
      throw EhCloudflare();
    }
    if (_looksLikeBan(text)) {
      throw _banException(text);
    }
    if (_looksLikeSadPanda(text)) {
      throw EhAuthRequired(AppL10n.current.ehAuthSadPanda);
    }
    if (response.statusCode >= 400) {
      throw EhNetworkException(
        AppL10n.current.ehNetImageStatusError(response.statusCode),
      );
    }
    if (_isImage(response.contentType, response.bodyBytes)) return;
    throw EhParseException(AppL10n.current.ehParseImageNotImage);
  }

  bool _isImage(String contentType, Uint8List bytes) {
    if (contentType.toLowerCase().startsWith('image/')) return true;
    if (bytes.length < 4) return false;
    if (bytes[0] == 0xFF && bytes[1] == 0xD8) return true; // JPEG
    if (bytes[0] == 0x89 && bytes[1] == 0x50) return true; // PNG
    if (bytes[0] == 0x47 && bytes[1] == 0x49) return true; // GIF
    if (bytes[0] == 0x52 && bytes[1] == 0x49) return true; // WebP/RIFF
    return false;
  }

  bool _looksLikeBan(String text) {
    final lower = text.toLowerCase();
    return lower.contains('temporarily banned') ||
        lower.contains('excessive request rate');
  }

  EhRateLimited _banException(String text) {
    final duration = _parseBanDuration(text);
    if (duration == null) {
      return EhRateLimited(
        retryAfter: const Duration(minutes: 30),
        message: AppL10n.current.ehBanTemporary,
      );
    }
    return EhRateLimited(
      retryAfter: duration,
      message: AppL10n.current.ehBanRecoverAfter(_banLabel(duration)),
    );
  }

  /// 从封禁页的 `ban expires in 3 hours and 55 minutes` 提取剩余时间。
  Duration? _parseBanDuration(String text) {
    final match = RegExp(
      r'ban expires in ([^.]+)',
      caseSensitive: false,
    ).firstMatch(text);
    if (match == null) return null;
    final phrase = match.group(1)!;
    final hours = RegExp(
      r'(\d+)\s*hours?',
      caseSensitive: false,
    ).firstMatch(phrase);
    final minutes = RegExp(
      r'(\d+)\s*minutes?',
      caseSensitive: false,
    ).firstMatch(phrase);
    var total = Duration.zero;
    if (hours != null) total += Duration(hours: int.parse(hours.group(1)!));
    if (minutes != null) {
      total += Duration(minutes: int.parse(minutes.group(1)!));
    }
    return total == Duration.zero ? null : total;
  }

  String _banLabel(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0) {
      return AppL10n.current.ehBanLabelHoursMinutes(hours, minutes);
    }
    return AppL10n.current.ehBanLabelMinutes(minutes);
  }

  bool _looksLikeSadPanda(String text) {
    return text.contains('Sad Panda') ||
        text.toLowerCase().contains('sadpanda');
  }

  bool _looksLikeCloudflare(int status, String text) {
    if (status != 403 && status != 503) {
      return text.contains('Just a moment');
    }
    return text.contains('Just a moment') ||
        text.contains('Cloudflare') ||
        text.contains('cf-browser-verification');
  }

  void dispose() {
    _inner.close(force: true);
  }
}
