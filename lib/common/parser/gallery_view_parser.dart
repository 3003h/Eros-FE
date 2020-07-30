import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/utils/dio_util.dart';
import 'package:dio/dio.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;

class GalleryViewParser {
  static Future<String> getImageUrl(String href) async {
    HttpManager httpManager = HttpManager.getInstance();

    var urlTemp = href.split('/');

    var url = 'https://e-hentai.org/lofi/s/' +
        urlTemp[urlTemp.length - 2] +
        '/' +
        urlTemp[urlTemp.length - 1];

    var cookie = Global.profile?.user?.cookie ?? "";

    Options options = Options(headers: {
      "Cookie": cookie,
    });

    var response = await httpManager.get(
      url,
      options: options,
    );

    var document = parse(response);

    Element imageElem = document.querySelector('#sm');
    var imageSrc = imageElem.attributes['src'];

    Global.logger.v('$imageSrc');

    return imageSrc;
  }
}
