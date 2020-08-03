import 'dart:convert';

import 'package:FEhViewer/common/tag_database.dart';
import 'package:FEhViewer/models/index.dart';
import 'package:FEhViewer/utils/dio_util.dart';
import 'package:FEhViewer/utils/utility.dart';
import 'package:FEhViewer/values/const.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' show parse;
import 'package:html_unescape/html_unescape.dart';
import 'package:intl/intl.dart';
import 'package:tuple/tuple.dart';

class GalleryListParser {
  /// 获取api
  static Future getGalleryApi(String req) async {
    HttpManager httpManager = HttpManager.getInstance(EHConst.EH_BASE_URL);
    const url = "/api.php";

    var response = await httpManager.postForm(url, data: req);

    return response;
  }

  /// 列表数据处理
  static Future<Tuple2<List<GalleryItem>, int>> parseGalleryList(
      String response,
      {isFavorite = false}) async {
    var document = parse(response);

    final _gallerySelector =
        "body > div.ido > div:nth-child(2) > table > tbody > tr";
    final _favSelector = "body > div.ido > form > table.itg.gltc > tbody > tr";

    final _listSelector = isFavorite ? _favSelector : _gallerySelector;

    final _galleryPageSelector =
        'body > div.ido > div:nth-child(2) > table.ptt > tbody > tr > td';
    final _favPageSelector =
        'body > div.ido > form > table.ptt > tbody > tr > td';
    final _pageSelector = isFavorite ? _favPageSelector : _galleryPageSelector;

    // final fav =
    //     document.querySelector("body > div.ido > form > p")?.text?.trim() ?? "";

    // 最大页数
    int _maxPage = 0;
    List<dom.Element> _pages = document.querySelectorAll(_pageSelector);
    if (_pages.length > 2) {
      dom.Element _maxPageElem = _pages[_pages.length - 2];
      _maxPage = int.parse(_maxPageElem.text.trim());
//      Global.logger.v('_maxPage $_maxPage');
    }

    // 画廊列表
    List<dom.Element> gallerys = document.querySelectorAll(_listSelector);
//    Global.logger.v('gallerys ${gallerys.length}');

    List<GalleryItem> _gallaryItems = [];
    for (var tr in gallerys) {
      final category = tr.querySelector('td.gl1c.glcat > div')?.text?.trim();

      // 表头或者广告
      if (category == null || category.isEmpty) {
        continue;
      }

      final title =
          tr.querySelector('td.gl3c.glname > a > div.glink')?.text?.trim();

      final url =
          tr.querySelector('td.gl3c.glname > a')?.attributes['href'] ?? '';

      RegExp urlRex = new RegExp(r"/g/(\d+)/(\w+)/$");
      var urlRult = urlRex.firstMatch(url);

      final gid = urlRult.group(1);
      final token = urlRult.group(2);

      // tags
      List tags = tr.querySelectorAll('div.gt');

      // 英文tag
      final List<String> simpleTags = [];
      for (var tag in tags) {
        var tagText = tag.text.trim();
        simpleTags.add(tagText);
      }

      // 中文tag
      final List<String> simpleTagsTranslate = [];
      for (var tag in tags) {
        final tagText = tag.text.trim();
        simpleTagsTranslate
            .add(await EhTagDatabase.getTranTag(tagText) ?? tagText);
      }

      // 封面图片
      final dom.Element img = tr.querySelector('td.gl2c > div > div > img');
      final String imgDataSrc = img.attributes['data-src'];
      final String imgSrc = img.attributes['src'];
      final String imgUrl = imgDataSrc ?? imgSrc ?? '';

      // 图片宽高
      final imageStyle = img.attributes['style'];
      var match =
          RegExp(r'height:(\d+)px;width:(\d+)px').firstMatch(imageStyle);
      final imageHeight = double.parse(match[1]);
      final imageWidth = double.parse(match[2]);

      // 评分星级计算 (api获取不到评分时用)
      final ratPx = tr
          .querySelector('td.gl2c > div:nth-child(2) > div.ir')
          .attributes['style'];
      RegExp pxA = new RegExp(r"-?(\d+)px\s+-?(\d+)px");
      var px = pxA.firstMatch(ratPx);

      //
      final ratingFB = (80.0 - double.parse(px.group(1))) / 16.0 -
          (px.group(2) == '21' ? 0.5 : 0.0);

//      Global.loggerNoStack.i('ratingFB $ratingFB');

      final postTime =
          tr.querySelector('td.gl2c > div:nth-child(2) > div')?.text?.trim() ??
              '';
      DateTime time =
          DateFormat('yyyy-MM-dd HH:mm').parseUtc(postTime).toLocal();

      final postTimeLocal = DateFormat('yyyy-MM-dd HH:mm').format(time);

      // 收藏标志
      final favTitle = tr
              .querySelector('td.gl2c > div:nth-child(2) > div')
              ?.attributes['title'] ??
          '';

      var favcat = '';
      if (favTitle.isNotEmpty) {
        var favcatStyle = tr
            .querySelector('td.gl2c > div:nth-child(2) > div')
            ?.attributes['style'];
        var favcatColor = RegExp(r'border-color:(#\w{3});')
                ?.firstMatch(favcatStyle)
                ?.group(1) ??
            '';
        favcat = EHConst.favCat[favcatColor] ?? '';
      }

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
        ..simpleTagsTranslat = simpleTagsTranslate
        ..ratingFallBack = ratingFB
        ..favTitle = favTitle
        ..favcat = favcat);
    }

    // 通过api请求获取更多信息
    if (_gallaryItems.length > 0) {
      await getMoreGalleryInfo(_gallaryItems);
    }

    return Tuple2(_gallaryItems, _maxPage);
  }

  /// 通过api请求获取更多信息
  /// 例如
  /// 画廊评分
  /// 日语标题
  /// 等等
  static Future<List<GalleryItem>> getMoreGalleryInfo(
      List<GalleryItem> galleryItems) async {
    // Global.logger.i('api qry items ${galleryItems.length}');
    if (galleryItems.length == 0) {
      return galleryItems;
    }

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

    var unescape = new HtmlUnescape();

    for (int i = 0; i < galleryItems.length; i++) {
      galleryItems[i].englishTitle = unescape.convert(rultList[i]['title']);
      galleryItems[i].japaneseTitle =
          unescape.convert(rultList[i]['title_jpn']);

      var rating = rultList[i]['rating'];
      // Global.loggerNoStack.v('$rating');
      galleryItems[i].rating = rating != null
          ? double.parse(rating)
          : galleryItems[i].ratingFallBack;

//      galleryItems[i].imgUrl = rultList[i]['thumb'];
      galleryItems[i].filecount = rultList[i]['filecount'];
      galleryItems[i].uploader = rultList[i]['uploader'];
    }

    return galleryItems;
  }
}
