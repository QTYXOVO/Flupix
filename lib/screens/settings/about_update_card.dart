import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/eh/eh_cookie_store.dart';
import '../../core/pixiv_auth.dart';
import '../../core/platform_capabilities.dart';
import '../../core/update_service.dart';
import '../../l10n/l10n.dart';
import '../../widgets/ui_kit.dart';

class AboutUpdateCard extends StatefulWidget {
  const AboutUpdateCard({super.key});

  @override
  State<AboutUpdateCard> createState() => _AboutUpdateCardState();
}

class _AboutUpdateCardState extends State<AboutUpdateCard> {
  static const MethodChannel _apkInstaller = MethodChannel(
    'flupix/apk_installer',
  );

  final PixivProxyStore _proxyStore = PixivProxyStore();

  String? _appVersion;
  bool _checkingUpdate = false;

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  void _notify(String message, {bool error = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
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

  Future<String?> _loadUpdateProxy() async {
    if (!AppCapabilities.supportsSystemProxy) return null;
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
      final message = error is UpdateCheckException ? error.message : '$error';
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
        final canAutoUpdate = AppCapabilities.canInstallPackage(downloadPath);
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
        AppCapabilities.canInstallPackage(url.path) &&
        AppCapabilities.isWindows;
    final isAndroidPackage =
        AppCapabilities.canInstallPackage(url.path) &&
        AppCapabilities.isAndroid;
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
          child: UpdateProgressDialog(
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
        await Process.start(package.path, const [
          '/VERYSILENT',
          '/SUPPRESSMSGBOXES',
          '/NORESTART',
          '/CLOSEAPPLICATIONS',
          '/RESTARTAPPLICATIONS',
        ], mode: ProcessStartMode.detached);
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
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return SectionCard(
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
                      onPressed: _checkingUpdate ? null : _checkForUpdate,
                      icon: _checkingUpdate
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.system_update_rounded, size: 18),
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
    );
  }
}

class UpdateProgressDialog extends StatelessWidget {
  const UpdateProgressDialog({
    super.key,
    required this.version,
    required this.progress,
  });

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
