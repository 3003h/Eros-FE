import 'dart:convert';

import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/models/index.dart';
import 'package:FEhViewer/models/states/gallery_model.dart';
import 'package:FEhViewer/utils/https_proxy.dart';
import 'package:FEhViewer/utils/logger.dart';
import 'package:FEhViewer/utils/network/gallery_request.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:provider/provider.dart';

class GalleryUtil {
  static Future<void> getAllImageHref(GalleryModel galleryModel) async {
    if (galleryModel.isGetAllImageHref) {
      loggerNoStack.d(' isGetAllImageHref return');
      return;
    }
    galleryModel.isGetAllImageHref = true;
    final int _filecount = int.parse(galleryModel.galleryItem.filecount);

    // 获取画廊所有图片页面的href
    while (galleryModel.previews.length < _filecount) {
      galleryModel.currentPreviewPageAdd();

      final List<GalleryPreview> _moreGalleryPreviewList =
          await Api.getGalleryPreview(
        galleryModel.galleryItem.url,
        page: galleryModel.currentPreviewPage,
      );

      // 避免重复添加
      if (_moreGalleryPreviewList.first.ser > galleryModel.previews.last.ser) {
        galleryModel.addAllPreview(_moreGalleryPreviewList);
      }
    }
    galleryModel.isGetAllImageHref = false;
  }

  /// 获取当前页的图片地址 优先从_galleryModel中读取 为空再查询api获取
  static Future<GalleryPreview> getImageInfo(
      GalleryModel _galleryModel, int index) async {
    // 数据获取处理
    GalleryUtil.getAllImageHref(_galleryModel).catchError((e, stack) {
      logger.e('$e \n $stack');
    }).whenComplete(() {
      // logger.v('getAllImageHref Complete');
    });

    try {
      final GalleryPreview _curPreview =
          _galleryModel.galleryItem.galleryPreview[index];
      final String _largeImageUrl = _curPreview.largeImageUrl;
      if (_largeImageUrl != null &&
          _largeImageUrl.isNotEmpty &&
          _curPreview.largeImageHeight != null &&
          _curPreview.largeImageWidth != null) {
        return _galleryModel.galleryItem.galleryPreview[index];
      } else {
        final GalleryPreview _preview = await GalleryPrecache.instance
            .paraImageLageInfoFromApi(
                _galleryModel.galleryItem.galleryPreview[index].href,
                _galleryModel.showKey,
                index: index);
        return _preview;
      }
    } catch (e, stack) {
      logger.e('$e \n $stack');
      rethrow;
    }
  }
}

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
    GalleryModel galleryModel, {
    @required List<GalleryPreview> previews,
    @required int index,
    @required int max,
  }) async {
    // loggerNoStack.d('当前index $index');
    for (int add = 1; add < max + 1; add++) {
      final int _index = index + add;

      // loggerNoStack.d('开始缓存index $index');
      if (_index > galleryModel.previews.length - 1) {
        return;
      }

      if (_curIndexList.contains(_index)) {
        continue;
      }

      final GalleryPreview _preview = galleryModel.previews[_index];
      if (_preview?.isCache ?? false) {
        loggerNoStack.d('index $_index 已存在缓存中 跳过');
        continue;
      }

      if (_preview?.startPrecache ?? false) {
        loggerNoStack.d('index $_index 已开始缓存 跳过');
        continue;
      }

      String _url = '';
      if (_preview.largeImageUrl?.isEmpty ?? true) {
        logger.d('get $_index from Api');
        _curIndexList.add(_index);
        final String _href = previews[_index].href;
        final GalleryPreview _imageFromApi = await GalleryPrecache.instance
            .paraImageLageInfoFromApi(_href, galleryModel.showKey,
                index: _index);

        _url = _imageFromApi.largeImageUrl;

        _preview
          ..largeImageUrl = _url
          ..largeImageWidth = _imageFromApi.largeImageWidth
          ..largeImageHeight = _imageFromApi.largeImageHeight;
        // logger.d('index $_index\n'
        //     'largeImageHeight:${_preview.largeImageHeight}\n'
        //     'largeImageWidth:${_preview.largeImageWidth}');
        _curIndexList.remove(_index);
      }

      _url = _preview.largeImageUrl;
      logger.v('$_index : $_url');

      final Future<bool> _future = _map[_url] ??
          (() {
            // logger.d(' new _future $_url');
            _map[_url] = _precacheSingleImage(context, _url, _preview);
            logger.d(' $_map');
            return _map[_url];
          })();

      _future
          .then((bool value) => _preview.isCache = value)
          .whenComplete(() => _map.remove(_url));
    }
  }

  Future<bool> _precacheSingleImage(
      BuildContext context, String url, GalleryPreview preview) async {
    final ImageProvider imageProviderExt = ExtendedNetworkImageProvider(
      url,
      cache: true,
      retries: 5,
    );

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

class GalleryImage extends StatefulWidget {
  const GalleryImage({
    Key key,
    @required this.index,
    this.downloadComplete,
  }) : super(key: key);

  @override
  _GalleryImageState createState() => _GalleryImageState();
  final int index;
  final ValueChanged<bool> downloadComplete;
}

class _GalleryImageState extends State<GalleryImage> {
  GalleryModel _galleryModel;
  Future<GalleryPreview> _future;

  @override
  void initState() {
    super.initState();
    final GalleryModel galleryModel =
        Provider.of<GalleryModel>(context, listen: false);
    if (galleryModel != _galleryModel) {
      _galleryModel = galleryModel;
      _future = GalleryUtil.getImageInfo(_galleryModel, widget.index);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final GalleryModel galleryModel =
        Provider.of<GalleryModel>(context, listen: false);
    if (galleryModel != _galleryModel) {
      _galleryModel = galleryModel;
    }
  }

  @override
  Widget build(BuildContext context) {
    final GalleryPreview _currentPreview =
        _galleryModel.galleryItem.galleryPreview[widget.index];
    return FutureBuilder<GalleryPreview>(
        future: _future,
        builder: (_, AsyncSnapshot<GalleryPreview> previewFromApi) {
          Widget _buildImage(String url, {bool extendedImage = false}) {
            return Container(
              child: extendedImage
                  ? ExtendedImage.network(
                      url,
                      // height: previewFromApi.data.largeImageHeight,
                      // width: previewFromApi.data.largeImageWidth,
                      fit: BoxFit.contain,
                      mode: ExtendedImageMode.gesture,
                      cache: true,
                    )
                  : CachedNetworkImage(
                      imageUrl: url,
                      fit: BoxFit.contain,
                      progressIndicatorBuilder:
                          (context, url, downloadProgress) {
                        // 下载进度回调
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              // CircularProgressIndicator(
                              //     value: downloadProgress.progress),
                              Container(
                                height: 70,
                                width: 70,
                                child: LiquidCircularProgressIndicator(
                                  value: downloadProgress.progress ?? 0.0,
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                          Color.fromARGB(255, 163, 199, 100)),
                                  backgroundColor:
                                      const Color.fromARGB(255, 50, 50, 50),
                                  // borderColor: Colors.teal[900],
                                  // borderWidth: 2.0,
                                  direction: Axis.vertical,
                                  center: downloadProgress.progress != null
                                      ? Text(
                                          '${(downloadProgress.progress ?? 0) * 100 ~/ 1}%',
                                          style: TextStyle(
                                            color:
                                                downloadProgress.progress < 0.5
                                                    ? CupertinoColors.white
                                                    : CupertinoColors.black,
                                            fontSize: 12,
                                            height: 1,
                                          ),
                                        )
                                      : Container(),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Text(
                                  '${widget.index + 1}',
                                  style: const TextStyle(
                                    color: CupertinoColors.systemGrey6,
                                    height: 1,
                                  ),
                                ),
                              )
                            ],
                          ),
                        );
                      },
                      errorWidget: (context, url, error) => const Center(
                        child: Icon(
                          Icons.error,
                          size: 50,
                          color: Colors.red,
                        ),
                      ),
                    ),
            );
          }

          if (_currentPreview.largeImageUrl == null ||
              _currentPreview.largeImageHeight == null) {
            if (previewFromApi.connectionState == ConnectionState.done) {
              if (previewFromApi.hasError) {
                // todo 加载异常
                // showToast('Error: ${previewFromApi.error}');
                logger.e(' ${previewFromApi.error}');
                return Center(child: Text('Error: ${previewFromApi.error}'));
              } else {
                _currentPreview.largeImageUrl =
                    previewFromApi.data.largeImageUrl;
                return _buildImage(_currentPreview.largeImageUrl);
              }
            } else {
              return Center(
                child: Container(
                  height: 100,
                  child: Column(
                    children: <Widget>[
                      Text(
                        '${widget.index + 1}',
                        style: const TextStyle(
                          fontSize: 50,
                          color: CupertinoColors.systemGrey6,
                        ),
                      ),
                      const Text(
                        '获取中...',
                        style: TextStyle(
                          color: CupertinoColors.systemGrey6,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          } else {
            // 返回图片部件
            final String url = _currentPreview.largeImageUrl;
            return _buildImage(url);
          }
        });
  }
}

class ViewChildBuilderDelegate extends SliverChildBuilderDelegate {
  ViewChildBuilderDelegate(
    Widget Function(BuildContext, int) builder, {
    int childCount,
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
  }) : super(builder,
            childCount: childCount,
            addAutomaticKeepAlives: addAutomaticKeepAlives,
            addRepaintBoundaries: addRepaintBoundaries);

  @override
  void didFinishLayout(int firstIndex, int lastIndex) {
    print('firstIndex: $firstIndex, lastIndex: $lastIndex');
  }
}
