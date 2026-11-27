import 'package:flutter/material.dart';

import '../../core/platform_capabilities.dart';
import '../../core/shizuku.dart';
import '../../l10n/l10n.dart';
import '../../widgets/ui_kit.dart';

class ShizukuCard extends StatefulWidget {
  const ShizukuCard({super.key});

  @override
  State<ShizukuCard> createState() => _ShizukuCardState();
}

class _ShizukuCardState extends State<ShizukuCard> with WidgetsBindingObserver {
  final ShizukuService _shizuku = ShizukuService();

  ShizukuStatus? _status;
  bool _loadingStatus = true;
  bool _requesting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (AppCapabilities.supportsShizuku) {
      _loadShizukuStatus();
    } else {
      _loadingStatus = false;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _notify(String message, {bool error = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && AppCapabilities.supportsShizuku) {
      _loadShizukuStatus();
    }
  }

  Future<void> _loadShizukuStatus() async {
    try {
      final status = await _shizuku.status();
      if (!mounted) return;
      setState(() {
        _status = status;
        _loadingStatus = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _status = null;
        _loadingStatus = false;
      });
    }
  }

  Future<void> _requestPermission() async {
    if (_requesting) return;
    setState(() => _requesting = true);
    try {
      final granted = await _shizuku.requestPermission();
      if (!mounted) return;
      final l10n = context.l10n;
      _notify(
        granted
            ? l10n.settingsShizukuGrantedMessage
            : l10n.settingsShizukuDeniedMessage,
        error: !granted,
      );
      await _loadShizukuStatus();
    } catch (error) {
      if (!mounted) return;
      _notify(context.l10n.settingsShizukuRequestFailed('$error'), error: true);
    } finally {
      if (mounted) setState(() => _requesting = false);
    }
  }

  Future<void> _openShizuku() async {
    try {
      final opened = await _shizuku.openShizuku();
      if (!mounted) return;
      if (!opened) _notify(context.l10n.settingsShizukuNotFound, error: true);
    } catch (error) {
      if (!mounted) return;
      _notify(context.l10n.settingsShizukuOpenFailed('$error'), error: true);
    }
  }

  String _statusLabel(ShizukuStatus status) {
    final l10n = context.l10n;
    if (!status.shizukuInstalled) return l10n.settingsShizukuNotInstalled;
    if (!status.shizukuRunning) return l10n.settingsShizukuNotRunning;
    if (!status.permissionGranted) return l10n.settingsShizukuNotGranted;
    if (!status.isRoot) {
      return l10n.settingsShizukuInsufficient('${status.uid}');
    }
    return l10n.settingsShizukuGrantedRoot;
  }

  String _statusDetail(ShizukuStatus status) {
    final l10n = context.l10n;
    if (!status.shizukuInstalled) {
      return l10n.settingsShizukuInstallHint;
    }
    if (!status.shizukuRunning) {
      return l10n.settingsShizukuRunHint;
    }
    if (!status.permissionGranted) {
      return l10n.settingsShizukuGrantHint;
    }
    if (!status.isRoot) {
      return l10n.settingsShizukuRootHint;
    }
    return l10n.settingsShizukuReadyHint;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final status = _status;
    final ready = status?.ready ?? false;

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TonalIcon(
                icon: Icons.shield_outlined,
                size: 46,
                background: scheme.tertiaryContainer,
                foreground: scheme.onTertiaryContainer,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.settingsShizukuTitle,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.settingsShizukuDescription,
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
          if (_loadingStatus)
            Row(
              children: [
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 10),
                Text(
                  l10n.settingsShizukuChecking,
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            )
          else if (status == null)
            Text(
              l10n.settingsShizukuError,
              style: textTheme.bodySmall?.copyWith(color: scheme.error),
            )
          else
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ready
                    ? scheme.primaryContainer
                    : scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    ready ? Icons.verified_outlined : Icons.gpp_maybe_outlined,
                    size: 20,
                    color: ready
                        ? scheme.onPrimaryContainer
                        : scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _statusLabel(status),
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: ready ? scheme.onPrimaryContainer : null,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _statusDetail(status),
                          style: textTheme.bodySmall?.copyWith(
                            color: ready
                                ? scheme.onPrimaryContainer
                                : scheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (!_loadingStatus &&
                  status != null &&
                  status.shizukuInstalled &&
                  status.shizukuRunning &&
                  !status.permissionGranted)
                FilledButton.icon(
                  onPressed: _requesting ? null : _requestPermission,
                  icon: _requesting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.key, size: 18),
                  label: Text(
                    _requesting
                        ? l10n.settingsShizukuGranting
                        : l10n.settingsShizukuGrant,
                  ),
                ),
              if (!_loadingStatus &&
                  status != null &&
                  status.shizukuInstalled &&
                  !status.shizukuRunning)
                FilledButton.tonalIcon(
                  onPressed: _openShizuku,
                  icon: const Icon(Icons.open_in_new, size: 18),
                  label: Text(l10n.settingsShizukuOpen),
                ),
              if (!_loadingStatus &&
                  status != null &&
                  status.shizukuInstalled &&
                  status.shizukuRunning &&
                  status.permissionGranted &&
                  !status.isRoot)
                FilledButton.tonalIcon(
                  onPressed: _openShizuku,
                  icon: const Icon(Icons.open_in_new, size: 18),
                  label: Text(l10n.settingsShizukuOpen),
                ),
              OutlinedButton.icon(
                onPressed: _loadingStatus ? null : _loadShizukuStatus,
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(l10n.settingsShizukuRefresh),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
