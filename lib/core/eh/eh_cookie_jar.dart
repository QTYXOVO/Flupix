import 'dart:io';

import 'eh_models.dart';

/// 带作用域的 Cookie，避免把 ExHentai 的 igneous 发给 E-Hentai，
/// 也避免把论坛的 cf_clearance 发给别的域名。
class JarCookie {
  const JarCookie({
    required this.name,
    required this.value,
    required this.domain,
    required this.hostOnly,
    this.expires,
  });

  final String name;
  final String value;
  final String domain;
  final bool hostOnly;
  final DateTime? expires;

  bool get expired => expires != null && expires!.isBefore(DateTime.now());

  bool matches(String host) {
    if (expired) return false;
    if (hostOnly) return host == domain;
    return host == domain || host.endsWith('.$domain');
  }
}

/// E-Hentai 系站点的 Cookie Jar。
///
/// 站点在新的登录流程里会通过 302 链下发 Cookie（例如 ExHentai 的 igneous），
/// 必须自行保存每一跳的 Set-Cookie，单靠 package:http 会丢失这些凭证。
class EhCookieJar {
  EhCookieJar(this._cookies);

  factory EhCookieJar.fromCookie(EhCookie cookie) {
    final cookies = <JarCookie>[];
    for (final entry in cookie.values.entries) {
      final name = entry.key;
      final value = entry.value.trim();
      if (value.isEmpty) continue;
      if (name == 'igneous' || name == 'yay') {
        cookies.add(
          JarCookie(
            name: name,
            value: value,
            domain: _exDomain,
            hostOnly: false,
          ),
        );
      } else if (name.startsWith('cf_') || name.startsWith('__cf')) {
        cookies.add(
          JarCookie(
            name: name,
            value: value,
            domain: _ehDomain,
            hostOnly: false,
          ),
        );
      } else {
        // 登录 Cookie 与偏好属于论坛域名，同时同步给里站。
        cookies.add(
          JarCookie(
            name: name,
            value: value,
            domain: _ehDomain,
            hostOnly: false,
          ),
        );
        if (name.startsWith('ipb_') || name == 'nw' || name == 'sp') {
          cookies.add(
            JarCookie(
              name: name,
              value: value,
              domain: _exDomain,
              hostOnly: false,
            ),
          );
        }
      }
    }
    return EhCookieJar(cookies);
  }

  static const _ehDomain = 'e-hentai.org';
  static const _exDomain = 'exhentai.org';

  final List<JarCookie> _cookies;
  bool _dirty = false;

  bool get dirty => _dirty;

  void markClean() => _dirty = false;

  String? valueOf(String name, String host) {
    for (final cookie in _cookies.reversed) {
      if (cookie.name == name && cookie.matches(host)) return cookie.value;
    }
    return null;
  }

  String headerFor(String host) {
    final parts = <String>[];
    final seen = <String>{};
    for (final cookie in _cookies) {
      if (!cookie.matches(host)) continue;
      if (!seen.add(cookie.name)) continue;
      parts.add('${cookie.name}=${cookie.value}');
    }
    return parts.join('; ');
  }

  void remove(String name) {
    final before = _cookies.length;
    _cookies.removeWhere((cookie) => cookie.name == name);
    if (_cookies.length != before) _dirty = true;
  }

  void applySetCookie(String header, Uri url) {
    final segments = header.split(';');
    final pair = segments.first.trim();
    final index = pair.indexOf('=');
    if (index <= 0) return;

    final name = pair.substring(0, index).trim();
    final value = pair.substring(index + 1).trim();
    if (name.isEmpty) return;

    String? domain;
    DateTime? expires;
    for (final segment in segments.skip(1)) {
      final separator = segment.indexOf('=');
      final key = (separator < 0 ? segment : segment.substring(0, separator))
          .trim()
          .toLowerCase();
      final attribute = separator < 0
          ? ''
          : segment.substring(separator + 1).trim();
      if (key == 'domain' && attribute.isNotEmpty) {
        domain = attribute.startsWith('.') ? attribute.substring(1) : attribute;
      } else if (key == 'max-age') {
        final seconds = int.tryParse(attribute);
        if (seconds != null) {
          expires = DateTime.now().add(Duration(seconds: seconds));
        }
      } else if (key == 'expires' && expires == null) {
        expires = _parseHttpDate(attribute);
      }
    }

    final scope = domain ?? url.host;
    final before = _cookies.length;
    _cookies.removeWhere(
      (cookie) => cookie.name == name && cookie.domain == scope,
    );
    final removed = _cookies.length != before;

    // 空值或已过期表示服务端要求删除该 Cookie。
    if (value.isEmpty ||
        (expires != null && expires.isBefore(DateTime.now()))) {
      if (removed) _dirty = true;
      return;
    }

    _cookies.add(
      JarCookie(
        name: name,
        value: value,
        domain: scope,
        hostOnly: domain == null,
        expires: expires,
      ),
    );
    _dirty = true;
  }

  EhCookie toCookie() {
    final values = <String, String>{};
    for (final cookie in _cookies) {
      if (cookie.expired) continue;
      values[cookie.name] = cookie.value;
    }
    return EhCookie(values);
  }

  DateTime? _parseHttpDate(String value) {
    try {
      return HttpDate.parse(value);
    } catch (_) {
      // HttpDate 对非法日期抛 HttpException，按无过期时间处理。
      return null;
    }
  }
}
