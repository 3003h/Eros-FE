import 'package:FEhViewer/http/dio_util.dart';
import 'package:FEhViewer/model/gallery.dart';
import 'package:FEhViewer/utils/storage.dart';
import 'package:FEhViewer/values/storages.dart';
import 'package:html/parser.dart';
import 'package:html/dom.dart' as dom;

import 'dart:convert';

import 'package:flutter/cupertino.dart';

// 翻译
String translateTagType(eng) {
  const d = {
    'artist': "作者",
    'female': "女性",
    'male': "男性",
    'parody': "原作",
    'character': "角色",
    'group': "团队",
    'language': "语言",
    'reclass': "归类",
    'misc': "杂项"
  };
  return d[eng];
}

// 标签颜色
getNameAndColor(name) {
  const d = {
    "misc": {"string": "Misc", "color": "#777777"},
    "doujinshi": {"string": "Doujinshi", "color": "#9E2720"},
    "manga": {"string": "Manga", "color": "#DB6C24"},
    "artist cg": {"string": "Artist CG", "color": "#D38F1D"},
    "game cg": {"string": "Game CG", "color": "#617C63"},
    "image set": {"string": "Image Set", "color": "#325CA2"},
    "cosplay": {"string": "Cosplay", "color": "#6A32A2"},
    "asian porn": {"string": "Asian Porn", "color": "#A23282"},
    "non-h": {"string": "Non-H", "color": "#5FA9CF"},
    "western": {"string": "Western", "color": "#AB9F60"}
  };
  return d[name.toLowerCase()];
}

class API {
  /// 获取热门画廊列表
  static Future<List<GalleryItemBean>> getPopular() async {
    HttpManager httpManager = HttpManager.getInstance("https://e-hentai.org/");
    const url = "/popular";

    var response = await httpManager.get(url);

    List<GalleryItemBean> list = parseGalleryList(response);

    return list;
  }

  /// 获取默认画廊列表
  static Future<List<GalleryItemBean>> getGallery() async {
    HttpManager httpManager = HttpManager.getInstance("https://e-hentai.org/");
    const url = "";

    var response = await httpManager.get(url);

    List<GalleryItemBean> list = parseGalleryList(response);

    return list;
  }

  /// 列表数据处理
  static List<GalleryItemBean> parseGalleryList(String response) {
    var document = parse(response);

    // 画廊列表
    List<dom.Element> gallerys = document.querySelectorAll(
        'body > div.ido > div:nth-child(2) > table > tbody > tr');

    debugPrint('len ${gallerys.length}');

    List<GalleryItemBean> gallaryItems = [];

    for (int i = 1; i < gallerys.length; i++) {
      debugPrint('index $i');

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

      final img = tr.querySelector('td.gl2c > div > div > img');
      final img_data_src = img.attributes['data-src'];
      final img_src = img.attributes['src'];

      final imgUrl = img_data_src ?? img_src ?? '';

      final List<String> simpleTags = [];
      var tag = tr.querySelectorAll('div.gt');
      tag.forEach((tag) {
        simpleTags.add(tag.text.trim());
      });

      final postTime =
          tr.querySelector('td.gl2c > div:nth-child(2) > div').text.trim();

      // 评分星级计算
      final ratPx = tr
          .querySelector('td.gl2c > div:nth-child(2) > div.ir')
          .attributes['style'];
      debugPrint('ratPx $ratPx');
      RegExp pxA = new RegExp(r"-?(\d+)px\s+-?(\d+)px");
      var px = pxA.firstMatch(ratPx);
      debugPrint('pxa ${px.group(1)}  pxb ${px.group(2)}');

      //
      final rating = (80.0 - double.parse(px.group(1))) / 16.0 -
          (px.group(2) == '21' ? 0.5 : 0.0);

      debugPrint('rating $rating');

      final uploader = tr.querySelector('td.gl4c.glhide > div > a').text.trim();

      final length =
          tr.querySelector('td.gl4c.glhide > div:nth-child(1)')?.text?.trim() ??
              '';

      GalleryItemBean galleryItemBean = new GalleryItemBean(
        japanese_title: title,
        imgUrl: imgUrl ?? '',
        url: url,
        length: length,
        category: category,
        simpleTags: simpleTags,
        postTime: postTime,
        uploader: uploader,
        rating: rating,
      );

      gallaryItems.add(galleryItemBean);
//      debugPrint(galleryItemBean.toString());
    }

    return gallaryItems;
  }

  ///tag翻译
  static Future<String> generateTagTranslat() async {
    HttpManager httpManager = HttpManager.getInstance("https://api.github.com");

    const url = "/repos/EhTagTranslation/Database/releases/latest";

    var urlJson = await httpManager.get(url);

    // 获取发布时间 作为版本号
    var curVer = "";
    curVer = urlJson["published_at"];
    debugPrint(curVer);

    var oriVer = StorageUtil().getString(TAG_TRANSLAT_VER);
    debugPrint(oriVer);

    StorageUtil().setString(TAG_TRANSLAT_VER, curVer);

    var dbJson = jsonEncode(StorageUtil().getJSON(TAG_TRANSLAT));

    if (dbJson == null ||
        dbJson.isEmpty ||
        dbJson == "null" ||
        curVer != oriVer) {
      debugPrint("TagTranslat更新");
      List assList = urlJson["assets"];

      Map assMap = new Map();
      assList.forEach((assets) {
        assMap[assets["name"]] = assets["browser_download_url"];
      });
      var dbUrl = assMap["db.text.json"];

      debugPrint(dbUrl);

      HttpManager httpDB = HttpManager.getInstance();
      dbJson = await httpDB.get(dbUrl);
      if (dbJson != null) {
        var data = jsonDecode(dbJson.toString());
        data = data["data"];
        StorageUtil().setJSON(TAG_TRANSLAT, jsonEncode(data));
      }
      debugPrint("更新完成");
    } else {
      debugPrint("不需更新");
    }

    return curVer;
  }
}
