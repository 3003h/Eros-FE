import 'package:collection/collection.dart';
import 'package:eros_fe/common/controller/tag_trans_controller.dart';
import 'package:eros_fe/models/base/eh_models.dart';
import 'package:eros_fe/utils/chapter.dart';
import 'package:get/get.dart' hide Node;
import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;
import 'package:intl/intl.dart';

import '../../const/const.dart';
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

      final String userIndex = userIndexElm?.attributes['href']?.trim() ?? '';
      final String userId = RegExp(r'.+index\.php\?showuser=(\d+)')
              .firstMatch(userIndex)
              ?.group(1) ??
          '';

      // 解析时间
      final Element? timeElem = comment.querySelector('div.c2 > div.c3');
      final String postTime = timeElem?.text.trim() ?? '';
      // logger.t(postTime);
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
      final String _attributesId = _c6?.attributes['id'] ?? '';
      _id = RegExp(r'_(\d+)').firstMatch(_attributesId)?.group(1) ?? '';

      // 解析评论内容
      final Element? contextElem = comment.querySelector('div.c6');

      final rawContent = contextElem?.innerHtml ?? '';
      logger.t('rawContent: $rawContent');

      // 识别URL，并修改为 a href 元素
      final linkifyContent = rawContent.replaceAllMapped(
        commentUrlRegExp,
        (match) => '<a href="${match.group(0)}">${match.group(0)}</a>',
      );

      final linkifyElement = parse(linkifyContent).body;

      // 解析评论评分详情
      final Element? scoresElem = comment.querySelector('div.c7');
      final spanElms = scoresElem?.querySelectorAll('span') ?? [];

      final _scoreDetails = [
        (scoresElem?.nodes.firstOrNull?.text ?? '').replaceFirstMapped(
            RegExp(r'(.+),\s+'), (match) => match.group(1) ?? ''),
        ...spanElms.map((e) => e.text).toList()
      ];
      // print('$_scoreDetails');

      final galleryComment = GalleryComment(
        id: _id,
        canEdit: _canEdit,
        canVote: _canVote,
        vote: _vote,
        name: postName,
        time: postTimeLocal,
        score: score,
        scoreDetails: _scoreDetails,
        memberId: userId,
        element: linkifyElement,
      );

      _galleryComment.add(galleryComment.copyWith(
        textList: galleryComment.getTextList().oN,
      ));
    } catch (e, stack) {
      logger.e('解析评论异常\n' + e.toString() + '\n' + stack.toString());
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
          title = title.split('|')[0].trim();
        }
        final String tagTranslate = await Get.find<TagTransController>()
                .getTagTranslateText(title, namespace: type) ??
            title;

        int tagVote = 0;
        final String? tagClass = tagElm.attributes['class'];
        if (tagClass == 'tup') {
          tagVote = 1;
        } else if (tagClass == 'tdn') {
          tagVote = -1;
        }

        galleryTags.add(GalleryTag(
          title: title,
          type: type,
          vote: tagVote,
          tagTranslat: tagTranslate,
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
  String _favCat = '';
  final Element? _favCatElm = document.querySelector('#fav');
  if (_favCatElm?.nodes.isNotEmpty ?? false) {
    final Element? _div = _favCatElm?.querySelector('div');
    final String _catStyle = _div?.attributes['style'] ?? '';
    final String _catPosition = RegExp(r'background-position:0px -(\d+)px;')
            .firstMatch(_catStyle)?[1] ??
        '';
    _favCat = '${(int.parse(_catPosition) - 2) ~/ 19}';
  }

  // apiUid
  final String _apiUid =
      RegExp(r'var\s*?apiuid\s*?=\s*?(\d+);').firstMatch(response)?.group(1) ??
          '';

  // apikey
  final String _apiKey = RegExp(r'var\s*?apikey\s*?=\s*?"([0-9a-f]+)";')
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
  final _torrentCount =
      RegExp(r'\d+').firstMatch(_elmTorrent?.text ?? '')?.group(0) ?? '0';

  final _tBody = document.querySelector('#gdd > table > tbody');
  final _listTr = _tBody?.children;
  final _mapGdt = <String, Element>{};
  // key gdt1, value gdt2
  for (final Element? _tr in _listTr ?? []) {
    final _listTd = _tr?.children;
    if (_listTd?.length == 2) {
      _mapGdt[_listTd![0].text.trim()] = _listTd[1];
    }
  }

  // print('^^^ $_mapGdt');

  final String _parent = _mapGdt['Parent:']?.text.trim() ?? '';
  final String _parentHref =
      _mapGdt['Parent:']?.querySelector('a')?.attributes['href'] ?? '';
  final String _visible = _mapGdt['Visible:']?.text.trim() ?? '';
  final String _language = _mapGdt['Language:']?.text.trim() ?? '';
  final String _fileSize = _mapGdt['File Size:']?.text.trim() ?? '';
  final String _postTime = _mapGdt['Posted:']?.text.trim() ?? '';
  final String _favCount = RegExp(r'\d+')
          .firstMatch(_mapGdt['Favorited:']?.text.trim() ?? '')
          ?.group(0) ??
      '';

  final Element? elmCategory = document.querySelector('#gdc > div');
  // 详情页解析 category
  final _category = elmCategory?.text ?? '';

  // uploader
  final _uploader = document.querySelector('#gdn > a')?.text.trim() ?? '';

  final _galleryComments = parseGalleryComment(document);
  final _chapter = _parseChapter(_galleryComments);

  // eventpane
  final _eventpane = document.querySelector('#eventpane')?.text ?? '';

  final galleryProvider = GalleryProvider(
    imgUrl: _imageUrl,
    tagGroup: await parseGalleryTags(document),
    galleryComment: _galleryComments,
    galleryImages: parseGalleryImage(document),
    chapter: _chapter,
    favTitle: _favTitle,
    favcat: _favCat,
    apiuid: _apiUid,
    apikey: _apiKey,
    archiverLink: _archiverLink,
    colorRating: _colorRating,
    isRatinged: _isRatinged,
    favoritedCount: _favCount,
    ratingCount: _ratingCount,
    ratingFallBack: _ratingFB,
    rating: _ratingNum,
    englishTitle: _englishTitle,
    japaneseTitle: _japaneseTitle,
    torrentcount: _torrentCount,
    language: _language,
    filesizeText: _fileSize,
    category: _category,
    uploader: _uploader,
    postTime: _postTime,
    parent: _parent,
    parentHref: _parentHref,
    visible: _visible,
  );

  return galleryProvider;
}

List<Chapter>? _parseChapter(List<GalleryComment> comments) {
  final listListChapter = <List<Chapter>>[];
  for (final comment in comments) {
    final listChapter = parseChapter((comment.element as Element?)?.text ?? '');
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
  final List<GalleryImage> galleryImages = [];

  // 小图 #gdt > div.gdtm
  List<Element> picList = document.querySelectorAll('#gdt > div.gdtm');
  if (picList.isNotEmpty) {
    for (final Element pic in picList) {
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
        thumbHeight: double.tryParse(height) ?? 0,
        thumbWidth: double.tryParse(width) ?? 0,
        offSet: double.tryParse(offSet) ?? 0,
      ));
    }
    return galleryImages;
  }

  // 大图 #gdt > div.gdtl
  picList = document.querySelectorAll('#gdt > div.gdtl');
  if (picList.isNotEmpty) {
    for (final Element pic in picList) {
      final String picHref = pic.querySelector('a')?.attributes['href'] ?? '';
      final Element? imgElem = pic.querySelector('img');
      final String picSer = imgElem?.attributes['alt']?.trim() ?? '';
      final String picSrcUrl = imgElem?.attributes['src']?.trim() ?? '';

      final array = picSrcUrl.split('-');
      final String width = array[array.length - 3];
      final String height = array[array.length - 2];
      logger.t('picSrcUrl: $picSrcUrl, width: $width, height: $height');

      galleryImages.add(GalleryImage(
        ser: int.parse(picSer),
        largeThumb: true,
        href: picHref,
        thumbUrl: picSrcUrl,
        oriWidth: double.tryParse(width) ?? 0,
        oriHeight: double.tryParse(height) ?? 0,
      ));
    }
    return galleryImages;
  }

  // 里站 #gdt > a
  // 新版缩略图dom, 统一了大小缩略图, 小图不再需要单独的分割处理
  picList = document.querySelectorAll('#gdt > a');
  if (picList.isNotEmpty) {
    for (final Element pic in picList) {
      final String picHref = pic.attributes['href'] ?? '';

      // 对 label 不为空设置的处理
      final divElm = pic.querySelector('div');
      final childrenElms = divElm?.children;
      // logger.d('>>>> childrenElms count: ${childrenElms?.length}');
      final hasChildren = childrenElms?.isNotEmpty ?? false;
      final destDivElm = hasChildren ? childrenElms![0] : divElm;
      final String style = destDivElm?.attributes['style'] ?? '';
      // logger.d('>>>> style: $style');

      final String picSrcUrl =
          RegExp(r'url\((.+)\)').firstMatch(style)?.group(1) ?? '';
      final String height =
          RegExp(r'height:(\d+)?px').firstMatch(style)?.group(1) ?? '0';
      final String width =
          RegExp(r'width:(\d+)?px').firstMatch(style)?.group(1) ?? '0';
      final String offSet =
          RegExp(r'\) -(\d+)?px ').firstMatch(style)?.group(1) ?? '0';

      final String title = destDivElm?.attributes['title'] ?? '';
      final String picSer =
          RegExp(r'Page (\d+):').firstMatch(title)?.group(1) ?? '';

      galleryImages.add(GalleryImage(
        ser: int.parse(picSer),
        largeThumb: false,
        href: picHref,
        thumbUrl: picSrcUrl,
        thumbHeight: double.tryParse(height) ?? 0,
        thumbWidth: double.tryParse(width) ?? 0,
        offSet: double.tryParse(offSet) ?? 0,
      ));
    }
    return galleryImages;
  }

  logger.e('No gallery images found');
  return galleryImages;
}
