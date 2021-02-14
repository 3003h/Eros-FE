import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:extended_image/extended_image.dart';
import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/common/service/depth_service.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/models/base/eh_models.dart';
import 'package:fehviewer/pages/gallery/controller/gallery_page_controller.dart';
import 'package:fehviewer/pages/image_view/controller/view_controller.dart';
import 'package:fehviewer/pages/image_view/view/view_widget.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';

class ViewImage extends StatefulWidget {
  const ViewImage({Key key, this.index, this.fade = true}) : super(key: key);
  final int index;
  final bool fade;

  @override
  _ViewImageState createState() => _ViewImageState();
}

class _ViewImageState extends State<ViewImage>
    with SingleTickerProviderStateMixin {
  Future<GalleryPreview> _imageFuture;
  AnimationController _animationController;

  final GalleryPageController _pageController = Get.find(tag: pageCtrlDepth);
  final CancelToken _getMoreCancelToken = CancelToken();

  ViewController get controller => Get.find();

  /// 拉取图片信息
  Future<GalleryPreview> fetchImage(
    int itemIndex, {
    bool refresh,
    bool changeSource = false,
  }) async {
    final int ser = itemIndex + 1;
    final GalleryPreview tPreview = _pageController.previewMap[ser];
    if (tPreview == null) {
      logger.v('idx:$itemIndex 所在页尚未获取， 开始获取');

      // 直接获取需要的
      await _pageController.loadPriviewsWhereIndex(itemIndex);

      // 依次按顺序获取缩略图对象
      // await _pageController.loadPriviewUntilIndex(itemIndex);
    }

    final GalleryPreview preview = await _pageController.getImageInfo(
      widget.index,
      cancelToken: _getMoreCancelToken,
      refresh: refresh,
      changeSource: changeSource,
    );
    return preview;
  }

  /// 重载图片数据，重构部件
  Future<void> _reloadImage({bool changeSource = true}) async {
    final GalleryPreview _currentPreview =
        _pageController.galleryItem.galleryPreview[widget.index];
    // 清除CachedNetworkImage的缓存
    try {
      await CachedNetworkImage.evictFromCache(
          _currentPreview.largeImageUrl ?? '');
    } catch (_) {}

    _currentPreview.largeImageUrl = null;

    setState(() {
      // 换源重载
      _imageFuture = fetchImage(
        widget.index,
        refresh: true,
        changeSource: changeSource,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    // _imageFuture = fetchImage(widget.index);
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.fade ? 200 : 0),
    );

    Get.find<ViewController>().vState.fade = true;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // logger.v('_ViewImageState ${widget.index}');
    _imageFuture = fetchImage(widget.index);

    return GestureDetector(
      onLongPress: () async {
        logger.d('long press');
        final GalleryPreview _currentPreview = await _imageFuture;
        showImageSheet(context, _currentPreview.largeImageUrl, _reloadImage);
      },
      child: FutureBuilder<GalleryPreview>(
          future: _imageFuture,
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
              case ConnectionState.active:
                return LoadingWidget(index: widget.index);
                break;
              case ConnectionState.done:
                if (snapshot.hasError) {
                  String _errInfo = '';
                  if (snapshot.error is DioError) {
                    final DioError dioErr = snapshot.error as DioError;
                    logger.e('${dioErr.error}');
                    _errInfo = dioErr.type.toString();
                  } else {
                    _errInfo = snapshot.error.toString();
                  }
                  return ErrorWidget(index: widget.index, errInfo: _errInfo);
                } else {
                  final GalleryPreview preview = snapshot.data;
                  return Container(
                    alignment: Alignment.center,
                    child: Stack(
                      children: [
                        ImageExtend(
                          url: preview.largeImageUrl,
                          index: widget.index,
                          animationController: _animationController,
                          reloadImage: _reloadImage,
                        ),
                        if (Global.inDebugMode)
                          Text('${preview.ser}',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color:
                                      CupertinoColors.secondarySystemBackground,
                                  shadows: <Shadow>[
                                    Shadow(
                                      color: Colors.black,
                                      offset: Offset(1, 1),
                                      blurRadius: 2,
                                    )
                                  ])),
                      ],
                    ),
                  );
                }
                break;
              default:
                return Container();
            }
          }),
    );
  }
}

class ImageExtend extends StatelessWidget {
  const ImageExtend(
      {Key key,
      this.url,
      this.index,
      this.animationController,
      this.reloadImage})
      : super(key: key);

  final String url;
  final int index;
  final AnimationController animationController;
  final VoidCallback reloadImage;

  @override
  Widget build(BuildContext context) {
    return ExtendedImage.network(
      url ?? '',
      fit: BoxFit.contain,
      handleLoadingProgress: true,
      clearMemoryCacheIfFailed: true,
      timeLimit: const Duration(seconds: 10),
      loadStateChanged: (ExtendedImageState state) {
        switch (state.extendedImageLoadState) {
          case LoadState.loading:
            animationController.reset();
            final loadingProgress = state.loadingProgress;
            final progress = loadingProgress?.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes
                : null;

            // logger.v('$progress');

            // 下载进度回调
            return UnconstrainedBox(
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: context.mediaQueryShortestSide,
                  minWidth: context.width / 2,
                ),
                alignment: Alignment.center,
                // margin: const EdgeInsets.symmetric(vertical: 50, horizontal: 50),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      height: 70,
                      width: 70,
                      child: LiquidCircularProgressIndicator(
                        value: progress ?? 0.0,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            Color.fromARGB(255, 163, 199, 100)),
                        backgroundColor: const Color.fromARGB(255, 50, 50, 50),
                        // borderColor: Colors.teal[900],
                        // borderWidth: 2.0,
                        direction: Axis.vertical,
                        center: progress != null
                            ? Text(
                                '${(progress ?? 0) * 100 ~/ 1}%',
                                style: TextStyle(
                                  color: progress < 0.5
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
                        '${index + 1}',
                        style: const TextStyle(
                          color: CupertinoColors.systemGrey6,
                          height: 1,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
            break;

          ///if you don't want override completed widget
          ///please return null or state.completedWidget
          //return null;
          //return state.completedWidget;
          case LoadState.completed:
            animationController.forward();
            return FadeTransition(
              opacity: animationController,
              child: ExtendedRawImage(
                image: state.extendedImageInfo?.image,
              ),
            );

            break;
          case LoadState.failed:
            logger.d('Failed $url');
            animationController.reset();
            return Container(
              alignment: Alignment.center,
              constraints: BoxConstraints(
                maxHeight: context.width * 0.8,
              ),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error,
                      size: 50,
                      color: Colors.red,
                    ),
                    const Text(
                      'Load image failed',
                      style: TextStyle(
                          fontSize: 10,
                          color: CupertinoColors.secondarySystemBackground),
                    ),
                    Text(
                      '${index + 1}',
                      style: const TextStyle(
                          color: CupertinoColors.secondarySystemBackground),
                    ),
                  ],
                ),
                onTap: () {
                  // state.reLoadImage();
                  reloadImage();
                },
              ),
            );
            break;
          default:
            return null;
        }
      },
    );
  }
}

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({Key key, this.index}) : super(key: key);
  final int index;

  @override
  Widget build(BuildContext context) {
    return UnconstrainedBox(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: context.mediaQueryShortestSide,
          minWidth: context.width / 2,
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              '${index + 1}',
              style: const TextStyle(
                fontSize: 50,
                color: CupertinoColors.systemGrey6,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const CupertinoActivityIndicator(),
                const SizedBox(width: 5),
                Text(
                  '${S.of(context).loading}...',
                  style: const TextStyle(
                    color: CupertinoColors.systemGrey6,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ErrorWidget extends StatelessWidget {
  const ErrorWidget({Key key, this.index, this.errInfo}) : super(key: key);
  final int index;
  final String errInfo;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      constraints: BoxConstraints(
        maxHeight: context.width * 0.8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error,
            size: 50,
            color: Colors.red,
          ),
          Text(
            errInfo,
            style: const TextStyle(
                fontSize: 10, color: CupertinoColors.secondarySystemBackground),
          ),
          Text(
            '${index + 1}',
            style: const TextStyle(
                color: CupertinoColors.secondarySystemBackground),
          ),
        ],
      ),
    );
  }
}
