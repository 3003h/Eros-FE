import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/const/const.dart';
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
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../controller/view_controller.dart';

class GalleryViewPage extends GetView<ViewController> {
  const GalleryViewPage({Key key}) : super(key: key);

  ViewState get state => controller?.vState;

  /// 画廊图片大图浏览
  @override
  Widget build(BuildContext context) {
    // logger.d('rebuild GalleryViewPage');
    state.initSize(context);
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
                      // child: Container(),
                      onPanDown: controller.handOnPanDown,
                      // onPanStart: (DragStartDetails details) {
                      //   logger.d('${details.localPosition} ');
                      // },
                      onTap: controller.tapLeft,
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      // child: Container(),
                      onPanDown: controller.handOnPanDown,
                      // onPanStart: (DragStartDetails details) {
                      //   logger.d('${details.localPosition} ');
                      // },
                      onTap: controller.tapRight,
                    ),
                  ),
                ],
              ),
              // 中心触摸区
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                child: Container(
                  key: state.centkey,
                  height: state.screensize.height / 4,
                  width: state.screensize.width / 2.5,
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
                          top: state.topBarOffset,
                          child: _buildTopBar(Get.context),
                        ),
                        // 底栏
                        AnimatedPositioned(
                          curve: Curves.fastOutSlowIn,
                          duration: const Duration(milliseconds: 300),
                          bottom: state.bottomBarOffset,
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
    // logger.v('_buildView ');
    return Obx(() {
      // 布局切换时进行页码跳转处理
      controller.checkViewModel();
      switch (state.viewMode) {
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
    return Container(
        // height: kTopBarHeight + controller.paddingTop,
        width: state.screensize.width,
        color: const Color.fromARGB(150, 0, 0, 0),
        padding: state.topBarPadding,
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
    if (state.viewMode != ViewMode.vertical) {
      // logger.v('${state?.itemIndex}');
      return Text(
        '${((state?.itemIndex) ?? 0) + 1}/${state.filecount}',
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
            '${((state?.itemIndex) ?? 0) + 1}/${state.filecount}',
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
    final double _max = state.filecount - 1.0;
    final List<GalleryPreview> previews = state.previews;
    return Container(
      color: const Color.fromARGB(150, 0, 0, 0),
      padding: state.bottomBarPadding,
      width: state.screensize.width,
      // height: kBottomBarHeight + controller.paddingBottom,
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: GetBuilder<ViewController>(
                      id: 'PageSlider',
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
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Row(
              children: <Widget>[
                // 分享按钮
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    logger.v('tap share');
                    showShareActionSheet(Get.context,
                        previews[controller.vState.itemIndex].largeImageUrl);
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
                if (state.viewMode != ViewMode.vertical)
                  Obx(() => GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          // logger.v('tap doublePage');
                          controller.switchColumnMode();
                        },
                        child: Container(
                          width: 40,
                          margin: const EdgeInsets.only(right: 10.0),
                          height: kBottomBarHeight,
                          child: Icon(
                            FontAwesomeIcons.bookOpen,
                            color: () {
                              switch (state.columnMode) {
                                case ColumnMode.single:
                                  return CupertinoColors.systemGrey6;
                                case ColumnMode.odd:
                                  return CupertinoColors.activeBlue;
                                case ColumnMode.even:
                                  return CupertinoColors.activeOrange;
                              }
                            }(),
                            // size: 24,
                          ),
                        ),
                      )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 竖直浏览布局 利用[ScrollablePositionedList]实现
  Widget _buildListView() {
    return GetBuilder<ViewController>(
        id: '_buildPhotoViewGallery',
        builder: (ViewController controller) {
          final ViewState state = controller.vState;
          return ScrollablePositionedList.builder(
            itemScrollController: controller.itemScrollController,
            itemPositionsListener: controller.itemPositionsListener,
            itemCount: state.filecount,
            itemBuilder: (BuildContext context, int index) {
              return ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: context.width,
                ),
                child: NumStack(
                  text: '$index',
                  child: GetBuilder<ViewController>(
                      id: 'GalleryImage_$index',
                      builder: (ViewController controller) {
                        // logger.d('build list item $index');
                        return Container(
                          height: () {
                            try {
                              return state.previews[index].largeImageHeight *
                                  (context.width /
                                      state.previews[index].largeImageWidth);
                            } on Exception catch (_) {
                              logger.d('${state.previews[index].toJson()}');
                              return state.previews[index].height *
                                  (context.width / state.previews[index].width);
                            } catch (e) {
                              return null;
                            }
                          }(),
                          width: context.width,
                          child: ViewImage(
                            index: index,
                          ),
                        );
                      }),
                ),
              );
            },
          );
        });
  }

  /// 水平方向浏览部件 使用[PhotoViewGallery] 实现
  Widget _buildPhotoViewGallery({bool reverse = false}) {
    const double _maxScale = 10;
    return GetBuilder<ViewController>(
      id: '_buildPhotoViewGallery',
      builder: (ViewController controller) {
        // logger.d('lastPreviewLen ${controller.previews.length}');
        final state = controller.vState;
        controller.lastPreviewLen = state.previews.length;

        return Obx(
          () => PhotoViewGallery.builder(
            scrollPhysics: const BouncingScrollPhysics(),
            reverse: reverse,
            itemCount: state.pageCount,
            customSize: state.screensize,
            builder: (BuildContext context, int pageIndex) {
              // logger.v('PhotoViewGallery.builder');
              return PhotoViewGalleryPageOptions.customChild(
                child: Container(
                  alignment: Alignment.center,
                  child: () {
                    if (state.columnMode != ColumnMode.single) {
                      // 双页阅读
                      final int indexLeft = state.columnMode == ColumnMode.odd
                          ? pageIndex * 2
                          : pageIndex * 2 - 1;

                      final List<Widget> _pageList = <Widget>[
                        if (indexLeft >= 0)
                          Expanded(
                            child: Container(
                              alignment: Alignment.centerRight,
                              child: NumStack(
                                text: '$indexLeft',
                                child: ViewImage(
                                  index: indexLeft,
                                  fade: state.fade,
                                ),
                              ),
                            ),
                          ),
                        if (state.filecount > indexLeft + 1)
                          Expanded(
                            child: Container(
                              alignment:
                                  indexLeft >= 0 ? Alignment.centerLeft : null,
                              child: NumStack(
                                text: '${indexLeft + 1}',
                                child: ViewImage(
                                  index: indexLeft + 1,
                                  fade: state.fade,
                                ),
                              ),
                            ),
                          ),
                      ];

                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children:
                            reverse ? _pageList.reversed.toList() : _pageList,
                      );
                    } else {
                      return NumStack(
                        text: '$pageIndex',
                        child: ViewImage(
                          index: pageIndex,
                          fade: state.fade,
                        ),
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
          ),
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
                'Loading ${state.itemIndex + 1}',
              ),
            ),
          );
  }
}

class NumStack extends StatelessWidget {
  const NumStack({Key key, this.text, @required this.child}) : super(key: key);
  final String text;
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
