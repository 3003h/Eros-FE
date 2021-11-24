import 'dart:convert';

import 'package:fehviewer/component/exception/error.dart';
import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/models/base/eh_models.dart';

GalleryImage parserMpvImageDispatch(String json) {
  // print('====================== $json');
  final rult = jsonDecode(json) as Map<String, dynamic>;
  final String imageUrl = rult['i'] as String;
  final sourceId = rult['s'];
  final width = rult['xres'] as String;
  final height = rult['yres'] as String;

  final lo = rult['yres'] as String;

  final originImageUrl = rult['lf'] as String;

  final regExpGalleryPageUrl = RegExp(r'/s/([0-9a-z]+)/(\d+)-(\d+)');
  final match = regExpGalleryPageUrl.firstMatch(lo);
  final ser = match?.group(3) ?? '1';
  final gid = match?.group(2) ?? '0';

  return GalleryImage(
    ser: int.parse(ser),
    gid: gid,
    imageUrl: imageUrl,
    sourceId: '$sourceId',
    imageWidth: double.parse(width),
    imageHeight: double.parse(height),
    originImageUrl: originImageUrl,
  );
}
