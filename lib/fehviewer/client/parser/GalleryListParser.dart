import 'dart:convert';

import 'package:FEhViewer/fehviewer/model/gallery.dart';
import 'package:FEhViewer/http/dio_util.dart';
import 'package:FEhViewer/utils/storage.dart';
import 'package:FEhViewer/values/storages.dart';
import 'package:flutter/cupertino.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:html/parser.dart';
import 'package:html/dom.dart' as dom;

import '../EhTagDatabase.dart';
import '../../../utils/utility.dart';

class GalleryListParser {
  /// 获取热门画廊列表
  static Future<List<GalleryItemBean>> getPopular() async {
    HttpManager httpManager = HttpManager.getInstance("https://e-hentai.org/");
    const url = "/popular";

    var response = await httpManager.get(url);

    List<GalleryItemBean> list = await parseGalleryList(response);

    return list;
  }

  /// 获取默认画廊列表
  static Future<List<GalleryItemBean>> getGallery() async {
    HttpManager httpManager = HttpManager.getInstance("https://e-hentai.org/");
    const url = "";

    var response = await httpManager.get(url);

    List<GalleryItemBean> list = await parseGalleryList(response);

    return list;
  }

  /// 获取api
  static Future getGalleryApi(String req) async {
    HttpManager httpManager = HttpManager.getInstance("https://e-hentai.org/");
    const url = "/api.php";

    var response = await httpManager.postForm(url, data: req);

    return response;
  }

  static void getMoreGalleryInfo(List<GalleryItemBean> galleryItems) async {
    debugPrint('api qry items ${galleryItems.length}');

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
//    debugPrint('${rultList}');

    var unescape = new HtmlUnescape();

    for (int i = 0; i < galleryItems.length; i++) {
//      print('${galleryItems[i].simpleTags}    ${rultList[i]['tags']}');

      galleryItems[i].english_title = unescape.convert(rultList[i]['title']);
      galleryItems[i].japanese_title = unescape.convert(rultList[i]['title_jpn']);
      galleryItems[i].rating = double.parse(rultList[i]['rating']);
      galleryItems[i].imgUrl = rultList[i]['thumb'];
      galleryItems[i].filecount = rultList[i]['filecount'];
    }
  }

  /// 列表数据处理
  static Future<List<GalleryItemBean>> parseGalleryList(String response) async {
    var document = parse(response);

    // 画廊列表
    List<dom.Element> gallerys = document.querySelectorAll(
        'body > div.ido > div:nth-child(2) > table > tbody > tr');

    List<GalleryItemBean> gallaryItems = [];

    for (int i = 1; i < gallerys.length; i++) {
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

//      debugPrint(url);
      RegExp urlRex = new RegExp(r"/g/(\d+)/(\w+)/$");
      var urlRult = urlRex.firstMatch(url);
//      debugPrint('gid ${urlRult.group(1)}  token ${urlRult.group(2)}');

      final gid = urlRult.group(1);
      final token = urlRult.group(2);

      // tags
      // todo 是否翻译tag
      final bool _enableTagTran = StorageUtil().getBool(ENABLE_TAG_TRANSLAT);
      final List<String> simpleTags = [];
      List tags = tr.querySelectorAll('div.gt');
//      tags.forEach((tag) async {
//        var tagText = tag.text.trim();
//        simpleTags.add(_enableTagTran ? await getTranTag(tagText) : tagText);
//      });
      for (var tag in tags) {
        var tagText = tag.text.trim();
        simpleTags.add(_enableTagTran
            ? await EhTagDatabase.getTranTag(tagText) ?? tagText
            : tagText);
      }

      final img = tr.querySelector('td.gl2c > div > div > img');
      final img_data_src = img.attributes['data-src'];
      final img_src = img.attributes['src'];
      final imgUrl = img_data_src ?? img_src ?? '';

      // old
      final postTime =
          tr.querySelector('td.gl2c > div:nth-child(2) > div').text.trim();

      final uploader = tr.querySelector('td.gl4c.glhide > div > a').text.trim();

      /// old end

      GalleryItemBean galleryItemBean = new GalleryItemBean(
        gid: gid,
        token: token,
        english_title: title,
//        imgUrl: imgUrl ?? '',
        url: url,
        category: category,
        simpleTags: simpleTags,
        postTime: postTime,
        uploader: uploader,
      );

      gallaryItems.add(galleryItemBean);
//      debugPrint(galleryItemBean.toString());
    }

    // 通过api请求获取更多信息
    await getMoreGalleryInfo(gallaryItems);

    return gallaryItems;
  }
}
