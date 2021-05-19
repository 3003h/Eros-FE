import 'package:fehviewer/models/index.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;

import '../global.dart';

GalleryPreview paraImage(String htmlText, String href) {
  // logger.d('htmlText $htmlText');
  final Document document = parse(htmlText);

  final RegExp regImageUrl = RegExp('<img[^>]*src=\"([^\"]+)\" style');
  final String imageUrl = regImageUrl.firstMatch(htmlText)?.group(1) ?? '';

  // logger.d('largeImageUrl $imageUrl');

  final Element? elmI2 = document.querySelector('#i2 > div:nth-child(1)');
  final RegExpMatch? _xy =
      RegExp(r'::\s+(\d+)\s+x\s+(\d+)(\s+::)?').firstMatch(elmI2!.text);
  final double? width = _xy != null ? double.parse(_xy.group(1)!) : null;
  final double? height = _xy != null ? double.parse(_xy.group(2)!) : null;

  final String _sourceId = RegExp(r"nl\('(.*?)'\)")
          .firstMatch(
              document.querySelector('#loadfail')!.attributes['onclick']!)!
          .group(1) ??
      '';

  // logger.v('para_sourceId: $_sourceId ');

  final GalleryPreview _rePreview = kDefGalleryPreview.copyWith(
    largeImageUrl: imageUrl,
    sourceId: _sourceId,
    largeImageWidth: width,
    largeImageHeight: height,
    href: href,
  );

  return _rePreview;
}
