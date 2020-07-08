import 'package:FEhViewer/client/tag_database.dart';
import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/models/index.dart';
import 'package:FEhViewer/utils/dio_util.dart';
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

    /// taglist
    galleryItem.tagGroup = [];
    const tagGroupSelect = '#taglist > table > tbody > tr';
    List<dom.Element> tagGroups = document.querySelectorAll(tagGroupSelect);
    Global.logger.v('tagGroups len  ${tagGroups.length}');
    for (var tagGroup in tagGroups) {
      var type = tagGroup
          .querySelector('td.tc')
          .text
          .trim();
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

//        Global.logger.v('$type:$title $tagTranslat');
        galleryTags.add(GalleryTag()
          ..title = title
          ..type = type
          ..tagTranslat = tagTranslat);
      }

      galleryItem.tagGroup.add(TagGroup()
        ..tagType = type
        ..galleryTags = galleryTags);
    }

    /// 评论区数据处理
    galleryItem.galleryComment = [];
    const commentSelect = '#cdiv > div.c1';
    List<dom.Element> commentList = document.querySelectorAll(commentSelect);
//    Global.logger.v('${commentList.length}');
    for (var comment in commentList) {
      // 评论人
      var postElem = comment.querySelector('div.c2 > div.c3 > a');
      var postName = postElem.text.trim();

      var timeElem = comment.querySelector('div.c2 > div.c3');
      var postTime = timeElem.text.trim();
      // 示例: Posted on 29 June 2020, 05:41 UTC by:  
      postTime = RegExp(r"Posted on (.+, .+) by").firstMatch(postTime).group(1);

      // 评论评分 (Uploader Comment 没有)
      var scoreElem = comment.querySelector('div.c2 > div.c5.nosel');
      var score = scoreElem?.text?.trim() ?? '';

      // 评论内容
      var contextElem = comment.querySelector('div.c6');
      var context = contextElem.nodes
          .map((node) {
        if (node.nodeType == dom.Node.TEXT_NODE) {
          return RegExp(r'^"?(.+)"?$')
              .firstMatch(node.text.trim())
              ?.group(1) ?? node.text;
        } else if (node.nodeType == dom.Node.ELEMENT_NODE &&
            (node as dom.Element).localName == 'br') {
          return '\n';
        }
      })
          .join();

//      contextElem.children.forEach((element) {
//        Global.logger.v('${element}');
//      });


//      Global.logger.v('${contextElem.children.length}');


      galleryItem.galleryComment.add(GalleryComment()
        ..name = postName
        ..context = context
        ..time = postTime
        ..score = score);
    }

    return galleryItem;
  }
}
