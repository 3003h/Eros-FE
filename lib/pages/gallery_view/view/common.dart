import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/network/gallery_request.dart';
import 'package:fehviewer/pages/gallery_main/controller/gallery_page_controller.dart';
import 'package:fehviewer/utils/https_proxy.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class GalleryPrecache {
  /// 内部构造方法，可避免外部暴露构造函数，进行实例化
  GalleryPrecache._internal();

  /// 工厂构造方法，这里使用命名构造函数方式进行声明
  factory GalleryPrecache.getInstance() => _getInstance();

  static GalleryPrecache get instance => _getInstance();

  /// 获取单例内部方法
  static GalleryPrecache _getInstance() {
    // 只能有一个实例
    _instance ??= GalleryPrecache._internal();
    return _instance;
  }

  /// 单例对象
  static GalleryPrecache _instance;

  final List<int> _curIndexList = <int>[];

  final Map<String, Future<bool>> _map = <String, Future<bool>>{};

  /// 由api获取画廊图片的信息
  /// [href] 爬取的页面地址 用来解析gid 和 imgkey
  /// [showKey] api必须
  /// [index] 索引 从 1 开始
  Future<GalleryPreview> paraImageLageInfoFromApi(
    String href,
    String showKey, {
    int index,
  }) async {
    const String url = '/api.php';

    final String cookie = Global.profile?.user?.cookie ?? '';

    final Options options = Options(headers: {
      'Cookie': cookie,
    });

//    logger.v('href = $href');

    final RegExp regExp =
        RegExp(r'https://e[-x]hentai.org/s/([0-9a-z]+)/(\d+)-(\d+)');
    final RegExpMatch regRult = regExp.firstMatch(href);
    final int gid = int.parse(regRult.group(2));
    final String imgkey = regRult.group(1);
    final int page = int.parse(regRult.group(3));

    final Map<String, Object> reqMap = {
      'method': 'showpage',
      'gid': gid,
      'page': page,
      'imgkey': imgkey,
      'showkey': showKey,
    };
    final String reqJsonStr = jsonEncode(reqMap);

    // logger.d('$reqJsonStr');

    final Options _cacheOptinos = buildCacheOptions(
      const Duration(days: 1),
      maxStale: const Duration(minutes: 1),
      options: options,
      subKey: reqJsonStr,
    );

    await CustomHttpsProxy.instance.init();
    final Response<dynamic> response = await Api.getHttpManager().postForm(
      url,
      options: _cacheOptinos,
      data: reqJsonStr,
    );

    // logger.d('$response');

    final dynamic rultJson = jsonDecode('$response');

    final RegExp regImageUrl = RegExp('<img[^>]*src=\"([^\"]+)\" style');
    final String imageUrl = regImageUrl.firstMatch(rultJson['i3']).group(1);
    final double width = double.parse(rultJson['x'].toString());
    final double height = double.parse(rultJson['y'].toString());

//    logger.v('$imageUrl');

    final GalleryPreview _rePreview = GalleryPreview()
      ..largeImageUrl = imageUrl
      ..ser = index + 1
      ..largeImageWidth = width
      ..largeImageHeight = height;
    // logger.v('${_rePreview.toJson()}');

    return _rePreview;
  }

  /// 一个很傻的预载功能 需要优化
  Future<void> precacheImages(
    BuildContext context,
    GalleryPageController controller, {
    @required List<GalleryPreview> previews,
    @required int index,
    @required int max,
  }) async {
    // logger.d('当前index $index');
    for (int add = 1; add < max + 1; add++) {
      final int _index = index + add;

      // logger.d('开始缓存index $index');
      if (_index > controller.previews.length - 1) {
        return;
      }

      if (_curIndexList.contains(_index)) {
        continue;
      }

      final GalleryPreview _preview = controller.previews[_index];
      if (_preview?.isCache ?? false) {
        // logger.d('index $_index 已存在缓存中 跳过');
        continue;
      }

      if (_preview?.startPrecache ?? false) {
        // logger.d('index $_index 已开始缓存 跳过');
        continue;
      }

      String _url = '';
      if (_preview.largeImageUrl?.isEmpty ?? true) {
        // logger.d('get $_index from Api');
        _curIndexList.add(_index);
        final String _href = previews[_index].href;
        final GalleryPreview _imageFromApi = await GalleryPrecache.instance
            .paraImageLageInfoFromApi(_href, controller.showKey, index: _index);

        _url = _imageFromApi.largeImageUrl;

        _preview
          ..largeImageUrl = _url
          ..largeImageWidth = _imageFromApi.largeImageWidth
          ..largeImageHeight = _imageFromApi.largeImageHeight;
        _curIndexList.remove(_index);
      }

      _url = _preview.largeImageUrl;
      // logger.v('$_index : $_url');

      final Future<bool> _future = _map[_url] ??
          (() {
            // logger.d(' new _future $_url');
            _map[_url] = _precacheSingleImage(context, _url, _preview);
            // logger.d(' $_map');
            return _map[_url];
          })();

      _future
          .then((bool value) => _preview.isCache = value)
          .whenComplete(() => _map.remove(_url));
    }
  }

  Future<bool> _precacheSingleImage(
      BuildContext context, String url, GalleryPreview preview) async {
    final ImageProvider imageProvider = CachedNetworkImageProvider(url);

    /// 预缓存图片
    precacheImage(imageProvider, context).then((_) {
      preview.isCache = true;
      return true;
    }).catchError((e, stack) {
      logger.e('$e /n $stack');
      return false;
    });
    return false;
  }
}
