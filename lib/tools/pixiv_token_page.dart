import 'dart:async';

import 'dart:io' show Platform;

import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../core/pixiv_auth.dart';
import '../widgets/ui_kit.dart';
import 'pixiv_login_page.dart';

class PixivTokenPage extends StatefulWidget {
  const PixivTokenPage({super.key});

  @override
  State<PixivTokenPage> createState() => _PixivTokenPageState();
}

class _PixivTokenPageState extends State<PixivTokenPage> {
  final PixivAuth _auth = PixivAuth();
  final PixivTokenStore _store = PixivTokenStore();
  final PixivProxyStore _proxyStore = PixivProxyStore();
  final TextEditingController _proxyController = TextEditingController();

  PixivToken? _token;
  Timer? _ticker;
  bool _busy = false;
  bool _showAccess = false;
  bool _showRefresh = false;
  String? _message;
  bool _isError = false;
  String? _phpSessionId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _token != null) setState(() {});
    });
    _restore();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _proxyController.dispose();
    super.dispose();
  }

  Future<void> _restore() async {
    final token = await _store.load();
    // 代理仅在 Windows 桌面端提供，移动端由系统级代理/VPN 接管。
    final proxy = Platform.isWindows
        ? await _proxyStore.load() ?? await readSystemProxy()
        : null;
    if (!mounted) return;
    setState(() {
      _token = token;
      _proxyController.text = proxy ?? '';
      _auth.proxy = proxy;
      _loading = false;
    });
  }

  Future<void> _applyProxy() async {
    final address = _proxyController.text.trim();
    _auth.proxy = address.isEmpty ? null : address;
    await _proxyStore.save(address);
    if (!mounted) return;
    FocusScope.of(context).unfocus();
    _notify(address.isEmpty ? '已切换为直连' : '代理已保存：$address');
  }

  Future<void> _useSystemProxy() async {
    final proxy = await readSystemProxy();
    if (!mounted) return;
    if (proxy == null) {
      _notify('未检测到已启用的系统代理，请先开启代理软件', error: true);
      return;
    }
    setState(() => _proxyController.text = proxy);
    await _applyProxy();
  }

  void _notify(String message, {bool error = false}) {
    setState(() {
      _message = message;
      _isError = error;
    });
  }

  Future<void> _login() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _message = null;
    });
    final pkce = generatePkcePair();
    try {
      final code = await Navigator.of(context).push<String>(
        MaterialPageRoute<String>(
          builder: (_) => PixivOAuthPage(challenge: pkce.challenge),
        ),
      );
      if (code == null) {
        _notify('已取消登录');
        return;
      }
      final token = await _auth.exchangeCode(code: code, verifier: pkce.verifier);
      await _store.save(token);
      if (!mounted) return;
      setState(() {
        _token = token;
        _showAccess = false;
        _showRefresh = false;
      });
      _notify('登录成功，已获取 Token');
    } on PixivAuthException catch (error) {
      _notify(error.message, error: true);
    } catch (error) {
      _notify('登录失败：$error', error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _refresh() async {
    final token = _token;
    if (token == null || _busy) return;
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final refreshed = await _auth.refresh(token.refreshToken);
      await _store.save(refreshed);
      if (!mounted) return;
      setState(() => _token = refreshed);
      _notify('Token 已刷新');
    } on PixivAuthException catch (error) {
      _notify(error.message, error: true);
    } catch (error) {
      _notify('刷新失败：$error', error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _clear() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除本地数据'),
        content: const Text('将删除本机保存的 access_token 与 refresh_token，之后需要重新登录。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('清除'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _store.clear();
    if (!mounted) return;
    setState(() {
      _token = null;
      _phpSessionId = null;
      _showAccess = false;
      _showRefresh = false;
    });
    _notify('已清除本地 Token');
  }

  Future<void> _fetchCookie() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final session = await Navigator.of(context).push<String>(
        MaterialPageRoute<String>(builder: (_) => const PixivCookiePage()),
      );
      if (!mounted) return;
      if (session == null) return;
      setState(() => _phpSessionId = session);
      _notify('已获取 PHPSESSID');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _mask(String value) {
    if (value.isEmpty) return '—';
    if (value.length <= 10) return '•' * value.length;
    return '${value.substring(0, 6)}••••••••${value.substring(value.length - 4)}';
  }

  String get _expiryLabel {
    final token = _token;
    if (token == null) return '';
    if (token.isExpired) return '已过期，请刷新';
    final remaining = token.remaining;
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes % 60;
    final seconds = remaining.inSeconds % 60;
    return '剩余 ${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final token = _token;

    return ToolPage(
      title: 'Pixiv Token',
      subtitle: 'OAuth 登录获取与刷新令牌',
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                _AccountCard(
                  token: token,
                  expiryLabel: _expiryLabel,
                  busy: _busy,
                  onLogin: _login,
                  onRefresh: _refresh,
                  onClear: _clear,
                ),
                if (_message != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        _isError ? Icons.error_outline : Icons.check_circle_outline,
                        size: 18,
                        color: _isError ? scheme.error : scheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _message!,
                          style: textTheme.bodySmall?.copyWith(
                            color: _isError ? scheme.error : scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (token != null) ...[
                  const SizedBox(height: 16),
                  SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('令牌', style: textTheme.titleSmall),
                            const Spacer(),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              tooltip: '复制全部',
                              onPressed: () => copyText(
                                context,
                                'access_token: ${token.accessToken}\n'
                                    'refresh_token: ${token.refreshToken}',
                              ),
                              icon: const Icon(Icons.copy_all_rounded, size: 20),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _TokenBlock(
                          label: 'access_token',
                          value: token.accessToken,
                          visible: _showAccess,
                          onToggle: () =>
                              setState(() => _showAccess = !_showAccess),
                          masked: _mask(token.accessToken),
                        ),
                        const Divider(height: 26),
                        _TokenBlock(
                          label: 'refresh_token',
                          value: token.refreshToken,
                          visible: _showRefresh,
                          onToggle: () =>
                              setState(() => _showRefresh = !_showRefresh),
                          masked: _mask(token.refreshToken),
                        ),
                      ],
                    ),
                  ),
                ],
                if (Platform.isWindows) ...[
                  const SizedBox(height: 16),
                  SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.vpn_lock_outlined,
                              size: 18,
                              color: scheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 6),
                            Text('网络代理', style: textTheme.titleSmall),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'pixiv 认证接口在国内通常无法直连，可填写 HTTP 代理地址；'
                          '留空表示直连。',
                          style: textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _proxyController,
                          keyboardType: TextInputType.url,
                          decoration: const InputDecoration(
                            labelText: '代理地址',
                            hintText: '127.0.0.1:7890',
                            prefixIcon: Icon(Icons.lan_outlined),
                          ),
                          onSubmitted: (_) => _applyProxy(),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            FilledButton.tonalIcon(
                              onPressed: _applyProxy,
                              icon: const Icon(Icons.check_rounded),
                              label: const Text('保存代理'),
                            ),
                            TextButton.icon(
                              onPressed: _useSystemProxy,
                              icon: const Icon(
                                Icons.settings_ethernet_rounded,
                                size: 18,
                              ),
                              label: const Text('读取系统代理'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Web 端 Cookie', style: textTheme.titleSmall),
                      const SizedBox(height: 4),
                      Text(
                        'Pixeval 等使用 WebAPI 的工具需要 PHPSESSID，'
                        '需在 pixiv 网页版登录后读取。',
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_phpSessionId != null)
                        CopyableValue(
                          label: 'PHPSESSID',
                          value: 'PHPSESSID=$_phpSessionId',
                        ),
                      const SizedBox(height: 8),
                      FilledButton.tonalIcon(
                        onPressed: _busy ? null : _fetchCookie,
                        icon: const Icon(Icons.cookie_outlined),
                        label: Text(
                          _phpSessionId == null ? '获取 pixiv.net Cookie' : '重新获取',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SectionCard(
                  color: scheme.surfaceContainerHigh,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.shield_outlined,
                            size: 18,
                            color: scheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '安全提示',
                            style: textTheme.labelLarge?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'access_token 与 refresh_token 等同于账号凭证，请勿分享或提交到公开仓库。'
                        '令牌仅保存在本机，除 pixiv 官方域名外不会向任何服务器发送数据。',
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({
    required this.token,
    required this.expiryLabel,
    required this.busy,
    required this.onLogin,
    required this.onRefresh,
    required this.onClear,
  });

  final PixivToken? token;
  final String expiryLabel;
  final bool busy;
  final VoidCallback onLogin;
  final VoidCallback onRefresh;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final user = token?.user;

    return SectionCard(
      color: scheme.primaryContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Avatar(url: user?.avatarUrl, scheme: scheme),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.name.isNotEmpty == true
                          ? user!.name
                          : (token == null ? '未登录' : '已登录'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium?.copyWith(
                        color: scheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user == null
                          ? '登录后可获取 access_token 与 refresh_token'
                          : '@${user.account} · UID ${user.id}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onPrimaryContainer.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (token != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: scheme.onPrimaryContainer.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    token!.isExpired
                        ? Icons.error_outline
                        : Icons.timelapse_rounded,
                    size: 15,
                    color: scheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    expiryLabel,
                    style: textTheme.labelMedium?.copyWith(
                      color: scheme.onPrimaryContainer,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (token == null)
                FilledButton.icon(
                  onPressed: busy ? null : onLogin,
                  icon: busy
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.login_rounded),
                  label: Text(busy ? '处理中…' : '登录 pixiv'),
                )
              else ...[
                FilledButton.icon(
                  onPressed: busy ? null : onRefresh,
                  icon: busy
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh_rounded),
                  label: Text(busy ? '处理中…' : '刷新 Token'),
                ),
                FilledButton.tonalIcon(
                  onPressed: busy ? null : onLogin,
                  icon: const Icon(Icons.swap_horiz_rounded),
                  label: const Text('重新登录'),
                ),
                TextButton.icon(
                  onPressed: busy ? null : onClear,
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('清除'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.url, required this.scheme});

  final String? url;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: scheme.onPrimaryContainer.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        Icons.person_outline_rounded,
        color: scheme.onPrimaryContainer,
      ),
    );
    if (url == null || url!.isEmpty) return fallback;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.network(
        url!,
        width: 52,
        height: 52,
        fit: BoxFit.cover,
        // pixiv 图片服务器要求带 Referer，否则会拒绝访问。
        headers: const {'Referer': 'https://app-api.pixiv.net/'},
        errorBuilder: (_, _, _) => fallback,
      ),
    );
  }
}

class _TokenBlock extends StatelessWidget {
  const _TokenBlock({
    required this.label,
    required this.value,
    required this.visible,
    required this.onToggle,
    required this.masked,
  });

  final String label;
  final String value;
  final bool visible;
  final VoidCallback onToggle;
  final String masked;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: textTheme.labelSmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            IconButton(
              visualDensity: VisualDensity.compact,
              tooltip: visible ? '隐藏' : '显示',
              onPressed: onToggle,
              icon: Icon(
                visible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                size: 18,
                color: scheme.onSurfaceVariant,
              ),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              tooltip: '复制',
              onPressed: () => copyText(context, value),
              icon: Icon(
                Icons.copy_rounded,
                size: 18,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        SelectableText(
          visible ? value : masked,
          style: textTheme.bodyMedium?.copyWith(
            fontFamily: 'monospace',
            letterSpacing: 0.4,
            height: 1.45,
            color: visible ? scheme.onSurface : scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
