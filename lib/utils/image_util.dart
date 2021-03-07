import 'package:flutter/widgets.dart';

class ImageUtil {
  static Rect? getImageSize(
    ImageProvider imageProvider,
  ) {
    Rect? _rect;
    imageProvider
        .resolve(const ImageConfiguration())
        .addListener(ImageStreamListener((ImageInfo info, _) {
      _rect = Rect.fromCenter(
        center: Offset.zero,
        width: info.image.width * 1.0,
        height: info.image.height * 1.0,
      );
    }));
    return _rect;
  }
}
