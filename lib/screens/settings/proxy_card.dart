import 'package:flutter/material.dart';

import '../../core/eh/eh_cookie_store.dart';
import '../../core/pixiv_auth.dart';
import '../../core/platform_capabilities.dart';
import '../../l10n/l10n.dart';
import '../../widgets/ui_kit.dart';

class ProxyCard extends StatefulWidget {
  const ProxyCard({super.key});

  @override
  State<ProxyCard> createState() => _ProxyCardState();
}

class _ProxyCardState extends State<ProxyCard> {
  final PixivProxyStore _proxyStore = PixivProxyStore();
  final TextEditingController _proxyController = TextEditingController();
  bool _savingProxy = false;

  @override
  void initState() {
    super.initState();
    if (AppCapabilities.supportsSystemProxy) {
      _loadProxy();
    }
  }

  @override
  void dispose() {
    _proxyController.dispose();
    super.dispose();
  }

  void _notify(String message, {bool error = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _loadProxy() async {
    final saved = await _proxyStore.load() ?? await EhCookieStore.loadProxy();
    final proxy = saved ?? await readSystemProxy();
    if (!mounted) return;
    setState(() => _proxyController.text = proxy ?? '');
  }

  Future<void> _saveProxy() async {
    if (_savingProxy) return;
    setState(() => _savingProxy = true);
    final address = _proxyController.text.trim();
    try {
      await _proxyStore.save(address);
      await EhCookieStore.saveProxy(address);
      if (!mounted) return;
      FocusScope.of(context).unfocus();
      final l10n = context.l10n;
      _notify(
        address.isEmpty
            ? l10n.settingsProxyDirect
            : l10n.settingsProxySaved(address),
      );
    } finally {
      if (mounted) setState(() => _savingProxy = false);
    }
  }

  Future<void> _useSystemProxy() async {
    final proxy = await readSystemProxy();
    if (!mounted) return;
    if (proxy == null) {
      _notify(context.l10n.settingsProxySystemMissing, error: true);
      return;
    }
    setState(() => _proxyController.text = proxy);
    await _saveProxy();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TonalIcon(
                icon: Icons.vpn_lock_outlined,
                size: 46,
                background: scheme.secondaryContainer,
                foreground: scheme.onSecondaryContainer,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.settingsProxyTitle,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.settingsProxyDescription,
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _proxyController,
            keyboardType: TextInputType.url,
            decoration: InputDecoration(
              labelText: l10n.settingsProxyAddress,
              hintText: '127.0.0.1:7890',
              prefixIcon: const Icon(Icons.lan_outlined),
            ),
            onSubmitted: (_) => _saveProxy(),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.tonalIcon(
                onPressed: _savingProxy ? null : _saveProxy,
                icon: const Icon(Icons.check_rounded),
                label: Text(
                  _savingProxy
                      ? l10n.settingsProxySaving
                      : l10n.settingsProxySave,
                ),
              ),
              TextButton.icon(
                onPressed: _savingProxy ? null : _useSystemProxy,
                icon: const Icon(Icons.settings_ethernet_rounded, size: 18),
                label: Text(l10n.settingsProxyReadSystem),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
