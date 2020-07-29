import 'dart:convert';
import 'dart:io';

import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/common/parser/gallery_detail_parser.dart';
import 'package:FEhViewer/common/parser/gallery_list_parser.dart';
import 'package:FEhViewer/models/galleryItem.dart';
import 'package:FEhViewer/models/index.dart';
import 'package:FEhViewer/utils/toast.dart';
import 'package:FEhViewer/values/const.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tuple/tuple.dart';

import 'dio_util.dart';

class EHUtils {
  /// list 分割
  static List<List<T>> splitList<T>(List<T> list, int len) {
    if (len <= 1) {
      return [list];
    }

    List<List<T>> result = List();
    int index = 1;

    while (true) {
      if (index * len < list.length) {
        List<T> temp = list.skip((index - 1) * len).take(len).toList();
        result.add(temp);
        index++;
        continue;
      }
      List<T> temp = list.skip((index - 1) * len).toList();
      result.add(temp);
      break;
    }
    return result;
  }
}

class Api {
  //改为使用 PersistCookieJar，在文档中有介绍，PersistCookieJar将cookie保留在文件中，
  // 因此，如果应用程序退出，则cookie始终存在，除非显式调用delete
  static PersistCookieJar _cookieJar;

  static Future<PersistCookieJar> get cookieJar async {
    // print(_cookieJar);
    if (_cookieJar == null) {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path;
      print('获取的文件系统目录 appDocPath： ' + appDocPath);
      _cookieJar = new PersistCookieJar(dir: appDocPath);
    }
    return _cookieJar;
  }

  /// 获取热门画廊列表
  static Future<Tuple2<List<GalleryItem>, int>> getPopular() async {
//    Global.logger.v("获取热门");

    HttpManager httpManager = HttpManager.getInstance(
        EHConst.getBaseSite(Global.profile.ehConfig.siteEx ?? false));
    const url = "/popular";

    var response = await httpManager.get(url);

    /*var cookieJar = await Api.cookieJar;
    List<Cookie> cookiesE =
        cookieJar.loadForRequest(Uri.parse(EHConst.EH_BASE_URL));
    List<Cookie> cookiesEX =
        cookieJar.loadForRequest(Uri.parse(EHConst.EX_BASE_URL));

    Global.logger.v('$cookiesE\n$cookiesEX');*/

    var tuple = await GalleryListParser.parseGalleryList(response);

    return tuple;
  }

  /// 获取画廊列表
  static Future<Tuple2<List<GalleryItem>, int>> getGallery(
      {int page, String fromGid, String serach, int cats}) async {
    HttpManager httpManager = HttpManager.getInstance(
        EHConst.getBaseSite(Global.profile.ehConfig.siteEx ?? false));

    var url = "/";
    var qry = '?page=${page ?? 0}';
    if (fromGid != null) {
      qry = '$qry&from=$fromGid';
    }
    if (cats != null) {
      qry = '$qry&f_cats=$cats';
    }

    if (serach != null) {
      var searArr = serach.split(':');
      if (searArr.length > 1) {
        var _search = Uri.encodeQueryComponent('${searArr[0]}:"${searArr[1]}"');
        qry = '$qry&f_search=$_search';
      }
    }

    url = '$url$qry';

    Options options = Options(headers: {
      "Referer": "https://e-hentai.org",
    });

    Global.logger.v(url);

    var response = await httpManager.get(url, options: options);

    return await GalleryListParser.parseGalleryList(response);
  }

  /// 获取收藏
  static Future<Tuple2<List<GalleryItem>, int>> getFavorite(
      {String favcat, int page}) async {
    HttpManager httpManager = HttpManager.getInstance(
        EHConst.getBaseSite(Global.profile.ehConfig.siteEx ?? false));

    //收藏时间排序
    var _order = Global?.profile?.ehConfig?.favoritesOrder;

    var url = '/favorites.php/';
    var qry = '?page=${page ?? 0}';
    if (favcat != null && favcat != "a" && favcat.isNotEmpty) {
      qry = '$qry&favcat=$favcat';
    }
    qry = "$qry&inline_set=${_order ?? ''}";
    url = '$url$qry';

    Global.logger.v(url);

    var response = await httpManager.get(url);

    return await GalleryListParser.parseGalleryList(response, isFavorite: true);
  }

  /// 获取画廊详细信息
  static Future<GalleryItem> getGalleryDetail(String inUrl) async {
    //?inline_set=ts_m 小图,40一页
    //?inline_set=ts_l 大图,20一页
    //hc=1#comments 显示全部评论
    //nw=always 不显示警告

    HttpManager httpManager = HttpManager.getInstance();
    var url = inUrl + '?hc=1&inline_set=ts_l&nw=always';

    // 不显示警告的处理 cookie加上 nw=1
    // 在 url使用 nw=always 未解决 自动写入cookie 暂时搞不懂 先手动设置下
    // todo 待优化
    var cookieJar = await Api.cookieJar;
    List<Cookie> cookies = cookieJar.loadForRequest(Uri.parse(inUrl));
    cookies.add(Cookie('nw', '1'));
    cookieJar.saveFromResponse(Uri.parse(url), cookies);

//    Global.logger.i("获取画廊 $url");
    var response = await httpManager.get(url);

    // TODO 画廊警告问题 使用 nw=always 未解决 待处理 怀疑和Session有关
    if ('$response'.contains(r'<strong>Offensive For Everyone</strong>')) {
      Global.logger.v('Offensive For Everyone');
      showToast('Offensive For Everyone');
    }

    GalleryItem galleryItem =
        await GalleryDetailParser.parseGalleryDetail(response);

    return galleryItem;
  }

  /// 获取画廊缩略图
  /// [inUrl] 画廊的地址
  /// [page] 缩略图页码
  static Future<List<GalleryPreview>> getGalleryPreview(String inUrl,
      {int page}) async {
    //?inline_set=ts_m 小图,40一页
    //?inline_set=ts_l 大图,20一页
    //hc=1#comments 显示全部评论
    //nw=always 不显示警告

    HttpManager httpManager = HttpManager.getInstance();
    var url = inUrl + '?p=$page';

    Global.logger.v(url);

    // 不显示警告的处理 cookie加上 nw=1
    // 在 url使用 nw=always 未解决 自动写入cookie 暂时搞不懂 先手动设置下
    // todo 待优化
    var cookieJar = await Api.cookieJar;
    List<Cookie> cookies = cookieJar.loadForRequest(Uri.parse(inUrl));
    cookies.add(Cookie('nw', '1'));
    cookieJar.saveFromResponse(Uri.parse(url), cookies);

    var response = await httpManager.get(url);

    return GalleryDetailParser.parseGalleryPreviewFromHtml(response);
  }

  /// 由图片url获取解析图库 showkey
  /// [href] 画廊图片展示页面的地址
  static Future<String> getShowkey(String href) async {
    HttpManager httpManager = HttpManager.getInstance();

    var url = href;

    var response = await httpManager.get(url);

    final RegExp regShowKey = RegExp(r'var showkey="([0-9a-z]+)";');

    var showkey = regShowKey.firstMatch(response)?.group(1) ?? '';

//    Global.logger.v('$showkey');

    return showkey;
  }

  /// 由api获取画廊图片的url
  /// [href] 爬取的页面地址 用来解析gid 和 imgkey
  /// [showKey] api必须
  /// [index] 索引 从 1 开始
  static Future<String> getShowInfo(String href, String showKey,
      {int index}) async {
    HttpManager httpManager = HttpManager.getInstance(EHConst.EH_BASE_URL);
    const url = "/api.php";

    var cookie = Global.profile?.user?.cookie ?? "";

    Options options = Options(headers: {
      "Cookie": cookie,
    });

//    Global.logger.v('href = $href');

    var regExp = RegExp(r'https://e[-x]hentai.org/s/([0-9a-z]+)/(\d+)-(\d+)');
    var regRult = regExp.firstMatch(href);
    var gid = int.parse(regRult.group(2));
    var imgkey = regRult.group(1);
    var page = int.parse(regRult.group(3));

    Map reqMap = {
      'method': 'showpage',
      'gid': gid,
      'page': page,
      'imgkey': imgkey,
      'showkey': showKey,
    };
    String reqJsonStr = jsonEncode(reqMap);

//    Global.logger.v('$reqJsonStr');

    var response = await httpManager.postForm(
      url,
      options: options,
      data: reqJsonStr,
    );

//    Global.logger.v('$response');

    var rultJson = jsonDecode('$response');

    final RegExp regImageUrl = RegExp("<img[^>]*src=\"([^\"]+)\" style");
    var imageUrl = regImageUrl.firstMatch(rultJson['i3']).group(1);

//    Global.logger.v('$imageUrl');

    return imageUrl;
  }
}
