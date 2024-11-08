import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

@immutable
class RectImageProvider extends ImageProvider<RectImageProvider> {
  const RectImageProvider(this.imageProvider, this.sourceRect);
  final ImageProvider imageProvider;
  final Rect sourceRect;

  @override
  Future<RectImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<RectImageProvider>(this);
  }

  @override
  ImageStreamCompleter loadImage(RectImageProvider key, decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key),
      scale: 1.0,
    );
  }

  Future<ui.Codec> _loadAsync(RectImageProvider key) async {
    final ImageStream stream = imageProvider.resolve(ImageConfiguration.empty);
    final Completer<ui.Codec> completer = Completer<ui.Codec>();

    stream.addListener(
      ImageStreamListener((ImageInfo info, bool synchronousCall) async {
        final image = info.image;
        final recorder = ui.PictureRecorder();
        final canvas = Canvas(recorder);
        final paint = Paint();

        canvas.drawImageRect(
          image,
          sourceRect,
          Rect.fromLTWH(0, 0, sourceRect.width, sourceRect.height),
          paint,
        );

        final picture = recorder.endRecording();
        final img = await picture.toImage(
          sourceRect.width.toInt(),
          sourceRect.height.toInt(),
        );

        final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
        final codec = await ui.instantiateImageCodec(
          byteData!.buffer.asUint8List(),
        );

        completer.complete(codec);
      }),
    );

    return completer.future;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (runtimeType != other.runtimeType) {
      return false;
    }
    final RectImageProvider typedOther = other as RectImageProvider;
    return imageProvider == typedOther.imageProvider &&
        sourceRect == typedOther.sourceRect;
  }

  @override
  int get hashCode => Object.hash(imageProvider, sourceRect);
}
