import 'package:flutter_test/flutter_test.dart';
import 'package:flupix/core/audio_converter.dart';

void main() {
  group('buildAudioConvertArguments', () {
    test('MP3 使用 lame 编码并应用码率', () {
      final arguments = buildAudioConvertArguments(
        inputPath: 'in.wav',
        outputPath: 'out.mp3',
        format: AudioFormat.mp3,
        bitrateKbps: 256,
      );

      expect(arguments, containsAllInOrder(['-i', 'in.wav']));
      expect(arguments, containsAllInOrder(['-c:a', 'libmp3lame']));
      expect(arguments, containsAllInOrder(['-b:a', '256k']));
      expect(arguments, contains('-vn'));
      expect(arguments, containsAllInOrder(['0:a:0']));
      expect(arguments.last, 'out.mp3');
    });

    test('WAV 按位深选择 PCM 编码且不写码率', () {
      final arguments = buildAudioConvertArguments(
        inputPath: 'in.flac',
        outputPath: 'out.wav',
        format: AudioFormat.wav,
        bitDepth: AudioBitDepth.pcm24,
      );

      expect(arguments, containsAllInOrder(['-c:a', 'pcm_s24le']));
      expect(arguments.any((argument) => argument == '-b:a'), isFalse);
    });

    test('FLAC 使用无损编码与压缩等级', () {
      final arguments = buildAudioConvertArguments(
        inputPath: 'in.mp3',
        outputPath: 'out.flac',
        format: AudioFormat.flac,
      );

      expect(arguments, containsAllInOrder(['-c:a', 'flac']));
      expect(arguments, containsAllInOrder(['-compression_level', '5']));
      expect(arguments.any((argument) => argument == '-b:a'), isFalse);
    });

    test('M4A 使用 AAC 编码', () {
      final arguments = buildAudioConvertArguments(
        inputPath: 'in.wav',
        outputPath: 'out.m4a',
        format: AudioFormat.m4a,
        bitrateKbps: 128,
      );

      expect(arguments, containsAllInOrder(['-c:a', 'aac']));
      expect(arguments, containsAllInOrder(['-b:a', '128k']));
    });

    test('OGG 与 Opus 使用对应编码器', () {
      final ogg = buildAudioConvertArguments(
        inputPath: 'in.wav',
        outputPath: 'out.ogg',
        format: AudioFormat.ogg,
        bitrateKbps: 192,
      );
      final opus = buildAudioConvertArguments(
        inputPath: 'in.wav',
        outputPath: 'out.opus',
        format: AudioFormat.opus,
        bitrateKbps: 96,
      );

      expect(ogg, containsAllInOrder(['-c:a', 'libvorbis']));
      expect(opus, containsAllInOrder(['-c:a', 'libopus']));
      expect(opus, containsAllInOrder(['-b:a', '96k']));
    });

    test('采样率与声道选项追加到输出文件之前', () {
      final arguments = buildAudioConvertArguments(
        inputPath: 'in.wav',
        outputPath: 'out.mp3',
        format: AudioFormat.mp3,
        sampleRate: 44100,
        channels: 1,
      );

      expect(arguments, containsAllInOrder(['-ar', '44100']));
      expect(arguments, containsAllInOrder(['-ac', '1']));
      expect(arguments.last, 'out.mp3');
    });
  });
}
