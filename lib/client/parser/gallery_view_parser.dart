import 'dart:convert';

import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/utils/dio_util.dart';
import 'package:FEhViewer/values/const.dart';
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

    var cookie = Global.profile?.token ?? "";

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

  static Future<String> getShowkey(String href) async {
    HttpManager httpManager = HttpManager.getInstance();

    var url = href;

    var cookie = Global.profile?.token ?? "";

    Options options = Options(headers: {
      "Cookie": cookie,
    });

    var response = await httpManager.get(
      url,
      options: options,
    );

    final RegExp regShowKey = RegExp(r'var showkey="([0-9a-z]+)";');

    var showkey = regShowKey.firstMatch(response)?.group(1) ?? '';

//    Global.logger.v('$showkey');

    return showkey;
  }

  static Future<String> getShowInfo(String href, String showKey,
      {int index}) async {
    HttpManager httpManager = HttpManager.getInstance(EHConst.EH_BASE_URL);
    const url = "/api.php";

    var cookie = Global.profile?.token ?? "";

    Options options = Options(headers: {
      "Cookie": cookie,
    });

    Global.logger.v('href = $href');

    var regExp = RegExp(r'https://e[-|x]hentai.org/s/([0-9a-z]+)/(\d+)-(\d+)');
    var regRult = regExp.firstMatch(href);
    var gid = int.parse(regRult.group(2));
    var imgkey = regRult.group(1);
    var page = int.parse(regRult.group(3));

    Map reqMap = {
      'method': 'showpage',
      'gid': gid,
      'page': page,
      'imgkey': imgkey,
      'showkey': showKey,
    };
    String reqJsonStr = jsonEncode(reqMap);

    Global.logger.v('$reqJsonStr');

    var response = await httpManager.postForm(
      url,
      options: options,
      data: reqJsonStr,
    );

//    Global.logger.v('$response');

    var rultJson = jsonDecode('$response');

    final RegExp regImageUrl = RegExp("<img[^>]*src=\"([^\"]+)\" style");
    var imageUrl = regImageUrl.firstMatch(rultJson['i3']).group(1);

    Global.logger.v('$imageUrl');

    return imageUrl;
  }
}
