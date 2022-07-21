import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/models/index.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;
import 'package:html_unescape/html_unescape.dart';

GalleryImage paraImage(String htmlText) {
  final Document document = parse(htmlText);
  final HtmlUnescape htmlUnescape = HtmlUnescape();

  final RegExp regImageUrl = RegExp(r'<img[^>]*src="([^"]+)" style');
  final String imageUrl = regImageUrl.firstMatch(htmlText)?.group(1) ?? '';

  // throw EhError(type: EhErrorType.image509);

  // if (imageUrl.endsWith('/509.gif') || imageUrl.endsWith('/509s.gif')) {
  //   throw EhError(type: EhErrorType.image509);
  // }

  // logger.d('largeImageUrl $imageUrl');

  final Element? elmI2 = document.querySelector('#i2 > div:nth-child(1)');
  final RegExpMatch? _xy =
      RegExp(r'::\s+(\d+)\s+x\s+(\d+)(\s+::)?').firstMatch(elmI2?.text ?? '');
  final double? width = _xy != null ? double.parse(_xy.group(1)!) : null;
  final double? height = _xy != null ? double.parse(_xy.group(2)!) : null;

  final String _sourceId = RegExp(r"nl\('(.*?)'\)")
          .firstMatch(
              document.querySelector('#loadfail')!.attributes['onclick']!)!
          .group(1) ??
      '';

  final RegExp urlRegExp =
      RegExp(r'https?://e[-x]hentai.org/g/([0-9]+)/([0-9a-z]+)/?');

  final Element? elmToGallery = document.querySelector('#i5 > div > a');
  final String? gUrl = elmToGallery?.attributes['href'];
  String gid = '';
  String token = '';
  if (gUrl != null) {
    final RegExpMatch? urlRult = urlRegExp.firstMatch(gUrl);
    gid = urlRult?.group(1) ?? '';
    token = urlRult?.group(2) ?? '';
  }

  final List<Element> serElms =
      document.querySelectorAll('#i2 > div.sn > div > span');
  final int ser = int.parse(serElms[0].text);

  // 原图链接
  final regExpOriginImageUrl = RegExp(r'<a href="([^"]+)fullimg.php([^"]+)">');
  final match = regExpOriginImageUrl.firstMatch(htmlText);
  String? originImageUrl;
  if (match?.groupCount == 2) {
    originImageUrl =
        '${htmlUnescape.convert(match!.group(1)!)}fullimg.php${htmlUnescape.convert(match.group(2)!)}';
  }
  // print('====================>$originImageUrl');

  final GalleryImage _reImage = kDefGalleryImage.copyWith(
    imageUrl: imageUrl,
    sourceId: _sourceId,
    imageWidth: width,
    imageHeight: height,
    gid: gid,
    token: token,
    ser: ser,
    originImageUrl: originImageUrl,
  );

  return _reImage;
}
