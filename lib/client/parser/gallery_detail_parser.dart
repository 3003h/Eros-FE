import 'package:FEhViewer/client/tag_database.dart';
import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/models/index.dart';
import 'package:FEhViewer/models/base/mode_init.dart';
import 'package:FEhViewer/utils/dio_util.dart';
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:dio/dio.dart';

class GalleryDetailParser {
  /// 获取画廊详细信息
  static Future<GalleryItem> getGalleryDetail(GalleryItem inGalleryItem) async {
    //

    Global.logger.i("获取画廊 ${inGalleryItem.url}");
    HttpManager httpManager = HttpManager.getInstance();
    final url = inGalleryItem.url;

    var cookie = Global.profile?.token ?? "";

    Options options = Options(headers: {
      "Cookie": cookie,
    });

    var response = await httpManager.get(url, options: options);

    GalleryItem galleryItem = await parseGalleryDetail(response);

    // Global.logger.v("$response");

    return galleryItem;
  }

  static Future<GalleryItem> parseGalleryDetail(String response) async {
    // 解析响应信息dom
    var document = parse(response);

    GalleryItem galleryItem = GalleryItem();

    // taglist
    galleryItem.tagGroup = [];
    const tagGroupSelect = '#taglist > table > tbody > tr';
    List<dom.Element> tagGroups = document.querySelectorAll(tagGroupSelect);
    Global.logger.v('tagGroups len  ${tagGroups.length}');
    for (var tagGroup in tagGroups) {
      var type = tagGroup.querySelector('td.tc').text.trim();
      type = RegExp(r"(\w+):?$").firstMatch(type).group(1);

      List<dom.Element> tags = tagGroup.querySelectorAll('td > div > a');
      List<GalleryTag> galleryTags = [];
      for (var tagElm in tags) {
        var title = tagElm.text.trim() ?? '';
        if (title.contains('|')) {
          title = title.split('|')[0];
        }
        var tagTranslat =
            await EhTagDatabase.getTranTag(title, nameSpase: type) ?? title;
//        Global.logger.v('$title $tagTranslat');
        galleryTags.add(GalleryTag()
          ..title = title
          ..type = type
          ..tagTranslat = tagTranslat);
      }

      galleryItem.tagGroup.add(TagGroup()
        ..tagType = type
        ..galleryTags = galleryTags);
    }

    return galleryItem;
  }
}
