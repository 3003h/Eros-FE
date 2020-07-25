import 'dart:io';

import 'package:FEhViewer/client/tag_database.dart';
import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/models/index.dart';
import 'package:FEhViewer/utils/dio_util.dart';
import 'package:FEhViewer/utils/toast.dart';
import 'package:FEhViewer/utils/utility.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' show parse;
import 'package:intl/intl.dart';

import 'gallery_view_parser.dart';

class GalleryDetailParser {
  /// 获取画廊详细信息
  ///
  static Future<GalleryItem> getGalleryDetail(GalleryItem inGalleryItem) async {
    //?inline_set=ts_m 小图,40一页
    //?inline_set=ts_l 大图,20一页
    //hc=1#comments 显示全部评论
    //nw=always 不显示警告

    HttpManager httpManager = HttpManager.getInstance();
    var url = inGalleryItem.url + '?hc=1&inline_set=ts_l&nw=always';
//    var url = inGalleryItem.url + '?hc=1&nw=always';

    // 不显示警告的处理 cookie加上 nw=1
    // 在 url使用 nw=always 未解决 自动写入cookie 暂时搞不懂 先手动设置下
    // todo 待优化
    var cookieJar = await Api.cookieJar;
    List<Cookie> cookies =
    cookieJar.loadForRequest(Uri.parse(inGalleryItem.url));
    cookies.add(Cookie('nw', '1'));
    cookieJar.saveFromResponse(Uri.parse(url), cookies);



    Global.logger.i("获取画廊 $url");
    var response = await httpManager.get(url);

    // TODO 画廊警告问题 使用 nw=always 未解决 待处理 怀疑和Session有关
    if ('$response'.contains(r'<strong>Offensive For Everyone</strong>')) {
      Global.logger.v('Offensive For Everyone');
      showToast('Offensive For Everyone');
    }

    GalleryItem galleryItem = await parseGalleryDetail(response);

    galleryItem.gid = inGalleryItem.gid;
    galleryItem.token = inGalleryItem.token;


    return galleryItem;
  }

  /// 解析响应数据
  static Future<GalleryItem> parseGalleryDetail(String response) async {
    // 解析响应信息dom
    var document = parse(response);

    GalleryItem galleryItem = GalleryItem();

    /// taglist
    galleryItem.tagGroup = [];
    const tagGroupSelect = '#taglist > table > tbody > tr';
    List<dom.Element> tagGroups = document.querySelectorAll(tagGroupSelect);
//    assert(tagGroups.length != 0);
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

    // 解析评论区数据
    galleryItem.galleryComment = [];
    const commentSelect = '#cdiv > div.c1';
    List<dom.Element> commentList = document.querySelectorAll(commentSelect);
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

    var showKey = '';

    // 解析画廊缩略图
    // 大图 #gdt > div.gdtl  小图 #gdt > div.gdtm
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

//        Global.logger.v('$picHref $picSrcUrl $height $width $offSet');

        dom.Element imgElem = pic.querySelector('img');
        var picSer = imgElem.attributes['alt'].trim();

        if (showKey.isEmpty) {
          showKey = await GalleryViewParser.getShowkey(picHref);
        }

        galleryItem.showKey = showKey;

        galleryItem.galleryPreview.add(GalleryPreview()
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
      List<dom.Element> picLsit = document.querySelectorAll('#gdt > div.gdtl');
      // 大图的处理
      for (var pic in picLsit) {
        var picHref = pic
            .querySelector('a')
            .attributes['href'];
        dom.Element imgElem = pic.querySelector('img');
        var picSer = imgElem.attributes['alt'].trim();
        var picSrcUrl = imgElem.attributes['src'].trim();

        if (showKey.isEmpty) {
          showKey = await GalleryViewParser.getShowkey(picHref);
        }

        galleryItem.showKey = showKey;

        galleryItem.galleryPreview.add(GalleryPreview()
          ..ser = int.parse(picSer)
          ..isLarge = true
          ..href = picHref
          ..imgUrl = picSrcUrl
        );
      }
    }

    // 解析收藏标志
    var favTitle = '';
    dom.Element fav = document.querySelector("#favoritelink");
//    favTitle = fav.text.trim();
    if (fav?.nodes?.length == 1) {
      favTitle = fav.text.trim();
    }
//    Global.logger.v('$favTitle  ${fav.nodes}');
    galleryItem.favTitle = favTitle;

    return galleryItem;
  }


}
