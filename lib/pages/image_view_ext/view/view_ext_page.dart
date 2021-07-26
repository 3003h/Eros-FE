import 'dart:math';

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
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

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
  });

  final int index;
  final List<String>? files;
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

class ImageListViewPage extends StatelessWidget {
  const ImageListViewPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget image = Container(
      height: context.height,
      width: context.width,
      color: Colors.black,
      child: GetBuilder<ViewExtController>(
        id: idImageListView,
        builder: (logic) {
          final vState = logic.vState;

          return ScrollablePositionedList.builder(
            itemScrollController: logic.itemScrollController,
            itemPositionsListener: logic.itemPositionsListener,
            itemCount: vState.filecount,
            itemBuilder: itemBuilder(),
          );
        },
      ),
    );

    // return Container(
    //   height: context.height,
    //   width: context.width,
    //   color: Colors.grey.withAlpha(150),
    //   child: InteractiveViewer(
    //     // boundaryMargin: EdgeInsets.all(400),
    //     minScale: 1.0,
    //     maxScale: 5.0,
    //     panEnabled: true,
    //     scaleEnabled: true,
    //     // child: Container(
    //     //   child: Image.asset('assets/40.png'),
    //     // ),
    //     child: UnconstrainedBox(child: image),
    //   ),
    // );

    return PhotoViewGallery.builder(
      itemCount: 1,
      customSize: context.mediaQuery.size,
      builder: (_, __) {
        return PhotoViewGalleryPageOptions.customChild(
          initialScale: 1.0,
          minScale: PhotoViewComputedScale.contained * 1.0,
          maxScale: 5.0,
          child: image,
        );
      },
    );
  }

  Widget Function(BuildContext context, int index) itemBuilder() {
    return (BuildContext context, int index) {
      final int itemSer = index + 1;

      return ConstrainedBox(
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

              return Container(
                padding:
                    EdgeInsets.only(bottom: vState.showPageInterval ? 8 : 0),
                height: _height,
                child: ViewImageExt(
                  imageSer: itemSer,
                  enableDoubleTap: false,
                  // expand: _height != null,
                ),
              );
            }),
      );
    };
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
                    minScale: PhotoViewComputedScale.contained * 1.0,
                    maxScale: PhotoViewComputedScale.covered * 10,
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
                logger.d('pageIndex $index ser ${index + 1}');

                /// 单页
                return ViewImageExt(
                  imageSer: index + 1,
                  initialScale: 1 / (logic.vState.showPageInterval ? 1.1 : 1.0),
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
        return Colors.black.withOpacity(min(1.0, max(1.0 - opacity, 0.0)));
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
    this.reverse = false,
  }) : super(key: key);

  final int pageIndex;
  final bool reverse;

  // ViewExtState get vState => controller.vState;

  @override
  Widget build(BuildContext context) {
    final ViewExtState vState = controller.vState;

    // 双页阅读
    final int serLeft = vState.columnMode == ViewColumnMode.oddLeft
        ? pageIndex * 2 + 1
        : pageIndex * 2;
    vState.serLeft = serLeft;

    // logger.d('pageIndex $pageIndex leftSer $serLeft');

    Alignment? alignmentL =
        vState.filecount > serLeft ? Alignment.centerRight : null;
    Alignment? alignmentR = serLeft <= 0 ? null : Alignment.centerLeft;

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

    // logger.d('_widthL:$_widthL  _widthR:$_widthR');

    final List<Widget> _pageList = <Widget>[
      if (serLeft > 0)
        Expanded(
          flex: _widthL * 1000 ~/ 1,
          child: Container(
            alignment: alignmentL,
            child: Hero(
              tag: serLeft,
              child: ViewImageExt(
                imageSer: serLeft,
                enableDoubleTap: false,
                // fade: vState.fade,
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
              child: ViewImageExt(
                imageSer: serLeft + 1,
                enableDoubleTap: false,
                // fade: vState.fade,
                // expand: true,
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
        // 非中心触摸区
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
