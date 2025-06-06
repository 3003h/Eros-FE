import 'package:eros_fe/component/exception/error.dart';
import 'package:eros_fe/const/const.dart';
import 'package:eros_fe/extension.dart';
import 'package:eros_fe/models/index.dart';
import 'package:eros_fe/utils/logger.dart';
import 'package:html_unescape/html_unescape.dart';

GalleryImage paraShowPageJson(Map<String, dynamic> jsonMap) {
  final HtmlUnescape htmlUnescape = HtmlUnescape();
  final RegExp regImageUrl = RegExp(r'<img[^>]*src="([^"]+)" style');
  final String imageUrl =
      regImageUrl.firstMatch('${jsonMap['i3']}')?.group(1) ?? '';

  logger.t('largeImageUrl $imageUrl');
  logger.t('jsonMap $jsonMap');

  final RegExpMatch? xy = RegExp(r'(\S+)\s+::\s+(\d+)\s+x\s+(\d+)(\s+::)?')
      .firstMatch('${jsonMap['i']}');

  final String? filename = xy?.group(1)?.trim();

  // final double? width = _xy != null ? double.parse(_xy.group(2)!) : null;
  // final double? height = _xy != null ? double.parse(_xy.group(3)!) : null;
  final double? width = double.tryParse('${jsonMap['x']}');
  final double? height = double.tryParse('${jsonMap['y']}');

  if (width == null || height == null) {
    throw EhError(type: EhErrorType.parse, error: 'width or height is null');
  }

  final RegExp urlRegExp =
      RegExp(r'https?://e[-x]hentai.org/g/([0-9]+)/([0-9a-z]+)/?');

  final RegExpMatch? urlResult = urlRegExp.firstMatch('${jsonMap['i5']}');
  final gid = urlResult?.group(1) ?? '';
  final token = urlResult?.group(2) ?? '';

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

  final String sourceId =
      RegExp(r"nl\('(.*?)'\)").firstMatch('${jsonMap['i6']}')?.group(1) ?? '';

  final GalleryImage reImage = kDefGalleryImage.copyWith(
    imageUrl: imageUrl.oN,
    sourceId: sourceId.oN,
    imageWidth: width.oN,
    imageHeight: height.oN,
    gid: gid.oN,
    token: token.oN,
    ser: ser,
    originImageUrl: originImageUrl.oN,
    filename: filename.oN,
  );

  return reImage;
}
