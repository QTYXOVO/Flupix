import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../core/pixiv_auth.dart';
import '../l10n/l10n.dart';

/// pixiv 官方登录页，登录完成后自动截获重定向中的授权码。
class PixivOAuthPage extends StatefulWidget {
  const PixivOAuthPage({super.key, required this.challenge});

  final String challenge;

  @override
  State<PixivOAuthPage> createState() => _PixivOAuthPageState();
}

class _PixivOAuthPageState extends State<PixivOAuthPage> {
  double _progress = 0;
  bool _handled = false;

  bool _tryHandle(String? url) {
    final code = extractAuthCode(url);
    if (code == null || _handled) return false;
    _handled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.of(context).pop(code);
    });
    return true;
  }

  bool _isExternalScheme(String? url) {
    if (url == null || url.isEmpty) return false;
    return !url.startsWith('http://') &&
        !url.startsWith('https://') &&
        !url.startsWith('about:');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.pixivLoginTitle),
        bottom: _progress < 1
            ? PreferredSize(
                preferredSize: const Size.fromHeight(3),
                child: LinearProgressIndicator(
                  value: _progress <= 0 ? null : _progress,
                  minHeight: 3,
                ),
              )
            : null,
      ),
      body: Column(
        children: [
          Expanded(
            child: InAppWebView(
              initialUrlRequest: URLRequest(
                url: WebUri(buildPixivLoginUrl(widget.challenge)),
              ),
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                domStorageEnabled: true,
                thirdPartyCookiesEnabled: true,
                useShouldOverrideUrlLoading: true,
                supportZoom: false,
                transparentBackground: false,
              ),
              onProgressChanged: (controller, progress) {
                if (mounted) setState(() => _progress = progress / 100);
              },
              onLoadStart: (controller, url) {
                _tryHandle(url?.toString());
              },
              onUpdateVisitedHistory: (controller, url, isReload) {
                _tryHandle(url?.toString());
              },
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                final url = navigationAction.request.url?.toString();
                if (_tryHandle(url)) {
                  return NavigationActionPolicy.CANCEL;
                }
                // pixiv 的 pixiv:// 等自定义协议在 WebView 中无法打开，直接拦截。
                if (_isExternalScheme(url)) {
                  return NavigationActionPolicy.CANCEL;
                }
                return NavigationActionPolicy.ALLOW;
              },
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            color: scheme.surfaceContainerLow,
            child: Text(
              l10n.pixivLoginPageHint,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

/// 打开 pixiv 网页版，用于读取 WebAPI 所需的 PHPSESSID Cookie。
class PixivCookiePage extends StatefulWidget {
  const PixivCookiePage({super.key});

  @override
  State<PixivCookiePage> createState() => _PixivCookiePageState();
}

class _PixivCookiePageState extends State<PixivCookiePage> {
  bool _collecting = false;

  Future<void> _collect() async {
    if (_collecting) return;
    setState(() => _collecting = true);
    try {
      final cookies = await CookieManager.instance().getCookies(
        url: WebUri('https://www.pixiv.net'),
      );
      final session = cookies
          .where((cookie) => cookie.name == 'PHPSESSID')
          .map((cookie) => cookie.value)
          .firstWhere((value) => value.isNotEmpty, orElse: () => '');
      if (!mounted) return;
      if (session.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.pixivPhpSessionMissing)),
        );
        return;
      }
      Navigator.of(context).pop(session);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.pixivCookieReadFailed)),
      );
    } finally {
      if (mounted) setState(() => _collecting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.pixivCookiePageTitle),
        actions: [
          TextButton(
            onPressed: _collecting ? null : _collect,
            child: Text(
              _collecting ? l10n.pixivReadingCookie : l10n.commonDone,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri('https://www.pixiv.net')),
        initialSettings: InAppWebViewSettings(
          javaScriptEnabled: true,
          domStorageEnabled: true,
          thirdPartyCookiesEnabled: true,
        ),
      ),
    );
  }
}
