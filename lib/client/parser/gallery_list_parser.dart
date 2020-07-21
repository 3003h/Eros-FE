import 'dart:convert';

import 'package:FEhViewer/client/tag_database.dart';
import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/models/index.dart';
import 'package:FEhViewer/utils/dio_util.dart';
import 'package:FEhViewer/utils/utility.dart';
import 'package:FEhViewer/values/const.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:intl/intl.dart';

class GalleryListParser {
  /// 获取热门画廊列表
  static Future<List<GalleryItem>> getPopular() async {
    Global.logger.v("获取热门");
    HttpManager httpManager = HttpManager.getInstance(
        EHConst.getBaseSite(Global.profile.ehConfig.siteEx));
    const url = "/popular";

    var cookie = Global.profile?.token ?? "";

    Options options = Options(headers: {
      "Cookie": cookie,
    });

    var response = await httpManager.get(url, options: options);

    List<GalleryItem> list = await parseGalleryList(response);

    return list;
  }

  /// 获取默认画廊列表
  static Future<List<GalleryItem>> getGallery(
      {int page, String fromGid}) async {
    bool isEx = Global.profile.ehConfig.siteEx;

    HttpManager httpManager = HttpManager.getInstance(
        EHConst.getBaseSite(Global.profile.ehConfig.siteEx));

    var url = "";
    if (page != null && fromGid != null) {
      url = "/?page=$page&from=$fromGid";
    } else if (page != null) {
      url = "/?page=$page";
    }

    debugPrint('$url');

    var cookie = Global.profile?.token ?? "";

    Options options =
        Options(headers: {"Cookie": cookie, "Referer": "https://e-hentai.org"});

    var response = await httpManager.get(url, options: options);

    List<GalleryItem> list = await parseGalleryList(response);

    return list;
  }

  /// 获取收藏
  static Future<List<GalleryItem>> getFavorite({String favcat}) async {
    HttpManager httpManager = HttpManager.getInstance(
        EHConst.getBaseSite(Global.profile.ehConfig.siteEx));

    //收藏时间排序
    var _order = Global?.profile?.ehConfig?.favoritesOrder;

    var url = "/favorites.php";
    if (favcat != null && favcat != "a" && favcat != '') {
      url = "$url?favcat=$favcat";
    }

    if (_order != null) {
      url = "$url?inline_set=$_order";
    }

    var cookie = Global.profile?.token ?? "";

    Global.logger.v('$url  cookie:$cookie');

    Options options = Options(headers: {
      "Cookie": cookie,
    });

    var response = await httpManager.get(url, options: options);

    List<GalleryItem> list = await parseGalleryList(response, isFavorite: true);

    return list;
  }

  /// 获取api
  static Future getGalleryApi(String req) async {
    HttpManager httpManager = HttpManager.getInstance(EHConst.EH_BASE_URL);
    const url = "/api.php";

    var response = await httpManager.postForm(url, data: req);

    return response;
  }

  /// 列表数据处理
  static Future<List<GalleryItem>> parseGalleryList(String response,
      {isFavorite = false}) async {
    var document = parse(response);

    const GALLERY_SELECT =
        "body > div.ido > div:nth-child(2) > table > tbody > tr";
    const FAVORITE_SELECT =
        "body > div.ido > form > table.itg.gltc > tbody > tr";

    final select = isFavorite ? FAVORITE_SELECT : GALLERY_SELECT;

    final fav =
        document.querySelector("body > div.ido > form > p")?.text?.trim() ?? "";

    // ignore: unnecessary_statements
    isFavorite ? Global.logger.v("fav num  $fav") : null;

    // 画廊列表
    List<dom.Element> gallerys = document.querySelectorAll(select);
//    Global.logger.v('gallerys ${gallerys.length}');

    List<GalleryItem> gallaryItems = [];
    for (int i = 0; i < gallerys.length; i++) {
      var tr = gallerys[i];

      final category = tr.querySelector('td.gl1c.glcat > div')?.text?.trim();

      // 表头或者广告
      if (category == null || category.isEmpty) {
        continue;
      }

      final title =
          tr.querySelector('td.gl3c.glname > a > div.glink')?.text?.trim();

      final url =
          tr.querySelector('td.gl3c.glname > a')?.attributes['href'] ?? '';

      RegExp urlRex = new RegExp(r"/g/(\d+)/(\w+)/$");
      var urlRult = urlRex.firstMatch(url);

      final gid = urlRult.group(1);
      final token = urlRult.group(2);

      // tags
      List tags = tr.querySelectorAll('div.gt');

      // 英文tag
      final List<String> simpleTags = [];
      for (var tag in tags) {
        var tagText = tag.text.trim();
        simpleTags.add(tagText);
      }

      // 中文tag
      final List<String> simpleTagsTranslate = [];
      for (var tag in tags) {
        var tagText = tag.text.trim();
        simpleTagsTranslate
            .add(await EhTagDatabase.getTranTag(tagText) ?? tagText);
      }

      final img = tr.querySelector('td.gl2c > div > div > img');
      final imgDataSrc = img.attributes['data-src'];
      final imgSrc = img.attributes['src'];
      final imgUrl = imgDataSrc ?? imgSrc ?? '';

      // 评分星级计算 (api获取不到评分时用)
      final ratPx = tr
          .querySelector('td.gl2c > div:nth-child(2) > div.ir')
          .attributes['style'];
      RegExp pxA = new RegExp(r"-?(\d+)px\s+-?(\d+)px");
      var px = pxA.firstMatch(ratPx);

      //
      final ratingFB = (80.0 - double.parse(px.group(1))) / 16.0 -
          (px.group(2) == '21' ? 0.5 : 0.0);

//      Global.loggerNoStack.i('ratingFB $ratingFB');

      final postTime =
          tr.querySelector('td.gl2c > div:nth-child(2) > div')?.text?.trim() ??
              '';
      DateTime time =
          DateFormat('yyyy-MM-dd HH:mm').parseUtc(postTime).toLocal();

      final postTimeLocal = DateFormat('yyyy-MM-dd HH:mm').format(time);

      // 收藏标志
      final favTitle = tr
              .querySelector('td.gl2c > div:nth-child(2) > div')
              ?.attributes['title'] ??
          '';

      gallaryItems.add(GalleryItem()
        ..gid = gid
        ..token = token
        ..englishTitle = title
        ..imgUrl = imgUrl ?? ''
        ..url = url
        ..category = category
        ..simpleTags = simpleTags
        ..postTime = postTimeLocal
        ..simpleTagsTranslat = simpleTagsTranslate
        ..ratingFallBack = ratingFB
        ..favTitle = favTitle);
    }

    // 通过api请求获取更多信息
    if (gallaryItems.length > 0) {
      await getMoreGalleryInfo(gallaryItems);
    }

    return gallaryItems;
  }

  /// 通过api请求获取更多信息
  /// 例如
  /// 画廊评分
  /// 日语标题
  /// 等等
  static Future<List<GalleryItem>> getMoreGalleryInfo(
      List<GalleryItem> galleryItems) async {
    // Global.logger.i('api qry items ${galleryItems.length}');
    if (galleryItems.length == 0) {
      return galleryItems;
    }

    // 通过api获取画廊详细信息
    List _gidlist = [];

    galleryItems.forEach((galleryItem) {
      _gidlist.add([galleryItem.gid, galleryItem.token]);
    });

    // 25个一组分割
    List _group = EHUtils.splitList(_gidlist, 25);

    List rultList = [];

    // 查询 合并结果
    for (int i = 0; i < _group.length; i++) {
      Map reqMap = {'gidlist': _group[i], 'method': 'gdata'};
      String reqJsonStr = jsonEncode(reqMap);
      var rult = await getGalleryApi(reqJsonStr);

      var jsonObj = jsonDecode(rult.toString());
      var tempList = jsonObj['gmetadata'];
      rultList.addAll(tempList);
    }

    var unescape = new HtmlUnescape();

    for (int i = 0; i < galleryItems.length; i++) {
      galleryItems[i].englishTitle = unescape.convert(rultList[i]['title']);
      galleryItems[i].japaneseTitle =
          unescape.convert(rultList[i]['title_jpn']);

      var rating = rultList[i]['rating'];
      // Global.loggerNoStack.v('$rating');
      galleryItems[i].rating = rating != null
          ? double.parse(rating)
          : galleryItems[i].ratingFallBack;

//      galleryItems[i].imgUrl = rultList[i]['thumb'];
      galleryItems[i].filecount = rultList[i]['filecount'];
      galleryItems[i].uploader = rultList[i]['uploader'];
    }

    return galleryItems;
  }
}
