import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../core/eh/eh_exceptions.dart';
import '../../core/eh/eh_models.dart';
import '../../core/eh/eh_session.dart';
import '../../l10n/l10n.dart';

/// E-Hentai / ExHentai 登录：WebView 抓 Cookie，手动粘贴兜底。
class EhLoginPage extends StatefulWidget {
  const EhLoginPage({super.key, required this.session});

  final EhSession session;

  @override
  State<EhLoginPage> createState() => _EhLoginPageState();
}

class _EhLoginPageState extends State<EhLoginPage> {
  final _manualController = TextEditingController();
  bool _capturing = false;
  bool _validating = false;
  bool _checkingEx = false;
  bool _autoExTried = false;
  String? _message;
  InAppWebViewController? _webController;
  Completer<EhCookie>? _webExCompleter;

  static const _loginUrl =
      'https://forums.e-hentai.org/index.php?act=Login&CODE=01';

  @override
  void dispose() {
    _manualController.dispose();
    super.dispose();
  }

  /// 分别读取论坛/主站与里站的 Cookie。
  ///
  /// 里站只用来补充 igneous、yay 等专属字段，避免旧的 ipb_* 覆盖论坛刚登录的结果。
  Future<EhCookie> _readCookies() async {
    final manager = CookieManager.instance();
    final account = <String, String>{};
    final ex = <String, String>{};
    for (final url in const [
      'https://forums.e-hentai.org/',
      'https://e-hentai.org/',
    ]) {
      try {
        final cookies = await manager.getCookies(url: WebUri(url));
        for (final cookie in cookies) {
          if (cookie.value.isNotEmpty) account[cookie.name] = cookie.value;
        }
      } catch (_) {
        // 单个域名读取失败不影响其它域名。
      }
    }
    try {
      final cookies = await manager.getCookies(
        url: WebUri('https://exhentai.org/'),
      );
      for (final cookie in cookies) {
        if (cookie.value.isNotEmpty) ex[cookie.name] = cookie.value;
      }
    } catch (_) {
      // 里站 Cookie 缺失时仍可继续，稍后会重新换取 igneous。
    }

    final values = <String, String>{...account};
    for (final entry in ex.entries) {
      if (entry.key == 'igneous' ||
          entry.key == 'yay' ||
          !values.containsKey(entry.key)) {
        values[entry.key] = entry.value;
      }
    }
    return EhCookie(values);
  }

  bool _sameAccount(EhCookie a, EhCookie b) {
    if (!a.isLoggedIn || !b.isLoggedIn) return false;
    return a.memberId == b.memberId && a.passHash == b.passHash;
  }

  void _pop() {
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  Future<void> _captureCookies({bool popOnSuccess = false}) async {
    if (_capturing) return;
    setState(() {
      _capturing = true;
      _message = null;
    });
    try {
      final cookie = await _readCookies();
      if (!mounted) return;

      if (!cookie.isLoggedIn) {
        setState(() => _message = context.l10n.ehLoginNoCookie);
        return;
      }

      final current = widget.session.cookie;
      final sameAccount = _sameAccount(current, cookie);
      if (sameAccount && current.hasExAccess) {
        // 同一登录态且已有里站凭证，不再重复校验。
        if (popOnSuccess) _pop();
        return;
      }

      final probe = widget.session.clientWith(cookie);
      var ok = false;
      try {
        ok = await probe.validateLogin();
      } on EhException catch (error) {
        if (mounted) setState(() => _message = error.message);
      } finally {
        probe.dispose();
      }
      if (!ok) {
        if (mounted && _message == null) {
          setState(() => _message = context.l10n.ehLoginNotEffective);
        }
        return;
      }

      final merged = sameAccount ? current.merge(cookie) : cookie;
      await widget.session.saveCookie(merged);
      if (!mounted) return;

      if (!merged.hasExAccess && !_autoExTried) {
        _autoExTried = true;
        await _refreshEx(quiet: true);
      } else if (merged.hasExAccess) {
        setState(() => _message = context.l10n.ehLoginGotCookies);
      }
      if (popOnSuccess) _pop();
    } finally {
      if (mounted) setState(() => _capturing = false);
    }
  }

  /// 用 Dart 侧客户端访问 ExHentai 换取 igneous（参考 EhPanda 的 IgneousRequest）。
  ///
  /// 原生请求被站点拒绝时，退回 WebView 走一次真实浏览器流程再读 Cookie。
  Future<void> _refreshEx({bool quiet = false}) async {
    if (_checkingEx) return;
    final l10n = context.l10n;
    setState(() {
      _checkingEx = true;
      _message = quiet
          ? l10n.ehLoginRefreshingExAfterLogin
          : l10n.ehLoginRefreshingEx;
    });
    try {
      await widget.session.refreshExAccess();
      if (!mounted) return;
      setState(() => _message = context.l10n.ehLoginExGranted);
    } on EhException catch (error) {
      final fallback = await _fetchExViaWebView();
      final igneous = fallback?.igneous;
      if (igneous != null && igneous != 'mystery') {
        await widget.session.saveCookie(widget.session.cookie.merge(fallback!));
        if (!mounted) return;
        setState(() => _message = context.l10n.ehLoginExGrantedViaWeb);
      } else {
        if (!mounted) return;
        setState(() => _message = error.message);
      }
    } finally {
      if (mounted) setState(() => _checkingEx = false);
    }
  }

  /// 让 WebView 访问一次 ExHentai，等待页面加载完成后读取 Cookie。
  Future<EhCookie?> _fetchExViaWebView() async {
    final controller = _webController;
    if (controller == null) return null;
    final completer = Completer<EhCookie>();
    _webExCompleter = completer;
    try {
      await controller.loadUrl(
        urlRequest: URLRequest(url: WebUri('https://exhentai.org/')),
      );
      return await completer.future.timeout(
        const Duration(seconds: 30),
        onTimeout: () => const EhCookie.empty(),
      );
    } catch (_) {
      return null;
    } finally {
      if (identical(_webExCompleter, completer)) _webExCompleter = null;
    }
  }

  /// 只清除 E-Hentai 系站点的 Cookie，避免影响其它工具的网页登录。
  Future<void> _clearWebCookies() async {
    if (_capturing || _checkingEx) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(dialogContext.l10n.ehLoginClearWebCookiesTitle),
        content: Text(dialogContext.l10n.ehLoginClearWebCookiesMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(dialogContext.l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(dialogContext.l10n.ehLoginClearWebCookiesConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _message = context.l10n.ehLoginClearingCookies);
    final manager = CookieManager.instance();
    for (final host in const [
      'https://forums.e-hentai.org/',
      'https://e-hentai.org/',
      'https://exhentai.org/',
      'https://s.exhentai.org/',
    ]) {
      final url = WebUri(host);
      try {
        final cookies = await manager.getCookies(url: url);
        for (final cookie in cookies) {
          await manager.deleteCookie(
            url: url,
            name: cookie.name,
            path: cookie.path ?? '/',
            domain: cookie.domain,
          );
        }
      } catch (_) {
        // 单个域名清理失败不影响其它域名。
      }
    }

    await widget.session.clearCookie();
    _autoExTried = false;
    _manualController.clear();
    if (!mounted) return;
    await _webController?.loadUrl(
      urlRequest: URLRequest(url: WebUri(_loginUrl)),
    );
    if (!mounted) return;
    setState(() => _message = context.l10n.ehLoginClearedCookies);
  }

  Future<void> _detectEx() async {
    if (_checkingEx) return;
    final cookie = await _readCookies();
    if (!mounted) return;

    if (!cookie.isLoggedIn && !widget.session.isLoggedIn) {
      setState(() => _message = context.l10n.ehLoginLoginFirst);
      return;
    }
    if (cookie.isLoggedIn) {
      final current = widget.session.cookie;
      final merged = _sameAccount(current, cookie)
          ? current.merge(cookie)
          : cookie;
      if (merged.headerValue != current.headerValue) {
        await widget.session.saveCookie(merged);
      }
    }
    await _refreshEx();
  }

  Future<void> _validateManual() async {
    final cookie = EhCookie.parse(_manualController.text);
    if (!cookie.isLoggedIn) {
      setState(() => _message = context.l10n.ehLoginManualMissing);
      return;
    }
    setState(() {
      _validating = true;
      _message = null;
    });
    final probe = widget.session.clientWith(cookie);
    try {
      final ok = await probe.validateLogin();
      if (!mounted) return;
      if (!ok) {
        setState(() => _message = context.l10n.ehLoginCookieInvalid);
        return;
      }
      await widget.session.saveCookie(cookie);
      if (!mounted) return;
      await _refreshEx(quiet: true);
      if (mounted) _pop();
    } on EhException catch (error) {
      if (mounted) setState(() => _message = error.message);
    } finally {
      probe.dispose();
      if (mounted) setState(() => _validating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.ehLoginTitle),
          actions: [
            TextButton(
              onPressed: _capturing
                  ? null
                  : () async {
                      await _captureCookies(popOnSuccess: true);
                    },
              child: Text(_capturing ? l10n.ehLoginReading : l10n.commonDone),
            ),
            const SizedBox(width: 8),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.ehLoginTabWeb),
              Tab(text: l10n.ehLoginTabManual),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: TabBarView(
                children: [
                  _buildWebViewTab(scheme, textTheme),
                  _buildManualTab(scheme, textTheme),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
              color: scheme.surfaceContainerLow,
              child: Text(
                _message ?? l10n.ehLoginHint,
                style: textTheme.bodySmall?.copyWith(
                  color: _message == null
                      ? scheme.onSurfaceVariant
                      : scheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebViewTab(ColorScheme scheme, TextTheme textTheme) {
    final l10n = context.l10n;
    return Column(
      children: [
        Expanded(
          child: InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(_loginUrl)),
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              domStorageEnabled: true,
              thirdPartyCookiesEnabled: true,
              supportZoom: true,
            ),
            onWebViewCreated: (controller) {
              _webController = controller;
            },
            onLoadStop: (controller, url) async {
              final completer = _webExCompleter;
              if (completer != null &&
                  (url?.host ?? '').endsWith('exhentai.org')) {
                final cookie = await _readCookies();
                _webExCompleter = null;
                if (!completer.isCompleted) completer.complete(cookie);
                return;
              }
              await _captureCookies();
            },
            onReceivedError: (controller, request, error) {
              if (request.isForMainFrame ?? false) {
                setState(
                  () =>
                      _message = l10n.ehLoginPageLoadFailed(error.description),
                );
              }
            },
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          color: scheme.surfaceContainerLow,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  l10n.ehLoginAutoHint,
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
              TextButton(
                onPressed: (_capturing || _checkingEx)
                    ? null
                    : _clearWebCookies,
                child: Text(l10n.ehLoginClearCookie),
              ),
              TextButton(
                onPressed: (_checkingEx || _capturing) ? null : _detectEx,
                child: Text(
                  _checkingEx ? l10n.ehLoginDetecting : l10n.ehLoginDetectEx,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildManualTab(ColorScheme scheme, TextTheme textTheme) {
    final l10n = context.l10n;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          l10n.ehLoginManualHint,
          style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _manualController,
          maxLines: 7,
          minLines: 5,
          style: textTheme.bodySmall,
          decoration: const InputDecoration(
            labelText: 'Cookie',
            hintText: 'ipb_member_id: ...\nipb_pass_hash: ...\nigneous: ...',
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: _validating ? null : _validateManual,
          icon: _validating
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.check),
          label: Text(
            _validating ? l10n.ehLoginValidating : l10n.ehLoginValidateAndSave,
          ),
        ),
      ],
    );
  }
}
