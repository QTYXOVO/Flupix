import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// pixiv 官方 App 使用的 OAuth 客户端参数（与 pixivpy 保持一致）。
const String pixivClientId = 'MOBrBDS8blbauoSck0ZfDbtuzpyT';
const String pixivClientSecret = 'lsACyCD94FhDUtGTXi3QzcFE2uU1hqtDaKeqrdwj';
const String pixivRedirectUri =
    'https://app-api.pixiv.net/web/v1/users/auth/pixiv/callback';
const String pixivTokenUrl = 'https://oauth.secure.pixiv.net/auth/token';
const String pixivLoginUrl = 'https://app-api.pixiv.net/web/v1/login';
const String pixivUserAgent = 'PixivAndroidApp/5.0.234 (Android 11; Pixel 5)';

class PixivAuthException implements Exception {
  PixivAuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

class PkcePair {
  const PkcePair({required this.verifier, required this.challenge});

  final String verifier;
  final String challenge;
}

class PixivUser {
  const PixivUser({
    required this.id,
    required this.name,
    required this.account,
    this.avatarUrl,
  });

  final String id;
  final String name;
  final String account;
  final String? avatarUrl;

  factory PixivUser.fromJson(Map<String, dynamic> json) {
    final profileImages = json['profile_image_urls'];
    String? avatar;
    if (profileImages is Map) {
      avatar = (profileImages['px_100x100'] ?? profileImages['px_170x170'])
          ?.toString();
    }
    return PixivUser(
      id: '${json['id'] ?? ''}',
      name: (json['name'] ?? '').toString(),
      account: (json['account'] ?? '').toString(),
      avatarUrl: avatar,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'account': account,
        'profile_image_urls': {'px_100x100': avatarUrl},
      };
}

class PixivToken {
  const PixivToken({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.obtainedAt,
    this.user,
  });

  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final DateTime obtainedAt;
  final PixivUser? user;

  DateTime get expiresAt => obtainedAt.add(Duration(seconds: expiresIn));

  Duration get remaining => expiresAt.difference(DateTime.now());

  bool get isExpired => remaining.isNegative;

  factory PixivToken.fromJson(Map<String, dynamic> json) {
    return PixivToken(
      accessToken: (json['access_token'] ?? '').toString(),
      refreshToken: (json['refresh_token'] ?? '').toString(),
      expiresIn: (json['expires_in'] as num?)?.toInt() ?? 3600,
      obtainedAt: DateTime.fromMillisecondsSinceEpoch(
        (json['obtained_at'] as num?)?.toInt() ?? 0,
      ),
      user: json['user'] is Map<String, dynamic>
          ? PixivUser.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'access_token': accessToken,
        'refresh_token': refreshToken,
        'expires_in': expiresIn,
        'obtained_at': obtainedAt.millisecondsSinceEpoch,
        if (user != null) 'user': user!.toJson(),
      };

  /// 由接口响应构造，同时记录获取时间。
  factory PixivToken.fromResponse(Map<String, dynamic> json) {
    return PixivToken(
      accessToken: (json['access_token'] ?? '').toString(),
      refreshToken: (json['refresh_token'] ?? '').toString(),
      expiresIn: (json['expires_in'] as num?)?.toInt() ?? 3600,
      obtainedAt: DateTime.now(),
      user: json['user'] is Map<String, dynamic>
          ? PixivUser.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// 生成本次登录专用的 PKCE 校验对。
PkcePair generatePkcePair() {
  final random = Random.secure();
  final verifierBytes = List<int>.generate(32, (_) => random.nextInt(256));
  final verifier = _base64Url(verifierBytes);
  final challenge = _base64Url(sha256.convert(utf8.encode(verifier)).bytes);
  return PkcePair(verifier: verifier, challenge: challenge);
}

String _base64Url(List<int> bytes) =>
    base64Url.encode(bytes).replaceAll('=', '');

String buildPixivLoginUrl(String challenge) {
  return '$pixivLoginUrl?code_challenge=${Uri.encodeComponent(challenge)}'
      '&code_challenge_method=S256&client=pixiv-android';
}

/// pixiv 登录成功后会把授权码拼在这些地址里返回。
String? extractAuthCode(String? url) {
  if (url == null || url.isEmpty) return null;
  if (url.startsWith('pixiv://account/login') ||
      url.startsWith(pixivRedirectUri)) {
    final queryStart = url.indexOf('?');
    if (queryStart < 0 || queryStart + 1 >= url.length) return null;
    return Uri.splitQueryString(url.substring(queryStart + 1))['code'];
  }
  return null;
}

class PixivAuth {
  PixivAuth({this.proxy});

  /// 形如 `127.0.0.1:7890`，为空表示直连。
  String? proxy;

  http.Client _buildClient() {
    final inner = HttpClient()
      ..connectionTimeout = const Duration(seconds: 20);
    final address = proxy?.trim();
    if (address != null && address.isNotEmpty) {
      inner.findProxy = (_) => 'PROXY $address';
    }
    return IOClient(inner);
  }

  Future<Map<String, dynamic>> _requestToken(
    Map<String, String> extra,
  ) async {
    final client = _buildClient();
    http.Response response;
    try {
      response = await client
          .post(
            Uri.parse(pixivTokenUrl),
            headers: {
              'Content-Type': 'application/x-www-form-urlencoded',
              'User-Agent': pixivUserAgent,
              'App-OS': 'android',
              'App-OS-Version': '11',
              'App-Version': '5.0.234',
            },
            body: {
              'client_id': pixivClientId,
              'client_secret': pixivClientSecret,
              'include_policy': 'true',
              ...extra,
            },
          )
          .timeout(const Duration(seconds: 30));
    } on SocketException catch (error) {
      final reason = error.osError?.message ?? error.message;
      throw PixivAuthException(
        '无法连接 pixiv 服务器（$reason）。'
        'oauth.secure.pixiv.net 在中国大陆通常无法直连，请先配置代理。',
      );
    } on TimeoutException {
      throw PixivAuthException('请求超时，请检查网络状态或代理地址是否正确。');
    } on http.ClientException catch (error) {
      // IOClient 会把 SocketException 包装成 ClientException，这里单独还原提示。
      if (error.message.contains('SocketException')) {
        final address = proxy?.trim();
        final target = (address == null || address.isEmpty) ? '当前为直连' : '当前代理 $address';
        throw PixivAuthException('无法连接 pixiv 服务器（$target），请确认代理已开启且地址正确。');
      }
      throw PixivAuthException('网络请求失败：${error.message}');
    } finally {
      client.close();
    }

    Map<String, dynamic> json;
    try {
      json = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    } catch (_) {
      throw PixivAuthException('服务器返回了无法解析的内容（HTTP ${response.statusCode}）');
    }

    final hasError = json['has_error'] == true;
    if (response.statusCode >= 400 || hasError) {
      final system = json['errors'];
      final message = (system is Map && system['system'] is Map)
          ? system['system']['message']?.toString()
          : null;
      throw PixivAuthException(
        message ??
            json['error_description']?.toString() ??
            json['error']?.toString() ??
            'HTTP ${response.statusCode}',
      );
    }
    return json;
  }

  Future<PixivToken> exchangeCode({
    required String code,
    required String verifier,
  }) async {
    final json = await _requestToken({
      'grant_type': 'authorization_code',
      'code': code,
      'code_verifier': verifier,
      'redirect_uri': pixivRedirectUri,
    });
    return PixivToken.fromResponse(json);
  }

  Future<PixivToken> refresh(String refreshToken) async {
    final json = await _requestToken({
      'grant_type': 'refresh_token',
      'refresh_token': refreshToken,
    });
    return PixivToken.fromResponse(json);
  }
}

/// 代理地址持久化（形如 `127.0.0.1:7890`）。
class PixivProxyStore {
  static const String _key = 'pixiv_proxy';

  Future<String?> load() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_key)?.trim();
    if (raw == null || raw.isEmpty) return null;
    return raw;
  }

  Future<void> save(String value) async {
    final preferences = await SharedPreferences.getInstance();
    final address = value.trim();
    if (address.isEmpty) {
      await preferences.remove(_key);
    } else {
      await preferences.setString(_key, address);
    }
  }
}

/// 读取 Windows「Internet 选项」中的系统代理，其余平台返回 null。
Future<String?> readSystemProxy() async {
  if (!Platform.isWindows) return null;
  try {
    final enabled = await Process.run('reg', [
      'query',
      r'HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings',
      '/v',
      'ProxyEnable',
    ]);
    if (enabled.exitCode != 0) return null;
    if (!enabled.stdout.toString().contains('0x1')) return null;

    final server = await Process.run('reg', [
      'query',
      r'HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings',
      '/v',
      'ProxyServer',
    ]);
    if (server.exitCode != 0) return null;
    final match =
        RegExp(r'ProxyServer\s+REG_SZ\s+(.+)').firstMatch(server.stdout.toString());
    final raw = match?.group(1)?.trim();
    if (raw == null || raw.isEmpty) return null;

    var value = raw;
    if (value.contains('=')) {
      final map = <String, String>{};
      for (final part in value.split(';')) {
        final index = part.indexOf('=');
        if (index <= 0) continue;
        map[part.substring(0, index).trim().toLowerCase()] =
            part.substring(index + 1).trim();
      }
      value = map['https'] ?? map['http'] ?? '';
    }
    value = value.replaceFirst(RegExp(r'^https?://', caseSensitive: false), '');
    return value.isEmpty ? null : value;
  } catch (_) {
    return null;
  }
}

/// Token 仅保存在本机偏好存储中，不会上传到任何第三方服务。
class PixivTokenStore {
  static const String _key = 'pixiv_token_record';

  Future<PixivToken?> load() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_key);
    if (raw == null || raw.isEmpty) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final token = PixivToken.fromJson(json);
      if (token.accessToken.isEmpty) return null;
      return token;
    } catch (_) {
      return null;
    }
  }

  Future<void> save(PixivToken token) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_key, jsonEncode(token.toJson()));
  }

  Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_key);
  }
}
