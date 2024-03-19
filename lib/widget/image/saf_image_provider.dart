import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui show Codec, ImmutableBuffer;

import 'package:eros_fe/utils/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_storage/shared_storage.dart' as ss;

@immutable
class SafUriImage extends ImageProvider<SafUriImage> {
  /// Creates an object that decodes a [File] as an image.
  ///
  /// The arguments must not be null.
  const SafUriImage(this.uri, {this.scale = 1.0});

  /// The uri to decode into an image.
  final Uri uri;

  /// The scale to place in the [ImageInfo] object of the image.
  final double scale;

  @override
  Future<SafUriImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<SafUriImage>(this);
  }

  @override
  ImageStreamCompleter loadImage(SafUriImage key, ImageDecoderCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode),
      scale: key.scale,
      debugLabel: uri.toString(),
      informationCollector: () => <DiagnosticsNode>[
        ErrorDescription('Path: ${uri.toString()}'),
      ],
    );
  }

  // @override
  // ImageStreamCompleter loadBuffer(
  //     SafUriImage key, ImageDecoderCallback decode) {
  //   return MultiFrameImageStreamCompleter(
  //     codec: _loadAsync(key, decode, null),
  //     scale: key.scale,
  //     debugLabel: uri.toString(),
  //     informationCollector: () => <DiagnosticsNode>[
  //       ErrorDescription('Path: ${uri.toString()}'),
  //     ],
  //   );
  // }

  Future<ui.Codec> _loadAsync(
      SafUriImage key, ImageDecoderCallback decode) async {
    assert(key == this);

    logger.d('loadAsync ${uri.toString()}');
    if (!(await ss.exists(uri) ?? false)) {
      logger.e('File not exists: ${uri.toString()}');
      PaintingBinding.instance.imageCache.evict(key);
      throw StateError('File does not exist: ${uri.toString()}');
    }

    final Uint8List? bytes = await ss.getDocumentContent(uri);
    if (bytes == null || bytes.lengthInBytes == 0) {
      // The file may become available later.
      PaintingBinding.instance.imageCache.evict(key);
      throw StateError('$uri is empty and cannot be loaded as an image.');
    }

    return decode(await ui.ImmutableBuffer.fromUint8List(bytes));
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is SafUriImage && other.uri == uri && other.scale == scale;
  }

  @override
  int get hashCode => Object.hash(uri, scale);

  @override
  String toString() =>
      '${objectRuntimeType(this, 'SafUriImage')}("${uri.toString()}", scale: $scale)';
}
