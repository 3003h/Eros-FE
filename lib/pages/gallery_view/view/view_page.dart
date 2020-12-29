import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/pages/gallery_view/view/view_widget.dart';
import 'package:fehviewer/route/routes.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../controller/view_controller.dart';

class GalleryViewPage extends GetView<ViewController> {
  const GalleryViewPage({Key key}) : super(key: key);

  /// 画廊图片大图浏览
  @override
  Widget build(BuildContext context) {
    logger.d(' rebuild GalleryViewPage');
    controller.initSize(context);
    return _buildPage(context);
  }

  // 页面
  Widget _buildPage(BuildContext context) {
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
      logger.d('rebuildView index ${controller.currentIndex}');
      controller.checkViewModel();
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
        // height: kTopBarHeight + controller.paddingTop,
        width: controller.screensize.width,
        color: const Color.fromARGB(150, 0, 0, 0),
        padding: controller.topBarPadding,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            // 页码提示
            _buildPageText(),
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
                // 菜单按钮
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

  Widget _buildPageText() {
    if (controller.viewMode != ViewMode.vertical) {
      return Text(
        '${controller.currentIndex + 1}/${controller.filecount}',
        style: const TextStyle(
          color: CupertinoColors.systemGrey6,
        ),
      );
    } else {
      return ValueListenableBuilder<Iterable<ItemPosition>>(
        valueListenable: controller.itemPositionsListener.itemPositions,
        builder: (_, Iterable<ItemPosition> positions, __) {
          controller.handItemPositionsChange(positions);

          return Text(
            '${controller.currentIndex + 1}/${controller.filecount}',
            style: const TextStyle(
              color: CupertinoColors.systemGrey6,
            ),
          );
        },
      );
    }
  }

  /// 底栏
  Widget _buildBottomBar() {
    final double _max = controller.filecount - 1.0;
    final List<GalleryPreview> previews = controller.previews;
    return Container(
      color: const Color.fromARGB(150, 0, 0, 0),
      padding: controller.bottomBarPadding,
      width: controller.screensize.width,
      // height: kBottomBarHeight + controller.paddingBottom,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Row(
              children: <Widget>[
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    logger.v('tap share');
                    showShareActionSheet(Get.context,
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
                const Spacer(),
              ],
            ),
          ),
          Row(
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
        ],
      ),
    );
  }

  // TODO(honjow): 竖直浏览布局
  Widget _buildListView_old() {
    return ListView.custom(
      childrenDelegate: ViewChildBuilderDelegate(
        (BuildContext context, int index) {
          return ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: context.width,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Container(
                  height: () {
                    try {
                      return controller.previews[index].largeImageHeight *
                          (context.width /
                              controller.previews[index].largeImageWidth);
                    } on Exception catch (_) {
                      logger.d('${controller.previews[index].toJson()}');
                      return controller.previews[index].height *
                          (context.width / controller.previews[index].width);
                    } catch (e) {
                      return null;
                    }
                  }(),
                  width: context.width,
                  child: GalleryImage(
                    index: index,
                  ),
                ),
                if (Global.inDebugMode)
                  Positioned(
                    left: 10,
                    top: 10,
                    child: Text(
                      '$index',
                      style: const TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
              ],
            ),
          );
        },
        childCount: controller.previews.length,
        onDidFinishLayout: controller.onDidFinishLayout,
      ),
      // cacheExtent: 0.0,
    );
  }

  Widget _buildListView() {
    return GetBuilder<ViewController>(
        id: '_buildPhotoViewGallery',
        builder: (ViewController controller) {
          return ScrollablePositionedList.builder(
            padding: EdgeInsets.only(top: Get.context.mediaQueryPadding.top),
            itemScrollController: controller.itemScrollController,
            itemPositionsListener: controller.itemPositionsListener,
            itemCount: controller.previews.length,
            itemBuilder: (BuildContext context, int index) {
              return ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: context.width,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Container(
                      height: () {
                        try {
                          return controller.previews[index].largeImageHeight *
                              (context.width /
                                  controller.previews[index].largeImageWidth);
                        } on Exception catch (_) {
                          logger.d('${controller.previews[index].toJson()}');
                          return controller.previews[index].height *
                              (context.width /
                                  controller.previews[index].width);
                        } catch (e) {
                          return null;
                        }
                      }(),
                      width: context.width,
                      child: GalleryImage(
                        index: index,
                      ),
                    ),
                    if (Global.inDebugMode)
                      Positioned(
                        left: 10,
                        top: 10,
                        child: Text(
                          '$index',
                          style: const TextStyle(
                              fontSize: 50,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        });
  }

  // todo 缩放倍数动态化?
  /// 水平方向浏览部件
  Widget _buildPhotoViewGallery({bool reverse = false}) {
    const double _maxScale = 10;

    return GetBuilder<ViewController>(
      id: '_buildPhotoViewGallery',
      builder: (ViewController controller) {
        logger.d('lastPreviewLen ${controller.previews.length}');
        controller.lastPreviewLen = controller.previews.length;
        return PhotoViewGallery.builder(
          // scrollPhysics: const BouncingScrollPhysics(),
          reverse: reverse,
          // itemCount: controller.previews.length,
          itemCount: controller.previews.length,
          customSize: controller.screensize,
          backgroundDecoration: const BoxDecoration(
            color: null,
          ),
          builder: (BuildContext context, int index) {
            return PhotoViewGalleryPageOptions.customChild(
              child: GalleryImage(
                index: index,
              ),
              initialScale: PhotoViewComputedScale.contained,
              minScale: PhotoViewComputedScale.contained * 1.0,
              maxScale: PhotoViewComputedScale.covered * _maxScale,
            );
          },
          loadingBuilder: loadingBuilder,
          // backgroundDecoration: null,
          pageController: controller.pageController,
          enableRotation: false,
          onPageChanged: controller.handOnPageChanged,
        );
      },
    );
  }

  Widget loadingBuilder(BuildContext context, ImageChunkEvent progress) {
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
                'Loading ${controller.currentIndex + 1}',
              ),
            ),
          );
  }
}
