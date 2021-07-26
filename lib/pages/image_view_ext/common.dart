import 'dart:async';

import 'package:extended_image/extended_image.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/network/gallery_request.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:fehviewer/generated/l10n.dart';

enum ViewColumnMode {
  // 双页 奇数页位于左边
  oddLeft,

  // 双页 偶数页位于左边
  evenLeft,

  // 单页
  single,
}

enum LoadType {
  network,
  file,
}

const Duration deFaultDurationTime = Duration(milliseconds: 300);
final Map<String, Timer?> debounceTimerMap = {};

// 防抖函数
void vDebounceM(
  Function? doSomething, {
  required String id,
  Duration durationTime = deFaultDurationTime,
}) {
  Timer? debounceTimer = debounceTimerMap[id];
  if (debounceTimer?.isActive ?? false) {
    logger.v('timer.cancel');
    debounceTimer?.cancel();
  }

  debounceTimer = Timer(durationTime, () {
    logger.v('func.call');
    doSomething?.call();
    debounceTimerMap[id] = null;
  });

  // debounceTimerMap.putIfAbsent(id, () => debounceTimer);
  debounceTimerMap[id] = debounceTimer;
}

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
  Stream<GalleryImage?> precacheImages(
    BuildContext context, {
    required Map<int, GalleryImage> imageMap,
    required int itemSer,
    required int max,
  }) async* {
    // logger.d('当前index $index');
    for (int add = 1; add < max + 1; add++) {
      final int _ser = itemSer + add;

      logger.v('开始预载 ser $_ser');

      if (_processingSerSet.contains(_ser)) {
        continue;
      }

      final GalleryImage? _imageTemp = imageMap[_ser];
      if (_imageTemp == null) {
        yield null;
        return;
      }

      GalleryImage _image = _imageTemp;

      if (_image.isCache ?? false) {
        logger.v('ser $_ser 已存在预载中 跳过');
        continue;
      }

      if (_image.startPrecache ?? false) {
        logger.v('ser $_ser 已开始预载 跳过');
        continue;
      }

      String _url = '';
      if (_image.imageUrl?.isEmpty ?? true) {
        _processingSerSet.add(_ser);
        final String _href = imageMap[_ser]?.href ?? '';

        // paraImageLageInfoFromHtml
        final GalleryImage _imageFromApi =
            await Api.fetchImageInfo(_href, ser: _ser);

        _url = _imageFromApi.imageUrl ?? '';

        _image = _image.copyWith(
          imageUrl: _url,
          imageWidth: _imageFromApi.imageWidth,
          imageHeight: _imageFromApi.imageHeight,
        );

        _processingSerSet.remove(_ser);
      }

      _url = _image.imageUrl ?? '';

      if (_url.isEmpty) {
        yield null;
        return;
      }

      final Future<GalleryImage?>? _future = _map[_url] ??
          (() {
            _map[_url] = _precacheSingleImage(context, _url, _image);
            return _map[_url];
          })();

      if (_future != null) {
        final GalleryImage? value = await _future;
        // logger.d('yield rult ser ${value?.ser}  ${value?.toJson()}');
        yield value?.copyWith(isCache: true);
        _map.remove(_url);
      }
    }
  }

  Future<GalleryImage?> _precacheSingleImage(
    BuildContext context,
    String url,
    GalleryImage image,
  ) async {
    final ImageProvider imageProvider = ExtendedNetworkImageProvider(
      url,
      cache: true,
    );

    /// 预缓存图片
    try {
      await precacheImage(imageProvider, context);
      return image.copyWith(isCache: true);
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
