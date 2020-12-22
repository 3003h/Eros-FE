import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/pages/gallery_view/view/view_widget.dart';
import 'package:fehviewer/route/routes.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/values/const.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../controller/view_controller.dart';

const double kBottomBarHeight = 44.0;
const double kTopBarHeight = 40.0;

class GalleryViewPage extends GetView<ViewController> {
  const GalleryViewPage({Key key}) : super(key: key);

  // ViewController controller;

  /// 画廊图片大图浏览
  @override
  Widget build(BuildContext context) {
    // controller = Get.find();

    return _buildPage();
  }

  // 页面
  Widget _buildPage() {
    return CupertinoTheme(
      data: const CupertinoThemeData(
        brightness: Brightness.dark,
      ),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: CupertinoPageScaffold(
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              // 内容部件
              _buildView(),
              // 外沿触摸区
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                child: Container(),
                onPanDown: controller.handOnPanDown,
                onPanStart: (DragStartDetails details) {
                  logger.d('${details.localPosition} ');
                },
              ),
              // 中心触摸区
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                child: Container(
                  key: controller.centkey,
                  height: controller.screensize.height / 4,
                  width: controller.screensize.width / 2.5,
                ),
                onTap: controller.handOnTapCent,
              ),
              SafeArea(
                bottom: false,
                top: false,
                left: false,
                right: false,
                child: Obx(() => Stack(
                      fit: StackFit.expand,
                      alignment: Alignment.center,
                      children: <Widget>[
                        // 顶栏
                        AnimatedPositioned(
                          curve: Curves.fastOutSlowIn,
                          duration: const Duration(milliseconds: 300),
                          top: controller.topBarOffset,
                          child: _buildTopBar(Get.context),
                        ),
                        // 底栏
                        AnimatedPositioned(
                          curve: Curves.fastOutSlowIn,
                          duration: const Duration(milliseconds: 300),
                          bottom: controller.bottomBarOffset,
                          child: _buildBottomBar(),
                        ),
                      ],
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 不同阅读方向不同布局
  Widget _buildView() {
    return Obx(() {
      switch (controller.viewMode) {
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
    final List<GalleryPreview> previews = controller.previews;
    return Container(
        height: kTopBarHeight + controller.paddingTop,
        width: controller.screensize.width,
        color: const Color.fromARGB(150, 0, 0, 0),
        padding: EdgeInsets.fromLTRB(
          controller.paddingLeft,
          controller.realPaddingTop,
          controller.paddingRight,
          4.0,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            // 页码提示
            Text(
              '${controller.currentIndex + 1}/${controller.filecount}',
              style: const TextStyle(
                color: CupertinoColors.systemGrey6,
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
                    showShareDialog(context,
                        previews[controller.currentIndex].largeImageUrl);
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
    final double _max = controller.filecount - 1.0;
    return Container(
      color: const Color.fromARGB(150, 0, 0, 0),
      padding: EdgeInsets.only(
        bottom: controller.realPaddingBottom,
        left: controller.paddingLeft,
        right: controller.paddingRight,
      ),
      width: controller.screensize.width,
      height: kBottomBarHeight + controller.paddingBottom,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: PageSlider(
                max: _max,
                sliderValue: controller.sliderValue,
                onChangedEnd: controller.handOnSliderChangedEnd,
                onChanged: controller.handOnSliderChanged,
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

  // TODO(honjow): 还没有完全实现 竖直浏览布局
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
                future: controller.futureViewGallery,
                builder: (BuildContext context,
                    AsyncSnapshot<GalleryPreview> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasError) {
                      return Container();
                    } else {
                      logger.d(
                          ' h: ${snapshot.data.largeImageHeight}  w: ${snapshot.data.largeImageWidth}  ${snapshot.data.largeImageWidth / controller.screensize.width}');
                      return Container(
                          // height: snapshot.data.largeImageHeight *
                          //     (snapshot.data.largeImageWidth /
                          //         _screensize.width),
                          // width: _screensize.width,
                          height: snapshot.data.largeImageHeight /
                              (snapshot.data.largeImageWidth /
                                  controller.screensize.width),
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
        childCount: controller.previews.length,
      ),
      cacheExtent: 0.0,
    );
  }

  // TODO(honjow): 缩放倍数动态化
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
      // itemCount: controller.previews.length,
      itemCount: controller.filecount,
      customSize: controller.screensize,
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
                    '获取中 ${controller.currentIndex + 1}',
                    style: const TextStyle(
//                          color: Colors.white,
                        ),
                  ),
                ),
              );
      },
      // backgroundDecoration: null,
      pageController: controller.pageController,
      enableRotation: false,
      // 旋转
      onPageChanged: controller.handOnPageChanged,
    );
  }
}
