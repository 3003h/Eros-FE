import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:extended_image/extended_image.dart';
import 'package:fehviewer/common/service/depth_service.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/network/gallery_request.dart';
import 'package:fehviewer/pages/gallery_main/controller/gallery_page_controller.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';

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
  // Future<GalleryPreview> _future;
  final CancelToken _getMoreCancelToken = CancelToken();

  GalleryPageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController =
        Get.find(tag: '${Get.find<DepthService>().pageCtrlDepth}');
    // _future = _pageController.getImageInfo(widget.index,
    //     cancelToken: _getMoreCancelToken);
  }

  @override
  void dispose() {
    super.dispose();
    // _getMoreCancelToken.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final GalleryPreview _currentPreview =
        _pageController.galleryItem.galleryPreview[widget.index];

    return FutureBuilder<GalleryPreview>(
      future: _pageController.getImageInfo(widget.index,
          cancelToken: _getMoreCancelToken),
      builder: (_, AsyncSnapshot<GalleryPreview> previewFromApi) {
        if (_currentPreview.largeImageUrl == null ||
            _currentPreview.largeImageHeight == null) {
          if (previewFromApi.connectionState == ConnectionState.done) {
            if (previewFromApi.hasError) {
              // todo 加载异常
              logger.e(' ${previewFromApi.error}');
              return Center(child: Text('Error: ${previewFromApi.error}'));
            } else {
              _currentPreview.largeImageUrl = previewFromApi.data.largeImageUrl;
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
          // 返回图片组件
          final String url = _currentPreview.largeImageUrl;
          return _buildImage(url);
        }
      },
    );
  }

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
              fadeInDuration: const Duration(milliseconds: 0),
              fadeOutDuration: const Duration(milliseconds: 0),
              progressIndicatorBuilder: (context, url, downloadProgress) {
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
                          valueColor: const AlwaysStoppedAnimation<Color>(
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
}

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

Future<void> showShareActionSheet(BuildContext context, String imageUrl) {
  return showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) {
        final CupertinoActionSheet dialog = CupertinoActionSheet(
          // title: const Text('分享方式'),
          cancelButton: CupertinoActionSheetAction(
              onPressed: () {
                Get.back();
              },
              child: const Text('取消')),
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
