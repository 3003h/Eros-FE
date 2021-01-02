import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/network/gallery_request.dart';
import 'package:fehviewer/store/tag_database.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;
import 'package:intl/intl.dart';

class GalleryDetailParser {
  /// 解析画廊详情数据
  static Future<GalleryItem> parseGalleryDetail(String response,
      {GalleryItem inGalleryItem}) async {
    // 解析响应信息dom
    final Document document = parse(response);

    final GalleryItem galleryItem = inGalleryItem ?? GalleryItem();

    // 封面图片
    final Element imageElem = document.querySelector('#gd1 > div');
    final String _imageElemStyle = imageElem.attributes['style'];
    final RegExpMatch _match =
        RegExp(r'url\((.+)\)').firstMatch(_imageElemStyle);
    final String _imageUrl = _match.group(1);
    if (galleryItem.imgUrl?.isEmpty ?? true) {
      galleryItem.imgUrl = _imageUrl;
    }

    // 完整的标签信息
    galleryItem.tagGroup = [];
    const String tagGroupSelect = '#taglist > table > tbody > tr';
    final List<Element> tagGroups = document.querySelectorAll(tagGroupSelect);
    for (final Element tagGroup in tagGroups) {
      try {
        String type = tagGroup.querySelector('td.tc').text.trim();
        type = RegExp(r'(\w+):?$').firstMatch(type).group(1);

        final List<Element> tags = tagGroup.querySelectorAll('td > div > a');
        final List<GalleryTag> galleryTags = [];
        for (final Element tagElm in tags) {
          String title = tagElm.text.trim() ?? '';
          if (title.contains('|')) {
            title = title.split('|')[0];
          }
          final String tagTranslat =
              await EhTagDatabase.getTranTag(title, nameSpase: type) ?? title;

//        logger.v('$type:$title $tagTranslat');
          galleryTags.add(GalleryTag()
            ..title = title
            ..type = type
            ..tagTranslat = tagTranslat);
        }

        galleryItem.tagGroup.add(TagGroup()
          ..tagType = type
          ..galleryTags = galleryTags);
      } catch (e, stack) {
        logger.e('解析tag数据异常\n' + e.toString() + '\n' + stack.toString());
      }
    }

    // 全部评论数据
    galleryItem.galleryComment = [];
    const String commentSelect = '#cdiv > div.c1';
    final List<Element> commentList = document.querySelectorAll(commentSelect);
//    logger.v('${commentList.length}');
    for (final Element comment in commentList) {
      try {
        // 评论人
        final Element postElem = comment.querySelector('div.c2 > div.c3 > a');
        final String postName = postElem.text.trim();

        // 解析时间
        final Element timeElem = comment.querySelector('div.c2 > div.c3');
        final String postTime = timeElem.text.trim();
        // logger.v(postTime);
        // 示例: Posted on 29 June 2020, 05:41 UTC by:
        // 20201027 修复评论问题
        // Posted on 29 June 2020, 05:41 by:
        final String postTimeUTC =
            RegExp(r'Posted on (.+, .+) by').firstMatch(postTime).group(1);

        // 时间由utc转为本地时间
        final DateTime time = DateFormat('dd MMMM yyyy, HH:mm', 'en_US')
            .parseUtc(postTimeUTC)
            .toLocal();
        final String postTimeLocal =
            DateFormat('yyyy-MM-dd HH:mm').format(time);

        // 评论评分 (Uploader Comment 没有)
        final Element scoreElem =
            comment.querySelector('div.c2 > div.c5.nosel');
        String score = '';
        if (scoreElem != null) {
          score = RegExp(r'((\+|-)(\d+))')
                  .firstMatch(scoreElem.text.trim())
                  ?.group(1) ??
              '';
        }

        bool _canEdit = false;
        bool _canVote = false;
        int _vote = 0;
        String _id = '';
        final Element _c4 = comment.querySelector('div.c2 > div.c4.nosel');
        if (_c4 != null) {
          final Element _hand = _c4.children.first;
          final String _handText = _hand.attributes['onclick'];
          if (_handText != null) {
            _id = RegExp(r'\((\d+)\)').firstMatch(_handText).group(1);
            _canEdit = _handText.contains('edit_');
            _canVote = _handText.contains('vote_');
            // logger.d(
            //     '$_handText\nid:$_id \n_canEdit:$_canEdit \n_canVote:$_canVote');
          }

          if (_c4.children.length > 1) {
            final Element _vUp = _c4.children.elementAt(0);
            final Element _vDown = _c4.children.elementAt(1);
            final String _vUpStyle = _vUp.attributes['style'];
            final String _vDownStyle = _vDown.attributes['style'];
            // logger.d('id $_id \n$_vUpStyle \n$_vDownStyle');
            if (_vUpStyle.isNotEmpty) {
              _vote = 1;
            }
            if (_vDownStyle.isNotEmpty) {
              _vote = -1;
            }
          }
        }

        // 解析评论内容
        final Element contextElem = comment.querySelector('div.c6');

        // br回车以及引号的处理
        final String context = contextElem.nodes.map((Node node) {
          if (node.nodeType == Node.TEXT_NODE) {
            return RegExp(r'^"?(.+)"?$')
                    .firstMatch(node.text.trim())
                    ?.group(1) ??
                node.text;
          } else if (node.nodeType == Node.ELEMENT_NODE &&
              (node as Element).localName == 'br') {
//          logger.v('${(node as Element).localName}  ${(node as Element).text}');
            return '\n';
          } else if (node.nodeType == Node.ELEMENT_NODE) {
//          logger.v('${(node as Element).localName}  ${(node as Element).text}');
            // 通常是链接 前后加空格便于和内容分开
            return ' ' + (node as Element).text.trim() + ' ';
          }
        }).join();

        galleryItem.galleryComment.add(GalleryComment()
          ..id = _id
          ..canEdit = _canEdit
          ..canVote = _canVote
          ..vote = _vote
          ..name = postName
          ..context = context
          ..time = postTimeLocal
          ..score = score);
      } catch (e, stack) {
        logger.e('解析评论异常\n' + e.toString() + '\n' + stack.toString());
      }
    }

    // 画廊缩略图
    final List<GalleryPreview> previewList = parseGalleryPreview(document);
    galleryItem.galleryPreview = previewList;

    // 画廊 showKey
    final String _showKey = await Api.getShowkey(previewList[0].href);
    galleryItem.showKey = _showKey;

    // 收藏夹标题
    String _favTitle = '';
    final Element fav = document.querySelector('#favoritelink');
    if (fav?.nodes?.length == 1) {
      _favTitle = fav.text.trim();
    }
    galleryItem.favTitle = _favTitle;

    // 收藏夹序号
    String _favcat = '';
    final Element _favcatElm = document.querySelector('#fav');
    if (_favcatElm.nodes.isNotEmpty) {
      final Element _div = _favcatElm.querySelector('div');
      final String _catStyle = _div?.attributes['style'];
      final String _catPosition =
          RegExp(r'background-position:0px -(\d+)px;').firstMatch(_catStyle)[1];
      _favcat = '${(int.parse(_catPosition) - 2) ~/ 19}';
    }
    galleryItem.favcat = _favcat;

    // apiuid
    final String apiuid =
        RegExp(r'var\s*?apiuid\s*?=\s*?(\d+);').firstMatch(response)?.group(1);
    galleryItem.apiuid = apiuid;

    // apikey
    final String apikey = RegExp(r'var\s*?apikey\s*?=\s*?"([0-9a-f]+)";')
        .firstMatch(response)
        ?.group(1);
    galleryItem.apikey = apikey;

    // 20201230 Archiver link
    final String or = RegExp(r"or=(.*?)'").firstMatch(response)?.group(1);
    // logger.d('or=$or');
    galleryItem.archiverLink =
        '${Api.getBaseUrl()}/archiver.php?gid=${galleryItem.gid}&token=${galleryItem.token}&or=$or';
    // logger.d('archiverLink: ${galleryItem.archiverLink}');

    final Element _ratingImage = document.querySelector('#rating_image');
    final String _ratingImageClass = _ratingImage.attributes['class'];
    galleryItem.isRatinged =
        _ratingImageClass.contains(RegExp(r'"ir\s+ir[a-z]"'));

    return galleryItem;
  }

  static List<GalleryPreview> parseGalleryPreviewFromHtml(String response) {
    // 解析响应信息dom
    final Document document = parse(response);
    return parseGalleryPreview(document);
  }

  /// 缩略图处理
  static List<GalleryPreview> parseGalleryPreview(Document document) {
    // 大图 #gdt > div.gdtl  小图 #gdt > div.gdtm
    final List<Element> picLsit = document.querySelectorAll('#gdt > div.gdtm');

    final List<GalleryPreview> galleryPreview = [];

    if (picLsit.isNotEmpty) {
      // 小图的处理
      for (final Element pic in picLsit) {
        final String picHref = pic.querySelector('a').attributes['href'];
        final String style = pic.querySelector('div').attributes['style'];
        final String picSrcUrl =
            RegExp(r'url\((.+)\)').firstMatch(style).group(1);
        final String height =
            RegExp(r'height:(\d+)?px').firstMatch(style).group(1);
        final String width =
            RegExp(r'width:(\d+)?px').firstMatch(style).group(1);
        final String offSet =
            RegExp(r'\) -(\d+)?px ').firstMatch(style).group(1);

        final Element imgElem = pic.querySelector('img');
        final String picSer = imgElem.attributes['alt'].trim();
        // logger.v('小图$picSer  $picSrcUrl');

        galleryPreview.add(GalleryPreview()
          ..ser = int.parse(picSer)
          ..isLarge = false
          ..href = picHref
          ..imgUrl = picSrcUrl
          ..height = double.parse(height)
          ..width = double.parse(width)
          ..offSet = double.parse(offSet));
      }
    } else {
      final List<Element> picLsit =
          document.querySelectorAll('#gdt > div.gdtl');
      // 大图的处理
      for (final Element pic in picLsit) {
        final String picHref = pic.querySelector('a').attributes['href'];
        final Element imgElem = pic.querySelector('img');
        final String picSer = imgElem.attributes['alt'].trim();
        final String picSrcUrl = imgElem.attributes['src'].trim();

        galleryPreview.add(GalleryPreview()
          ..ser = int.parse(picSer)
          ..isLarge = true
          ..href = picHref
          ..imgUrl = picSrcUrl);
      }
    }

    return galleryPreview;
  }
}
