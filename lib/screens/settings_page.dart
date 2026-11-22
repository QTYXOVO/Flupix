import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/app_settings.dart';
import '../core/app_theme.dart';
import '../core/eh/eh_cookie_store.dart';
import '../core/pixiv_auth.dart';
import '../core/shizuku.dart';
import '../core/update_service.dart';
import '../l10n/l10n.dart';
import '../widgets/ui_kit.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.settings});

  final AppSettings settings;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with WidgetsBindingObserver {
  static const MethodChannel _apkInstaller = MethodChannel(
    'flupix/apk_installer',
  );

  final ShizukuService _shizuku = ShizukuService();
  final PixivProxyStore _proxyStore = PixivProxyStore();
  final TextEditingController _proxyController = TextEditingController();

  ShizukuStatus? _status;
  bool _loadingStatus = true;
  bool _requesting = false;
  bool _savingProxy = false;
  bool _checkingUpdate = false;
  String? _appVersion;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadAppVersion();
    if (Platform.isAndroid) {
      _loadShizukuStatus();
    } else {
      _loadingStatus = false;
    }
    if (Platform.isWindows) {
      _loadProxy();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _proxyController.dispose();
    super.dispose();
  }

  Future<void> _loadAppVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (!mounted) return;
      setState(() => _appVersion = info.version);
    } catch (_) {
      if (!mounted) return;
      setState(() => _appVersion = '');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && Platform.isAndroid) {
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

  Future<String?> _loadUpdateProxy() async {
    if (!Platform.isWindows) return null;
    return await _proxyStore.load() ??
        await EhCookieStore.loadProxy() ??
        await readSystemProxy();
  }

  Future<void> _checkForUpdate() async {
    if (_checkingUpdate) return;
    setState(() => _checkingUpdate = true);
    UpdateService? service;
    try {
      service = UpdateService(proxy: await _loadUpdateProxy());
      final current = _appVersion ?? '';
      final result = await service.checkForUpdate(
        current.isEmpty ? '0.0.0' : current,
      );
      if (!mounted) return;
      if (!result.hasUpdate) {
        _notify(context.l10n.settingsUpdateLatest(_appVersion ?? '—'));
        return;
      }
      await _showUpdateDialog(result.release);
    } catch (error) {
      if (!mounted) return;
      final message = error is UpdateCheckException
          ? error.message
          : '$error';
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            // 带操作按钮的 SnackBar 默认会常驻，这里强制超时后自动消失。
            persist: false,
            duration: const Duration(seconds: 5),
            content: Text(context.l10n.settingsUpdateCheckFailed(message)),
            action: SnackBarAction(
              label: context.l10n.settingsUpdateOpenReleases,
              onPressed: _openReleasesPage,
            ),
          ),
        );
    } finally {
      service?.close();
      if (mounted) setState(() => _checkingUpdate = false);
    }
  }

  Future<void> _showUpdateDialog(AppRelease release) async {
    final l10n = context.l10n;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final scheme = Theme.of(dialogContext).colorScheme;
        final textTheme = Theme.of(dialogContext).textTheme;
        final downloadPath = release.downloadUrl?.path.toLowerCase() ?? '';
        final canAutoUpdate =
            (Platform.isWindows && downloadPath.endsWith('.exe')) ||
            (Platform.isAndroid && downloadPath.endsWith('.apk'));
        return AlertDialog(
          icon: const Icon(Icons.system_update_rounded),
          title: Text(l10n.settingsUpdateAvailableTitle(release.version)),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.settingsUpdateCurrentVersion(_appVersion ?? '—'),
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.settingsUpdateReleaseNotes,
                    style: textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  if (release.notes.isEmpty)
                    Text(
                      l10n.settingsUpdateNoNotes,
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    )
                  else
                    SelectableText(release.notes, style: textTheme.bodySmall),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.commonCancel),
            ),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                if (canAutoUpdate) {
                  _startUpdate(release);
                } else {
                  _openReleaseUrl(release.downloadUrl ?? release.releaseUrl);
                }
              },
              icon: Icon(
                canAutoUpdate
                    ? Icons.system_update_alt_rounded
                    : Icons.download_rounded,
                size: 18,
              ),
              label: Text(
                canAutoUpdate
                    ? l10n.settingsUpdateInstall
                    : l10n.settingsUpdateDownload,
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _startUpdate(AppRelease release) async {
    final url = release.downloadUrl;
    if (url == null) {
      await _openReleaseUrl(release.releaseUrl);
      return;
    }
    final isWindowsInstaller =
        Platform.isWindows && url.path.toLowerCase().endsWith('.exe');
    final isAndroidPackage =
        Platform.isAndroid && url.path.toLowerCase().endsWith('.apk');
    if (!isWindowsInstaller && !isAndroidPackage) {
      await _openReleaseUrl(url);
      return;
    }

    final progress = ValueNotifier<double?>(null);
    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => PopScope(
          canPop: false,
          child: _UpdateProgressDialog(
            version: release.version,
            progress: progress,
          ),
        ),
      ),
    );

    UpdateService? service;
    var dialogOpen = true;
    try {
      service = UpdateService(proxy: await _loadUpdateProxy());
      final fallbackName = isWindowsInstaller
          ? 'Flupix-setup.exe'
          : 'Flupix-update.apk';
      final fileName = url.pathSegments.isEmpty
          ? fallbackName
          : url.pathSegments.last;
      final tempDir = await getTemporaryDirectory();
      final updateDir = Directory(
        '${tempDir.path}${Platform.pathSeparator}updates',
      );
      await updateDir.create(recursive: true);
      final package = File(
        '${updateDir.path}${Platform.pathSeparator}$fileName',
      );
      await service.downloadFile(
        url,
        package,
        onProgress: (received, total) {
          if (total != null && total > 0) {
            progress.value = received / total;
          }
        },
      );
      progress.value = 1;

      final hashUrl = release.sha256Url;
      if (hashUrl != null) {
        final text = await service.fetchText(hashUrl);
        final expected = text.trim().split(RegExp(r'\s+')).first.toLowerCase();
        final actual = await service.sha256OfFile(package);
        if (expected.isNotEmpty && actual.toLowerCase() != expected) {
          throw const UpdateCheckException('安装包校验失败，请重试');
        }
      }

      if (isWindowsInstaller) {
        await Process.start(
          package.path,
          const [
            '/VERYSILENT',
            '/SUPPRESSMSGBOXES',
            '/NORESTART',
            '/CLOSEAPPLICATIONS',
            '/RESTARTAPPLICATIONS',
          ],
          mode: ProcessStartMode.detached,
        );
        await Future<void>.delayed(const Duration(milliseconds: 500));
        exit(0);
      }

      final canInstall =
          await _apkInstaller.invokeMethod<bool>('canInstall') ?? true;
      if (!canInstall) {
        await _apkInstaller.invokeMethod<void>('openInstallSettings');
        if (dialogOpen && mounted) {
          Navigator.of(context, rootNavigator: true).pop();
          dialogOpen = false;
        }
        if (mounted) _notify(context.l10n.settingsUpdateInstallPermission);
        return;
      }

      if (dialogOpen && mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        dialogOpen = false;
      }
      await _apkInstaller.invokeMethod<void>('install', {'path': package.path});
    } catch (error) {
      if (dialogOpen && mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        dialogOpen = false;
      }
      if (!mounted) return;
      final message = error is UpdateCheckException
          ? error.message
          : error is PlatformException
          ? error.message ?? error.code
          : '$error';
      _notify(context.l10n.settingsUpdateFailed(message), error: true);
    } finally {
      service?.close();
    }
  }

  Future<void> _openReleasesPage() =>
      _openReleaseUrl(UpdateService.releasesPage);

  Future<void> _openReleaseUrl(Uri url) async {
    try {
      final opened = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!opened && mounted) {
        _notify(context.l10n.settingsUpdateOpenFailed, error: true);
      }
    } catch (_) {
      if (!mounted) return;
      _notify(context.l10n.settingsUpdateOpenFailed, error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.settings,
      builder: (context, _) {
        final l10n = context.l10n;
        final scheme = Theme.of(context).colorScheme;
        final textTheme = Theme.of(context).textTheme;
        return ToolPage(
          title: l10n.settingsTitle,
          subtitle: Platform.isAndroid
              ? l10n.settingsSubtitleAndroid
              : l10n.settingsSubtitleDesktop,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.settingsAppearanceMode, style: textTheme.titleSmall),
                    const SizedBox(height: 12),
                    SegmentedButton<ThemeMode>(
                      showSelectedIcon: false,
                      segments: [
                        ButtonSegment(
                          value: ThemeMode.system,
                          icon: const Icon(Icons.brightness_auto),
                          label: Text(l10n.settingsThemeSystem),
                        ),
                        ButtonSegment(
                          value: ThemeMode.light,
                          icon: const Icon(Icons.light_mode),
                          label: Text(l10n.settingsThemeLight),
                        ),
                        ButtonSegment(
                          value: ThemeMode.dark,
                          icon: const Icon(Icons.dark_mode),
                          label: Text(l10n.settingsThemeDark),
                        ),
                      ],
                      selected: {widget.settings.themeMode},
                      onSelectionChanged: (selection) =>
                          widget.settings.setThemeMode(selection.first),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.settingsLanguage, style: textTheme.titleSmall),
                    const SizedBox(height: 12),
                    SegmentedButton<String>(
                      showSelectedIcon: false,
                      segments: [
                        ButtonSegment(
                          value: 'system',
                          icon: const Icon(Icons.language),
                          label: Text(l10n.settingsLanguageSystem),
                        ),
                        ButtonSegment(
                          value: 'zh',
                          label: Text(l10n.settingsLanguageChinese),
                        ),
                        ButtonSegment(
                          value: 'en',
                          label: Text(l10n.settingsLanguageEnglish),
                        ),
                      ],
                      selected: {
                        widget.settings.locale?.languageCode ?? 'system',
                      },
                      onSelectionChanged: (selection) {
                        final code = selection.first;
                        widget.settings.setLocale(
                          code == 'system' ? null : Locale(code),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.settingsSeedColor, style: textTheme.titleSmall),
                    const SizedBox(height: 4),
                    Text(
                      l10n.settingsSeedColorHint,
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        for (final preset in kSeedPresets)
                          _SeedSwatch(
                            preset: preset,
                            selected: widget.settings.seedColor.toARGB32() ==
                                preset.color.toARGB32(),
                            onTap: () =>
                                widget.settings.setSeedColor(preset.color),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildFeatureVisibilityCard(context),
              if (Platform.isWindows) ...[
                const SizedBox(height: 16),
                _buildProxyCard(context),
              ],
              if (Platform.isAndroid) ...[
                const SizedBox(height: 16),
                _buildShizukuCard(context),
              ],
              const SizedBox(height: 16),
              SectionCard(
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.asset(
                        'assets/app_icon.png',
                        width: 52,
                        height: 52,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Flupix',
                                  style: textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              FilledButton.tonalIcon(
                                onPressed: _checkingUpdate
                                    ? null
                                    : _checkForUpdate,
                                icon: _checkingUpdate
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.system_update_rounded,
                                        size: 18,
                                      ),
                                label: Text(
                                  _checkingUpdate
                                      ? l10n.settingsUpdateChecking
                                      : l10n.settingsUpdateCheck,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n.settingsAboutVersion(_appVersion ?? '—'),
                            style: textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            l10n.settingsAboutPrivacy,
                            style: textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeatureVisibilityCard(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return SectionCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        value: widget.settings.showDisabledTools,
        onChanged: widget.settings.setShowDisabledTools,
        title: Text(l10n.settingsShowDisabled, style: textTheme.titleSmall),
        subtitle: Text(
          l10n.settingsShowDisabledHint,
          style: textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildProxyCard(BuildContext context) {
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

  Widget _buildShizukuCard(BuildContext context) {
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

  String _statusLabel(ShizukuStatus status) {
    final l10n = context.l10n;
    if (!status.shizukuInstalled) return l10n.settingsShizukuNotInstalled;
    if (!status.shizukuRunning) return l10n.settingsShizukuNotRunning;
    if (!status.permissionGranted) return l10n.settingsShizukuNotGranted;
    if (!status.isRoot) return l10n.settingsShizukuInsufficient('${status.uid}');
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
}

class _SeedSwatch extends StatelessWidget {
  const _SeedSwatch({
    required this.preset,
    required this.selected,
    required this.onTap,
  });

  final SeedPreset preset;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final onSwatch =
        ThemeData.estimateBrightnessForColor(preset.color) == Brightness.dark
            ? Colors.white
            : Colors.black;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: preset.color,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected ? scheme.onSurface : Colors.transparent,
                width: 2.5,
              ),
            ),
            child: selected
                ? Icon(Icons.check, color: onSwatch, size: 24)
                : null,
          ),
          const SizedBox(height: 6),
          Text(
            preset.label,
            style: textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _UpdateProgressDialog extends StatelessWidget {
  const _UpdateProgressDialog({required this.version, required this.progress});

  final String version;
  final ValueNotifier<double?> progress;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.settingsUpdateDownloading(version)),
      content: ValueListenableBuilder<double?>(
        valueListenable: progress,
        builder: (context, value, _) {
          final installing = value != null && value >= 1;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LinearProgressIndicator(value: value),
              const SizedBox(height: 12),
              Text(
                installing
                    ? l10n.settingsUpdateInstalling
                    : value == null
                    ? '—'
                    : '${(value * 100).round()}%',
              ),
            ],
          );
        },
      ),
    );
  }
}
