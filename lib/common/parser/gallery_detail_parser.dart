import 'package:FEhViewer/common/tag_database.dart';
import 'package:FEhViewer/models/index.dart';
import 'package:FEhViewer/utils/utility.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;
import 'package:intl/intl.dart';

class GalleryDetailParser {

  /// 解析响应数据
  static Future<GalleryItem> parseGalleryDetail(String response, {GalleryItem inGalleryItem}) async {
    // 解析响应信息dom
    var document = parse(response);

    GalleryItem galleryItem = inGalleryItem ?? GalleryItem();

    /// taglist
    galleryItem.tagGroup = [];
    const tagGroupSelect = '#taglist > table > tbody > tr';
    List<Element> tagGroups = document.querySelectorAll(tagGroupSelect);
    for (var tagGroup in tagGroups) {
      var type = tagGroup
          .querySelector('td.tc')
          .text
          .trim();
      type = RegExp(r"(\w+):?$").firstMatch(type).group(1);

      List<Element> tags = tagGroup.querySelectorAll('td > div > a');
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

    // 解析评论区数据
    galleryItem.galleryComment = [];
    const commentSelect = '#cdiv > div.c1';
    List<Element> commentList = document.querySelectorAll(commentSelect);
//    Global.logger.v('${commentList.length}');
    for (var comment in commentList) {
      // 评论人
      var postElem = comment.querySelector('div.c2 > div.c3 > a');
      var postName = postElem.text.trim();

      // 解析时间
      var timeElem = comment.querySelector('div.c2 > div.c3');
      var postTime = timeElem.text.trim();
      // 示例: Posted on 29 June 2020, 05:41 UTC by:  
      var postTimeUTC = RegExp(r"Posted on (.+, .+) UTC by").firstMatch(
          postTime).group(1);

      // 时间由utc转为本地时间
      DateTime time = DateFormat('dd MMMM yyyy, HH:mm', 'en_US').parseUtc(
          postTimeUTC).toLocal();
      final postTimeLocal = DateFormat('yyyy-MM-dd HH:mm').format(time);


      // 评论评分 (Uploader Comment 没有)
      var scoreElem = comment.querySelector('div.c2 > div.c5.nosel');
      var score = scoreElem?.text?.trim() ?? '';

      // 解析评论内容 TODO href的解析有问题
      var contextElem = comment.querySelector('div.c6');
      // br回车以及引号的处理
      var context = contextElem.nodes
          .map((node) {
        if (node.nodeType == Node.TEXT_NODE) {
          return RegExp(r'^"?(.+)"?$')
              .firstMatch(node.text.trim())
              ?.group(1) ?? node.text;
        } else if (node.nodeType == Node.ELEMENT_NODE &&
            (node as Element).localName == 'br') {
          return '\n';
        }
      })
          .join();

      galleryItem.galleryComment.add(GalleryComment()
        ..name = postName
        ..context = context
        ..time = postTimeLocal
        ..score = score);
    }


    // 解析画廊缩略图
    List<GalleryPreview> previewList = parseGalleryPreview(document);
    galleryItem.galleryPreview = previewList;


    // 获取画廊 showKey
    final showKey = await Api.getShowkey(previewList[0].href);
    galleryItem.showKey = showKey;

    // 解析收藏标志
    var favTitle = '';
    Element fav = document.querySelector("#favoritelink");
    if (fav?.nodes?.length == 1) {
      favTitle = fav.text.trim();
    }

    galleryItem.favTitle = favTitle;

    return galleryItem;
  }

  static List<GalleryPreview> parseGalleryPreviewFromHtml(String response) {
    // 解析响应信息dom
    var document = parse(response);
    return parseGalleryPreview(document);
  }

  static List<GalleryPreview> parseGalleryPreview(Document document) {
    // 大图 #gdt > div.gdtl  小图 #gdt > div.gdtm
    List<Element> picLsit = document.querySelectorAll('#gdt > div.gdtm');

    List<GalleryPreview> galleryPreview = [];

    if (picLsit.length > 0) {
      // 小图的处理
      for (var pic in picLsit) {
        var picHref = pic
            .querySelector('a')
            .attributes['href'];
        var style = pic
            .querySelector('div')
            .attributes['style'];
        var picSrcUrl = RegExp(r"url\((.+)\)").firstMatch(style).group(1);
        var height = RegExp(r"height:(\d+)?px").firstMatch(style).group(1);
        var width = RegExp(r"width:(\d+)?px").firstMatch(style).group(1);
        var offSet = RegExp(r"\) -(\d+)?px ").firstMatch(style).group(1);

        Element imgElem = pic.querySelector('img');
        var picSer = imgElem.attributes['alt'].trim();

        galleryPreview.add(GalleryPreview()
          ..ser = int.parse(picSer)
          ..isLarge = false
          ..href = picHref
          ..imgUrl = picSrcUrl
          ..height = double.parse(height)
          ..width = double.parse(width)
          ..offSet = double.parse(offSet)
        );
      }
    } else {
      List<Element> picLsit = document.querySelectorAll('#gdt > div.gdtl');
      // 大图的处理
      for (var pic in picLsit) {
        var picHref = pic
            .querySelector('a')
            .attributes['href'];
        Element imgElem = pic.querySelector('img');
        var picSer = imgElem.attributes['alt'].trim();
        var picSrcUrl = imgElem.attributes['src'].trim();

        galleryPreview.add(GalleryPreview()
          ..ser = int.parse(picSer)
          ..isLarge = true
          ..href = picHref
          ..imgUrl = picSrcUrl
        );
      }
    }

    return galleryPreview;
  }


}
