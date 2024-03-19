import 'dart:ui' as ui show Codec;

import 'package:eros_fe/utils/logger.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_storage/shared_storage.dart' as ss;

import 'saf_image_provider.dart';

class ExtendedSafImageProvider extends SafUriImage
    with ExtendedImageProvider<SafUriImage> {
  const ExtendedSafImageProvider(
    Uri uri, {
    double scale = 1.0,
    this.cacheRawData = false,
    this.imageCacheName,
  })  : assert(!kIsWeb, 'not support on web'),
        super(uri, scale: scale);

  /// Whether cache raw data if you need to get raw data directly.
  /// For example, we need raw image data to edit,
  /// but [ui.Image.toByteData()] is very slow. So we cache the image
  /// data here.
  @override
  final bool cacheRawData;

  /// The name of [ImageCache], you can define custom [ImageCache] to store this provider.
  @override
  final String? imageCacheName;

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

  Future<ui.Codec> _loadAsync(
      SafUriImage key, ImageDecoderCallback decode) async {
    assert(key == this);

    logger.t('loadAsync ${uri.toString()}');
    if (!(await ss.exists(uri) ?? false)) {
      PaintingBinding.instance.imageCache.evict(key);
      throw StateError('File does not exist: ${uri.toString()}');
    }

    final Uint8List? bytes = await ss.getDocumentContent(uri);

    if (bytes == null || bytes.lengthInBytes == 0) {
      // The file may become available later.
      PaintingBinding.instance.imageCache.evict(key);
      throw StateError('$uri is empty and cannot be loaded as an image.');
    }

    return await instantiateImageCodec(bytes, decode);
  }

  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is ExtendedSafImageProvider &&
        uri == other.uri &&
        scale == other.scale &&
        cacheRawData == other.cacheRawData &&
        imageCacheName == other.imageCacheName;
  }

  @override
  int get hashCode => Object.hash(
        uri,
        scale,
        cacheRawData,
        imageCacheName,
      );

  @override
  String toString() =>
      '${objectRuntimeType(this, 'SafUriImage')}("${uri.toString()}", scale: $scale)';
}
