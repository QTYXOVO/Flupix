import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/exif/exif_data.dart';
import '../core/exif/exif_parser.dart';
import '../core/exif/exif_strip.dart';
import '../core/platform_capabilities.dart';
import '../l10n/l10n.dart';
import '../widgets/ui_kit.dart';

/// 图片 EXIF 分析：读取相机、镜头、拍摄参数与 GPS 位置。
class ExifPage extends StatefulWidget {
  const ExifPage({super.key});

  @override
  State<ExifPage> createState() => _ExifPageState();
}

class _ExifPageState extends State<ExifPage> {
  Uint8List? _bytes;
  String? _fileName;
  int? _fileSize;
  ExifParseResult? _result;
  int? _width;
  int? _height;
  bool _busy = false;
  bool _exporting = false;

  Future<void> _pickImage() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final file = await FilePicker.pickFile(
        dialogTitle: context.l10n.exifPickImage,
        type: FileType.custom,
        allowedExtensions: const [
          'jpg',
          'jpeg',
          'png',
          'webp',
          'tif',
          'tiff',
          'heic',
          'heif',
          'gif',
        ],
      );
      if (file == null) return;

      final bytes = await file.readAsBytes();
      final size = await file.length();
      final result = readExif(bytes);
      final dimensions = await _imageSize(bytes);
      if (!mounted) return;
      setState(() {
        _bytes = bytes;
        _fileName = file.name;
        _fileSize = size;
        _result = result;
        _width = dimensions?.$1;
        _height = dimensions?.$2;
      });
    } catch (error) {
      if (mounted) _notify(context.l10n.exifLoadFailed('$error'));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<(int, int)?> _imageSize(Uint8List bytes) async {
    ui.ImmutableBuffer? buffer;
    ui.ImageDescriptor? descriptor;
    try {
      buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
      descriptor = await ui.ImageDescriptor.encoded(buffer);
      return (descriptor.width, descriptor.height);
    } catch (_) {
      return null;
    } finally {
      descriptor?.dispose();
      buffer?.dispose();
    }
  }

  bool get _canStrip {
    final container = _result?.container;
    return _bytes != null &&
        (container == ExifContainer.jpeg ||
            container == ExifContainer.png ||
            container == ExifContainer.webp);
  }

  Future<void> _stripAndExport() async {
    final bytes = _bytes;
    final result = _result;
    if (bytes == null || result == null || _exporting) return;

    setState(() => _exporting = true);
    try {
      final stripped = stripImageMetadata(bytes, container: result.container);
      if (stripped.status == MetadataStripStatus.unsupported) {
        _notify(context.l10n.exifStripUnsupported);
        return;
      }
      final target = _strippedFileName(result.container);
      final uri = await FilePicker.saveFile(
        fileName: target,
        bytes: stripped.bytes,
        mimeType: _mimeTypeFor(result.container),
        dialogTitle: context.l10n.exifStripExport,
      );
      if (uri == null || !mounted) return;
      // 桌面端返回文件路径，可取到实际另存的文件名；移动端沿用默认名。
      final segments = uri.pathSegments;
      final savedName = AppCapabilities.isDesktop && segments.isNotEmpty
          ? Uri.decodeComponent(segments.last)
          : target;
      _notify(context.l10n.exifStripSaved(savedName));
    } catch (error) {
      if (mounted) _notify(context.l10n.exifStripFailed('$error'));
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  String _strippedFileName(ExifContainer container) {
    final original = _fileName ?? 'image';
    final dot = original.lastIndexOf('.');
    final base = dot > 0 ? original.substring(0, dot) : original;
    final extension = switch (container) {
      ExifContainer.jpeg => 'jpg',
      ExifContainer.png => 'png',
      ExifContainer.webp => 'webp',
      _ => 'bin',
    };
    return '${base}_stripped.$extension';
  }

  String _mimeTypeFor(ExifContainer container) {
    return switch (container) {
      ExifContainer.jpeg => 'image/jpeg',
      ExifContainer.png => 'image/png',
      ExifContainer.webp => 'image/webp',
      _ => 'application/octet-stream',
    };
  }

  void _notify(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openMap(double latitude, double longitude) async {
    final uri = Uri.parse(
      'https://www.openstreetmap.org/?mlat=$latitude&mlon=$longitude'
      '#map=16/$latitude/$longitude',
    );
    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened && mounted) _notify(context.l10n.commonError);
    } catch (_) {
      if (mounted) _notify(context.l10n.commonError);
    }
  }

  Future<void> _copyReport(ExifData data) async {
    final l10n = context.l10n;
    final buffer = StringBuffer();
    buffer.writeln(_fileName ?? '');
    buffer.writeln('${l10n.exifFormat}: ${_result?.container.label ?? '—'}');
    final dimensions = _dimensions(data);
    if (dimensions != null) {
      buffer.writeln(
        '${l10n.exifDimensions}: ${dimensions.$1} × ${dimensions.$2}',
      );
    }
    if (_fileSize != null) {
      buffer.writeln('${l10n.exifFileSize}: ${_formatBytes(_fileSize)}');
    }
    buffer.writeln(
      '${l10n.exifByteOrder}: '
      '${data.littleEndian ? l10n.exifByteOrderLittle : l10n.exifByteOrderBig}',
    );
    for (final group in data.groups) {
      buffer.writeln();
      buffer.writeln('【${_groupLabel(context, group.kind)}】');
      for (final tag in group.tags) {
        buffer.writeln('${tag.name}: ${tag.formatted}');
      }
    }
    await copyText(context, buffer.toString());
  }

  // -------------------------------------------------------------------- 取值

  (int, int)? _dimensions(ExifData? data) {
    if (_width != null && _height != null) return (_width!, _height!);
    final width =
        _rawInt(data?.tag(ExifGroupKind.exif, 0xA002)) ??
        _rawInt(data?.tag(ExifGroupKind.image, 0x0100));
    final height =
        _rawInt(data?.tag(ExifGroupKind.exif, 0xA003)) ??
        _rawInt(data?.tag(ExifGroupKind.image, 0x0101));
    if (width == null || height == null || width <= 0 || height <= 0) {
      return null;
    }
    return (width, height);
  }

  int? _rawInt(ExifTag? tag) {
    final value = tag?.value;
    return value is int ? value : null;
  }

  String? _validText(String? value) {
    final text = value?.trim();
    if (text == null || text.isEmpty || text == '—') return null;
    return text;
  }

  double? _coordinate(
    ExifData data,
    int valueTag,
    int refTag,
    String positiveRef,
  ) {
    final raw = data.tag(ExifGroupKind.gps, valueTag)?.value;
    if (raw is! List<ExifRational> || raw.length < 3) return null;
    final value = raw[0].value + raw[1].value / 60 + raw[2].value / 3600;
    if (!value.isFinite) return null;
    final ref = data.tag(ExifGroupKind.gps, refTag)?.formatted ?? '';
    if (ref.isEmpty) return value;
    return ref.toUpperCase().startsWith(positiveRef) ? value : -value;
  }

  double? _altitude(ExifData data) {
    final raw = data.tag(ExifGroupKind.gps, 0x0006)?.value;
    final value = raw is ExifRational ? raw.value : null;
    if (value == null || !value.isFinite) return null;
    final ref = data.tag(ExifGroupKind.gps, 0x0005)?.value;
    final refValue = ref is int
        ? ref
        : (ref is Uint8List && ref.isNotEmpty ? ref.first : null);
    return refValue == 1 ? -value : value;
  }

  List<(String, String)> _summaryRows(BuildContext context, ExifData data) {
    final l10n = context.l10n;
    final rows = <(String, String)>[];

    void add(String label, String? value) {
      final text = _validText(value);
      if (text == null) return;
      rows.add((label, text));
    }

    final make = data.tag(ExifGroupKind.image, 0x010F)?.formatted;
    final model = data.tag(ExifGroupKind.image, 0x0110)?.formatted;
    final makeText = _validText(make);
    final modelText = _validText(model);
    final String? camera;
    if (makeText == null) {
      camera = modelText;
    } else if (modelText == null) {
      camera = makeText;
    } else if (modelText.toLowerCase().startsWith(makeText.toLowerCase())) {
      camera = modelText;
    } else {
      camera = '$makeText $modelText';
    }
    add(l10n.exifCamera, camera);
    add(l10n.exifLens, data.tag(ExifGroupKind.exif, 0xA434)?.formatted);
    add(
      l10n.exifTakenAt,
      data.tag(ExifGroupKind.exif, 0x9003)?.formatted ??
          data.tag(ExifGroupKind.image, 0x0132)?.formatted,
    );
    add(l10n.exifShutter, data.tag(ExifGroupKind.exif, 0x829A)?.formatted);
    add(l10n.exifAperture, data.tag(ExifGroupKind.exif, 0x829D)?.formatted);
    add(
      l10n.exifIso,
      data.tag(ExifGroupKind.exif, 0x8827)?.formatted ??
          data.tag(ExifGroupKind.exif, 0x8833)?.formatted,
    );
    add(l10n.exifFocalLength, data.tag(ExifGroupKind.exif, 0x920A)?.formatted);
    add(l10n.exifExposureBias, data.tag(ExifGroupKind.exif, 0x9204)?.formatted);
    add(l10n.exifFlash, data.tag(ExifGroupKind.exif, 0x9209)?.formatted);
    add(l10n.exifWhiteBalance, data.tag(ExifGroupKind.exif, 0xA403)?.formatted);
    add(l10n.exifOrientation, data.tag(ExifGroupKind.image, 0x0112)?.formatted);
    add(l10n.exifSoftware, data.tag(ExifGroupKind.image, 0x0131)?.formatted);
    if (data.hasXmp) add(l10n.exifXmp, l10n.commonYes);
    return rows;
  }

  String _groupLabel(BuildContext context, ExifGroupKind kind) {
    final l10n = context.l10n;
    return switch (kind) {
      ExifGroupKind.image => l10n.exifGroupImage,
      ExifGroupKind.exif => l10n.exifGroupExif,
      ExifGroupKind.gps => l10n.exifGroupGps,
      ExifGroupKind.interop => l10n.exifGroupInterop,
      ExifGroupKind.thumbnail => l10n.exifGroupThumbnail,
    };
  }

  // ---------------------------------------------------------------------- UI

  @override
  Widget build(BuildContext context) {
    final data = _result?.data;
    return ToolPage(
      title: context.l10n.toolExifTitle,
      subtitle: context.l10n.exifSubtitle,
      actions: [
        if (data != null)
          IconButton(
            tooltip: context.l10n.exifCopyAll,
            icon: const Icon(Icons.copy_all_outlined),
            onPressed: () => _copyReport(data),
          ),
      ],
      child: _bytes == null ? _buildEmpty(context) : _buildContent(context),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        const SizedBox(height: 48),
        Center(child: TonalIcon(icon: Icons.photo_library_outlined, size: 76)),
        const SizedBox(height: 20),
        Text(
          context.l10n.exifEmptyTitle,
          textAlign: TextAlign.center,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          context.l10n.exifEmptyHint,
          textAlign: TextAlign.center,
          style: textTheme.bodySmall?.copyWith(
            height: 1.5,
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: FilledButton.icon(
            onPressed: _busy ? null : _pickImage,
            icon: _busy
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.add_photo_alternate_outlined),
            label: Text(
              _busy ? context.l10n.commonLoading : context.l10n.exifPickImage,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 900) return _buildNarrowContent(context);
        final sideWidth = (constraints.maxWidth * 0.32).clamp(340.0, 440.0);
        final remaining = constraints.maxWidth - 60 - sideWidth;
        final columns = remaining >= 1000
            ? 3
            : remaining >= 620
            ? 2
            : 1;
        return _buildWideContent(
          context,
          sideWidth: sideWidth,
          columns: columns,
        );
      },
    );
  }

  Widget _buildNarrowContent(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final result = _result;
    final data = result?.data;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        _buildFileCard(context),
        const SizedBox(height: 16),
        if (result != null && result.unsupported)
          _buildNotice(
            context,
            Icons.info_outline,
            context.l10n.exifUnsupported,
          )
        else if (data == null)
          _buildNotice(context, Icons.search_off, context.l10n.exifNoExif)
        else ...[
          _buildSummary(context, data),
          if (_hasGps(data)) ...[
            const SizedBox(height: 16),
            _buildGps(context, data),
          ],
          if (data.thumbnail != null) ...[
            const SizedBox(height: 16),
            _buildThumbnail(context, data.thumbnail!),
          ],
          const SizedBox(height: 16),
          _buildAllTags(context, data),
          const SizedBox(height: 16),
          Text(
            context.l10n.exifLocalHint,
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  /// 宽屏（PC 横屏）：左侧信息栏 + 右侧多列标签卡片，减少纵向滚动。
  Widget _buildWideContent(
    BuildContext context, {
    required double sideWidth,
    required int columns,
  }) {
    final data = _result?.data;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: sideWidth, child: _buildSidePane(context)),
          const SizedBox(width: 20),
          Expanded(child: _buildTagPane(context, data, columns: columns)),
        ],
      ),
    );
  }

  Widget _buildSidePane(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final result = _result;
    final data = result?.data;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _buildFileCard(context),
        const SizedBox(height: 16),
        if (result != null && result.unsupported)
          _buildNotice(
            context,
            Icons.info_outline,
            context.l10n.exifUnsupported,
          )
        else if (data == null)
          _buildNotice(context, Icons.search_off, context.l10n.exifNoExif)
        else ...[
          _buildSummary(context, data),
          if (_hasGps(data)) ...[
            const SizedBox(height: 16),
            _buildGps(context, data),
          ],
          if (data.thumbnail != null) ...[
            const SizedBox(height: 16),
            _buildThumbnail(context, data.thumbnail!),
          ],
          const SizedBox(height: 16),
          Text(
            context.l10n.exifLocalHint,
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTagPane(
    BuildContext context,
    ExifData? data, {
    required int columns,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (data == null) {
      return const SizedBox.shrink();
    }

    final grouped = _distributeGroups(data.groups, columns);
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Row(
          children: [
            Text(
              context.l10n.exifAllTags,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              context.l10n.exifTagCount(data.allTags.length),
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < grouped.length; i++) ...[
              if (i > 0) const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final group in grouped[i])
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildGroupCard(context, group),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  /// 按标签数量把分组贪心分配到各列，尽量保持列高均衡。
  List<List<ExifGroup>> _distributeGroups(List<ExifGroup> groups, int columns) {
    final result = List.generate(columns, (_) => <ExifGroup>[]);
    final heights = List<int>.filled(columns, 0);
    for (final group in groups) {
      var target = 0;
      for (var i = 1; i < columns; i++) {
        if (heights[i] < heights[target]) target = i;
      }
      result[target].add(group);
      heights[target] += group.tags.length + 2;
    }
    return result;
  }

  /// 宽屏下直接展开的分组卡片，省去逐个点开 ExpansionTile 的操作。
  Widget _buildGroupCard(BuildContext context, ExifGroup group) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return SectionCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _groupLabel(context, group.kind),
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                context.l10n.exifTagCount(group.tags.length),
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          for (final tag in group.tags) _TagRow(tag: tag, labelWidth: 112),
        ],
      ),
    );
  }

  bool _hasGps(ExifData data) =>
      _coordinate(data, 0x0002, 0x0001, 'N') != null &&
      _coordinate(data, 0x0004, 0x0003, 'E') != null;

  Widget _buildFileCard(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final data = _result?.data;
    final dimensions = _dimensions(data);
    final meta = <String>[
      _result?.container.label ?? '—',
      if (_fileSize != null) _formatBytes(_fileSize),
      if (dimensions != null) '${dimensions.$1} × ${dimensions.$2}',
    ].join(' · ');

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: SizedBox(
                  width: 96,
                  height: 96,
                  child: Image.memory(
                    _bytes!,
                    fit: BoxFit.cover,
                    cacheWidth: 256,
                    gaplessPlayback: true,
                    errorBuilder: (context, error, stackTrace) => ColoredBox(
                      color: scheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _fileName ?? context.l10n.commonUnknown,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      meta,
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    if (data != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${context.l10n.exifByteOrder}: '
                        '${data.littleEndian ? context.l10n.exifByteOrderLittle : context.l10n.exifByteOrderBig}',
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.tonalIcon(
                onPressed: _busy || _exporting ? null : _pickImage,
                icon: _busy
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add_photo_alternate_outlined, size: 18),
                label: Text(
                  _busy
                      ? context.l10n.commonLoading
                      : context.l10n.exifChangeImage,
                ),
              ),
              TextButton.icon(
                onPressed: _busy || _exporting ? null : _clear,
                icon: const Icon(Icons.delete_outline, size: 18),
                label: Text(context.l10n.commonRemove),
              ),
            ],
          ),
          if (_canStrip) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _exporting ? null : _stripAndExport,
                icon: _exporting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.cleaning_services_outlined, size: 18),
                label: Text(
                  _exporting
                      ? context.l10n.exifStripExporting
                      : context.l10n.exifStripExport,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              context.l10n.exifStripHint,
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _clear() {
    setState(() {
      _bytes = null;
      _fileName = null;
      _fileSize = null;
      _result = null;
      _width = null;
      _height = null;
      _exporting = false;
    });
  }

  Widget _buildNotice(BuildContext context, IconData icon, String message) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return SectionCard(
      color: scheme.surfaceContainerHigh,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: scheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: textTheme.bodySmall?.copyWith(
                height: 1.5,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(BuildContext context, ExifData data) {
    final textTheme = Theme.of(context).textTheme;
    final rows = _summaryRows(context, data);
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.exifKeySection,
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          if (rows.isEmpty) ...[
            const SizedBox(height: 8),
            Text(context.l10n.exifNoTags, style: textTheme.bodySmall),
          ] else
            for (final row in rows) _DetailRow(label: row.$1, value: row.$2),
        ],
      ),
    );
  }

  Widget _buildGps(BuildContext context, ExifData data) {
    final textTheme = Theme.of(context).textTheme;
    final latitude = _coordinate(data, 0x0002, 0x0001, 'N')!;
    final longitude = _coordinate(data, 0x0004, 0x0003, 'E')!;
    final altitude = _altitude(data);
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.exifGpsSection,
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          _DetailRow(
            label: context.l10n.exifCoordinates,
            value:
                '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}',
          ),
          if (altitude != null)
            _DetailRow(
              label: context.l10n.exifAltitude,
              value: '${altitude.toStringAsFixed(1)} m',
            ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.tonalIcon(
              onPressed: () => _openMap(latitude, longitude),
              icon: const Icon(Icons.map_outlined, size: 18),
              label: Text(context.l10n.exifOpenMap),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnail(BuildContext context, Uint8List thumbnail) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.exifThumbnail,
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.memory(
              thumbnail,
              height: 160,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => SizedBox(
                height: 80,
                child: Center(
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllTags(BuildContext context, ExifData data) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return SectionCard(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
            child: Row(
              children: [
                Text(
                  context.l10n.exifAllTags,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  context.l10n.exifTagCount(data.allTags.length),
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          for (final group in data.groups)
            Theme(
              data: Theme.of(context)
                  .copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 12),
                childrenPadding: const EdgeInsets.only(bottom: 8),
                title: Text(
                  _groupLabel(context, group.kind),
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  context.l10n.exifTagCount(group.tags.length),
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                children: [for (final tag in group.tags) _TagRow(tag: tag)],
              ),
            ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: textTheme.labelSmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: SelectableText(value, style: textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

class _TagRow extends StatelessWidget {
  const _TagRow({required this.tag, this.labelWidth = 136});

  final ExifTag tag;
  final double labelWidth;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: labelWidth,
            child: Text(
              tag.name,
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SelectableText(tag.formatted, style: textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}

String _formatBytes(int? bytes) {
  if (bytes == null || bytes < 0) return '—';
  if (bytes < 1024) return '$bytes B';
  const units = ['KB', 'MB', 'GB'];
  var value = bytes / 1024;
  var unit = 0;
  while (value >= 1024 && unit < units.length - 1) {
    value /= 1024;
    unit++;
  }
  return '${value.toStringAsFixed(value >= 10 ? 0 : 1)} ${units[unit]}';
}
