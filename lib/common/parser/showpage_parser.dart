import 'dart:convert';

import 'package:eros_fe/component/exception/error.dart';
import 'package:eros_fe/const/const.dart';
import 'package:eros_fe/extension.dart';
import 'package:eros_fe/models/index.dart';
import 'package:eros_fe/utils/logger.dart';
import 'package:html_unescape/html_unescape.dart';

GalleryImage paraShowPage(String jsonString) {
  final HtmlUnescape htmlUnescape = HtmlUnescape();
  final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;

  final RegExp regImageUrl = RegExp(r'<img[^>]*src="([^"]+)" style');
  final String imageUrl =
      regImageUrl.firstMatch('${jsonMap['i3']}')?.group(1) ?? '';

  logger.t('largeImageUrl $imageUrl');

  final RegExpMatch? _xy = RegExp(r'(\S+)\s+::\s+(\d+)\s+x\s+(\d+)(\s+::)?')
      .firstMatch('${jsonMap['i']}');

  final String? filename = _xy != null ? _xy.group(1)?.trim() : null;

  // final double? width = _xy != null ? double.parse(_xy.group(2)!) : null;
  // final double? height = _xy != null ? double.parse(_xy.group(3)!) : null;
  final double? width = double.parse('${jsonMap['x']}');
  final double? height = double.parse('${jsonMap['y']}');

  if (width == null || height == null) {
    throw EhError(type: EhErrorType.parse, error: 'width or height is null');
  }

  final RegExp urlRegExp =
      RegExp(r'https?://e[-x]hentai.org/g/([0-9]+)/([0-9a-z]+)/?');

  final RegExpMatch? urlRult = urlRegExp.firstMatch('${jsonMap['i5']}');
  final gid = urlRult?.group(1) ?? '';
  final token = urlRult?.group(2) ?? '';

  final int ser = int.parse('${jsonMap['p']}');

  // 原图链接
  final regExpOriginImageUrl = RegExp(r'<a href="([^"]+)fullimg([^"]+)">');
  final match = regExpOriginImageUrl.firstMatch('${jsonMap['i6']}');
  String? originImageUrl;
  if (match?.groupCount == 2) {
    originImageUrl =
        '${htmlUnescape.convert(match!.group(1)!)}fullimg${htmlUnescape.convert(match.group(2)!)}';
  }
  logger.t('======>>>> originImageUrl: $originImageUrl');

  final String _sourceId =
      RegExp(r"nl\('(.*?)'\)").firstMatch('${jsonMap['i6']}')?.group(1) ?? '';

  final GalleryImage _reImage = kDefGalleryImage.copyWith(
    imageUrl: imageUrl.oN,
    sourceId: _sourceId.oN,
    imageWidth: width.oN,
    imageHeight: height.oN,
    gid: gid.oN,
    token: token.oN,
    ser: ser,
    originImageUrl: originImageUrl.oN,
    filename: filename.oN,
  );

  return _reImage;
}
