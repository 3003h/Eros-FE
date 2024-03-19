import 'dart:convert';

import 'package:eros_fe/models/base/eh_models.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;

Mpv parserMpvPage(String html) {
  final Document document = parse(html);

  final mpvkey =
      RegExp(r'mpvkey(\s+)?=(\s+)?"([0-9a-z]+)"').firstMatch(html)?.group(3);
  final imagelistStr =
      RegExp(r'imagelist(\s+)?=(\s+)?(\[.+\]);').firstMatch(html)?.group(3);

  final gidStr =
      RegExp(r'gid(\s+)?=(\s+)?(\d+);').firstMatch(html)?.group(3) ?? '0';

  // print('mpvkey:$mpvkey\ngid:$gidStr');

  final imageList = <MvpImage>[];
  for (final dynamic e in jsonDecode(imagelistStr ?? '[]') as List<dynamic>) {
    final MvpImage _mpvImage = MvpImage.fromJson(e as Map<String, dynamic>);
    // print('------- _mpvImage ${_mpvImage.thumbName}');
    imageList.add(_mpvImage);
  }

  return Mpv(
    imagelist: imageList,
    gid: int.parse(gidStr),
    mpvkey: mpvkey,
  );
}
