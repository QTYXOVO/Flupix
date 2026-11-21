import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import 'eh_client.dart';
import 'eh_repository.dart';

/// 带 Cookie/Referer 与磁盘缓存的图片 Provider，供缩略图和阅读器共用。
class EhImageProvider extends ImageProvider<EhImageProvider> {
  const EhImageProvider({
    required this.client,
    required this.url,
    required this.referer,
  });

  final EhClient client;
  final String url;
  final String referer;

  @override
  Future<EhImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<EhImageProvider>(this);
  }

  @override
  ImageStreamCompleter loadImage(
    EhImageProvider key,
    ImageDecoderCallback decode,
  ) {
    return MultiFrameImageStreamCompleter(
      codec: _load(key, decode),
      scale: 1,
      debugLabel: url,
      informationCollector: () => [
        DiagnosticsProperty<String>(
          'URL',
          url,
          style: DiagnosticsTreeStyle.errorProperty,
        ),
      ],
    );
  }

  Future<ui.Codec> _load(
    EhImageProvider key,
    ImageDecoderCallback decode,
  ) async {
    final bytes = await EhImageLoader.loadBytes(
      key.client,
      url: key.url,
      referer: key.referer,
    );
    final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
    return decode(buffer);
  }

  @override
  bool operator ==(Object other) {
    return other is EhImageProvider &&
        other.url == url &&
        other.referer == referer;
  }

  @override
  int get hashCode => Object.hash(url, referer);

  @override
  String toString() => 'EhImageProvider("$url")';
}
