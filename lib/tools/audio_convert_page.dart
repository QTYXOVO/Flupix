import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../core/audio_converter.dart';
import '../core/platform_capabilities.dart';
import '../l10n/l10n.dart';
import '../widgets/ui_kit.dart';

const MethodChannel _audioSaveChannel = MethodChannel('flupix/audio_save');

/// FFmpeg 驱动的音频格式转换工具。
class AudioConvertPage extends StatefulWidget {
  const AudioConvertPage({super.key});

  @override
  State<AudioConvertPage> createState() => _AudioConvertPageState();
}

class _AudioConvertPageState extends State<AudioConvertPage> {
  static const List<int> _bitrateOptions = [96, 128, 192, 256, 320];
  static const List<int> _sampleRateOptions = [
    8000,
    16000,
    22050,
    32000,
    44100,
    48000,
    96000,
  ];
  static const List<String> _inputExtensions = [
    'mp3',
    'wav',
    'flac',
    'm4a',
    'aac',
    'ogg',
    'oga',
    'opus',
    'wma',
    'aiff',
    'aif',
    'amr',
    'ape',
    'm4b',
    'mp2',
    'ac3',
    'alac',
    'caf',
    'au',
  ];

  PlatformFile? _pickedFile;
  String? _inputPath;
  AudioInfo? _info;
  int? _sourceSize;
  bool _probing = false;

  AudioFormat _format = AudioFormat.mp3;
  int _bitrate = 192;
  AudioBitDepth _bitDepth = AudioBitDepth.pcm16;
  int? _sampleRate;
  int? _channels;

  bool _converting = false;
  double? _progress;
  double _speed = 0;

  File? _resultFile;
  String? _resultName;
  int? _resultSize;
  AudioFormat? _resultFormat;
  bool _saving = false;

  String? _error;
  String? _engineVersion;

  @override
  void initState() {
    super.initState();
    _loadEngineVersion();
  }

  @override
  void dispose() {
    if (_converting) {
      unawaited(AudioConvertService.cancel());
    }
    super.dispose();
  }

  Future<void> _loadEngineVersion() async {
    final version = await AudioConvertService.engineVersion();
    if (mounted) setState(() => _engineVersion = version);
  }

  // ------------------------------------------------------------------ 文件选择

  Future<void> _pickAudio() async {
    if (_converting) return;
    try {
      final file = await FilePicker.pickFile(
        dialogTitle: context.l10n.audioSelectAudioFile,
        type: FileType.custom,
        allowedExtensions: _inputExtensions,
      );
      if (file == null) return;
      setState(() {
        _pickedFile = file;
        _inputPath = null;
        _info = null;
        _sourceSize = file.lengthSync();
        _resultFile = null;
        _resultName = null;
        _resultSize = null;
        _resultFormat = null;
        _error = null;
        _probing = true;
      });
      final path = await _resolveInputPath(file);
      final info = await AudioConvertService.probe(path);
      if (!mounted) return;
      setState(() {
        _inputPath = path;
        _info = info;
        _sourceSize = info.sizeBytes ?? _sourceSize;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = '$error');
      _notify(context.l10n.audioReadFailed('$error'), error: true);
    } finally {
      if (mounted) setState(() => _probing = false);
    }
  }

  /// 尽量直接使用本地路径；SAF 等虚拟路径先复制到临时目录。
  Future<String> _resolveInputPath(PlatformFile file) async {
    final direct = file.path;
    if (direct != null && direct.isNotEmpty) return direct;

    final tempRoot = await getTemporaryDirectory();
    final directory = Directory(
      '${tempRoot.path}${Platform.pathSeparator}flupix_audio_input',
    );
    await directory.create(recursive: true);
    final safeName = file.name.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    final target = File(
      '${directory.path}${Platform.pathSeparator}'
      '${DateTime.now().millisecondsSinceEpoch}_$safeName',
    );
    final sink = target.openWrite();
    try {
      await sink.addStream(file.readAsByteStream());
    } finally {
      await sink.close();
    }
    return target.path;
  }

  // -------------------------------------------------------------------- 转码

  Future<void> _convert() async {
    final inputPath = _inputPath;
    if (inputPath == null || _converting) return;

    final format = _format;
    final outputName =
        '${_baseName(_pickedFile?.name ?? 'audio')}.${format.extension}';
    try {
      final tempRoot = await getTemporaryDirectory();
      final directory = Directory(
        '${tempRoot.path}${Platform.pathSeparator}flupix_audio_output',
      );
      await directory.create(recursive: true);
      final output = File(
        '${directory.path}${Platform.pathSeparator}$outputName',
      );
      if (await output.exists()) await output.delete();

      setState(() {
        _converting = true;
        _progress = 0;
        _speed = 0;
        _resultFile = null;
        _resultName = null;
        _resultSize = null;
        _resultFormat = null;
        _error = null;
      });

      await AudioConvertService.convert(
        inputPath: inputPath,
        outputPath: output.path,
        format: format,
        bitrateKbps: _bitrate,
        sampleRate: _sampleRate,
        channels: _channels,
        bitDepth: _bitDepth,
        duration: _info?.duration,
        onProgress: (progress) {
          if (!mounted) return;
          setState(() {
            _progress = progress.fraction;
            _speed = progress.speed;
          });
        },
      );

      final size = await output.length();
      if (!mounted) return;
      setState(() {
        _progress = 1;
        _resultFile = output;
        _resultName = outputName;
        _resultSize = size;
        _resultFormat = format;
      });
      _notify(context.l10n.audioConvertDoneHint);
    } on AudioConversionCancelled {
      if (mounted) _notify(context.l10n.audioConvertCancelled);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = '$error');
      _notify(context.l10n.audioConvertFailedToast, error: true);
    } finally {
      if (mounted) setState(() => _converting = false);
    }
  }

  Future<void> _cancelConvert() async {
    await AudioConvertService.cancel();
  }

  Future<void> _saveResult() async {
    final file = _resultFile;
    final name = _resultName;
    final format = _resultFormat;
    if (file == null || name == null || format == null || _saving) return;

    setState(() => _saving = true);
    try {
      final bytes = await file.readAsBytes();
      final savedName = AppCapabilities.savesFilesToMediaStore
          ? await _saveOnAndroid(name: name, bytes: bytes, format: format)
          : await _saveWithPicker(name: name, bytes: bytes, format: format);
      if (savedName == null || !mounted) return;
      _notify(context.l10n.audioSavedName(savedName));
    } catch (error) {
      if (mounted) {
        _notify(context.l10n.audioSaveFailed('$error'), error: true);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  /// Android 使用应用内保存，避免系统按 MIME 给文件名追加 `.oga` 等后缀。
  Future<String?> _saveOnAndroid({
    required String name,
    required Uint8List bytes,
    required AudioFormat format,
  }) async {
    try {
      return await _audioSaveChannel.invokeMethod<String>('saveFile', {
        'fileName': name,
        'bytes': bytes,
      });
    } on MissingPluginException {
      // 旧安装包没有该通道时回退到通用保存对话框。
      return _saveWithPicker(name: name, bytes: bytes, format: format);
    }
  }

  Future<String?> _saveWithPicker({
    required String name,
    required Uint8List bytes,
    required AudioFormat format,
  }) async {
    final uri = await FilePicker.saveFile(
      fileName: name,
      bytes: bytes,
      mimeType: format.mimeType,
      dialogTitle: context.l10n.audioSaveAudioFile,
    );
    return uri == null ? null : name;
  }

  // ------------------------------------------------------------------ 工具方法

  String _baseName(String name) {
    final sanitized = name.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    final dot = sanitized.lastIndexOf('.');
    final base = dot > 0 ? sanitized.substring(0, dot) : sanitized;
    return base.isEmpty ? 'audio' : base;
  }

  String _formatBytes(int? bytes) {
    if (bytes == null) return context.l10n.audioSizeUnknown;
    if (bytes < 1024) return '$bytes B';
    const units = ['KB', 'MB', 'GB'];
    var value = bytes / 1024;
    var index = 0;
    while (value >= 1024 && index < units.length - 1) {
      value /= 1024;
      index++;
    }
    return '${value.toStringAsFixed(value >= 100 ? 0 : 1)} ${units[index]}';
  }

  String _formatDuration(Duration duration) {
    final seconds = duration.inSeconds;
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final rest = seconds % 60;
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:'
          '${rest.toString().padLeft(2, '0')}';
    }
    return '$minutes:${rest.toString().padLeft(2, '0')}';
  }

  String _formatSampleRate(int rate) {
    if (rate % 1000 == 0) return '${rate ~/ 1000} kHz';
    return '${(rate / 1000).toStringAsFixed(1)} kHz';
  }

  String _formatChannels(int? channels) {
    if (channels == null) return context.l10n.audioChannelsUnknown;
    if (channels == 1) return context.l10n.audioMono;
    if (channels == 2) return context.l10n.audioStereo;
    return context.l10n.audioChannelsCount(channels);
  }

  String? _codecLabel(AudioInfo info) {
    final codec = info.codec;
    if (codec == null || codec.isEmpty) return info.container;
    return codec.toUpperCase();
  }

  void _notify(String message, {bool error = false}) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error
            ? Theme.of(context).colorScheme.errorContainer
            : null,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ------------------------------------------------------------------ 界面构建

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ToolPage(
      title: context.l10n.audioConvertTitle,
      subtitle: context.l10n.audioConvertSubtitle,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          _buildSourceCard(scheme, textTheme),
          const SizedBox(height: 16),
          _buildSettingsCard(scheme, textTheme),
          const SizedBox(height: 16),
          if (_converting)
            _buildProgressCard(scheme, textTheme)
          else
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: _inputPath == null || _probing ? null : _convert,
                icon: const Icon(Icons.graphic_eq_rounded),
                label: Text(context.l10n.audioConvertTo(_format.label)),
              ),
            ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            _buildErrorCard(scheme, textTheme),
          ],
          if (_resultFile != null) ...[
            const SizedBox(height: 16),
            _buildResultCard(scheme, textTheme),
          ],
          const SizedBox(height: 24),
          Text(
            context.l10n.audioEngineLine(
              _engineVersion ?? context.l10n.audioEngineLoading,
            ),
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceCard(ColorScheme scheme, TextTheme textTheme) {
    final file = _pickedFile;
    final info = _info;
    final hasFile = file != null;

    return SectionCard(
      color: hasFile ? scheme.primaryContainer : scheme.surfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TonalIcon(
                icon: hasFile
                    ? Icons.audio_file_rounded
                    : Icons.library_music_outlined,
                background: hasFile
                    ? scheme.primary.withValues(alpha: 0.16)
                    : scheme.surfaceContainerHighest,
                foreground: hasFile
                    ? scheme.onPrimaryContainer
                    : scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasFile ? file.name : context.l10n.audioSelectAudioFile,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: hasFile ? scheme.onPrimaryContainer : null,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      hasFile
                          ? '${_formatBytes(_sourceSize)}'
                                '${info == null ? '' : ' · ${_formatDuration(info.duration)}'}'
                          : context.l10n.audioSupportedFormats,
                      style: textTheme.bodySmall?.copyWith(
                        color: hasFile
                            ? scheme.onPrimaryContainer.withValues(alpha: 0.75)
                            : scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasFile)
                IconButton(
                  tooltip: context.l10n.audioChangeFile,
                  onPressed: _converting ? null : _pickAudio,
                  icon: Icon(
                    Icons.swap_horiz_rounded,
                    color: scheme.onPrimaryContainer,
                  ),
                ),
            ],
          ),
          if (_probing) ...[
            const SizedBox(height: 16),
            const LinearProgressIndicator(minHeight: 4),
          ] else if (info != null) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoChip(
                  icon: Icons.memory_rounded,
                  label: _codecLabel(info) ?? context.l10n.audioUnknownCodec,
                  scheme: scheme,
                  onPrimaryContainer: true,
                ),
                if (info.sampleRate != null)
                  _InfoChip(
                    icon: Icons.speed_rounded,
                    label: _formatSampleRate(info.sampleRate!),
                    scheme: scheme,
                    onPrimaryContainer: true,
                  ),
                _InfoChip(
                  icon: Icons.surround_sound_rounded,
                  label: _formatChannels(info.channels),
                  scheme: scheme,
                  onPrimaryContainer: true,
                ),
              ],
            ),
          ] else if (!hasFile) ...[
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonalIcon(
                onPressed: _pickAudio,
                icon: const Icon(Icons.folder_open_rounded),
                label: Text(context.l10n.audioBrowseLocal),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSettingsCard(ColorScheme scheme, TextTheme textTheme) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.audioOutputFormat,
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final format in AudioFormat.values)
                ChoiceChip(
                  label: Text(format.label),
                  selected: _format == format,
                  showCheckmark: false,
                  onSelected: _converting
                      ? null
                      : (_) => setState(() => _format = format),
                ),
            ],
          ),
          if (!_format.lossless) ...[
            const Divider(height: 28),
            _buildOptionTitle(context.l10n.audioBitrate, textTheme),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final bitrate in _bitrateOptions)
                  ChoiceChip(
                    label: Text(context.l10n.audioBitrateValue('$bitrate')),
                    selected: _bitrate == bitrate,
                    showCheckmark: false,
                    onSelected: _converting
                        ? null
                        : (_) => setState(() => _bitrate = bitrate),
                  ),
              ],
            ),
          ],
          if (_format == AudioFormat.wav) ...[
            const Divider(height: 28),
            _buildOptionTitle(context.l10n.audioBitDepth, textTheme),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final depth in AudioBitDepth.values)
                  ChoiceChip(
                    label: Text(depth.label),
                    selected: _bitDepth == depth,
                    showCheckmark: false,
                    onSelected: _converting
                        ? null
                        : (_) => setState(() => _bitDepth = depth),
                  ),
              ],
            ),
          ],
          const Divider(height: 28),
          _buildOptionTitle(context.l10n.audioSampleRate, textTheme),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: Text(context.l10n.audioKeepOriginal),
                selected: _sampleRate == null,
                showCheckmark: false,
                onSelected: _converting
                    ? null
                    : (_) => setState(() => _sampleRate = null),
              ),
              for (final rate in _sampleRateOptions)
                ChoiceChip(
                  label: Text(_formatSampleRate(rate)),
                  selected: _sampleRate == rate,
                  showCheckmark: false,
                  onSelected: _converting
                      ? null
                      : (_) => setState(() => _sampleRate = rate),
                ),
            ],
          ),
          const Divider(height: 28),
          _buildOptionTitle(context.l10n.audioChannels, textTheme),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: Text(context.l10n.audioKeepOriginal),
                selected: _channels == null,
                showCheckmark: false,
                onSelected: _converting
                    ? null
                    : (_) => setState(() => _channels = null),
              ),
              ChoiceChip(
                label: Text(context.l10n.audioMono),
                selected: _channels == 1,
                showCheckmark: false,
                onSelected: _converting
                    ? null
                    : (_) => setState(() => _channels = 1),
              ),
              ChoiceChip(
                label: Text(context.l10n.audioStereo),
                selected: _channels == 2,
                showCheckmark: false,
                onSelected: _converting
                    ? null
                    : (_) => setState(() => _channels = 2),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTitle(String title, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildProgressCard(ColorScheme scheme, TextTheme textTheme) {
    final progress = _progress;
    return SectionCard(
      color: scheme.secondaryContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  context.l10n.audioConvertingTo(_format.label),
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: scheme.onSecondaryContainer,
                  ),
                ),
              ),
              Text(
                progress == null
                    ? context.l10n.audioProcessing
                    : '${(progress * 100).clamp(0, 100).toStringAsFixed(0)}%',
                style: textTheme.labelLarge?.copyWith(
                  color: scheme.onSecondaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: scheme.onSecondaryContainer.withValues(
                alpha: 0.12,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  _speed > 0
                      ? context.l10n.audioSpeedValue(_speed.toStringAsFixed(1))
                      : context.l10n.audioPreparing,
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSecondaryContainer.withValues(alpha: 0.8),
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: _cancelConvert,
                icon: const Icon(Icons.close_rounded, size: 18),
                label: Text(context.l10n.commonCancel),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(ColorScheme scheme, TextTheme textTheme) {
    return SectionCard(
      color: scheme.errorContainer,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline_rounded, color: scheme.onErrorContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _error!,
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(ColorScheme scheme, TextTheme textTheme) {
    return SectionCard(
      color: scheme.tertiaryContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TonalIcon(
                icon: Icons.check_circle_rounded,
                background: scheme.tertiary.withValues(alpha: 0.18),
                foreground: scheme.onTertiaryContainer,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.audioConvertDoneTitle,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: scheme.onTertiaryContainer,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$_resultName · ${_formatBytes(_resultSize)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onTertiaryContainer.withValues(
                          alpha: 0.75,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _saving ? null : _saveResult,
              icon: const Icon(Icons.save_alt_rounded),
              label: Text(
                _saving ? context.l10n.audioSaving : context.l10n.audioSaveFile,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.scheme,
    this.onPrimaryContainer = false,
  });

  final IconData icon;
  final String label;
  final ColorScheme scheme;
  final bool onPrimaryContainer;

  @override
  Widget build(BuildContext context) {
    final foreground = onPrimaryContainer
        ? scheme.onPrimaryContainer
        : scheme.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: foreground.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: foreground),
          const SizedBox(width: 5),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall
                ?.copyWith(color: foreground, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
