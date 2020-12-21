import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:dns_client/dns_client.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:extended_image/extended_image.dart';
import 'package:fehviewer/common/controller/advance_search_controller.dart';
import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/common/parser/gallery_detail_parser.dart';
import 'package:fehviewer/common/parser/gallery_list_parser.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/models/galleryItem.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/utils/dio_util.dart';
import 'package:fehviewer/utils/https_proxy.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/toast.dart';
import 'package:fehviewer/utils/utility.dart';
import 'package:fehviewer/values/const.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share/share.dart';
import 'package:tuple/tuple.dart';

final Api api = Api();

// ignore: avoid_classes_with_only_static_members
class Api {
  Api() {
    final String _baseUrl = EHConst.getBaseSite(
        Get.find<EhConfigService>().isSiteEx.value ?? false);
    httpManager = HttpManager.getInstance(baseUrl: _baseUrl);
  }

  HttpManager httpManager;
  String _baseUrl;

  //改为使用 PersistCookieJar，在文档中有介绍，PersistCookieJar将cookie保留在文件中，
  // 因此，如果应用程序退出，则cookie始终存在，除非显式调用delete
  static PersistCookieJar _cookieJar;

  static Future<PersistCookieJar> get cookieJar async {
    // print(_cookieJar);
    if (_cookieJar == null) {
      print('获取的文件系统目录 appSupportPath： ' + Global.appSupportPath);
      _cookieJar = PersistCookieJar(dir: Global.appSupportPath);
    }
    return _cookieJar;
  }

  static Future<String> getIpByDoH(String url) async {
    final DnsOverHttps dns = DnsOverHttps.cloudflare();
    final List<InternetAddress> response = await dns.lookup(url);
    if (response.isNotEmpty) {
      return response.first.address;
    } else {
      return url;
    }
  }

  static HttpManager getHttpManager({bool cache = true}) {
    final String _baseUrl = EHConst.getBaseSite(
        Get.find<EhConfigService>().isSiteEx.value ?? false);
    return HttpManager(_baseUrl, cache: cache);
  }

  static Options getCacheOptions({bool forceRefresh = false}) {
    return buildCacheOptions(
      const Duration(days: 3),
      maxStale: const Duration(days: 1),
      forceRefresh: forceRefresh,
    );
  }

  static String getBaseUrl() {
    return EHConst.getBaseSite(
        Get.find<EhConfigService>().isSiteEx.value ?? false);
  }

  /// 获取热门画廊列表
  static Future<Tuple2<List<GalleryItem>, int>> getPopular(
      {bool refresh = false}) async {
//    logger.v("获取热门");

    const String url = '/popular?inline_set=dm_l';
    // const String url = '/popular';

    // await CustomHttpsProxy.instance.init();

    final Options _cacheOptions = getCacheOptions(forceRefresh: refresh);

    final String response =
        await getHttpManager().get(url, options: _cacheOptions);

    final Tuple2<List<GalleryItem>, int> tuple =
        await GalleryListParser.parseGalleryList(response, refresh: refresh);

    return tuple;
  }

  /// 获取画廊列表
  static Future<Tuple2<List<GalleryItem>, int>> getGallery({
    int page,
    String fromGid,
    String serach,
    int cats,
    bool refresh = false,
  }) async {
    final EhConfigService ehConfigController = Get.find();
    final AdvanceSearchController searchController = Get.find();

    String url = '/';
    String qry = '?page=${page ?? 0}&inline_set=dm_l';
    // String qry = '?page=${page ?? 0}';

    if (ehConfigController.isSafeMode.value) {
      qry = '$qry&f_cats=767';
    } else if (cats != null) {
      qry = '$qry&f_cats=$cats';
    }

    if (fromGid != null) {
      qry = '$qry&from=$fromGid';
    }

    if (ehConfigController.isSafeMode.value) {
      serach = 'parody:gundam\$';
    }

    /// 搜索词处理
    if (serach != null) {
      final List<String> searArr = serach.split(':');
      if (searArr.length == 2 &&
          !serach.trim().contains('\$') &&
          !serach.trim().contains('"')) {
        String _end = '';
        if (searArr[0] != 'uploader') {
          _end = '\$';
        }
        final String _search =
            Uri.encodeQueryComponent('${searArr[0]}:"${searArr[1]}$_end"');
        qry = '$qry&f_search=$_search';
      } else {
        logger.d('原始处理');
        final String _search = Uri.encodeQueryComponent(serach.trim());
        qry = '$qry&f_search=$_search';
      }
    }

    url = '$url$qry';

    /// 高级搜索处理
    if (searchController.enableAdvance.value ?? false) {
      url = '$url&advsearch=1${searchController.getAdvanceSearchText()}';
    }

    // , options: Options(extra: {'refresh': refresh})
    final Options options = Options(headers: {
      'Referer': 'https://e-hentai.org',
    }, extra: {
      'refresh': refresh
    });

    // final Options _cacheOptions = buildCacheOptions(
    //   const Duration(days: 1),
    //   maxStale: const Duration(hours: 1),
    //   forceRefresh: refresh,
    //   options: Options(headers: {
    //     'Referer': 'https://e-hentai.org',
    //   }),
    // );
    final Options _cacheOptions = getCacheOptions(forceRefresh: refresh);

    logger.v(url);

    await CustomHttpsProxy.instance.init();
    final String response =
        await getHttpManager().get(url, options: _cacheOptions);

    return await GalleryListParser.parseGalleryList(response, refresh: refresh);
  }

  /// 获取收藏
  static Future<Tuple2<List<GalleryItem>, int>> getFavorite({
    String favcat,
    int page,
    bool refresh = false,
  }) async {
    /// inline_set不能和页码同时使用 会默认定向到第一页
    String _getUrl({String inlineSet}) {
      String url = '/favorites.php/';
      String qry = '?page=${page ?? 0}';
      if (favcat != null && favcat != 'a' && favcat.isNotEmpty) {
        qry = '$qry&favcat=$favcat';
      }
      if (inlineSet != null && inlineSet.isNotEmpty) {
        qry = "$qry&inline_set=${inlineSet ?? ''}";
      }
      url = '$url$qry';

      logger.v(url);
      return url;
    }

    final String url = _getUrl();

    final Options _cacheOptions = getCacheOptions(forceRefresh: refresh);

    await CustomHttpsProxy.instance.init();
    String response = await getHttpManager().get(url, options: _cacheOptions);

    // 排序方式检查 不符合则设置 然后重新请求
    // 获取收藏排序设置
    final FavoriteOrder order = EnumToString.fromString(
            FavoriteOrder.values, Global?.profile?.ehConfig?.favoritesOrder) ??
        FavoriteOrder.fav;
    // 排序参数
    final String _order = EHConst.favoriteOrder[order] ?? EHConst.FAV_ORDER_FAV;
    final bool isOrderFav = GalleryListParser.isFavoriteOrder(response);
    if (isOrderFav ^ (order == FavoriteOrder.fav)) {
      // 重设排序方式
      loggerNoStack.d('$isOrderFav 重设排序方式 $_order');
      final String _urlOrder = _getUrl(inlineSet: _order);
      await getHttpManager()
          .get(_urlOrder, options: getCacheOptions(forceRefresh: true));
      response = await getHttpManager().get(url, options: _cacheOptions);
    }

    // 列表样式检查 不符合则重新设置
    final bool isDml = GalleryListParser.isGalleryListDmL(response);
    if (isDml) {
      return await GalleryListParser.parseGalleryList(
        response,
        isFavorite: true,
        refresh: refresh,
      );
    } else {
      final String url = _getUrl(inlineSet: 'dm_l');
      final String response =
          await getHttpManager().get(url, options: _cacheOptions);
      return await GalleryListParser.parseGalleryList(
        response,
        isFavorite: true,
        refresh: refresh,
      );
    }
  }

  /// 获取画廊详细信息
  /// ?inline_set=ts_m 小图,40一页
  /// ?inline_set=ts_l 大图,20一页
  /// c=1#comments 显示全部评论
  /// nw=always 不显示警告
  static Future<GalleryItem> getGalleryDetail({
    String inUrl,
    GalleryItem inGalleryItem,
    bool refresh = false,
  }) async {
    // final HttpManager httpManager = HttpManager.getInstance();
    final String url = inUrl + '?hc=1&inline_set=ts_l&nw=always';
    // final String url = inUrl;

    // 不显示警告的处理 cookie加上 nw=1
    // 在 url使用 nw=always 未解决 自动写入cookie 暂时搞不懂 先手动设置下
    // todo 待优化
    final PersistCookieJar cookieJar = await Api.cookieJar;
    final List<Cookie> cookies = cookieJar.loadForRequest(Uri.parse(inUrl));
    cookies.add(Cookie('nw', '1'));
    cookieJar.saveFromResponse(Uri.parse(url), cookies);

    logger.i('获取画廊 $url');
    await CustomHttpsProxy.instance.init();
    final String response = await getHttpManager()
        .get(url, options: getCacheOptions(forceRefresh: refresh));

    // TODO 画廊警告问题 使用 nw=always 未解决 待处理 怀疑和Session有关
    if ('$response'.contains(r'<strong>Offensive For Everyone</strong>')) {
      logger.v('Offensive For Everyone');
      showToast('Offensive For Everyone');
    }

    final GalleryItem galleryItem =
        await GalleryDetailParser.parseGalleryDetail(response,
            inGalleryItem: inGalleryItem);

    // logger.v(galleryItem.toJson());

    return galleryItem;
  }

  /// 获取画廊缩略图
  /// [inUrl] 画廊的地址
  /// [page] 缩略图页码
  static Future<List<GalleryPreview>> getGalleryPreview(
    String inUrl, {
    int page,
    bool refresh = false,
    CancelToken cancelToken,
  }) async {
    //?inline_set=ts_m 小图,40一页
    //?inline_set=ts_l 大图,20一页
    //hc=1#comments 显示全部评论
    //nw=always 不显示警告

    // final HttpManager httpManager = HttpManager.getInstance();
    final String url = inUrl + '?p=$page';

    // logger.v(url);

    // 不显示警告的处理 cookie加上 nw=1
    // 在 url使用 nw=always 未解决 自动写入cookie 暂时搞不懂 先手动设置下
    // todo 待优化
    final PersistCookieJar cookieJar = await Api.cookieJar;
    final List<Cookie> cookies = cookieJar.loadForRequest(Uri.parse(inUrl));
    cookies.add(Cookie('nw', '1'));
    cookieJar.saveFromResponse(Uri.parse(url), cookies);

    await CustomHttpsProxy.instance.init();
    final String response = await getHttpManager().get(
      url,
      options: getCacheOptions(forceRefresh: refresh),
      cancelToken: cancelToken,
    );

    return GalleryDetailParser.parseGalleryPreviewFromHtml(response);
  }

  /// 由图片url获取解析图库 showkey
  /// [href] 画廊图片展示页面的地址
  static Future<String> getShowkey(
    String href, {
    bool refresh = false,
  }) async {
    final String url = href;

    await CustomHttpsProxy.instance.init();
    final String response = await getHttpManager()
        .get(url, options: getCacheOptions(forceRefresh: refresh));

    final RegExp regShowKey = RegExp(r'var showkey="([0-9a-z]+)";');

    final String showkey = regShowKey.firstMatch(response)?.group(1) ?? '';

//    logger.v('$showkey');

    return showkey;
  }

  /// 通过api请求获取更多信息
  /// 例如
  /// 画廊评分
  /// 日语标题
  /// 等等
  static Future<List<GalleryItem>> getMoreGalleryInfo(
    List<GalleryItem> galleryItems, {
    bool refresh = false,
  }) async {
    // logger.i('api qry items ${galleryItems.length}');
    if (galleryItems.isEmpty) {
      return galleryItems;
    }

    // 通过api获取画廊详细信息
    List _gidlist = [];

    galleryItems.forEach((GalleryItem galleryItem) {
      _gidlist.add([galleryItem.gid, galleryItem.token]);
    });

    // 25个一组分割
    List _group = EHUtils.splitList(_gidlist, 25);

    List rultList = [];

    // 查询 合并结果
    for (int i = 0; i < _group.length; i++) {
      Map reqMap = {'gidlist': _group[i], 'method': 'gdata'};
      final String reqJsonStr = jsonEncode(reqMap);

      await CustomHttpsProxy.instance.init();
      final rult = await getGalleryApi(reqJsonStr, refresh: refresh);

      final jsonObj = jsonDecode(rult.toString());
      final tempList = jsonObj['gmetadata'];
      rultList.addAll(tempList);
    }

    final HtmlUnescape unescape = HtmlUnescape();

    for (int i = 0; i < galleryItems.length; i++) {
      galleryItems[i].englishTitle = unescape.convert(rultList[i]['title']);
      galleryItems[i].japaneseTitle =
          unescape.convert(rultList[i]['title_jpn']);

      final rating = rultList[i]['rating'];
      galleryItems[i].rating = rating != null
          ? double.parse(rating)
          : galleryItems[i].ratingFallBack;

      final String thumb = rultList[i]['thumb'];
      galleryItems[i].imgUrlL = thumb;
      /*final String imageUrl = thumb.endsWith('-jpg_l.jpg')
          ? thumb.replaceFirst('-jpg_l.jpg', '-jpg_250.jpg')
          : thumb;

      galleryItems[i].imgUrl = imageUrl;*/

      // logger.v('${rultList[i]["tags"]}');

      galleryItems[i].filecount = rultList[i]['filecount'] as String;
      galleryItems[i].uploader = rultList[i]['uploader'] as String;
      galleryItems[i].category = rultList[i]['category'] as String;
      final List<String> tags = List<String>.from(
          rultList[i]['tags'].map((e) => e as String).toList());
      galleryItems[i].tagsFromApi = tags;

      /// 判断获取语言标识
      // galleryItems[i].translated = '';
      // if (tags.contains('translated')) {
      //   logger.v('hase translated');
      //   galleryItems[i].translated = EHUtils.getLangeage(tags[0]);
      // }
      if (tags.isNotEmpty) {
        galleryItems[i].translated = EHUtils.getLangeage(tags[0]) ?? '';
      }

      // Global.logger
      //     .v('${galleryItems[i].translated}   ${galleryItems[i].tagsFromApi}');
    }

    return galleryItems;
  }

  static Future<void> getMoreGalleryInfoOne(
    GalleryItem galleryItem, {
    bool refresh = false,
  }) async {
    final RegExp urlRex = RegExp(r'http?s://e(-|x)hentai.org/g/(\d+)/(\w+)?/$');
    logger.v(galleryItem.url);
    final RegExpMatch urlRult = urlRex.firstMatch(galleryItem.url);
    logger.v(urlRult.groupCount);

    final String gid = urlRult.group(2);
    final String token = urlRult.group(3);

    galleryItem.gid = gid;
    galleryItem.token = token;

    final List<GalleryItem> reqGalleryItems = <GalleryItem>[galleryItem];

    await getMoreGalleryInfo(reqGalleryItems, refresh: refresh);
  }

  /// 获取api
  static Future getGalleryApi(
    String req, {
    bool refresh = false,
  }) async {
    const String url = '/api.php';

    await CustomHttpsProxy.instance.init();
    final response = await getHttpManager().postForm(
      url,
      data: req,
      options: getCacheOptions(forceRefresh: refresh),
    );

    return response;
  }

  /// 分享图片
  static Future<void> shareImage(String imageUrl) async {
    final CachedNetworkImage image = CachedNetworkImage(imageUrl: imageUrl);
    final DefaultCacheManager manager =
        image.cacheManager ?? DefaultCacheManager();
    final Map<String, String> headers = image.httpHeaders;
    final File file = await manager.getSingleFile(
      image.imageUrl,
      headers: headers,
    );
    Share.shareFiles(<String>[file.path]);
  }

  /// 保存图片到相册
  ///
  /// 默认为下载网络图片，如需下载资源图片，需要指定 [isAsset] 为 `true`。
  static Future<bool> saveImage(BuildContext context, String imageUrl,
      {bool isAsset = false}) async {
    Future<void> _jumpToAppSettings(context) async {
      return showCupertinoDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: const Text('页面跳转'),
            content: Container(
              child: const Text('您禁用了应用的必要权限:\n读写手机存储,是否到设置里允许?'),
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                child: const Text('取消'),
                onPressed: () {
                  Get.back();
                },
              ),
              CupertinoDialogAction(
                child: const Text('确定'),
                onPressed: () {
                  // 跳转
                  openAppSettings();
                },
              ),
            ],
          );
        },
      );
    }

    if (Platform.isIOS) {
      logger.v('check ios photos Permission');
      final PermissionStatus status = await Permission.photos.status;
      logger.v(status);
      if (status.isPermanentlyDenied) {
        _jumpToAppSettings(context);
        return false;
      } else {
        if (await Permission.photos.request().isGranted) {
          return _saveImage(imageUrl);
          // Either the permission was already granted before or the user just granted it.
        } else {
          throw '无法存储图片,请先授权~';
        }
      }
    } else {
      final PermissionStatus status = await Permission.storage.status;
      logger.v(status);
      if (await Permission.storage.status.isPermanentlyDenied) {
        if (await Permission.storage.request().isGranted) {
          _saveImage(imageUrl);
        } else {
          await _jumpToAppSettings(context);
          return false;
        }
      } else {
        if (await Permission.storage.request().isGranted) {
          // Either the permission was already granted before or the user just granted it.
          return _saveImage(imageUrl);
        } else {
          throw '无法存储图片,请先授权~';
        }
      }
    }
    return false;
  }

  static Future<bool> _saveImage(String imageUrl,
      {bool isAsset = false}) async {
    try {
      if (imageUrl == null) throw '保存失败,图片不存在!';

      /// 保存的图片数据
      Uint8List imageBytes;

      if (isAsset == true) {
        /// 保存资源图片
        final ByteData bytes = await rootBundle.load(imageUrl);
        imageBytes = bytes.buffer.asUint8List();
      } else {
        /// 保存网络图片
        final CachedNetworkImage image = CachedNetworkImage(imageUrl: imageUrl);
        final DefaultCacheManager manager =
            image.cacheManager ?? DefaultCacheManager();
        final Map<String, String> headers = image.httpHeaders;
        final File file = await manager.getSingleFile(
          image.imageUrl,
          headers: headers,
        );
        imageBytes = await file.readAsBytes();

        ExtendedNetworkImageProvider _image = ExtendedNetworkImageProvider(
          imageUrl,
          cache: true,
        );
        Uint8List _imageBytes = await _image.getNetworkImageData();
      }

      /// 保存图片
      final result = await ImageGallerySaver.saveImage(imageBytes);

      if (result == null || result == '') throw '图片保存失败';

      print('保存成功');
      return true;
    } catch (e) {
      print(e.toString());
      rethrow;
    }
  }
}
