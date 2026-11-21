import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

/// 应用对应的 GitHub 仓库。
const String kUpdateRepoOwner = 'QTYXOVO';
const String kUpdateRepoName = 'Flupix';

/// 一次 GitHub Release 查询的结果。
class AppRelease {
  const AppRelease({
    required this.version,
    required this.tagName,
    required this.title,
    required this.notes,
    required this.releaseUrl,
    this.downloadUrl,
  });

  /// 去掉 `v` 前缀后的版本号，例如 `1.2.0`。
  final String version;

  final String tagName;
  final String title;

  /// Markdown 格式的更新说明，可能为空。
  final String notes;

  final Uri releaseUrl;

  /// 与当前平台匹配的下载地址，未找到时为 null。
  final Uri? downloadUrl;
}

class UpdateCheckResult {
  const UpdateCheckResult({required this.release, required this.hasUpdate});

  final AppRelease release;
  final bool hasUpdate;
}

class UpdateCheckException implements Exception {
  const UpdateCheckException(this.message, {this.statusCode});

  final String message;

  /// HTTP 状态码，网络错误时为 null。
  final int? statusCode;

  @override
  String toString() => message;
}

/// 通过 GitHub Releases 检查应用更新。
class UpdateService {
  UpdateService({http.Client? client, String? proxy})
    : _client = client ?? _createClient(proxy);

  final http.Client _client;

  /// 与应用内代理设置保持一致；为空时直连。
  static http.Client _createClient(String? proxy) {
    final inner = HttpClient()
      ..connectionTimeout = const Duration(seconds: 15);
    final address = proxy?.trim();
    if (address != null && address.isNotEmpty) {
      inner.findProxy = (_) => 'PROXY $address';
    }
    return IOClient(inner);
  }

  Uri get latestReleaseApi => Uri.parse(
    'https://api.github.com/repos/$kUpdateRepoOwner/$kUpdateRepoName/releases/latest',
  );

  static Uri get releasesPage => Uri.parse(
    'https://github.com/$kUpdateRepoOwner/$kUpdateRepoName/releases/latest',
  );

  Future<UpdateCheckResult> checkForUpdate(String currentVersion) async {
    final release = await fetchLatestRelease();
    return UpdateCheckResult(
      release: release,
      hasUpdate: compareVersions(release.version, currentVersion) > 0,
    );
  }

  Future<AppRelease> fetchLatestRelease() async {
    final http.Response response;
    try {
      response = await _client
          .get(
            latestReleaseApi,
            headers: const {
              'Accept': 'application/vnd.github+json',
              'X-GitHub-Api-Version': '2022-11-28',
              'User-Agent': 'Flupix-Updater',
            },
          )
          .timeout(const Duration(seconds: 15));
    } on TimeoutException {
      throw const UpdateCheckException('请求超时');
    } on SocketException catch (error) {
      throw UpdateCheckException('网络连接失败：${error.message}');
    } on http.ClientException catch (error) {
      throw UpdateCheckException('网络请求失败：${error.message}');
    }

    if (response.statusCode != 200) {
      final reason = response.statusCode == 404
          ? '尚未发布任何版本'
          : 'HTTP ${response.statusCode}';
      throw UpdateCheckException(reason, statusCode: response.statusCode);
    }

    final Object? decoded;
    try {
      decoded = jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      throw const UpdateCheckException('返回数据格式异常');
    }
    if (decoded is! Map<String, dynamic>) {
      throw const UpdateCheckException('返回数据格式异常');
    }

    final tagName = (decoded['tag_name'] as String? ?? '').trim();
    final version = normalizeVersion(tagName);
    if (version.isEmpty) {
      throw const UpdateCheckException('版本号缺失');
    }

    final assets = (decoded['assets'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>();
    final htmlUrl = decoded['html_url'] as String?;
    final releaseUrl = htmlUrl == null || htmlUrl.isEmpty
        ? releasesPage
        : Uri.tryParse(htmlUrl) ?? releasesPage;

    return AppRelease(
      version: version,
      tagName: tagName,
      title: (decoded['name'] as String? ?? '').trim(),
      notes: (decoded['body'] as String? ?? '').trim(),
      releaseUrl: releaseUrl,
      downloadUrl: _pickDownloadUrl(assets),
    );
  }

  void close() => _client.close();

  Uri? _pickDownloadUrl(Iterable<Map<String, dynamic>> assets) {
    final candidates = <(String, Uri)>[];
    for (final asset in assets) {
      final name = (asset['name'] as String? ?? '').toLowerCase();
      final url = Uri.tryParse(asset['browser_download_url'] as String? ?? '');
      if (name.isEmpty || url == null) continue;
      candidates.add((name, url));
    }

    String? best;
    if (Platform.isAndroid) {
      best = _firstMatching(candidates, (name) => name.contains('android') && name.endsWith('.apk')) ??
          _firstMatching(candidates, (name) => name.endsWith('.apk'));
    } else if (Platform.isWindows) {
      best = _firstMatching(candidates, (name) => name.contains('windows') && name.endsWith('.zip')) ??
          _firstMatching(candidates, (name) => name.endsWith('.zip'));
    }
    return best == null ? null : Uri.parse(best);
  }

  String? _firstMatching(List<(String, Uri)> candidates, bool Function(String) test) {
    for (final (name, url) in candidates) {
      if (test(name)) return url.toString();
    }
    return null;
  }
}

/// 去掉可能存在的 `v` 前缀。
String normalizeVersion(String raw) =>
    raw.trim().replaceFirst(RegExp(r'^[vV]'), '');

/// 比较两个版本号，返回 -1 / 0 / 1；非数字段按 0 处理。
int compareVersions(String a, String b) {
  final left = _versionParts(a);
  final right = _versionParts(b);
  final length = left.length > right.length ? left.length : right.length;
  for (var i = 0; i < length; i++) {
    final l = i < left.length ? left[i] : 0;
    final r = i < right.length ? right[i] : 0;
    if (l != r) return l > r ? 1 : -1;
  }
  return 0;
}

List<int> _versionParts(String raw) {
  final core = normalizeVersion(raw).split('+').first.split('-').first;
  return [
    for (final part in core.split('.'))
      int.tryParse(part.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
  ];
}
