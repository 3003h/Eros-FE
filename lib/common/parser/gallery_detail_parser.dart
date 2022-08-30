import 'package:fehviewer/common/controller/tag_trans_controller.dart';
import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/models/base/eh_models.dart';
import 'package:fehviewer/utils/chapter.dart';
import 'package:get/get.dart' hide Node;
import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;
import 'package:intl/intl.dart';

import '../../utils/logger.dart';

String parseErrGallery(String response) {
  final Document document = parse(response);
  const String msgSelect = 'div > p';
  final msg = document.querySelector(msgSelect)?.text ?? '';
  return msg;
}

// 评论解析
List<GalleryComment> parseGalleryComment(Document document) {
  // 全部评论数据
  final List<GalleryComment> _galleryComment = [];
  const String commentSelect = '#cdiv > div.c1';
  final List<Element> commentList = document.querySelectorAll(commentSelect);
  for (final Element comment in commentList) {
    try {
      final userElm = comment.querySelector('div.c2 > div.c3');
      final childrenElms = userElm?.children;

      // 评论人
      final Element? postElem = childrenElms?[0];
      final String postName = postElem?.text.trim() ?? '';

      final Element? userIndexElm =
          comment.querySelector('div.c2 > div.c3 > a:nth-child(3)');

      // print('userIndexElm ${userIndexElm?.innerHtml}');

      final String userIndex = userIndexElm?.attributes['href']?.trim() ?? '';
      final String userId = RegExp(r'.+index\.php\?showuser=(\d+)')
              .firstMatch(userIndex)
              ?.group(1) ??
          '';

      // 解析时间
      final Element? timeElem = comment.querySelector('div.c2 > div.c3');
      final String postTime = timeElem?.text.trim() ?? '';
      // logger.v(postTime);
      // 示例: Posted on 29 June 2020, 05:41 UTC by:
      // 20201027 修复评论问题
      // Posted on 29 June 2020, 05:41 by:
      final String postTimeUTC =
          RegExp(r'Posted on (.+, .+) by').firstMatch(postTime)?.group(1) ?? '';

      // 时间由utc转为本地时间
      final DateTime time = DateFormat('dd MMMM yyyy, HH:mm', 'en_US')
          .parseUtc(postTimeUTC)
          .toLocal();
      final String postTimeLocal = DateFormat('yyyy-MM-dd HH:mm').format(time);

      // 评论评分 (Uploader Comment 没有)
      final Element? scoreElem = comment.querySelector('div.c2 > div.c5.nosel');
      String score = '';
      if (scoreElem != null) {
        score = RegExp(r'(([+-])(\d+))')
                .firstMatch(scoreElem.text.trim())
                ?.group(1) ??
            '';
      }

      // 可编辑
      bool _canEdit = false;

      // 可评论
      bool _canVote = false;

      int _vote = 0;
      String _id = '';
      final Element? _c4 = comment.querySelector('div.c2 > div.c4.nosel');
      if (_c4 != null) {
        final Element _hand = _c4.children.first;
        final String _handText = _hand.attributes['onclick'] ?? '';
        // _id = RegExp(r'\((\d+)\)').firstMatch(_handText)?.group(1) ?? '';
        _canEdit = _handText.contains('edit_');
        _canVote = _handText.contains('vote_');

        if (_c4.children.length > 1) {
          final Element _vUp = _c4.children.elementAt(0);
          final Element _vDown = _c4.children.elementAt(1);
          final String _vUpStyle = _vUp.attributes['style'] ?? '';
          final String _vDownStyle = _vDown.attributes['style'] ?? '';
          if (_vUpStyle.isNotEmpty) {
            _vote = 1;
          }
          if (_vDownStyle.isNotEmpty) {
            _vote = -1;
          }
        }
      }

      final Element? _c6 = comment.querySelector('div.c6');
      final String _attriId = _c6?.attributes['id'] ?? '';
      _id = RegExp(r'_(\d+)').firstMatch(_attriId)?.group(1) ?? '';

      // 解析评论内容
      final Element? contextElem = comment.querySelector('div.c6');

      /// for in遍历的方式处理
      final List<GalleryCommentSpan> commentSpansf = [];
      for (final Node node in contextElem?.nodes ?? []) {
        if (node.nodeType == Node.TEXT_NODE) {
          final String _nodeText = RegExp(r'^"?(.+)"?$')
                  .firstMatch(node.text?.trim() ?? '')
                  ?.group(1)
                  ?.trim() ??
              node.text?.trim() ??
              '';

          // 如果数组最后一个是纯文本 直接追加文本
          if (commentSpansf.isNotEmpty &&
              (commentSpansf.last.sType == CommentSpanType.text)) {
            commentSpansf.last = commentSpansf.last
                .copyWith(text: '${commentSpansf.last.text ?? ''}$_nodeText');
          } else {
            commentSpansf.add(GalleryCommentSpan(text: _nodeText)
                .copyWithSpanType(CommentSpanType.text));
          }
        } else if (node.nodeType == Node.ELEMENT_NODE) {
          // br标签 换行
          if ((node as Element).localName == 'br') {
            // 如果数组最后一个是纯文本 直接追加文本
            if (commentSpansf.isNotEmpty &&
                (commentSpansf.last.sType == CommentSpanType.text)) {
              commentSpansf.last = commentSpansf.last
                  .copyWith(text: '${commentSpansf.last.text ?? ''}\n');
            } else {
              commentSpansf.add(const GalleryCommentSpan(text: '\n')
                  .copyWithSpanType(CommentSpanType.text));
            }
            continue;
          }

          // span 带 href
          if (node.localName == 'span' && node.children.isNotEmpty) {
            final Element? _nodeElm = node.children.first;
            final String _nodeHref = _nodeElm?.attributes['href'] ?? '';
            final GalleryCommentSpan _commentSpan = GalleryCommentSpan(
              text: _nodeElm?.text.trim() ?? _nodeHref,
              href: _nodeHref,
            ).copyWithSpanType(CommentSpanType.linkText);

            commentSpansf.add(_commentSpan);
            continue;
          }

          // a标签带href
          if (node.localName == 'a') {
            final Element? _nodeElm = node;

            final String _nodeHref = _nodeElm?.attributes['href'] ?? '';
            // logger.d('_nodeHref $_nodeHref');

            if (_nodeElm?.children.isNotEmpty ?? false) {
              final Element? _imgElm = _nodeElm?.children
                  .firstWhere((element) => element.localName == 'img');
              final _nodeImageUrl = _imgElm?.attributes['src'];
              final GalleryCommentSpan _commentSpan = GalleryCommentSpan(
                text: _nodeElm?.text.trim() ?? _nodeHref,
                href: _nodeHref,
                imageUrl: _nodeImageUrl,
              ).copyWithSpanType(CommentSpanType.linkImage);

              commentSpansf.add(_commentSpan);
              continue;
            } else {
              // 如果数组最后一个是纯文本 直接追加文本
              if (_nodeHref.isEmpty &&
                  commentSpansf.isNotEmpty &&
                  (commentSpansf.last.sType == CommentSpanType.text)) {
                commentSpansf.last = commentSpansf.last.copyWith(
                    text: '${commentSpansf.last.text}${_nodeElm?.text ?? ''}');
              } else {
                // 文本和href相同的情况，添加为普通文本内容，靠linkedText组件自动识别区分
                if (_nodeElm?.text == _nodeHref) {
                  commentSpansf.add(GalleryCommentSpan(
                    text: _nodeElm?.text ?? _nodeHref,
                    href: _nodeHref,
                  ).copyWithSpanType(CommentSpanType.text));
                } else {
                  // 文本和href不同 才添加linkText类型
                  commentSpansf.add(GalleryCommentSpan(
                    text: _nodeElm?.text ?? _nodeHref,
                    href: _nodeHref,
                  ).copyWithSpanType(CommentSpanType.linkText));
                }
              }
            }
          }

          // 只有一个img的情况 无href
          if (node.localName == 'img') {
            final Element? _nodeElm = node;
            final String _nodeImageUrl = _nodeElm?.attributes['src'] ?? '';

            final _commentSpan = GalleryCommentSpan(
              text: _nodeElm?.text.trim() ?? _nodeImageUrl,
              imageUrl: _nodeImageUrl,
            ).copyWithSpanType(CommentSpanType.image);

            commentSpansf.add(_commentSpan);
          }
        }
      }

      // 解析评论评分详情
      final Element? scoresElem = comment.querySelector('div.c7');
      final spanElms = scoresElem?.querySelectorAll('span') ?? [];

      final _scoreDetails = [
        (scoresElem?.nodes.first.text ?? '').replaceFirstMapped(
            RegExp(r'(.+),\s+'), (match) => match.group(1) ?? ''),
        ...spanElms.map((e) => e.text).toList()
      ];
      // print('$_scoreDetails');

      _galleryComment.add(GalleryComment(
        id: _id,
        canEdit: _canEdit,
        canVote: _canVote,
        vote: _vote,
        name: postName,
        span: commentSpansf,
        time: postTimeLocal,
        score: score,
        scoreDetails: _scoreDetails,
        menberId: userId,
      ));
    } catch (e, stack) {
      // logger.e('解析评论异常\n' + e.toString() + '\n' + stack.toString());
    }
  }

  return _galleryComment;
}

Future<List<TagGroup>> parseGalleryTags(Document document) async {
  // 完整的标签信息
  final List<TagGroup> _tagGroup = [];
  const String tagGroupSelect = '#taglist > table > tbody > tr';
  final List<Element> elmTagGroups = document.querySelectorAll(tagGroupSelect);
  for (final Element elmTagGroup in elmTagGroups) {
    try {
      String type = elmTagGroup.querySelector('td.tc')?.text.trim() ?? '';
      type = RegExp(r'(\w+):?$').firstMatch(type)?.group(1) ?? '';

      final List<Element> tags = elmTagGroup.querySelectorAll('td > div > a');
      final List<GalleryTag> galleryTags = [];
      for (final Element tagElm in tags) {
        String title = tagElm.text.trim();
        if (title.contains('|')) {
          title = title.split('|')[0];
        }
        final String tagTranslat = await Get.find<TagTransController>()
                .getTagTranslateText(title, namespace: type) ??
            title;

        int tagVote = 0;
        final String? tagclass = tagElm.attributes['class'];
        if (tagclass == 'tup') {
          tagVote = 1;
        } else if (tagclass == 'tdn') {
          tagVote = -1;
        }

        galleryTags.add(GalleryTag(
          title: title,
          type: type,
          vote: tagVote,
          tagTranslat: tagTranslat,
        ));
      }

      _tagGroup.add(TagGroup(tagType: type, galleryTags: galleryTags));
    } catch (e, stack) {
      // logger.e('解析tag数据异常\n' + e.toString() + '\n' + stack.toString());
      // rethrow;
    }
  }
  return _tagGroup;
}

/// 解析画廊详情数据
Future<GalleryProvider> parseGalleryDetail(String response) async {
  // 解析响应信息dom
  final Document document = parse(response);

  // GalleryItem galleryProvider = const GalleryItem();

  // 封面图片
  final Element? imageElem = document.querySelector('#gd1 > div');
  final String _imageElemStyle = imageElem?.attributes['style'] ?? '';
  final RegExpMatch? _match =
      RegExp(r'url\((.+)\)').firstMatch(_imageElemStyle);
  final String _imageUrl = _match?.group(1) ?? '';

  // 收藏夹标题
  String _favTitle = '';
  final Element? fav = document.querySelector('#favoritelink');
  if (fav?.nodes.length == 1) {
    _favTitle = fav?.text.trim() ?? '';
  }

  // 收藏夹序号
  String _favcat = '';
  final Element? _favcatElm = document.querySelector('#fav');
  if (_favcatElm?.nodes.isNotEmpty ?? false) {
    final Element? _div = _favcatElm?.querySelector('div');
    final String _catStyle = _div?.attributes['style'] ?? '';
    final String _catPosition = RegExp(r'background-position:0px -(\d+)px;')
            .firstMatch(_catStyle)?[1] ??
        '';
    _favcat = '${(int.parse(_catPosition) - 2) ~/ 19}';
  }

  // apiuid
  final String _apiuid =
      RegExp(r'var\s*?apiuid\s*?=\s*?(\d+);').firstMatch(response)?.group(1) ??
          '';

  // apikey
  final String _apikey = RegExp(r'var\s*?apikey\s*?=\s*?"([0-9a-f]+)";')
          .firstMatch(response)
          ?.group(1) ??
      '';

// 20201230 Archiver link
  final String or = RegExp(r"or=(.*?)'").firstMatch(response)?.group(1) ?? '';
  final _archiverLink = or;

  final Element? _ratingImage = document.querySelector('#rating_image');
  final String _ratingImageClass = _ratingImage?.attributes['class'] ?? '';
  final _colorRating = _ratingImageClass;
  final _isRatinged = _ratingImageClass.contains(RegExp(r'ir([rgby])'));

  // 收藏次数
  final String _favCount =
      document.querySelector('#favcount')?.text.replaceFirstMapped(
                RegExp(r'(\d+).+'),
                (Match m) => m.group(1) ?? '',
              ) ??
          '';
  final _favoritedCount = _favCount;

  // 评分人次
  final String _ratingCount =
      document.querySelector('#rating_count')?.text ?? '';

  // 平均分
  final String _rating = RegExp(r'([\d.]+)')
          .firstMatch(document.querySelector('#rating_label')?.text ?? '')
          ?.group(1) ??
      '0';
  final _ratingNum = double.parse(_rating);

  final String ratPx =
      document.querySelector('#rating_image')?.attributes['style'] ?? '';
  final RegExp pxA = RegExp(r'-?(\d+)px\s+-?(\d+)px');
  final RegExpMatch? px = pxA.firstMatch(ratPx);

  final double _ratingFB = (80.0 - double.parse(px?.group(1) ?? '0')) / 16.0 -
      (px?.group(2) == '21' ? 0.5 : 0.0);

  // 英语标题
  final _englishTitle = document.querySelector('#gn')?.text ?? '';

  // 日语标题
  final _japaneseTitle = document.querySelector('#gj')?.text ?? '';

  final Element? _elmTorrent =
      document.querySelector('#gd5')?.children[2].children[1];
  // 种子数量
  final _torrentcount =
      RegExp(r'\d+').firstMatch(_elmTorrent?.text ?? '')?.group(0) ?? '0';

  final String _language = document
          .querySelector('#gdd > table > tbody > tr:nth-child(3) > td.gdt2')
          ?.text
          .replaceFirstMapped(
            RegExp(r'(\w+).*'),
            (Match m) => m.group(1) ?? '',
          ) ??
      '';

  final String _fileSize = document
          .querySelector('#gdd > table > tbody > tr:nth-child(4) > td.gdt2')
          ?.text ??
      '';

  final Element? elmCategory = document.querySelector('#gdc > div');
  // 详情页解析 category
  final _category = elmCategory?.text ?? '';

  // uploader
  final _uploader = document.querySelector('#gdn > a')?.text.trim() ?? '';
  print('######_uploader $_uploader');

  final _galleryComments = parseGalleryComment(document);

  final _chapter = _parseChapter(_galleryComments);
  // print(_chapter.map((e) => e.toJson()).join('\n'));

  final galleryProvider = GalleryProvider(
    imgUrl: _imageUrl,
    tagGroup: await parseGalleryTags(document),
    galleryComment: _galleryComments,
    galleryImages: parseGalleryImage(document),
    chapter: _chapter,
    favTitle: _favTitle,
    favcat: _favcat,
    apiuid: _apiuid,
    apikey: _apikey,
    archiverLink: _archiverLink,
    colorRating: _colorRating,
    isRatinged: _isRatinged,
    favoritedCount: _favoritedCount,
    ratingCount: _ratingCount,
    ratingFallBack: _ratingFB,
    rating: _ratingNum,
    englishTitle: _englishTitle,
    japaneseTitle: _japaneseTitle,
    torrentcount: _torrentcount,
    language: _language,
    filesizeText: _fileSize,
    category: _category,
    uploader: _uploader,
  );

  return galleryProvider;
}

List<Chapter>? _parseChapter(List<GalleryComment> comments) {
  final listListChapter = <List<Chapter>>[];
  for (final comment in comments) {
    final listChapter = parseChapter(comment.text);
    if (listChapter.length >= 2) {
      listListChapter.add(listChapter);
    }
  }

  if (listListChapter.isNotEmpty) {
    final listChapter = listListChapter.reduce(
        (value, element) => value.length > element.length ? value : element);
    return listChapter;
  }
  return null;
}

List<GalleryImage> parseGalleryImageFromHtml(String response) {
// 解析响应信息dom
  final Document document = parse(response);
  return parseGalleryImage(document);
}

/// 缩略图处理
List<GalleryImage> parseGalleryImage(Document document) {
  // 大图 #gdt > div.gdtl  小图 #gdt > div.gdtm
  final List<Element> picLsit = document.querySelectorAll('#gdt > div.gdtm');

  final List<GalleryImage> galleryImages = [];

  if (picLsit.isNotEmpty) {
    // 小图的处理
    for (final Element pic in picLsit) {
      final String picHref = pic.querySelector('a')?.attributes['href'] ?? '';
      final String style = pic.querySelector('div')?.attributes['style'] ?? '';
      final String picSrcUrl =
          RegExp(r'url\((.+)\)').firstMatch(style)?.group(1) ?? '';
      final String height =
          RegExp(r'height:(\d+)?px').firstMatch(style)?.group(1) ?? '';
      final String width =
          RegExp(r'width:(\d+)?px').firstMatch(style)?.group(1) ?? '';
      final String offSet =
          RegExp(r'\) -(\d+)?px ').firstMatch(style)?.group(1) ?? '';

      final Element? imgElem = pic.querySelector('img');
      final String picSer = imgElem?.attributes['alt']?.trim() ?? '';

      galleryImages.add(GalleryImage(
        ser: int.parse(picSer),
        largeThumb: false,
        href: picHref,
        thumbUrl: picSrcUrl,
        thumbHeight: double.parse(height),
        thumbWidth: double.parse(width),
        offSet: double.parse(offSet),
      ));
    }
  } else {
    final List<Element> picLsit = document.querySelectorAll('#gdt > div.gdtl');
    // 大图的处理
    for (final Element pic in picLsit) {
      final String picHref = pic.querySelector('a')?.attributes['href'] ?? '';
      final Element? imgElem = pic.querySelector('img');
      final String picSer = imgElem?.attributes['alt']?.trim() ?? '';
      final String picSrcUrl = imgElem?.attributes['src']?.trim() ?? '';

      galleryImages.add(GalleryImage(
          ser: int.parse(picSer),
          largeThumb: true,
          href: picHref,
          thumbUrl: picSrcUrl));
    }
  }

  return galleryImages;
}
