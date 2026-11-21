import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:ffmpeg_kit_flutter_new_audio/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new_audio/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter_new_audio/ffmpeg_session.dart';
import 'package:ffmpeg_kit_flutter_new_audio/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter_new_audio/media_information.dart';
import 'package:ffmpeg_kit_flutter_new_audio/return_code.dart';
import 'package:ffmpeg_kit_flutter_new_audio/statistics.dart';
import 'package:ffmpeg_kit_flutter_new_audio/stream_information.dart';

import '../l10n/l10n.dart';

/// 支持的输出格式。
enum AudioFormat {
  mp3('MP3', 'mp3', 'audio/mpeg', lossless: false),
  wav('WAV', 'wav', 'audio/wav', lossless: true),
  flac('FLAC', 'flac', 'audio/flac', lossless: true),
  m4a('M4A', 'm4a', 'audio/mp4', lossless: false),
  ogg('OGG', 'ogg', 'audio/ogg', lossless: false),
  opus('Opus', 'opus', 'audio/opus', lossless: false);

  const AudioFormat(
    this.label,
    this.extension,
    this.mimeType, {
    required this.lossless,
  });

  final String label;
  final String extension;
  final String mimeType;

  /// 无损格式不提供码率选项。
  final bool lossless;
}

/// WAV 输出的位深。
enum AudioBitDepth {
  pcm16('pcm_s16le'),
  pcm24('pcm_s24le'),
  float32('pcm_f32le');

  const AudioBitDepth(this.codec);

  final String codec;

  String get label {
    switch (this) {
      case AudioBitDepth.pcm16:
        return AppL10n.current.audioBitDepth16;
      case AudioBitDepth.pcm24:
        return AppL10n.current.audioBitDepth24;
      case AudioBitDepth.float32:
        return AppL10n.current.audioBitDepthFloat32;
    }
  }
}

/// 探测到的源音频信息。
class AudioInfo {
  const AudioInfo({
    required this.duration,
    this.container,
    this.codec,
    this.sampleRate,
    this.channels,
    this.bitrate,
    this.sizeBytes,
  });

  final Duration duration;
  final String? container;
  final String? codec;
  final int? sampleRate;
  final int? channels;
  final int? bitrate;
  final int? sizeBytes;
}

/// 转码进度。
class AudioConversionProgress {
  const AudioConversionProgress({
    required this.processed,
    required this.duration,
    required this.speed,
  });

  final Duration processed;

  /// 源音频总时长，未知时为 null。
  final Duration? duration;

  /// FFmpeg 报告的转码倍速，0 表示未知。
  final double speed;

  /// 0~1 的进度；总时长未知时返回 null。
  double? get fraction {
    final total = duration?.inMilliseconds ?? 0;
    if (total <= 0) return null;
    return (processed.inMilliseconds / total).clamp(0.0, 1.0);
  }
}

class AudioConversionException implements Exception {
  const AudioConversionException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AudioConversionCancelled implements Exception {
  const AudioConversionCancelled();
}

/// 构建 FFmpeg 转码参数。抽成纯函数便于测试。
List<String> buildAudioConvertArguments({
  required String inputPath,
  required String outputPath,
  required AudioFormat format,
  int bitrateKbps = 192,
  int? sampleRate,
  int? channels,
  AudioBitDepth bitDepth = AudioBitDepth.pcm16,
}) {
  final arguments = <String>[
    '-hide_banner',
    '-y',
    '-i',
    inputPath,
    // 只保留第一条音频流，丢弃封面等附带视频流。
    '-vn',
    '-map',
    '0:a:0',
    '-map_metadata',
    '0',
  ];

  switch (format) {
    case AudioFormat.mp3:
      arguments.addAll(['-c:a', 'libmp3lame', '-b:a', '${bitrateKbps}k']);
    case AudioFormat.wav:
      arguments.addAll(['-c:a', bitDepth.codec]);
    case AudioFormat.flac:
      arguments.addAll(['-c:a', 'flac', '-compression_level', '5']);
    case AudioFormat.m4a:
      arguments.addAll(['-c:a', 'aac', '-b:a', '${bitrateKbps}k']);
    case AudioFormat.ogg:
      arguments.addAll(['-c:a', 'libvorbis', '-b:a', '${bitrateKbps}k']);
    case AudioFormat.opus:
      arguments.addAll(['-c:a', 'libopus', '-b:a', '${bitrateKbps}k']);
  }

  if (sampleRate != null) {
    arguments.addAll(['-ar', '$sampleRate']);
  }
  if (channels != null) {
    arguments.addAll(['-ac', '$channels']);
  }

  arguments.add(outputPath);
  return arguments;
}

/// 音频探测与转码服务。
///
/// Windows/Linux 调用系统 ffmpeg、ffprobe；Android 使用内置的 FFmpegKit。
class AudioConvertService {
  AudioConvertService._();

  /// 桌面端使用系统 FFmpeg，移动端使用随包内置的 FFmpegKit。
  static bool get usesSystemEngine => Platform.isWindows || Platform.isLinux;

  static int? _activeSessionId;
  static Process? _activeProcess;
  static bool _cancelRequested = false;

  /// 读取源音频的时长、编码等信息。
  static Future<AudioInfo> probe(String path) {
    if (usesSystemEngine) return _probeWithProcess(path);
    return _probeWithKit(path);
  }

  /// 执行转码，失败时抛出 [AudioConversionException]。
  static Future<void> convert({
    required String inputPath,
    required String outputPath,
    required AudioFormat format,
    int bitrateKbps = 192,
    int? sampleRate,
    int? channels,
    AudioBitDepth bitDepth = AudioBitDepth.pcm16,
    Duration? duration,
    void Function(AudioConversionProgress progress)? onProgress,
  }) {
    if (usesSystemEngine) {
      return _convertWithProcess(
        inputPath: inputPath,
        outputPath: outputPath,
        format: format,
        bitrateKbps: bitrateKbps,
        sampleRate: sampleRate,
        channels: channels,
        bitDepth: bitDepth,
        duration: duration,
        onProgress: onProgress,
      );
    }
    return _convertWithKit(
      inputPath: inputPath,
      outputPath: outputPath,
      format: format,
      bitrateKbps: bitrateKbps,
      sampleRate: sampleRate,
      channels: channels,
      bitDepth: bitDepth,
      duration: duration,
      onProgress: onProgress,
    );
  }

  /// 取消当前正在执行的转码任务。
  static Future<void> cancel() async {
    if (usesSystemEngine) {
      final process = _activeProcess;
      if (process == null) return;
      _cancelRequested = true;
      process.kill();
      return;
    }

    final sessionId = _activeSessionId;
    if (sessionId == null) return;
    _activeSessionId = null;
    await FFmpegKit.cancel(sessionId);
  }

  /// 返回 FFmpeg 版本，用于界面展示。
  static Future<String?> engineVersion() async {
    if (usesSystemEngine) {
      try {
        final result = await Process.run('ffmpeg', const ['-version']);
        if (result.exitCode != 0) return null;
        final firstLine = '${result.stdout}'.split('\n').first.trim();
        final match = RegExp(r'ffmpeg version (\S+)').firstMatch(firstLine);
        return match?.group(1) ?? firstLine;
      } catch (_) {
        return null;
      }
    }
    try {
      return await FFmpegKitConfig.getFFmpegVersion();
    } catch (_) {
      return null;
    }
  }

  // ------------------------------------------------------------ 系统 FFmpeg

  static Future<AudioInfo> _probeWithProcess(String path) async {
    ProcessResult result;
    try {
      result = await Process.run('ffprobe', [
        '-v',
        'error',
        '-print_format',
        'json',
        '-show_format',
        '-show_streams',
        '-i',
        path,
      ]);
    } on ProcessException {
      throw AudioConversionException(AppL10n.current.audioFfprobeNotFound);
    }
    if (result.exitCode != 0) {
      throw AudioConversionException(_describeFailure('${result.stderr}'));
    }

    Map<String, dynamic> json;
    try {
      json = jsonDecode('${result.stdout}') as Map<String, dynamic>;
    } catch (_) {
      throw AudioConversionException(AppL10n.current.audioProbeParseFailed);
    }

    Map<String, dynamic>? audioStream;
    final streams = json['streams'];
    if (streams is List) {
      for (final stream in streams) {
        if (stream is Map && stream['codec_type'] == 'audio') {
          audioStream = Map<String, dynamic>.from(stream);
          break;
        }
      }
    }
    if (audioStream == null) {
      throw AudioConversionException(AppL10n.current.audioNoAudioStream);
    }

    final format = json['format'] is Map
        ? Map<String, dynamic>.from(json['format'] as Map)
        : const <String, dynamic>{};
    final seconds = double.tryParse('${format['duration'] ?? ''}') ?? 0;

    return AudioInfo(
      duration: Duration(milliseconds: (seconds * 1000).round()),
      container: format['format_name'] as String?,
      codec: audioStream['codec_name'] as String?,
      sampleRate: int.tryParse('${audioStream['sample_rate'] ?? ''}'),
      channels: int.tryParse('${audioStream['channels'] ?? ''}'),
      bitrate: int.tryParse(
        '${audioStream['bit_rate'] ?? format['bit_rate'] ?? ''}',
      ),
      sizeBytes: int.tryParse('${format['size'] ?? ''}'),
    );
  }

  static Future<void> _convertWithProcess({
    required String inputPath,
    required String outputPath,
    required AudioFormat format,
    int bitrateKbps = 192,
    int? sampleRate,
    int? channels,
    AudioBitDepth bitDepth = AudioBitDepth.pcm16,
    Duration? duration,
    void Function(AudioConversionProgress progress)? onProgress,
  }) async {
    final baseArguments = buildAudioConvertArguments(
      inputPath: inputPath,
      outputPath: outputPath,
      format: format,
      bitrateKbps: bitrateKbps,
      sampleRate: sampleRate,
      channels: channels,
      bitDepth: bitDepth,
    );
    // 通过 stdout 输出结构化进度，便于解析百分比。
    final output = baseArguments.removeLast();
    final arguments = [
      ...baseArguments,
      '-progress',
      'pipe:1',
      '-nostats',
      output,
    ];

    _cancelRequested = false;
    Process process;
    try {
      process = await Process.start('ffmpeg', arguments);
    } on ProcessException {
      throw AudioConversionException(AppL10n.current.audioFfmpegNotFound);
    }
    _activeProcess = process;

    final errors = ListQueue<String>();
    final stderrFuture = process.stderr
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .forEach((line) {
          final text = line.trim();
          if (text.isEmpty) return;
          errors.addLast(text);
          while (errors.length > 40) {
            errors.removeFirst();
          }
        });

    var processed = Duration.zero;
    var speed = 0.0;
    await for (final line
        in process.stdout
            .transform(utf8.decoder)
            .transform(const LineSplitter())) {
      final separator = line.indexOf('=');
      if (separator <= 0) continue;
      final key = line.substring(0, separator);
      final value = line.substring(separator + 1);
      switch (key) {
        case 'out_time_us':
          final microseconds = int.tryParse(value);
          if (microseconds != null && microseconds >= 0) {
            processed = Duration(microseconds: microseconds);
          }
        case 'speed':
          final parsed = double.tryParse(value.replaceAll('x', ''));
          if (parsed != null) speed = parsed;
        case 'progress':
          onProgress?.call(
            AudioConversionProgress(
              processed: processed,
              duration: duration,
              speed: speed,
            ),
          );
      }
    }

    final exitCode = await process.exitCode;
    await stderrFuture;
    _activeProcess = null;

    final cancelled = _cancelRequested;
    _cancelRequested = false;
    if (cancelled) throw const AudioConversionCancelled();
    if (exitCode != 0) {
      throw AudioConversionException(_describeFailure(errors.join('\n')));
    }
  }

  // --------------------------------------------------------------- FFmpegKit

  static Future<AudioInfo> _probeWithKit(String path) async {
    final session = await FFprobeKit.getMediaInformation(path);
    final MediaInformation? information = session.getMediaInformation();
    if (information == null) {
      throw AudioConversionException(
        _describeFailure(await session.getOutput()),
      );
    }

    StreamInformation? audioStream;
    for (final stream in information.getStreams()) {
      if (stream.getType() == 'audio') {
        audioStream = stream;
        break;
      }
    }
    if (audioStream == null) {
      throw AudioConversionException(AppL10n.current.audioNoAudioStream);
    }

    final seconds = double.tryParse(information.getDuration() ?? '') ?? 0;

    return AudioInfo(
      duration: Duration(milliseconds: (seconds * 1000).round()),
      container: information.getFormat(),
      codec: audioStream.getCodec(),
      sampleRate: int.tryParse(audioStream.getSampleRate() ?? ''),
      channels: audioStream.getNumberProperty('channels')?.toInt(),
      bitrate: int.tryParse(audioStream.getBitrate() ?? ''),
      sizeBytes: int.tryParse(information.getSize() ?? ''),
    );
  }

  static Future<void> _convertWithKit({
    required String inputPath,
    required String outputPath,
    required AudioFormat format,
    int bitrateKbps = 192,
    int? sampleRate,
    int? channels,
    AudioBitDepth bitDepth = AudioBitDepth.pcm16,
    Duration? duration,
    void Function(AudioConversionProgress progress)? onProgress,
  }) async {
    final arguments = buildAudioConvertArguments(
      inputPath: inputPath,
      outputPath: outputPath,
      format: format,
      bitrateKbps: bitrateKbps,
      sampleRate: sampleRate,
      channels: channels,
      bitDepth: bitDepth,
    );

    final completer = Completer<FFmpegSession>();
    final session = await FFmpegKit.executeWithArgumentsAsync(
      arguments,
      (completed) {
        if (!completer.isCompleted) completer.complete(completed);
      },
      null,
      (Statistics statistics) {
        onProgress?.call(
          AudioConversionProgress(
            processed: Duration(milliseconds: statistics.getTime()),
            duration: duration,
            speed: statistics.getSpeed(),
          ),
        );
      },
    );
    _activeSessionId = session.getSessionId();

    final completed = await completer.future;
    _activeSessionId = null;

    final returnCode = await completed.getReturnCode();
    if (ReturnCode.isSuccess(returnCode)) return;
    if (ReturnCode.isCancel(returnCode)) {
      throw const AudioConversionCancelled();
    }
    throw AudioConversionException(
      _describeFailure(await completed.getOutput()),
    );
  }

  static String _describeFailure(String? logs) {
    if (logs == null || logs.trim().isEmpty) {
      return AppL10n.current.audioConvertFailedHint;
    }
    final lines = logs
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    for (final line in lines.reversed) {
      if (line.toLowerCase().contains('error') ||
          line.toLowerCase().contains('invalid')) {
        return line.length > 180 ? '${line.substring(0, 180)}…' : line;
      }
    }
    final last = lines.isEmpty
        ? AppL10n.current.audioConvertFailed
        : lines.last;
    return last.length > 180 ? '${last.substring(0, 180)}…' : last;
  }
}
