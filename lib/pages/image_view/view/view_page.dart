import 'package:extended_image/extended_image.dart';
import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/pages/image_view/controller/view_state.dart';
import 'package:fehviewer/pages/image_view/view/view_image.dart';
import 'package:fehviewer/pages/image_view/view/view_widget.dart';
import 'package:fehviewer/route/routes.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../controller/view_controller.dart';

double kPageViewPadding = 4.0;

class GalleryViewPage extends GetView<ViewController> {
  const GalleryViewPage({Key? key}) : super(key: key);

  ViewState get vState => controller.vState;

  /// 画廊图片大图浏览
  @override
  Widget build(BuildContext context) {
    // logger.d('rebuild GalleryViewPage');
    vState.initSize(context);
    // logger.d('build ${state.viewMode}  ${state.columnMode}');
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
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onPanDown: controller.handOnPanDown,
                      onTap: controller.tapLeft,
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onPanDown: controller.handOnPanDown,
                      onTap: controller.tapRight,
                    ),
                  ),
                ],
              ),
              // 中心触摸区
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                child: Container(
                  key: vState.centkey,
                  height: vState.screensize.height / 4,
                  width: vState.screensize.width / 2.5,
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
                          top: vState.topBarOffset,
                          child: _buildTopBar(Get.context!),
                        ),
                        // 底栏
                        AnimatedPositioned(
                          curve: Curves.fastOutSlowIn,
                          duration: const Duration(milliseconds: 300),
                          bottom: vState.bottomBarOffset,
                          child: _buildBottomBar(context),
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
    // logger.v('_buildView ');
    return Obx(() {
      // 布局切换时进行页码跳转处理
      controller.checkViewModel();
      switch (vState.viewMode) {
        case ViewMode.topToBottom:
          return _buildListView();
        case ViewMode.LeftToRight:
          return _buildPhotoViewGallery();
        // return _buildExtendedImageGesturePageView();
        case ViewMode.rightToLeft:
          return _buildPhotoViewGallery(reverse: true);
        default:
          // return _buildPhotoViewGallery();
          return _buildPhotoViewGallery();
      }
    });
  }

  /// 顶栏
  Widget _buildTopBar(BuildContext context) {
    return Container(
        // height: kTopBarHeight + controller.paddingTop,
        width: vState.screensize.width,
        color: const Color.fromARGB(150, 0, 0, 0),
        padding: vState.topBarPadding,
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
    if (vState.viewMode != ViewMode.topToBottom) {
      // logger.v('${state?.itemIndex}');
      return Text(
        '${vState.itemIndex + 1}/${vState.filecount}',
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
            '${vState.itemIndex + 1}/${vState.filecount}',
            style: const TextStyle(
              color: CupertinoColors.systemGrey6,
            ),
          );
        },
      );
    }
  }

  /// 底栏
  Widget _buildBottomBar(BuildContext context) {
    final double _max = vState.filecount - 1.0;
    // logger.d('max = $_max');
    final Map<int, GalleryImage> imageMap = vState.imageMap;
    const _kTextStyle = TextStyle(color: Colors.white, fontSize: 10);
    return Container(
      color: const Color.fromARGB(150, 0, 0, 0),
      padding: vState.bottomBarPadding,
      width: vState.screensize.width,
      // height: kBottomBarHeight + controller.paddingBottom,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: GetBuilder<ViewController>(
                      id: GetIds.IMAGE_VIEW_SLIDER,
                      builder: (ViewController controller) {
                        final ViewState vState = controller.vState;
                        return PageSlider(
                          max: _max,
                          sliderValue: vState.sliderValue,
                          onChangedEnd: controller.handOnSliderChangedEnd,
                          onChanged: controller.handOnSliderChanged,
                        );
                      }),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                // 分享按钮
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    logger.v('tap share');
                    final GalleryImage? p =
                        imageMap[controller.vState.itemIndex + 1];
                    logger.v(p?.toJson());
                    showShareActionSheet(context, p?.imageUrl! ?? '');
                  },
                  child: Container(
                    width: 40,
                    height: kBottomBarHeight,
                    child: Column(
                      children: [
                        const Icon(
                          LineIcons.share,
                          color: CupertinoColors.systemGrey6,
                          size: 26,
                        ),
                        const Spacer(),
                        Text(
                          S.of(context).share,
                          style: _kTextStyle,
                        ),
                      ],
                    ),
                  ),
                ),

                // 自动阅读按钮
                if (vState.viewMode != ViewMode.topToBottom)
                  Obx(() {
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        controller.tapAutoRead(context);
                      },
                      onLongPress: () {
                        controller.longTapAutoRead(context);
                      },
                      child: Container(
                        width: 40,
                        height: kBottomBarHeight,
                        child: Column(
                          children: [
                            Icon(
                              LineIcons.hourglassHalf,
                              size: 26,
                              color: vState.autoRead
                                  ? CupertinoColors.activeBlue
                                  : CupertinoColors.systemGrey6,
                            ),
                            const Spacer(),
                            const Text(
                              'Auto',
                              style: _kTextStyle,
                            ),
                          ],
                        ),
                      ),
                    );
                  })
                else
                  const SizedBox.shrink(),

                // 双页切换按钮
                if (vState.viewMode != ViewMode.topToBottom)
                  Obx(() => GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          controller.switchColumnMode();
                        },
                        child: Container(
                          width: 40,
                          // margin: const EdgeInsets.only(right: 10.0),
                          height: kBottomBarHeight,
                          child: Column(
                            children: [
                              Icon(
                                LineIcons.bookOpen,
                                size: 26,
                                color: () {
                                  switch (vState.columnMode) {
                                    case ViewColumnMode.single:
                                      return CupertinoColors.systemGrey6;
                                    case ViewColumnMode.odd:
                                      return CupertinoColors.activeBlue;
                                    case ViewColumnMode.even:
                                      return CupertinoColors.activeOrange;
                                  }
                                }(),
                              ),
                              const Spacer(),
                              Text(
                                '双页',
                                style: _kTextStyle,
                              ),
                            ],
                          ),
                        ),
                      ))
                else
                  const SizedBox.shrink(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 上下浏览布局 利用[ScrollablePositionedList]实现
  Widget _buildListView() {
    return GetBuilder<ViewController>(
        id: GetIds.IMAGE_VIEW,
        builder: (ViewController controller) {
          final ViewState vState = controller.vState;
          return ScrollablePositionedList.builder(
            itemScrollController: controller.itemScrollController,
            itemPositionsListener: controller.itemPositionsListener,
            itemCount: vState.filecount,
            itemBuilder: (BuildContext context, int index) {
              final int itemSer = index + 1;

              return ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: context.width,
                ),
                child: GetBuilder<ViewController>(
                    id: '${GetIds.IMAGE_VIEW_SER}$itemSer',
                    builder: (ViewController controller) {
                      double? _height = () {
                        try {
                          final _curImage = vState.imageMap[itemSer];
                          return _curImage!.imageHeight! *
                              (context.width / _curImage.imageWidth!);
                        } on Exception catch (_) {
                          final _curImage = vState.imageMap[itemSer];
                          return _curImage!.thumbHeight! *
                              (context.width / _curImage.thumbWidth!);
                        } catch (e) {
                          return null;
                        }
                      }();

                      if (_height != null) {
                        _height += vState.showPageInterval ? 8 : 0;
                      }

                      return Container(
                        padding: EdgeInsets.only(
                            bottom: vState.showPageInterval ? 8 : 0),
                        height: _height,
                        child: ViewImage(
                          ser: itemSer,
                          expand: _height != null,
                        ),
                      );
                    }),
              );
            },
          );
        });
  }

  /// 左右方向翻页浏览部件 使用[PhotoViewGallery] 实现
  Widget _buildPhotoViewGallery({bool reverse = false}) {
    const double _maxScale = 10;

    return GetBuilder<ViewController>(
      id: GetIds.IMAGE_VIEW,
      builder: (ViewController controller) {
        final ViewState vState = controller.vState;
        controller.lastImagesSize = vState.images.length;

        return PhotoViewGallery.builder(
          scrollPhysics: const BouncingScrollPhysics(),
          reverse: reverse,
          itemCount: vState.pageCount,
          customSize: vState.screensize,
          builder: (BuildContext context, int pageIndex) {
            return PhotoViewGalleryPageOptions.customChild(
              child: Container(
                // alignment: Alignment.center,
                padding: EdgeInsets.symmetric(
                    horizontal: vState.showPageInterval ? kPageViewPadding : 0),
                child: () {
                  if (vState.columnMode != ViewColumnMode.single) {
                    // 双页阅读
                    final int serLeft = vState.columnMode == ViewColumnMode.odd
                        ? pageIndex * 2 + 1
                        : pageIndex * 2;

                    Alignment? alignmentL = vState.filecount > serLeft
                        ? Alignment.centerRight
                        : null;
                    Alignment? alignmentR =
                        serLeft <= 0 ? null : Alignment.centerLeft;

                    double? _widthL = () {
                      try {
                        final _curImage = vState.imageMap[serLeft];
                        return _curImage!.imageWidth! / _curImage.imageHeight!;
                      } on Exception catch (_) {
                        final _curImage = vState.imageMap[serLeft];
                        return _curImage!.thumbWidth! / _curImage.thumbHeight!;
                      } catch (e) {
                        return 1.0;
                      }
                    }();

                    double? _widthR = () {
                      if (vState.filecount <= serLeft) {
                        return 0.0;
                      }
                      try {
                        final _curImage = vState.imageMap[serLeft + 1];
                        return _curImage!.imageWidth! / _curImage.imageHeight!;
                      } on Exception catch (_) {
                        final _curImage = vState.imageMap[serLeft + 1];
                        return _curImage!.thumbWidth! / _curImage.thumbHeight!;
                      } catch (e) {
                        return 1.0;
                      }
                    }();

                    logger.d('_widthL:$_widthL  _widthR:$_widthR');

                    final List<Widget> _pageList = <Widget>[
                      if (serLeft > 0)
                        Expanded(
                          flex: _widthL * 1000 ~/ 1,
                          child: Container(
                            alignment: alignmentL,
                            child: Hero(
                              tag: serLeft,
                              child: ViewImage(
                                ser: serLeft,
                                fade: vState.fade,
                                // expand: true,
                              ),
                            ),
                          ),
                        ),
                      if (vState.filecount > serLeft)
                        Expanded(
                          flex: _widthR * 1000 ~/ 1,
                          child: Container(
                            alignment: alignmentR,
                            child: Hero(
                              tag: serLeft + 1,
                              child: ViewImage(
                                ser: serLeft + 1,
                                fade: vState.fade,
                                // expand: true,
                              ),
                            ),
                          ),
                        ),
                    ];

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children:
                          reverse ? _pageList.reversed.toList() : _pageList,
                    );
                  } else {
                    return ViewImage(
                      ser: pageIndex + 1,
                      fade: vState.fade,
                      expand: true,
                    );
                  }
                }(),
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

  /// 左右方向浏览部件 使用[ExtendedImageGesturePageView] 实现
  /// todo 缩放的处理有点问题
  Widget _buildExtendedImageGesturePageView({bool reverse = false}) {
    final ViewState vState = controller.vState;
    return ExtendedImageGesturePageView.builder(
      itemBuilder: (BuildContext context, int pageIndex) {
        Widget image = ViewImage(
          ser: pageIndex,
          fade: vState.fade,
          enableSlideOutPage: true,
        );
        image = Container(
          child: image,
          padding: const EdgeInsets.all(5.0),
        );

        image = ExtendedImageSlidePage(
          child: image,
          slideAxis: SlideAxis.vertical,
          slideType: SlideType.onlyImage,
        );

        return image;
      },
      itemCount: vState.filecount,
      onPageChanged: controller.handOnPageChanged,
      controller: controller.pageController,
      reverse: reverse,
    );
  }

  Widget loadingBuilder(BuildContext context, ImageChunkEvent? progress) {
    return progress != null
        ? Container(
            child: Center(
              child: Text(
                '${progress.cumulativeBytesLoaded * 100 ~/ (progress.expectedTotalBytes ?? 1)} %',
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          )
        : Container(
            child: Center(
              child: Text(
                'Loading ${vState.itemIndex + 1}',
              ),
            ),
          );
  }
}

class NumStack extends StatelessWidget {
  const NumStack({Key? key, this.text, required this.child}) : super(key: key);
  final String? text;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        child,
        if (Global.inDebugMode)
          Positioned(
            left: 10,
            top: 10,
            child: Text(
              text ?? '',
              style: const TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: <Shadow>[
                    Shadow(
                      color: Colors.black,
                      offset: Offset(2, 2),
                      blurRadius: 4,
                    )
                  ]),
            ),
          ),
      ],
    );
  }
}
