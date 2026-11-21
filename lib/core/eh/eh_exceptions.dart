import '../../l10n/l10n.dart';

/// E-Hentai 客户端统一异常。页面只需区分这几种，避免把底层异常直接抛给 UI。
sealed class EhException implements Exception {
  const EhException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// 网络不可达、超时、连接被重置等。
class EhNetworkException extends EhException {
  const EhNetworkException(super.message);
}

/// E-Hentai 图片服务器 509 限流，或 IP 因请求过快被临时封禁。
class EhRateLimited extends EhException {
  EhRateLimited({
    this.retryAfter = const Duration(seconds: 60),
    String? message,
  }) : super(message ?? AppL10n.current.ehErrorRateLimited);

  final Duration retryAfter;
}

/// Cloudflare 验证页或 403 拦截。
class EhCloudflare extends EhException {
  EhCloudflare() : super(AppL10n.current.ehErrorCloudflare);
}

/// 未登录、Cookie 失效，或 ExHentai 没有访问权限。
class EhAuthRequired extends EhException {
  const EhAuthRequired(super.message);
}

/// HTML/JSON 结构与预期不符。
class EhParseException extends EhException {
  const EhParseException(super.message);
}
