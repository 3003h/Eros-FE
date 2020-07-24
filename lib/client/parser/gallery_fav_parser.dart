import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/utils/dio_util.dart';
import 'package:FEhViewer/values/const.dart';
import 'package:dio/dio.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;

class GalleryFavParser {
  /// 收藏操作
  static Future<void> galleryAddfavorite(String gid, String token,
      {String favcat = 'favdel', String favnote}) async {
    HttpManager httpManager = HttpManager.getInstance(
        EHConst.getBaseSite(Global.profile.ehConfig.siteEx ?? false));

    var url = '/gallerypopups.php?gid=$gid&t=$token&act=addfav';
    var cookie = Global.profile?.user?.cookie ?? "";

    Options options = Options(headers: {
      "Cookie": cookie,
    });

    FormData formData = FormData.fromMap({'favcat': favcat, 'update': '1'});

    var response = await httpManager.postForm(
      url,
      options: options,
      data: formData,
    );

    // TODO a
    saveFavcat(gid, token);
  }

  static Future<List> gallerySelfavcat(String gid, String token) async {
//    Global.logger.v('gallerySelfavcat');

    HttpManager httpManager = HttpManager.getInstance(
        EHConst.getBaseSite(Global.profile.ehConfig.siteEx ?? false));

    var url = '/gallerypopups.php?gid=$gid&t=$token&act=addfav';
    var cookie = Global.profile?.user?.cookie ?? "";

    Options options = Options(headers: {
      "Cookie": cookie,
    });

    var response = await httpManager.get(
      url,
      options: options,
    );

    return parserAddFavPage(response);
  }

  static List parserAddFavPage(String response) {
    // 解析响应信息dom
    var document = parse(response);

    List favList = [];

    List<Element> favcats =
        document.querySelectorAll("#galpop > div > div.nosel > div");
    for (Element fav in favcats) {
      List<Element> divs = fav.querySelectorAll('div');
      String favId = divs[0].querySelector('input').attributes['value'].trim();
      var favTitle = divs[2].text.trim();
//      Global.logger.v('$favId  $favTitle');
      favList.add({'favId': favId, 'favTitle': favTitle});
    }

    return favList.sublist(0, 10);
  }

  static Future<List> getFavcat(String gid, String token,
      {bool cache = true}) async {
    // profile为空或者cache标志否
    if (Global.profile.user.favcat == null ||
        Global.profile.user.favcat.isEmpty ||
        !cache) {
      Global.profile.user.favcat = await gallerySelfavcat(gid, token);
    }

    return Global.profile.user.favcat;
  }

  static Future<void> saveFavcat(String gid, String token) async {
    Global.profile.user.favcat = await gallerySelfavcat(gid, token);
  }
}
