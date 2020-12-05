import 'dart:io';

import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/models/index.dart';
import 'package:FEhViewer/models/states/gallery_cache_model.dart';
import 'package:FEhViewer/models/states/gallery_model.dart';
import 'package:FEhViewer/route/navigator_util.dart';
import 'package:FEhViewer/utils/toast.dart';
import 'package:FEhViewer/utils/utility.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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

  Future<GalleryPreview> _futurePhotoViewGallery;

  @override
  void initState() {
    super.initState();
    _currentIndex = 0;
    _bottomBarOffset = 0;
    _topBarOffset = 0;
    _showBar = false;
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
      // 预载后面5张图
      Global.logger.v('预载后面5张图 didChangeDependencies');
      GalleryPrecache.instance.precacheImages(
        context,
        _galleryModel,
        previews: _galleryModel.previews,
        index: widget.index,
        max: 5,
      );
    }
    _currentIndex = widget.index;
    Future<void>.delayed(const Duration(milliseconds: 100)).then((_) {
      _galleryCacheModel.setIndex(_galleryModel.galleryItem.gid, _currentIndex,
          notify: false);
    });
    _sliderValue = _currentIndex / 1.0;
    _futurePhotoViewGallery = _getImageInfo();
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
    Global.logger.d('$value');
    // if (widget.pageController.hasClients) {
    //   widget.pageController.jumpToPage(value ~/ 1);
    // }
    final int _index = value ~/ 1;
    _galleryCacheModel.setIndex(_galleryModel.galleryItem.gid, _index);
    _pageController.jumpToPage(_index);
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
                Global.logger.v('${pre}  ${next}');
                return pre != next && next > pre;
              },
              builder: (context, int len, child) {
                // Global.logger.d('CupertinoPageScaffold build');
                return Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    // 内容部件
                    Container(
                      child: _buildPhotoViewGallery(),
                      // child: _buildListView(),
                    ),
                    // 外沿触摸区
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      child: Container(),
                      onPanDown: (DragDownDetails details) {
                        final Rect _centRect =
                            WidgetUtil.getWidgetGlobalRect(_centkey);

                        final double _dx = details.globalPosition.dx;
                        final double _dy = details.globalPosition.dy;
                        // Global.logger.d(
                        //     'onPanDown ${details.globalPosition}  $_centRect');
                        if ((_dx < _centRect.left || _dx > _centRect.right) &&
                            (_dy < _centRect.top || _dy > _centRect.bottom)) {
                          Global.logger.d('onPanDown hide bar');
                          setState(() {
                            _showBar = false;
                          });
                        }
                      },
                      onPanStart: (DragStartDetails details) {
                        Global.logger.d('${details.localPosition} ');
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
                    Global.logger.v('back');
                    NavigatorUtil.goBack(context);
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
                    Global.logger.v('tap share');
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
                    Global.logger.v('menu');
                    // NavigatorUtil.goBack(context);
                  },
                  child: Container(
                    width: 40,
                    margin: const EdgeInsets.only(right: 8.0),
                    height: kBottomBarHeight,
                    child: const Icon(
                      FontAwesomeIcons.listUl,
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

  /// 竖直浏览布局
  Widget _buildListView() {
    return ListView.builder(
      itemBuilder: (BuildContext context, int index) {
        return GalleryImage(index: index);
      },
      itemCount: _galleryModel.previews.length,
    );
  }

  /// 水平方向浏览部件
  Widget _buildPhotoViewGallery() {
    double _maxScale = 10;
    // Global.logger.d('preview ${preview.data.toJson()}');
    // final double _width = preview.data.largeImageWidth;
    // final double _height = preview.data.largeImageHeight;
    //
    // if (_height / _width > _size.height / _size.width) {
    //   // 计算缩放到屏幕宽度一致时，图片的高
    //   final double _tempHeight = _height * _size.width / _width;
    //   Global.logger.d('_tempHeight $_tempHeight');
    //   _maxScale = _tempHeight / _size.height;
    // }
    Global.logger.d(' $_maxScale');
    return PhotoViewGallery.builder(
      scrollPhysics: const BouncingScrollPhysics(),
      itemCount: _galleryModel.previews.length,
      customSize: _screensize,
      backgroundDecoration: const BoxDecoration(
        color: null,
      ),
      builder: (BuildContext context, int index) {
        return PhotoViewGalleryPageOptions.customChild(
          child: GalleryImage(index: index),
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
//            Global.logger.v('onPageChanged');
        GalleryPrecache.instance.precacheImages(
          context,
          _galleryModel,
          previews: _galleryModel.previews,
          index: index,
          max: 5,
        );
        _currentIndex = index;
        _sliderValue = _currentIndex / 1.0;
        _galleryCacheModel.setIndex(
            _galleryModel.galleryItem.gid, _currentIndex);
        _futurePhotoViewGallery =
            GalleryUtil.getImageInfo(_galleryModel, _currentIndex);
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
                Navigator.pop(context);
              },
              child: const Text('取消')),
          actions: <Widget>[
            CupertinoActionSheetAction(
                onPressed: () {
                  Global.logger.v('保存到相册');
                  Api.saveImage(context, imageUrl).then((rult) {
                    Navigator.pop(context);
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
                  Global.logger.v('系统分享');
                  Api.shareImage(imageUrl);
                },
                child: const Text('系统分享')),
          ],
        );
        return dialog;
      });
}
