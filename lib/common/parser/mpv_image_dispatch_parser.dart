import 'dart:convert';

import 'package:eros_fe/index.dart';

GalleryImage parserMpvImageDispatch(String json) {
  logger.d('================MPV json\n$json');
  final result = jsonDecode(json) as Map<String, dynamic>;
  final String imageUrl = '${result['i']}';
  final sourceId = '${result['s']}';
  final width = '${result['xres']}';
  final height = '${result['yres']}';

  final lo = '${result['yres']}';

  final originImageUrl = '${result['lf']}';

  final regExpGalleryPageUrl = RegExp(r'/s/([0-9a-z]+)/(\d+)-(\d+)');
  final match = regExpGalleryPageUrl.firstMatch(lo);
  final ser = match?.group(3) ?? '1';
  final gid = match?.group(2) ?? '0';

  return GalleryImage(
    ser: int.parse(ser),
    gid: gid,
    imageUrl: imageUrl,
    sourceId: sourceId,
    imageWidth: double.parse(width),
    imageHeight: double.parse(height),
    originImageUrl: originImageUrl,
  );
}
