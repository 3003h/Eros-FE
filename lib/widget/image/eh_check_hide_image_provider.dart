import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class EhCheckHideImage extends ImageProvider<EhCheckHideImage> {
  EhCheckHideImage({
    required this.imageProvider,
    this.scale = 1.0,
    this.checkPHashHide = false,
    this.checkQRCodeHide = false,
  });

  final ImageProvider imageProvider;
  final bool? checkPHashHide;
  final bool? checkQRCodeHide;
  final double scale;

  @override
  ImageStreamCompleter load(EhCheckHideImage key, DecoderCallback decode) {
    final DecoderCallback decodeCheck = (
      Uint8List bytes, {
      int? cacheWidth,
      int? cacheHeight,
      bool? allowUpscaling,
    }) {
      return _instantiateImageCodec(
        bytes,
        checkPHashHide: checkPHashHide,
        checkQRCodeHide: checkQRCodeHide,
      );
    };

    final ImageStreamCompleter completer = imageProvider.load(
      key.imageProvider,
      decodeCheck,
    );

    return completer;
  }

  @override
  Future<EhCheckHideImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<EhCheckHideImage>(this);
  }

  Future<Codec> _instantiateImageCodec(
    Uint8List list, {
    bool? checkPHashHide,
    bool? checkQRCodeHide,
  }) async {
    final ImmutableBuffer buffer = await ImmutableBuffer.fromUint8List(list);
    final ImageDescriptor descriptor = await ImageDescriptor.encoded(buffer);

    // if (checkPHashHide ?? false) {
    //   throw EhError(type: EhErrorType.imageHide, error: 'checkPHashHide');
    // }
    //
    // if (checkQRCodeHide ?? false) {
    //   throw EhError(type: EhErrorType.imageHide, error: 'checkQRCodeHide');
    // }

    return descriptor.instantiateCodec();
  }
}
