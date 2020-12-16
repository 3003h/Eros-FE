import 'dart:io';

import 'package:FEhViewer/common/controller/ehconfig_controller.dart';
import 'package:FEhViewer/models/index.dart';
import 'package:FEhViewer/models/states/gallery_cache_model.dart';
import 'package:FEhViewer/models/states/gallery_model.dart';
import 'package:FEhViewer/pages/gallery_detail/gallery_detail_widget.dart';
import 'package:FEhViewer/route/routes.dart';
import 'package:FEhViewer/utils/logger.dart';
import 'package:FEhViewer/utils/toast.dart';
import 'package:FEhViewer/utils/utility.dart';
import 'package:FEhViewer/values/const.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:provider/provider.dart';

import 'gallery_view_base.dart';

const double kBottomBarHeight = 44.0;
const double kTopBarHeight = 40.0;

class GalleryViewPage extends StatefulWidget {
  const GalleryViewPage({Key key, int index})
      : index = index ?? 0,
        super(key: key);

  final int index;

  @override
  _GalleryViewPageState createState() => _GalleryViewPageState();
}

class _GalleryViewPageState extends State<GalleryViewPage> {
  // with AutomaticKeepAliveClientMixin {
  int _currentIndex;
  GalleryModel _galleryModel;
  GalleryCacheModel _galleryCacheModel;
  double _sliderValue;

  bool _showBar;

  double _bottomBarOffset;
  double _realPaddingBottom;
  double _bottomBarWidth;

  double _topBarOffset;
  double _realPaddingTop;
  double _topBarWidth;

  Size _screensize;
  double _paddingLeft;
  double _paddingRight;
  double _paddingTop;
  double _paddingBottom;

  final GlobalKey _centkey = GlobalKey();

  PageController _pageController;

  Future<GalleryPreview> _futureViewGallery;

  final EhConfigController ehConfigController = Get.find();

  @override
  void initState() {
    super.initState();
    _currentIndex = 0;
    _bottomBarOffset = 0;
    _topBarOffset = 0;
    _showBar = false;
    logger.d('_index ${widget.index}');
    _pageController =
        PageController(initialPage: widget.index, viewportFraction: 1.1);
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final GalleryModel galleryModel =
        Provider.of<GalleryModel>(context, listen: false);
    final GalleryCacheModel galleryCacheModel =
        Provider.of<GalleryCacheModel>(context, listen: false);

    if (galleryModel != _galleryModel) {
      _galleryModel = galleryModel;
      _galleryCacheModel = galleryCacheModel;

      final int preload = ehConfigController.preloadImage.value;
      if (ehConfigController.viewMode.value != ViewMode.vertical) {
        // 预载后面5张图
        logger.v('预载后面 $preload 张图 didChangeDependencies');
        GalleryPrecache.instance.precacheImages(
          context,
          _galleryModel,
          previews: _galleryModel.previews,
          index: widget.index,
          max: preload,
        );
      }
    }
    _currentIndex = widget.index;
    Future<void>.delayed(const Duration(milliseconds: 100)).then((_) {
      _galleryCacheModel.setIndex(_galleryModel.galleryItem.gid, _currentIndex,
          notify: false);
    });
    _sliderValue = _currentIndex / 1.0;
    _futureViewGallery = _getImageInfo();
  }

  Future<GalleryPreview> _getImageInfo() async {
    return GalleryUtil.getImageInfo(_galleryModel, _currentIndex);
  }

  void _initSize(BuildContext context) {
    final MediaQueryData _mq = MediaQuery.of(context);
    _screensize = _mq.size;
    _paddingLeft = _mq.padding.left;
    _paddingRight = _mq.padding.right;
    _paddingTop = _mq.padding.top;
    _paddingBottom = _mq.padding.bottom;

    // 底栏底部距离
    _realPaddingBottom =
        Platform.isAndroid ? 20 + _paddingBottom : _paddingBottom;

    // 底栏有效宽度
    // _bottomBarWidth = _screensize.width - _paddingLeft - _paddingRight;

    // 底栏隐藏时偏移
    final double _offsetBottomHide = _realPaddingBottom + kBottomBarHeight;

    // 底栏显示隐藏切换
    _bottomBarOffset = _showBar ? 0 : -_offsetBottomHide - 10;

    // 顶栏边距
    _realPaddingTop = _paddingTop;

    // 顶栏隐藏时偏移
    final double _offsetTopHide = kTopBarHeight + _paddingTop;
    _topBarOffset = _showBar ? 0 : -_offsetTopHide - 10;
  }

  /// 画廊图片大图浏览
  @override
  Widget build(BuildContext context) {
    // super.build(context);

    _initSize(context);

    return _buildPage(_screensize);
  }

  void _handOnChangedEnd(double value) {
    logger.d('to $value');
    // if (widget.pageController.hasClients) {
    //   widget.pageController.jumpToPage(value ~/ 1);
    // }
    final int _index = value ~/ 1;
    showLoadingDialog(context, _index).then((_) {
      _galleryCacheModel.setIndex(_galleryModel.galleryItem.gid, _index);
      _pageController.jumpToPage(_index);
    });
    // _galleryCacheModel.setIndex(_galleryModel.galleryItem.gid, _index);
    // _pageController.jumpToPage(_index);
  }

  void _handOnChanged(double value) {
    setState(() {
      _sliderValue = value;
    });
  }

  // 页面
  Widget _buildPage(Size _screensize) {
    return CupertinoTheme(
      data: const CupertinoThemeData(
        brightness: Brightness.dark,
        // barBackgroundColor: CupertinoColors.white,
      ),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: CupertinoPageScaffold(
          child: Selector<GalleryModel, int>(
              selector: (context, galleryModel) => galleryModel.previews.length,
              shouldRebuild: (pre, next) {
                // logger.v('${pre}  ${next}');
                return pre != next && next > pre;
              },
              builder: (context, int len, child) {
                // logger.d('CupertinoPageScaffold build');
                return Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    // 内容部件
                    _buildView(),
                    // 外沿触摸区
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      child: Container(),
                      onPanDown: (DragDownDetails details) {
                        final Rect _centRect =
                            WidgetUtil.getWidgetGlobalRect(_centkey);

                        final double _dx = details.globalPosition.dx;
                        final double _dy = details.globalPosition.dy;
                        // logger.d(
                        //     'onPanDown ${details.globalPosition}  $_centRect');
                        if ((_dx < _centRect.left || _dx > _centRect.right) &&
                            (_dy < _centRect.top || _dy > _centRect.bottom)) {
                          logger.d('onPanDown hide bar');
                          setState(() {
                            _showBar = false;
                          });
                        }
                      },
                      onPanStart: (DragStartDetails details) {
                        logger.d('${details.localPosition} ');
                      },
                    ),
                    // 中心触摸区
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      child: Container(
                        key: _centkey,
                        height: _screensize.height / 4,
                        width: _screensize.width / 2.5,
                      ),
                      onTap: () {
                        setState(() {
                          _showBar = !_showBar;
                        });
                      },
                    ),
                    SafeArea(
                      bottom: false,
                      top: false,
                      left: false,
                      right: false,
                      child: Stack(
                        fit: StackFit.expand,
                        alignment: Alignment.center,
                        children: <Widget>[
                          // 顶栏
                          AnimatedPositioned(
                            curve: Curves.fastOutSlowIn,
                            duration: const Duration(milliseconds: 300),
                            top: _topBarOffset,
                            child: _buildTopBar(context),
                          ),
                          // 底栏
                          AnimatedPositioned(
                            curve: Curves.fastOutSlowIn,
                            duration: const Duration(milliseconds: 300),
                            bottom: _bottomBarOffset,
                            child: _buildBottomBar(),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }),
        ),
      ),
    );
  }

  Widget _buildView() {
    return Obx(() {
      switch (ehConfigController.viewMode.value) {
        case ViewMode.vertical:
          return _buildListView();
        case ViewMode.horizontalLeft:
          return _buildPhotoViewGallery();
        case ViewMode.horizontalRight:
          return _buildPhotoViewGallery(reverse: true);
        default:
          return _buildPhotoViewGallery();
      }
    });
  }

  /// 顶栏
  Widget _buildTopBar(BuildContext context) {
    final List<GalleryPreview> previews = _galleryModel.previews;
    return Container(
        height: kTopBarHeight + _paddingTop,
        width: _screensize.width,
        color: const Color.fromARGB(150, 0, 0, 0),
        padding: EdgeInsets.fromLTRB(
          _paddingLeft,
          _realPaddingTop,
          _paddingRight,
          4.0,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Text(
              '${_currentIndex + 1}/${_galleryModel.galleryItem.filecount}',
              style: const TextStyle(
                color: CupertinoColors.systemGrey6,
                // shadows: <Shadow>[
                //   Shadow(
                //     color: Colors.black,
                //     offset: Offset(1, 1),
                //     blurRadius: 2,
                //   )
                // ],
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    logger.v('back');
                    Get.back();
                  },
                  child: Container(
                    width: 40,
                    height: kBottomBarHeight,
                    child: const Icon(
                      FontAwesomeIcons.chevronLeft,
                      color: CupertinoColors.systemGrey6,
                      // size: 24,
                    ),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    logger.v('tap share');
                    _showShareDialog(
                        context, previews[_currentIndex].largeImageUrl);
                  },
                  child: Container(
                    width: 40,
                    height: kBottomBarHeight,
                    child: const Icon(
                      FontAwesomeIcons.share,
                      color: CupertinoColors.systemGrey6,
                      // size: 24,
                    ),
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    logger.v('menu');
                    Get.toNamed(EHRoutes.viewSeting);
                  },
                  child: Container(
                    width: 40,
                    margin: const EdgeInsets.only(right: 8.0),
                    height: kBottomBarHeight,
                    child: const Icon(
                      FontAwesomeIcons.ellipsisH,
                      color: CupertinoColors.systemGrey6,
                      // size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ));
  }

  /// 底栏
  Widget _buildBottomBar() {
    final double _max = int.parse(_galleryModel.galleryItem.filecount) - 1.0;
    return Container(
      color: const Color.fromARGB(150, 0, 0, 0),
      padding: EdgeInsets.only(
        bottom: _realPaddingBottom,
        left: _paddingLeft,
        right: _paddingRight,
      ),
      width: _screensize.width,
      height: kBottomBarHeight + _paddingBottom,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: PageSlider(
                max: _max,
                sliderValue: _sliderValue,
                onChangedEnd: _handOnChangedEnd,
                onChanged: _handOnChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /*Widget _buildExtendedImageGesturePageView() {
    final List<GalleryPreview> previews = _galleryModel.previews;
    return ExtendedImageGesturePageView.builder(
      itemBuilder: (BuildContext context, int index) {
        final Widget image = GalleryImage(index: index);
        if (index == _currentIndex) {
          return Hero(
            tag: previews[index].href + index.toString(),
            child: image,
          );
        } else {
          return image;
        }
      },
      itemCount: previews.length,
      onPageChanged: (int index) {
        // 预载
        GalleryPrecache.instance.precache(
          context,
          _galleryModel,
          previews: _galleryModel.previews,
          index: index,
          max: 5,
        );
        setState(() {
          _currentIndex = index;
        });
      },
      controller: widget.pageController,
      scrollDirection: Axis.horizontal,
    );
  }*/

  /// 竖直浏览布局  TODO 还没有实现
  Widget _buildListView() {
    return ListView.custom(
      childrenDelegate: ViewChildBuilderDelegate(
        (BuildContext context, int index) {
          return ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: double.infinity, //宽度尽可能大
              minHeight: 200.0, //最小高度
            ),
            child: FutureBuilder<GalleryPreview>(
                future: _futureViewGallery,
                builder: (BuildContext context,
                    AsyncSnapshot<GalleryPreview> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasError) {
                      return Container();
                    } else {
                      logger.d(
                          ' h: ${snapshot.data.largeImageHeight}  w: ${snapshot.data.largeImageWidth}  ${snapshot.data.largeImageWidth / _screensize.width}');
                      return Container(
                          // height: snapshot.data.largeImageHeight *
                          //     (snapshot.data.largeImageWidth /
                          //         _screensize.width),
                          // width: _screensize.width,
                          height: snapshot.data.largeImageHeight /
                              (snapshot.data.largeImageWidth /
                                  _screensize.width),
                          // width: snapshot.data.largeImageWidth,
                          child: GalleryImage(index: index));
                    }
                  } else {
                    return Container(
                      alignment: Alignment.center,
                      child: const CupertinoActivityIndicator(
                        radius: 20,
                      ),
                    );
                  }
                }),
          );
        },
        childCount: _galleryModel.previews.length,
      ),
      cacheExtent: 0.0,
    );

    /*return ListView.builder(
      itemBuilder: (BuildContext context, int index) {
        return ConstrainedBox(
          child: GalleryImage(index: index),
          constraints: const BoxConstraints(
              minWidth: double.infinity, //宽度尽可能大
              minHeight: 200.0 //最小高度
              ),
        );
      },
      itemCount: _galleryModel.previews.length,
    );*/
  }

  /// 水平方向浏览部件
  Widget _buildPhotoViewGallery({bool reverse = false}) {
    double _maxScale = 10;
    // logger.d('preview ${preview.data.toJson()}');
    // final double _width = preview.data.largeImageWidth;
    // final double _height = preview.data.largeImageHeight;
    //
    // if (_height / _width > _size.height / _size.width) {
    //   // 计算缩放到屏幕宽度一致时，图片的高
    //   final double _tempHeight = _height * _size.width / _width;
    //   logger.d('_tempHeight $_tempHeight');
    //   _maxScale = _tempHeight / _size.height;
    // }
    // logger.d(' $_maxScale');

    return PhotoViewGallery.builder(
      // scrollPhysics: const BouncingScrollPhysics(),
      reverse: reverse,
      itemCount: _galleryModel.previews.length,
      customSize: _screensize,
      backgroundDecoration: const BoxDecoration(
        color: null,
      ),
      builder: (BuildContext context, int index) {
        return PhotoViewGalleryPageOptions.customChild(
          child: GalleryImage(
            index: index,
          ),
          initialScale: PhotoViewComputedScale.covered,
          minScale: PhotoViewComputedScale.contained * 1.0,
          maxScale: PhotoViewComputedScale.covered * _maxScale,
        );
      },
      loadingBuilder: (BuildContext context, progress) {
        return progress != null
            ? Container(
                child: Center(
                  child: Text(
                    '${progress.cumulativeBytesLoaded * 100 ~/ progress.expectedTotalBytes} %',
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            : Container(
                child: Center(
                  child: Text(
                    '获取中 ${_currentIndex + 1}',
                    style: const TextStyle(
//                          color: Colors.white,
                        ),
                  ),
                ),
              );
      },
      // backgroundDecoration: null,
      pageController: _pageController,
      enableRotation: false,
      // 旋转
      onPageChanged: (int index) {
//            logger.v('onPageChanged');
        GalleryPrecache.instance.precacheImages(
          context,
          _galleryModel,
          previews: _galleryModel.previews,
          index: index,
          max: ehConfigController.preloadImage.value,
        );
        _currentIndex = index;
        _sliderValue = _currentIndex / 1.0;
        _galleryCacheModel.setIndex(
            _galleryModel.galleryItem.gid, _currentIndex);
        setState(() {});
      },
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
            '${widget.sliderValue ~/ 1 + 1}',
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
            '${widget.max ~/ 1 + 1}',
            style: const TextStyle(color: CupertinoColors.systemGrey6),
          ),
        ],
      ),
    );
  }
}

/// ShareDialog
Future<void> _showShareDialog(BuildContext context, String imageUrl) {
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
