import 'package:extended_image/extended_image.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/network/gallery_request.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class GalleryPara {
  /// 内部构造方法，可避免外部暴露构造函数，进行实例化
  GalleryPara._internal();

  /// 工厂构造方法，这里使用命名构造函数方式进行声明
  factory GalleryPara.getInstance() => _getInstance();

  static GalleryPara get instance => _getInstance();

  /// 获取单例内部方法
  static GalleryPara _getInstance() {
    // 只能有一个实例
    _instance ??= GalleryPara._internal();
    return _instance;
  }

  /// 单例对象
  static GalleryPara _instance;

  final Set<int> _processingSerSet = <int>{};

  final Map<String, Future<bool>> _map = <String, Future<bool>>{};

  /// 一个很傻的预载功能 需要优化
  Future<void> precacheImages(
    BuildContext context, {
    @required Map<int, GalleryPreview> previewMap,
    @required int itemSer,
    @required int max,
  }) async {
    // logger.d('当前index $index');
    for (int add = 1; add < max + 1; add++) {
      final int _ser = itemSer + add;

      // logger.d('开始缓存 ser $ser');
      if (previewMap[_ser] == null) {
        return;
      }

      if (_processingSerSet.contains(_ser)) {
        continue;
      }

      final GalleryPreview _preview = previewMap[_ser];
      if (_preview?.isCache ?? false) {
        // logger.d('ser $ser 已存在缓存中 跳过');
        continue;
      }

      if (_preview?.startPrecache ?? false) {
        logger.d('ser $_ser 已开始缓存 跳过');
        continue;
      }

      String _url = '';
      if (_preview.largeImageUrl?.isEmpty ?? true) {
        _processingSerSet.add(_ser);
        final String _href = previewMap[_ser].href;

        // paraImageLageInfoFromHtml
        final GalleryPreview _imageFromApi =
            await Api.ftchImageInfo(_href, ser: _ser);

        _url = _imageFromApi.largeImageUrl;

        _preview
          ..largeImageUrl = _url
          ..largeImageWidth = _imageFromApi.largeImageWidth
          ..largeImageHeight = _imageFromApi.largeImageHeight;
        _processingSerSet.remove(_ser);
      }

      _url = _preview.largeImageUrl;
      // logger.v('$ser : $_url');

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
    // final ImageProvider imageProvider = CachedNetworkImageProvider(url);
    final ImageProvider imageProvider = ExtendedNetworkImageProvider(
      url,
      cache: true,
    );

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
