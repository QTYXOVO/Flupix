import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app_settings.dart';
import '../core/shizuku.dart';
import '../l10n/l10n.dart';
import '../screens/settings_page.dart';
import '../widgets/ui_kit.dart';

class QqStickerPage extends StatefulWidget {
  const QqStickerPage({super.key});

  @override
  State<QqStickerPage> createState() => _QqStickerPageState();
}

class _QqStickerPageState extends State<QqStickerPage> {
  bool _loading = true;
  bool _scanning = false;
  bool _saving = false;
  Map<dynamic, dynamic>? _status;
  List<_StickerPack> _packs = const <_StickerPack>[];
  final Set<String> _selected = <String>{};
  String? _message;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      _loadStatus();
    } else {
      _loading = false;
    }
  }

  String get _phase {
    final status = _status;
    if (status == null) return 'unknown';
    if (status['qqInstalled'] != true) return 'qq';
    if (status['shizukuInstalled'] != true) return 'not_installed';
    if (status['shizukuRunning'] != true) return 'stopped';
    if (status['permissionGranted'] != true) return 'denied';
    if (status['isRoot'] != true) return 'shell';
    if (status['cacheExists'] != true) return 'no_cache';
    return 'ready';
  }

  Future<void> _loadStatus({bool quiet = false}) async {
    if (!Platform.isAndroid) return;
    if (!quiet) {
      setState(() => _loading = true);
    }
    try {
      final status = await ShizukuService.channel
          .invokeMethod<Map<dynamic, dynamic>>('getStatus');
      if (!mounted) return;
      setState(() {
        _status = status;
        _loading = false;
        if (_phase != 'ready') {
          _packs = const <_StickerPack>[];
          _selected.clear();
        }
      });
    } on PlatformException catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _isError = true;
        _message = error.message ?? context.l10n.qqStickerReadStatusFailed;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _isError = true;
        _message = context.l10n.qqStickerReadStatusFailedDetail('$error');
      });
    }
  }

  Future<void> _openSettings() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SettingsPage(settings: SettingsScope.of(context)),
      ),
    );
    if (mounted) await _loadStatus(quiet: true);
  }

  Future<void> _scan() async {
    if (_scanning) return;
    setState(() {
      _scanning = true;
      _message = null;
    });
    try {
      final result = await ShizukuService.channel
          .invokeMethod<Map<dynamic, dynamic>>('scanPacks');
      final rawPacks = result?['packs'] as List<dynamic>? ?? const <dynamic>[];
      final packs = rawPacks
          .whereType<Map<dynamic, dynamic>>()
          .map(_StickerPack.fromMap)
          .where((pack) => pack.stickers.isNotEmpty)
          .toList();
      if (!mounted) return;
      setState(() {
        _packs = packs;
        _selected.clear();
        _scanning = false;
        _isError = false;
        _message = packs.isEmpty
            ? context.l10n.qqStickerNoStickers
            : context.l10n.qqStickerFoundPacks(packs.length);
      });
    } on PlatformException catch (error) {
      if (!mounted) return;
      setState(() {
        _scanning = false;
        _isError = true;
        _message = error.message ?? context.l10n.qqStickerScanFailed;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _scanning = false;
        _isError = true;
        _message = context.l10n.qqStickerScanFailedDetail('$error');
      });
    }
  }

  Future<void> _save() async {
    if (_selected.isEmpty || _saving) return;
    final groups = <String, List<String>>{};
    for (final key in _selected) {
      final index = key.indexOf('/');
      if (index <= 0) continue;
      final packId = key.substring(0, index);
      final name = key.substring(index + 1);
      groups.putIfAbsent(packId, () => <String>[]).add(name);
    }
    if (groups.isEmpty) return;

    setState(() {
      _saving = true;
      _message = null;
    });
    try {
      final result = await ShizukuService.channel
          .invokeMethod<Map<dynamic, dynamic>>(
            'saveStickers',
            <String, dynamic>{
              'groups': <Map<String, dynamic>>[
                for (final entry in groups.entries)
                  <String, dynamic>{'packId': entry.key, 'names': entry.value},
              ],
            },
          );
      final saved = (result?['saved'] as num?)?.toInt() ?? 0;
      final failed = (result?['failed'] as List<dynamic>?)?.length ?? 0;
      if (!mounted) return;
      setState(() {
        _saving = false;
        _selected.clear();
        _isError = saved == 0;
        _message = saved == 0
            ? context.l10n.qqStickerSaveFailedRetry
            : '${context.l10n.qqStickerSavedToFolder(saved)}'
                  '${failed > 0 ? context.l10n.qqStickerSaveFailedSuffix(failed) : ''}';
      });
      if (saved > 0) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(context.l10n.qqStickerSavedToGallery(saved)),
            ),
          );
      }
    } on PlatformException catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _isError = true;
        _message = error.message ?? context.l10n.qqStickerSaveFailed;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _isError = true;
        _message = context.l10n.qqStickerSaveFailedDetail('$error');
      });
    }
  }

  void _toggle(_StickerPack pack, _Sticker sticker) {
    final key = '${pack.id}/${sticker.name}';
    setState(() {
      if (!_selected.add(key)) _selected.remove(key);
    });
  }

  void _togglePack(_StickerPack pack) {
    final keys = pack.stickers
        .map((sticker) => '${pack.id}/${sticker.name}')
        .toList();
    final allSelected = keys.every(_selected.contains);
    setState(() {
      if (allSelected) {
        _selected.removeAll(keys);
      } else {
        _selected.addAll(keys);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ToolPage(
      title: context.l10n.qqStickerTitle,
      subtitle: context.l10n.qqStickerSubtitle,
      child: !Platform.isAndroid
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  context.l10n.qqStickerAndroidOnly,
                  style: textTheme.bodyLarge?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            )
          : _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => _loadStatus(quiet: true),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      children: [
                        _buildStatusCard(context),
                        if (_message != null) ...[
                          const SizedBox(height: 12),
                          _MessageRow(message: _message!, error: _isError),
                        ],
                        if (_packs.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Text(
                                context.l10n.qqStickerPacks,
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                context.l10n.qqStickerPacksCount(_packs.length),
                                style: textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            context.l10n.qqStickerSaveLocation,
                            style: textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 12),
                          for (final pack in _packs)
                            _buildPackTile(context, pack),
                        ],
                      ],
                    ),
                  ),
                ),
                if (_selected.isNotEmpty) _buildSaveBar(context),
              ],
            ),
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final phase = _phase;

    IconData icon;
    String title;
    String detail;
    switch (phase) {
      case 'qq':
        icon = Icons.chat_bubble_outline;
        title = context.l10n.qqStickerQqMissing;
        detail = context.l10n.qqStickerQqMissingDetail;
        break;
      case 'not_installed':
        icon = Icons.extension_off_outlined;
        title = context.l10n.qqStickerShizukuMissing;
        detail = context.l10n.qqStickerShizukuMissingDetail;
        break;
      case 'stopped':
        icon = Icons.power_settings_new;
        title = context.l10n.qqStickerShizukuStopped;
        detail = context.l10n.qqStickerShizukuStoppedDetail;
        break;
      case 'denied':
        icon = Icons.lock_outline;
        title = context.l10n.qqStickerShizukuDenied;
        detail = context.l10n.qqStickerShizukuDeniedDetail;
        break;
      case 'shell':
        final uid = (_status?['uid'] as num?)?.toInt() ?? -1;
        icon = Icons.gpp_maybe_outlined;
        title = context.l10n.qqStickerShizukuInsufficient;
        detail = context.l10n.qqStickerShizukuInsufficientDetail(uid);
        break;
      case 'no_cache':
        icon = Icons.folder_off_outlined;
        title = context.l10n.qqStickerNoCache;
        detail = context.l10n.qqStickerNoCacheDetail;
        break;
      case 'ready':
        icon = Icons.verified_outlined;
        title = context.l10n.qqStickerReady;
        detail = _packs.isEmpty
            ? context.l10n.qqStickerReadyHintEmpty
            : context.l10n.qqStickerReadyHintCount(_packs.length);
        break;
      default:
        icon = Icons.devices_other;
        title = context.l10n.qqStickerUnknownStatus;
        detail = context.l10n.qqStickerUnknownStatusDetail;
    }

    final actions = <Widget>[];
    if (phase == 'not_installed' ||
        phase == 'stopped' ||
        phase == 'denied' ||
        phase == 'shell') {
      actions.add(
        FilledButton.tonalIcon(
          onPressed: _openSettings,
          icon: const Icon(Icons.settings_outlined, size: 18),
          label: Text(context.l10n.qqStickerGoSettings),
        ),
      );
    }
    if (phase == 'ready') {
      actions.add(
        FilledButton.icon(
          onPressed: _scanning ? null : _scan,
          icon: _scanning
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.search, size: 18),
          label: Text(
            _scanning
                ? context.l10n.qqStickerScanning
                : (_packs.isEmpty
                      ? context.l10n.qqStickerScan
                      : context.l10n.qqStickerRescan),
          ),
        ),
      );
    }
    if (phase != 'qq') {
      actions.add(
        OutlinedButton.icon(
          onPressed: () => _loadStatus(),
          icon: const Icon(Icons.refresh, size: 18),
          label: Text(context.l10n.settingsShizukuRefresh),
        ),
      );
    }

    final ready = phase == 'ready';
    return SectionCard(
      color: ready ? scheme.primaryContainer : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TonalIcon(
                icon: icon,
                background: ready ? scheme.primary : scheme.secondaryContainer,
                foreground: ready
                    ? scheme.onPrimary
                    : scheme.onSecondaryContainer,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      detail,
                      style: textTheme.bodySmall?.copyWith(
                        height: 1.4,
                        color: ready
                            ? scheme.onPrimaryContainer
                            : scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (actions.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(spacing: 8, runSpacing: 8, children: actions),
          ],
        ],
      ),
    );
  }

  Widget _buildPackTile(BuildContext context, _StickerPack pack) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final keys = pack.stickers
        .map((sticker) => '${pack.id}/${sticker.name}')
        .toList();
    final allSelected = keys.every(_selected.contains);
    final selectedCount = keys.where(_selected.contains).length;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: PageStorageKey<String>('qq-pack-${pack.id}'),
          leading: _PackCover(path: pack.cover),
          title: Text(
            context.l10n.qqStickerPackTitle(pack.id),
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            selectedCount > 0
                ? context.l10n.qqStickerPackSelectedSummary(
                    pack.stickers.length,
                    selectedCount,
                  )
                : context.l10n.qqStickerPackSummary(pack.stickers.length),
            style: textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  context.l10n.qqStickerTapToSelect,
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _togglePack(pack),
                  child: Text(
                    allSelected
                        ? context.l10n.commonDeselectAll
                        : context.l10n.qqStickerSelectPack,
                  ),
                ),
              ],
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final sticker in pack.stickers)
                  _buildStickerTile(context, pack, sticker),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStickerTile(
    BuildContext context,
    _StickerPack pack,
    _Sticker sticker,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final selected = _selected.contains('${pack.id}/${sticker.name}');
    return GestureDetector(
      onTap: () => _toggle(pack, sticker),
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? scheme.primary : Colors.transparent,
            width: 2,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _Thumb(path: sticker.thumb, iconSize: 24),
            if (selected)
              Positioned(
                right: 4,
                top: 4,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check, size: 10, color: scheme.onPrimary),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveBar(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: scheme.surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.qqStickerSelectedCount(_selected.length),
                    style: textTheme.titleSmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    context.l10n.qqStickerSaveToAlbum,
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.download_rounded, size: 18),
              label: Text(
                _saving
                    ? context.l10n.qqStickerSaving
                    : context.l10n.commonSave,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StickerPack {
  const _StickerPack({required this.id, required this.stickers});

  final String id;
  final List<_Sticker> stickers;

  factory _StickerPack.fromMap(Map<dynamic, dynamic> map) {
    final raw = map['stickers'] as List<dynamic>? ?? const <dynamic>[];
    return _StickerPack(
      id: map['id'] as String? ?? '',
      stickers: raw
          .whereType<Map<dynamic, dynamic>>()
          .map(_Sticker.fromMap)
          .toList(),
    );
  }

  String? get cover {
    for (final sticker in stickers) {
      if (sticker.thumb != null) return sticker.thumb;
    }
    return null;
  }
}

class _Sticker {
  const _Sticker({required this.name, required this.size, this.thumb});

  final String name;
  final int size;
  final String? thumb;

  factory _Sticker.fromMap(Map<dynamic, dynamic> map) {
    return _Sticker(
      name: map['name'] as String? ?? '',
      size: (map['size'] as num?)?.toInt() ?? 0,
      thumb: map['thumb'] as String?,
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({this.path, this.iconSize = 32});

  final String? path;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final source = path;
    if (source == null) {
      return Icon(
        Icons.emoji_emotions_outlined,
        size: iconSize,
        color: scheme.onSurfaceVariant,
      );
    }
    return Image.file(
      File(source),
      fit: BoxFit.contain,
      gaplessPlayback: true,
      errorBuilder: (_, _, _) => Icon(
        Icons.broken_image_outlined,
        size: iconSize,
        color: scheme.onSurfaceVariant,
      ),
    );
  }
}

class _PackCover extends StatelessWidget {
  const _PackCover({this.path});

  final String? path;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.antiAlias,
      child: _Thumb(path: path, iconSize: 22),
    );
  }
}

class _MessageRow extends StatelessWidget {
  const _MessageRow({required this.message, required this.error});

  final String message;
  final bool error;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          error ? Icons.error_outline : Icons.check_circle_outline,
          size: 18,
          color: error ? scheme.error : scheme.primary,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            message,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: error ? scheme.error : scheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
