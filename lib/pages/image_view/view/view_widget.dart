import 'package:dio/dio.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/network/gallery_request.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/*class GalleryImage extends StatefulWidget {
  const GalleryImage({
    Key key,
    @required this.index,
    this.fade = true,
  }) : super(key: key);

  final int index;
  final bool fade;

  @override
  _GalleryImageState createState() => _GalleryImageState();
}

class _GalleryImageState extends State<GalleryImage>
    with SingleTickerProviderStateMixin {
  Future<GalleryPreview> _future;
  final CancelToken _getMoreCancelToken = CancelToken();

  AnimationController _controller;
  Animation _animation;

  GalleryPageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = Get.find(tag: pageCtrlDepth);

    // logger.v('${widget.fade}');

    _future = _pageController.getImageInfo(
      widget.index,
      cancelToken: _getMoreCancelToken,
    );

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.fade ? 200 : 0),
    );
    _animation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(_controller);

    Get.find<ViewController>().vState.fade = true;
  }

  @override
  void dispose() {
    clearGestureDetailsCache();
    _controller.dispose();
    // _getMoreCancelToken.cancel();
    super.dispose();
  }

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
      _future = _pageController.getImageInfo(
        widget.index,
        cancelToken: _getMoreCancelToken,
        refresh: true,
        changeSource: changeSource,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final GalleryPreview _currentPreview =
        _pageController.galleryItem.galleryPreview[widget.index];

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: () {
        logger.d('long press');

        showImageSheet(context, _currentPreview.largeImageUrl, _reloadImage);
      },
      child: FutureBuilder<GalleryPreview>(
        future: _future,
        builder: (_, AsyncSnapshot<GalleryPreview> previewFromApi) {
          if (_currentPreview.largeImageUrl == null ||
              _currentPreview.largeImageHeight == null) {
            if (previewFromApi.connectionState == ConnectionState.done) {
              String _errInfo = '';
              // 获取图片url等信息 异常
              if (previewFromApi.hasError) {
                logger.e(' ${previewFromApi.error}');
                if (previewFromApi.error is DioError) {
                  final DioError dioErr = previewFromApi.error as DioError;
                  logger.e('${dioErr.error}');

                  _errInfo = dioErr.type.toString();
                }
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
                        _errInfo,
                        style: const TextStyle(
                            fontSize: 10,
                            color: CupertinoColors.secondarySystemBackground),
                      ),
                      Text(
                        '${widget.index + 1}',
                        style: const TextStyle(
                            color: CupertinoColors.secondarySystemBackground),
                      ),
                    ],
                  ),
                );
              } else {
                // 更新状态 显示 CachedNetworkImage 组件
                _currentPreview.largeImageUrl =
                    previewFromApi.data.largeImageUrl;
                _currentPreview.largeImageHeight =
                    previewFromApi.data.largeImageHeight;
                _currentPreview.largeImageWidth =
                    previewFromApi.data.largeImageWidth;
                _currentPreview.sourceId = previewFromApi.data.sourceId;

                Future.delayed(const Duration(milliseconds: 100)).then((_) {
                  Get.find<ViewController>()
                      .update(['GalleryImage_${widget.index}']);
                });

                return _buildImageExtend(_currentPreview.largeImageUrl);
              }
            } else {
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
                        '${widget.index + 1}',
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
          } else {
            // 返回图片组件
            final String url = _currentPreview.largeImageUrl;
            return _buildImageExtend(url);
          }
        },
      ),
    );
  }

  Widget _buildImageExtend(String url) {
    return ExtendedImage.network(
      url ?? '',
      fit: BoxFit.contain,
      handleLoadingProgress: true,
      clearMemoryCacheIfFailed: true,
      timeLimit: const Duration(seconds: 10),
      loadStateChanged: (ExtendedImageState state) {
        switch (state.extendedImageLoadState) {
          case LoadState.loading:
            _controller.reset();
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
                        '${widget.index + 1}',
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
            _controller.forward();
            return FadeTransition(
              opacity: _controller,
              child: ExtendedRawImage(
                image: state.extendedImageInfo?.image,
              ),
            );

            break;
          case LoadState.failed:
            logger.d('Failed $url');
            _controller.reset();
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
                      '${widget.index + 1}',
                      style: const TextStyle(
                          color: CupertinoColors.secondarySystemBackground),
                    ),
                  ],
                ),
                onTap: () {
                  // state.reLoadImage();
                  _reloadImage();
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

  Widget _buildImage(String url) {
    return Container(
      child: CachedNetworkImage(
        imageUrl: url ?? '',
        fit: BoxFit.contain,
        fadeInDuration: const Duration(milliseconds: 100),
        fadeOutDuration: const Duration(milliseconds: 100),
        progressIndicatorBuilder: (context, url, downloadProgress) {
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
                      value: downloadProgress.progress ?? 0.0,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Color.fromARGB(255, 163, 199, 100)),
                      backgroundColor: const Color.fromARGB(255, 50, 50, 50),
                      // borderColor: Colors.teal[900],
                      // borderWidth: 2.0,
                      direction: Axis.vertical,
                      center: downloadProgress.progress != null
                          ? Text(
                              '${(downloadProgress.progress ?? 0) * 100 ~/ 1}%',
                              style: TextStyle(
                                color: downloadProgress.progress < 0.5
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
}*/

/// 页面滑条
class PageSlider extends StatefulWidget {
  const PageSlider({
    Key key,
    @required this.max,
    @required this.sliderValue,
    @required this.onChangedEnd,
    @required this.onChanged,
  }) : super(key: key);

  final double max;
  final double sliderValue;
  final ValueChanged<double> onChangedEnd;
  final ValueChanged<double> onChanged;

  @override
  _PageSliderState createState() => _PageSliderState();
}

class _PageSliderState extends State<PageSlider> {
  double _value;

  @override
  void initState() {
    super.initState();
    _value = widget.sliderValue;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _value = widget.sliderValue;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: <Widget>[
          Text(
            '${widget.sliderValue.round() + 1}',
            style: const TextStyle(color: CupertinoColors.systemGrey6),
          ),
          Expanded(
            child: CupertinoSlider(
                min: 0,
                max: widget.max,
                value: widget.sliderValue,
                onChanged: (double newValue) {
                  setState(() {
                    _value = newValue;
                  });
                  widget.onChanged(newValue);
                },
                onChangeEnd: (double newValue) {
                  widget.onChangedEnd(newValue);
                }),
          ),
          Text(
            '${widget.max.round() + 1}',
            style: const TextStyle(color: CupertinoColors.systemGrey6),
          ),
        ],
      ),
    );
  }
}

typedef DidFinishLayoutCallBack = dynamic Function(
    int firstIndex, int lastIndex);

class ViewChildBuilderDelegate extends SliverChildBuilderDelegate {
  ViewChildBuilderDelegate(
    Widget Function(BuildContext, int) builder, {
    int childCount,
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    this.onDidFinishLayout,
  }) : super(builder,
            childCount: childCount,
            addAutomaticKeepAlives: addAutomaticKeepAlives,
            addRepaintBoundaries: addRepaintBoundaries);

  final DidFinishLayoutCallBack onDidFinishLayout;

  @override
  void didFinishLayout(int firstIndex, int lastIndex) {
    onDidFinishLayout(firstIndex, lastIndex);
    // print('firstIndex: $firstIndex, lastIndex: $lastIndex');
  }
}

Future<void> showShareActionSheet(BuildContext context, String imageUrl) {
  return showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) {
        final CupertinoActionSheet dialog = CupertinoActionSheet(
          cancelButton: CupertinoActionSheetAction(
              onPressed: () {
                Get.back();
              },
              child: Text(S.of(context).cancel)),
          actions: <Widget>[
            CupertinoActionSheetAction(
                onPressed: () {
                  logger.v('保存到相册');
                  Api.saveImage(context, imageUrl).then((rult) {
                    Get.back();
                    if (rult != null && rult) {
                      showToast('保存成功');
                    }
                  }).catchError((e) {
                    showToast(e);
                  });
                },
                child: const Text('保存到相册')),
            CupertinoActionSheetAction(
                onPressed: () {
                  logger.v('系统分享');
                  Api.shareImage(imageUrl);
                },
                child: const Text('系统分享')),
          ],
        );
        return dialog;
      });
}

Future<void> showImageSheet(
    BuildContext context, String imageUrl, VoidCallback reload) {
  return showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) {
        final CupertinoActionSheet dialog = CupertinoActionSheet(
          cancelButton: CupertinoActionSheetAction(
              onPressed: () {
                Get.back();
              },
              child: Text(S.of(context).cancel)),
          actions: <Widget>[
            CupertinoActionSheetAction(
                onPressed: () {
                  reload();
                  Get.back();
                },
                child: Text(S.of(context).reload_image)),
            CupertinoActionSheetAction(
                onPressed: () {
                  Get.back();
                  showShareActionSheet(context, imageUrl);
                },
                child: Text(S.of(context).share_image)),
          ],
        );
        return dialog;
      });
}
