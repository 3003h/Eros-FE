import 'dart:math';

import 'package:english_words/english_words.dart';
import 'package:extended_image/extended_image.dart';
import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/pages/image_view_ext/view/view_ext.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:zoom_widget/zoom_widget.dart';

import '../common.dart';
import '../controller/view_ext_contorller.dart';
import '../controller/view_ext_state.dart';
import 'view_image_ext.dart';

typedef DoubleClickAnimationListener = void Function();

class ViewRepository {
  ViewRepository({
    this.index = 0,
    this.loadType = LoadType.network,
    this.files,
    required this.gid,
  });

  final int index;
  final List<String>? files;
  final String gid;
  final LoadType loadType;
}

class ViewExtPage extends StatefulWidget {
  const ViewExtPage({Key? key}) : super(key: key);

  @override
  _ViewExtPageState createState() => _ViewExtPageState();
}

class _ViewExtPageState extends State<ViewExtPage>
    with TickerProviderStateMixin {
  final ViewExtController controller = Get.find();

  ViewExtState get vState => controller.vState;

  @override
  Widget build(BuildContext context) {
    return const CupertinoTheme(
      data: CupertinoThemeData(
        brightness: Brightness.dark,
      ),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: ImagePlugins(
          child: ImageGestureDetector(
            child: ImagePageView(),
          ),
        ),
      ),
    );
  }
}

class ImagePageView extends StatelessWidget {
  const ImagePageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ViewExtController>(
      id: idImagePageView,
      builder: (logic) {
        switch (logic.vState.viewMode) {
          case ViewMode.topToBottom:
            return const ImageListViewPage();
          case ViewMode.LeftToRight:
            return const ViewImageSlidePage();
          case ViewMode.rightToLeft:
            return const ViewImageSlidePage(reverse: true);
          default:
            return const ViewImageSlidePage();
        }
      },
    );
  }
}

class ImageListViewPage extends GetView<ViewExtController> {
  const ImageListViewPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget imageListview = Container(
      height: context.height,
      width: context.width,
      color: CupertinoTheme.of(context).scaffoldBackgroundColor,
      child: GetBuilder<ViewExtController>(
        id: idImageListView,
        builder: (logic) {
          loggerSimple.d('builder ImageListViewPage');

          final vState = logic.vState;

          return ScrollablePositionedList.builder(
            // minCacheExtent: 500,
            padding: EdgeInsets.only(
              top: context.mediaQueryPadding.top,
              bottom: context.mediaQueryPadding.bottom,
            ),
            itemScrollController: logic.itemScrollController,
            itemPositionsListener: logic.itemPositionsListener,
            itemCount: vState.filecount,
            itemBuilder: itemBuilder(),
          );
        },
      ),
    );

    Widget imageListview2 = Container(
      color: CupertinoTheme.of(context).scaffoldBackgroundColor,
      child: GetBuilder<ViewExtController>(
        id: idImageListView,
        builder: (logic) {
          final vState = logic.vState;

          return ListView.builder(
            padding: const EdgeInsets.all(0),
            itemCount: vState.filecount,
            itemBuilder: itemBuilder(),
          );
        },
      ),
    );

    Widget imageListview3 = Container(
      color: CupertinoTheme.of(context).scaffoldBackgroundColor,
      child: GetBuilder<ViewExtController>(
        id: idImageListView,
        builder: (logic) {
          final vState = logic.vState;

          return ListView.builder(
            controller: controller.autoScrollController,
            padding: const EdgeInsets.all(0),
            itemCount: vState.filecount,
            itemBuilder: itemBuilder2(),
          );
        },
      ),
    );

    final _list = generateWordPairs().take(700).toList();
    Widget wordlist = Container(
      color: Colors.blueGrey,
      child: ListView.builder(
        itemCount: _list.length,
        itemBuilder: (_, index) {
          final w = _list[index];
          return Text('$w', style: const TextStyle(color: Colors.white));
        },
      ),
    );

    Widget wordlist2 = Container(
      color: Colors.blueGrey,
      child: GetBuilder<ViewExtController>(
        id: idImageListView,
        builder: (logic) {
          return ListView.builder(
            itemCount: _list.length,
            itemBuilder: (_, index) {
              final w = _list[index];
              return AutoScrollTag(
                  key: ValueKey(index),
                  controller: logic.autoScrollController,
                  index: index,
                  child: Text('$w', style: const TextStyle(color: Colors.white)));
            },
          );
        },
      ),
    );

    if (false)
      return Zoom(
        maxZoomWidth: context.width * 2,
        maxZoomHeight: context.height * 2,
        enableScroll: false,
        child: Center(child: imageListview),
      );

    if (false)
      return Zoom(
        maxZoomWidth: context.width * 0.5,
        maxZoomHeight: context.height * 0.5,
        enableScroll: false,
        child: wordlist,
      );

    if (false)
      return Container(
        height: context.height,
        width: context.width,
        color: Colors.grey.withAlpha(150),
        child: InteractiveViewer(
          // boundaryMargin: EdgeInsets.all(400),
          minScale: 1.0,
          maxScale: 2.0,
          panEnabled: true,
          scaleEnabled: true,
          // child: Container(
          //   child: Image.asset('assets/40.png'),
          // ),
          child: imageListview3,
        ),
      );

    if (false)
      return PhotoView.customChild(
        initialScale: 1.0,
        customSize: context.mediaQuery.size,
        minScale: PhotoViewComputedScale.contained * 1.0,
        maxScale: 5.0,
        tightMode: true,
        child: imageListview,
      );

    // if (false)
    return PhotoViewGallery.builder(
      itemCount: 1,
      builder: (_, __) {
        return PhotoViewGalleryPageOptions.customChild(
          scaleStateController: controller.photoViewScaleStateController,
          initialScale: 1.0,
          minScale: PhotoViewComputedScale.contained * 1.0,
          maxScale: 5.0,
          // scaleStateCycle: lisviewScaleStateCycle,
          child: imageListview,
        );
      },
    );
  }

  Widget Function(BuildContext context, int index) itemBuilder() {
    return (BuildContext context, int index) {
      final int itemSer = index + 1;
      // loggerSimple.d('builder itemBuilder $itemSer');

      return ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: context.width,
        ),
        child: GetBuilder<ViewExtController>(
            id: '$idImageListView$itemSer',
            builder: (logic) {
              loggerSimple.v('builder itemBuilder $itemSer');

              final vState = logic.vState;
              double? _height = () {
                if (vState.imageSizeMap[itemSer] != null) {
                  final imageSize = vState.imageSizeMap[itemSer]!;
                  return imageSize.height * (context.width / imageSize.width);
                }

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

              loggerSimple.v('builder itemBuilder $itemSer $_height');

              return AnimatedContainer(
                padding:
                    EdgeInsets.only(bottom: vState.showPageInterval ? 8 : 0),
                height: _height ?? context.mediaQueryShortestSide * 4 / 3,
                // height: _height,
                duration: const Duration(milliseconds: 200),
                curve: Curves.ease,
                child: ViewImageExt(
                  imageSer: itemSer,
                  enableDoubleTap: false,
                  mode: ExtendedImageMode.none,
                  // expand: _height != null,
                ),
              );
            }),
      );
    };
  }

  Widget Function(BuildContext context, int index) itemBuilder2() {
    return (BuildContext context, int index) {
      final int itemSer = index + 1;

      return AutoScrollTag(
        key: ValueKey(index),
        controller: controller.autoScrollController,
        index: index,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: context.width,
          ),
          child: GetBuilder<ViewExtController>(
              id: '$idImageListView$itemSer',
              builder: (logic) {
                final vState = logic.vState;
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

                loggerSimple.d('ViewImageExt2');

                return Container(
                  padding:
                      EdgeInsets.only(bottom: vState.showPageInterval ? 8 : 0),
                  height: _height,
                  child: ViewImageExt(
                    imageSer: itemSer,
                    enableDoubleTap: false,
                    mode: ExtendedImageMode.none,
                    // expand: _height != null,
                  ),
                );
              }),
        ),
      );
    };
  }
}

PhotoViewScaleState lisviewScaleStateCycle(PhotoViewScaleState actual) {
  logger.d('actual $actual');
  // switch (actual) {
  //   case PhotoViewScaleState.initial:
  //   case PhotoViewScaleState.covering:
  //   case PhotoViewScaleState.originalSize:
  //     return PhotoViewScaleState.zoomedOut;
  //   default:
  //     return PhotoViewScaleState.initial;
  // }
  switch (actual) {
    case PhotoViewScaleState.initial:
      return PhotoViewScaleState.covering;
    case PhotoViewScaleState.covering:
      return PhotoViewScaleState.originalSize;
    case PhotoViewScaleState.originalSize:
      return PhotoViewScaleState.initial;
    case PhotoViewScaleState.zoomedIn:
    case PhotoViewScaleState.zoomedOut:
      return PhotoViewScaleState.initial;
    default:
      return PhotoViewScaleState.initial;
  }
}

class ViewImageSlidePage extends GetView<ViewExtController> {
  const ViewImageSlidePage({Key? key, this.reverse = false}) : super(key: key);
  final bool reverse;

  @override
  Widget build(BuildContext context) {
    return ExtendedImageSlidePage(
      child: GetBuilder<ViewExtController>(
        id: idSlidePage,
        builder: (logic) {
          if (logic.vState.columnMode != ViewColumnMode.single) {
            return PhotoViewGallery.builder(
                backgroundDecoration:
                    const BoxDecoration(color: Colors.transparent),
                pageController: logic.pageController,
                itemCount: logic.vState.pageCount,
                onPageChanged: controller.handOnPageChanged,
                scrollDirection: Axis.horizontal,
                customSize: context.mediaQuery.size,
                scrollPhysics: const CustomScrollPhysics(),
                reverse: reverse,
                builder: (BuildContext context, int pageIndex) {
                  /// 双页
                  return PhotoViewGalleryPageOptions.customChild(
                    initialScale: PhotoViewComputedScale.contained,
                    minScale: PhotoViewComputedScale.contained * 0.8,
                    maxScale: PhotoViewComputedScale.covered * 5,
                    // scaleStateCycle: lisviewScaleStateCycle,
                    child: DoublePageView(pageIndex: pageIndex),
                  );
                });
          } else {
            return ExtendedImageGesturePageView.builder(
              controller: logic.pageController,
              itemCount: logic.vState.pageCount,
              onPageChanged: controller.handOnPageChanged,
              scrollDirection: Axis.horizontal,
              physics: const CustomScrollPhysics(),
              reverse: reverse,
              itemBuilder: (BuildContext context, int index) {
                logger.v('pageIndex $index ser ${index + 1}');

                loggerSimple.d('ViewImageExt2');

                /// 单页
                return ViewImageExt(
                  imageSer: index + 1,
                  initialScale: logic.vState.showPageInterval ? (1 / 1.1) : 1.0,
                );
              },
            );
          }
        },
      ),
      slideAxis: SlideAxis.vertical,
      slideType: SlideType.wholePage,
      resetPageDuration: const Duration(milliseconds: 300),
      slidePageBackgroundHandler: (Offset offset, Size pageSize) {
        double opacity = 0.0;
        opacity = offset.distance /
            (Offset(pageSize.width, pageSize.height).distance / 2.0);
        return CupertinoColors.systemBackground.darkColor
            .withOpacity(min(1.0, max(1.0 - opacity, 0.0)));
      },
      onSlidingPage: (ExtendedImageSlidePageState state) {
        if (controller.vState.showBar) {
          controller.vState.showBar = !state.isSliding;
          controller.update([idViewBar]);
        }
      },
    );
  }
}

class DoublePageView extends GetView<ViewExtController> {
  const DoublePageView({
    Key? key,
    required this.pageIndex,
  }) : super(key: key);

  final int pageIndex;

  // ViewExtState get vState => controller.vState;

  @override
  Widget build(BuildContext context) {
    final ViewExtState vState = controller.vState;
    final reverse = vState.viewMode == ViewMode.rightToLeft;

    // 双页阅读
    final int serStart = vState.columnMode == ViewColumnMode.oddLeft
        ? pageIndex * 2 + 1
        : pageIndex * 2;
    vState.serStart = serStart;

    // logger.d('pageIndex $pageIndex leftSer $serStart');

    Alignment? alignmentL =
        vState.filecount > serStart ? Alignment.centerRight : null;
    Alignment? alignmentR = serStart <= 0 ? null : Alignment.centerLeft;

    logger.d('alignmentL:$alignmentL  alignmentR:$alignmentR');

    double? _flexStart = () {
      try {
        final _curImage = vState.imageMap[serStart];
        return _curImage!.imageWidth! / _curImage.imageHeight!;
      } on Exception catch (_) {
        final _curImage = vState.imageMap[serStart];
        return _curImage!.thumbWidth! / _curImage.thumbHeight!;
      } catch (e) {
        return 1.0;
      }
    }();

    double? _flexEnd = () {
      if (vState.filecount <= serStart) {
        return 0.0;
      }
      try {
        final _curImage = vState.imageMap[serStart + 1];
        return _curImage!.imageWidth! / _curImage.imageHeight!;
      } on Exception catch (_) {
        final _curImage = vState.imageMap[serStart + 1];
        return _curImage!.thumbWidth! / _curImage.thumbHeight!;
      } catch (e) {
        return 1.0;
      }
    }();

    logger.d('_flexStart:$_flexStart  _flexEnd:$_flexEnd');

    final List<Widget> _pageList = <Widget>[
      if (serStart > 0)
        Expanded(
          flex: _flexStart * 1000 ~/ 1,
          child: Container(
            alignment: reverse ? alignmentR : alignmentL,
            child: Hero(
              tag: serStart,
              child: ViewImageExt(
                imageSer: serStart,
                enableDoubleTap: false,
                mode: ExtendedImageMode.none,
              ),
            ),
          ),
        ),
      if (vState.filecount > serStart)
        Expanded(
          flex: _flexEnd * 1000 ~/ 1,
          child: Container(
            alignment: reverse ? alignmentL : alignmentR,
            child: Hero(
              tag: serStart + 1,
              child: ViewImageExt(
                imageSer: serStart + 1,
                enableDoubleTap: false,
                mode: ExtendedImageMode.none,
              ),
            ),
          ),
        ),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: reverse ? _pageList.reversed.toList() : _pageList,
    );
  }
}

///  显示顶栏 底栏 slider等
class ImagePlugins extends GetView<ViewExtController> {
  const ImagePlugins({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  ViewExtState get vState => controller.vState;

  @override
  Widget build(BuildContext context) {
    vState.bottomBarHeight = context.mediaQueryPadding.bottom +
        kTopBarHeight * 2 +
        (vState.showThumbList ? kThumbListViewHeight : 0);

    return Container(
      child: Stack(
        alignment: Alignment.center,
        children: [
          child,
          GetBuilder<ViewExtController>(
            id: idViewBar,
            builder: (logic) {
              return Stack(
                children: [
                  AnimatedPositioned(
                    curve: Curves.fastOutSlowIn,
                    duration: const Duration(milliseconds: 300),
                    top: logic.vState.topBarOffset,
                    // top: 50,
                    child: const ViewTopBar(),
                  ),
                  AnimatedPositioned(
                    curve: Curves.fastOutSlowIn,
                    duration: const Duration(milliseconds: 300),
                    bottom: logic.vState.bottomBarOffset,
                    child: const ViewBottomBar(),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

/// 控制触摸手势事件
class ImageGestureDetector extends GetView<ViewExtController> {
  const ImageGestureDetector({
    Key? key,
    required this.child,
  }) : super(key: key);
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        child,
        // 两侧触摸区
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: controller.tapLeft,
              ),
            ),
            SizedBox(
              height: context.height,
              width: context.width / 2.5,
            ),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: controller.tapRight,
              ),
            ),
          ],
        ),
        // 中心触摸区
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          child: Container(
            height: context.height / 4,
            width: context.width / 2.5,
          ),
          onTap: controller.handOnTapCent,
        ),
      ],
    );
  }
}
