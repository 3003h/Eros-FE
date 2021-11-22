import 'dart:convert';

import 'package:fehviewer/models/base/eh_models.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;

Mpv parserMpvImage(String html) {
  final Document document = parse(html);

  final mpvkey =
      RegExp(r'mpvkey\s+=\s+"([0-9a-z]+)"').firstMatch(html)?.group(1);
  final imagelistStr =
      RegExp(r'imagelist\s+=\s+(\[.+\]);').firstMatch(html)?.group(1);

  // print('mpvkey:$mpvkey\nimagelistStr:$imagelistStr');

  final imageList = <MvpImage>[];
  for (final dynamic e in jsonDecode(imagelistStr ?? '[]') as List<dynamic>) {
    final MvpImage _mpvImage = MvpImage.fromJson(e as Map<String, dynamic>);
    // print('------- _mpvImage ${_mpvImage.thumbName}');
    imageList.add(_mpvImage);
  }

  print('${imageList.length}');

  return Mpv(
    imagelist: imageList,
    mpvkey: mpvkey,
  );
}
