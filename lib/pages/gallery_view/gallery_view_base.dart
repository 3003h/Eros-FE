import 'dart:convert';

import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/models/index.dart';
import 'package:FEhViewer/models/states/gallery_model.dart';
import 'package:FEhViewer/utils/https_proxy.dart';
import 'package:FEhViewer/utils/utility.dart';
import 'package:dio/dio.dart';
import 'package:extended_image/extended_image.dart';
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

  /// 由api获取画廊图片的url
  /// [href] 爬取的页面地址 用来解析gid 和 imgkey
  /// [showKey] api必须
  /// [index] 索引 从 1 开始
  Future<String> getImageLageUrl(String href, String showKey,
      {int index}) async {
    const String url = '/api.php';

    final String cookie = Global.profile?.user?.cookie ?? '';

    final Options options = Options(headers: {
      'Cookie': cookie,
    });

//    Global.logger.v('href = $href');

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

    // Global.logger.v('$reqJsonStr');

    await CustomHttpsProxy.instance.init();
    final Response response = await Api.getHttpManager().postForm(
      url,
      options: options,
      data: reqJsonStr,
    );

    // Global.logger.v('$response');

    final rultJson = jsonDecode('$response');

    final RegExp regImageUrl = RegExp('<img[^>]*src=\"([^\"]+)\" style');
    final imageUrl = regImageUrl.firstMatch(rultJson['i3']).group(1);

//    Global.logger.v('$imageUrl');

    return imageUrl;
  }

  // 一个很傻的预载功能 需要优化
  Future<void> precache(
    BuildContext context,
    GalleryModel galleryModel, {
    @required List<GalleryPreview> previews,
    @required int index,
    @required int max,
  }) async {
    // Global.loggerNoStack.d('当前index $index');
    for (int add = 1; add < max + 1; add++) {
      final int _index = index + add;

      // Global.loggerNoStack.d('开始缓存index $index');
      if (_index > galleryModel.previews.length - 1) {
        return;
      }

      if (_curIndexList.contains(_index)) {
        continue;
      }

      final GalleryPreview _preview = galleryModel.previews[_index];
      if (_preview?.isCache ?? false) {
        // Global.loggerNoStack.d('index $_index 已存在缓存中 continue');
        continue;
      }

      String _url = '';
      if (_preview.largeImageUrl?.isEmpty ?? true) {
        Global.logger.d('get $_index from Api');
        _curIndexList.add(_index);
        final String _href = previews[_index].href;
        _url = await GalleryPrecache.instance
            .getImageLageUrl(_href, galleryModel.showKey, index: _index);

        galleryModel.previews[_index].largeImageUrl = _url;
        _curIndexList.remove(_index);
      }

      _url = galleryModel.previews[_index].largeImageUrl;

      Global.logger.v('index : $_url');

      /// 预缓存图片
      precacheImage(
              ExtendedNetworkImageProvider(
                _url,
                cache: true,
                retries: 5,
              ),
              context)
          .then((_) {
        galleryModel.previews[_index].isCache = true;
      }).whenComplete(() {
        _curIndexList.remove(_index);
      });
    }
  }
}
