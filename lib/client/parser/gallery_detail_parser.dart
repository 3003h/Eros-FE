import 'package:FEhViewer/client/tag_database.dart';
import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/models/index.dart';
import 'package:FEhViewer/utils/dio_util.dart';
import 'package:dio/dio.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:intl/intl.dart';

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
//    Global.logger.v('tagGroups len  ${tagGroups.length}');
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
      var postTimeUTC = RegExp(r"Posted on (.+, .+) UTC by").firstMatch(
          postTime).group(1);

/*      var postTimes = RegExp(r"Posted on (\d+)\s?(\w+)\s+(\d+),\s?(.+) UTC by")
          .firstMatch(postTime);

      var postTimeParse = DateTime.parse(postTime);
      Global.logger.v(
          '${postTimes.group(1)} ${postTimes.group(2)} ${postTimes.group(
              3)} ${postTimes.group(4)}');

      var now = new DateTime.now();
      var formatter = new DateFormat('yyyy-MMMM-dd HH:mm','en_US');
      String formatted = formatter.format(now);
      Global.logger.v(formatted);*/


      DateTime time = DateFormat('dd MMMM yyyy, HH:mm', 'en_US').parseUtc(
          postTimeUTC).toLocal();

      final postTimeLocal = DateFormat('yyyy-MM-dd HH:mm').format(time);

//      Global.logger.v('$postTimeUTC \n ${postTimeLocal}');


      // 评论评分 (Uploader Comment 没有)
      var scoreElem = comment.querySelector('div.c2 > div.c5.nosel');
      var score = scoreElem?.text?.trim() ?? '';

      // 评论内容
      var contextElem = comment.querySelector('div.c6');
      // br回车以及引号的处理
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

      galleryItem.galleryComment.add(GalleryComment()
        ..name = postName
        ..context = context
        ..time = postTimeLocal
        ..score = score);
    }


    /// 画廊缩略图
    /// 大图 #gdt > div.gdtl  小图 #gdt > div.gdtm
    List<dom.Element> picLsit = document.querySelectorAll('#gdt > div.gdtm');
//    Global.logger.v('${picLsit.length}');

    galleryItem.galleryPreview = [];

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
        Global.logger.v('$picHref $picSrcUrl $height $width $offSet');
        galleryItem.galleryPreview.add(GalleryPreview()
          ..isLarge = false
          ..href = picHref
          ..imgUrl = picSrcUrl
          ..height = double.parse(height)
          ..width = double.parse(width)
          ..offSet = double.parse(offSet)
        );
      }
    } else {
      List<dom.Element> picLsit = document.querySelectorAll('#gdt > div.gdtl');
      // 大图的处理
      for (var pic in picLsit) {
        var picHref = pic
            .querySelector('a')
            .attributes['href'];
        dom.Element imgElem = pic.querySelector('img');
        var picSer = imgElem.attributes['alt'].trim();
        var picSrcUrl = imgElem.attributes['src'].trim();
        Global.logger.v('$picHref  $picSer  $picSrcUrl');

        galleryItem.galleryPreview.add(GalleryPreview()
          ..isLarge = true
          ..href = picHref
          ..imgUrl = picSrcUrl
        );
      }
    }

    return galleryItem;
  }
}
