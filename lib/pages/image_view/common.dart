import 'dart:async';

import 'package:eros_fe/extension.dart';
import 'package:eros_fe/models/index.dart';
import 'package:eros_fe/network/request.dart';
import 'package:eros_fe/utils/logger.dart';
import 'package:extended_image/extended_image.dart';
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
      final int ser = itemSer + add;

      logger.t('开始预载 ser $ser');

      if (_processingSerSet.contains(ser)) {
        continue;
      }

      final GalleryImage? imageTemp = imageMap[ser];
      if (imageTemp == null) {
        // yield null;
        continue;
      }

      GalleryImage image = imageTemp;

      if (image.completeCache ?? false) {
        logger.t('ser $ser 已预载完成 跳过');
        continue;
      }

      if (image.startPrecache ?? false) {
        logger.t('ser $ser 已开始预载 跳过');
        continue;
      }

      String url = '';
      if (image.imageUrl?.isEmpty ?? true) {
        if (showKey == null) {
          logger.d('ser $ser, showKey is null, skip precache');
          continue;
        }

        _processingSerSet.add(ser);
        final String href = imageMap[ser]?.href ?? '';

        // paraImageLageInfoFromHtml
        final GalleryImage? imageFetch = await fetchImageInfoByHtml(href);
        // final GalleryImage? imageFetch =
        //     await fetchImageInfoByApi(href, showKey: showKey);

        url = imageFetch?.imageUrl ?? '';

        image = image.copyWith(
          imageUrl: url.oN,
          imageWidth: imageFetch?.imageWidth.oN,
          imageHeight: imageFetch?.imageHeight.oN,
          originImageUrl: imageFetch?.originImageUrl.oN,
          filename: imageFetch?.filename.oN,
          showKey: imageFetch?.showKey.oN,
        );

        _processingSerSet.remove(ser);
      }

      url = image.imageUrl ?? '';

      if (url.isEmpty) {
        // yield null;
        continue;
      }

      _map.putIfAbsent(url, () {
        logger.d('ser $ser, 开始预载图片 $url');
        return _precacheSingleImage(url, image);
      });

      final Future<GalleryImage?>? futureImage = _map[url];

      if (futureImage != null) {
        final GalleryImage? value = await futureImage;
        // logger.d('yield rult ser ${value?.ser}  ${value?.toJson()}');
        yield value?.copyWith(completeCache: true.oN);
        _map.remove(url);
        continue;
      }
    }
  }

  Future<GalleryImage?> _precacheSingleImage(
    String url,
    GalleryImage image,
  ) async {
    final cacheKey = image.getCacheKey(url);
    logger.d('_precacheSingleImage, 开始预载图片 $url,\ncacheKey: $cacheKey');
    final ImageProvider imageProvider = ExtendedNetworkImageProvider(
      url,
      cache: true,
      cacheKey: cacheKey,
      retries: 5,
      timeLimit: const Duration(seconds: 5),
    );

    /// 预缓存图片
    try {
      await precacheImage(imageProvider, Get.context!);
      logger.d('预载图片完成 $url');
      return image.copyWith(completeCache: true.oN);
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
