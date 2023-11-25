import 'dart:async';

import 'package:extended_image/extended_image.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/network/request.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

enum ViewColumnMode {
  // 双页 奇数页位于左边
  oddLeft,

  // 双页 偶数页位于左边
  evenLeft,

  // 单页
  single,
}

enum LoadFrom {
  gallery,
  download,
  archiver,
}

Map<String, bool> _throttles = {};

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
    return _instance!;
  }

  /// 单例对象
  static GalleryPara? _instance;

  final Set<int> _processingSerSet = <int>{};

  final Map<String, Future<GalleryImage?>> _map =
      <String, Future<GalleryImage?>>{};

  /// 一个很傻的预载功能 需要优化
  Stream<GalleryImage?> ehPrecacheImages({
    required Map<int, GalleryImage>? imageMap,
    required int itemSer,
    required int max,
    String? showKey,
  }) async* {
    if (imageMap == null) {
      return;
    }

    for (int add = 1; add < max + 1; add++) {
      final int _ser = itemSer + add;

      logger.t('开始预载 ser $_ser');

      if (_processingSerSet.contains(_ser)) {
        continue;
      }

      final GalleryImage? _imageTemp = imageMap[_ser];
      if (_imageTemp == null) {
        // yield null;
        continue;
      }

      GalleryImage _image = _imageTemp;

      if (_image.completeCache ?? false) {
        logger.t('ser $_ser 已预载完成 跳过');
        continue;
      }

      if (_image.startPrecache ?? false) {
        logger.t('ser $_ser 已开始预载 跳过');
        continue;
      }

      String _url = '';
      if (_image.imageUrl?.isEmpty ?? true) {
        if (showKey == null) {
          logger.d('showKey is null, skip precache');
          continue;
        }

        _processingSerSet.add(_ser);
        final String _href = imageMap[_ser]?.href ?? '';

        // paraImageLageInfoFromHtml
        // final GalleryImage? _imageFetch = await fetchImageInfo(_href);
        final GalleryImage? _imageFetch =
            await fetchImageInfoByApi(_href, showKey: showKey);

        _url = _imageFetch?.imageUrl ?? '';

        _image = _image.copyWith(
          imageUrl: _url,
          imageWidth: _imageFetch?.imageWidth,
          imageHeight: _imageFetch?.imageHeight,
          originImageUrl: _imageFetch?.originImageUrl,
          filename: _imageFetch?.filename,
          showKey: _imageFetch?.showKey,
        );

        _processingSerSet.remove(_ser);
      }

      _url = _image.imageUrl ?? '';

      if (_url.isEmpty) {
        // yield null;
        continue;
      }

      _map.putIfAbsent(_url, () => _precacheSingleImage(_url, _image));

      final Future<GalleryImage?>? _future = _map[_url];

      if (_future != null) {
        final GalleryImage? value = await _future;
        // logger.d('yield rult ser ${value?.ser}  ${value?.toJson()}');
        yield value?.copyWith(completeCache: true);
        _map.remove(_url);
        continue;
      }
    }
  }

  Future<GalleryImage?> _precacheSingleImage(
    String url,
    GalleryImage image,
  ) async {
    final ImageProvider imageProvider = ExtendedNetworkImageProvider(
      url,
      cache: true,
      retries: 5,
      timeLimit: const Duration(seconds: 5),
    );

    /// 预缓存图片
    try {
      await precacheImage(imageProvider, Get.context!);
      return image.copyWith(completeCache: true);
    } catch (e, stack) {
      logger.e('$e /n $stack');
      return null;
    }
  }
}

class CustomScrollPhysics extends BouncingScrollPhysics {
  const CustomScrollPhysics({ScrollPhysics? parent}) : super(parent: parent);

  @override
  CustomScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return CustomScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  SpringDescription get spring => SpringDescription.withDampingRatio(
        mass: 0.5,
        stiffness: 300.0, // Increase this value as you wish.
        ratio: 1.1,
      );
}
