import 'dart:io';

import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/common/tag_database.dart';
import 'package:FEhViewer/models/index.dart';
import 'package:FEhViewer/utils/utility.dart';
import 'package:FEhViewer/values/const.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' show parse;
import 'package:intl/intl.dart';
import 'package:tuple/tuple.dart';

class GalleryListParser {
  /// 检查返回结果是否是l视图
  static bool isGalleryListDmL(String response) {
    final dom.Document document = parse(response);
    final List<dom.Element> domList =
        document.querySelectorAll('#dms > div > select > option');

    for (final dom.Element elm in domList) {
      // Global.logger.v('${elm.attributes["value"]}  ${elm.attributes.keys}');
      final Map<dynamic, String> attributes = elm.attributes;
      if (attributes.keys.contains('selected')) {
        return attributes['value'] == 'l';
      } else {
        return true;
      }
    }
    return true;
  }

  ///  收藏夹，检查返回结果的排序方式
  static bool isFavoriteOrder(String response) {
    final dom.Document document = parse(response);

    final List<dom.Element> domList =
        document.querySelectorAll('body > div.ido > div');

    if (domList.length > 2) {
      final dom.Element orderElm = domList[2].querySelector('div > span');
      // Global.logger.d('${orderElm.text}');
      return orderElm.text?.trim() == 'Favorited';
    }

    return false;
  }

  /// 列表数据处理
  static Future<Tuple2<List<GalleryItem>, int>> parseGalleryList(
    String response, {
    bool isFavorite = false,
    bool refresh = false,
  }) async {
    final dom.Document document = parse(response);

    const String _gallerySelector =
        'body > div.ido > div:nth-child(2) > table > tbody > tr';
    const String _favSelector =
        'body > div.ido > form > table.itg.gltc > tbody > tr';

    final String _listSelector = isFavorite ? _favSelector : _gallerySelector;

    const String _galleryPageSelector =
        'body > div.ido > div:nth-child(2) > table.ptt > tbody > tr > td';
    const String _favPageSelector =
        'body > div.ido > form > table.ptt > tbody > tr > td';
    final String _pageSelector =
        isFavorite ? _favPageSelector : _galleryPageSelector;

    const _favoritesSelector = 'body > div.ido > div.nosel > div';

    if (isFavorite) {
      /// 收藏夹列表
      List<dom.Element> favorites =
          document.querySelectorAll(_favoritesSelector);
      int _favId = 0;
      final List<Map<String, String>> favcatList = <Map<String, String>>[];
      for (final dom.Element elm in favorites) {
        final List<dom.Element> divs = elm.querySelectorAll('div');
        // Global.logger.v('${divs}');
        if (divs.isNotEmpty && divs.length >= 3) {
          final Map<String, String> map = <String, String>{
            'favId': '$_favId',
            'favTitle': divs[2].text ?? ''
          };
          favcatList.add(map);
          _favId += 1;
        }
      }
      if (favcatList.isNotEmpty) {
        Global.profile.user.favcat = favcatList;
        // Global.logger.v('$favcatList');
      }
    }

    // 最大页数
    int _maxPage = 0;
    List<dom.Element> _pages = document.querySelectorAll(_pageSelector);
    if (_pages.length > 2) {
      final dom.Element _maxPageElem = _pages[_pages.length - 2];
      _maxPage = int.parse(_maxPageElem.text.trim());
//      Global.logger.v('_maxPage $_maxPage');
    }

    // 画廊列表
    List<dom.Element> gallerys = document.querySelectorAll(_listSelector);
//    Global.logger.v('gallerys ${gallerys.length}');

    final List<GalleryItem> _gallaryItems = [];
    for (final dom.Element tr in gallerys) {
      final String category =
          tr.querySelector('td.gl1c.glcat > div')?.text?.trim();

      // 表头或者广告
      if (category == null || category.isEmpty) {
        continue;
      }

      final String title =
          tr.querySelector('td.gl3c.glname > a > div.glink')?.text?.trim();

      final String url =
          tr.querySelector('td.gl3c.glname > a')?.attributes['href'] ?? '';

      final RegExp urlRex = RegExp(r'/g/(\d+)/(\w+)/$');
      final RegExpMatch urlRult = urlRex.firstMatch(url);

      final String gid = urlRult.group(1);
      final String token = urlRult.group(2);

      // tags
      final List<dom.Element> tags = tr.querySelectorAll('div.gt');

      // tag
      final List<SimpleTag> simpleTags = <SimpleTag>[];
      final RegExp colorRex = RegExp(r'#(\w{6})');
      for (final dom.Element tag in tags) {
        final String tagText = tag.text.trim();
        final String translate =
            await EhTagDatabase.getTranTag(tagText) ?? tagText;

        final String style = tag.attributes['style'];
        String color = '';
        String backgroundColor = '';
        if (style != null) {
          final Iterable<RegExpMatch> matches = colorRex.allMatches(style);
          color = matches.elementAt(0)[0];
          backgroundColor = matches.elementAt(3)[0];
          // Global.logger
          //     .d('$translate ${matches.length} $color  $backgroundColor');
        }
        simpleTags.add(SimpleTag()
          ..text = tagText
          ..translat = translate
          ..color = color
          ..backgrondColor = backgroundColor);
      }

      // 封面图片
      final dom.Element img = tr.querySelector('td.gl2c > div > div > img');
      final String imgDataSrc = img.attributes['data-src'];
      final String imgSrc = img.attributes['src'];
      final String imgUrl = imgDataSrc ?? imgSrc ?? '';

      // 图片宽高
      final String imageStyle = img.attributes['style'];
      final RegExpMatch match =
          RegExp(r'height:(\d+)px;width:(\d+)px').firstMatch(imageStyle);
      final double imageHeight = double.parse(match[1]);
      final double imageWidth = double.parse(match[2]);

      // 评分星级计算 (api获取不到评分时用)
      final String ratPx = tr
          .querySelector('td.gl2c > div:nth-child(2) > div.ir')
          .attributes['style'];
      final RegExp pxA = RegExp(r'-?(\d+)px\s+-?(\d+)px');
      final RegExpMatch px = pxA.firstMatch(ratPx);

      //
      final double ratingFB = (80.0 - double.parse(px.group(1))) / 16.0 -
          (px.group(2) == '21' ? 0.5 : 0.0);

//      Global.loggerNoStack.i('ratingFB $ratingFB');

      final String postTime =
          tr.querySelector('td.gl2c > div:nth-child(2) > div')?.text?.trim() ??
              '';
      DateTime time =
          DateFormat('yyyy-MM-dd HH:mm').parseUtc(postTime).toLocal();

      final String postTimeLocal = DateFormat('yyyy-MM-dd HH:mm').format(time);

      // 收藏标志
      final String favTitle = tr
              .querySelector('td.gl2c > div:nth-child(2) > div')
              ?.attributes['title'] ??
          '';

      String favcat = '';
      if (favTitle.isNotEmpty) {
        final String favcatStyle = tr
            .querySelector('td.gl2c > div:nth-child(2) > div')
            ?.attributes['style'];
        final String favcatColor = RegExp(r'border-color:(#\w{3});')
                ?.firstMatch(favcatStyle)
                ?.group(1) ??
            '';
        favcat = EHConst.favCat[favcatColor] ?? '';
      }

      // safeMode检查
      if (Platform.isIOS && Global.profile.ehConfig.safeMode) {
        if (category.trim() == 'Non-H') {
          _gallaryItems.add(GalleryItem()
            ..gid = gid
            ..token = token
            ..englishTitle = title
            ..imgUrl = imgUrl ?? ''
            ..imgHeight = imageHeight
            ..imgWidth = imageWidth
            ..url = url
            ..category = category
            ..simpleTags = simpleTags
            ..postTime = postTimeLocal
            ..ratingFallBack = ratingFB
            ..favTitle = favTitle
            ..favcat = favcat);
        }
      } else {
        _gallaryItems.add(GalleryItem()
          ..gid = gid
          ..token = token
          ..englishTitle = title
          ..imgUrl = imgUrl ?? ''
          ..imgHeight = imageHeight
          ..imgWidth = imageWidth
          ..url = url
          ..category = category
          ..simpleTags = simpleTags
          ..postTime = postTimeLocal
          ..ratingFallBack = ratingFB
          ..favTitle = favTitle
          ..favcat = favcat);
      }
    }

    // 通过api请求获取更多信息
    if (_gallaryItems.isNotEmpty) {
      await Api.getMoreGalleryInfo(_gallaryItems, refresh: refresh);
    }

    return Tuple2(_gallaryItems, _maxPage);
  }
}
