import 'package:archive_async/archive_async.dart';
import 'package:extended_image/extended_image.dart';
import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/pages/image_view/view/view_widget.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';

import '../common.dart';
import '../controller/view_controller.dart';
import '../controller/view_state.dart';
import 'image_list_view.dart';
import 'image_page_view.dart';
import 'view_image.dart';

typedef DoubleClickAnimationListener = void Function();

class ViewRepository {
  ViewRepository({
    this.index = 0,
    this.loadType = LoadFrom.gallery,
    this.files,
    this.asyncArchives,
    required this.gid,
  });

  final int index;
  final List<String>? files;
  final String gid;
  final LoadFrom loadType;
  final List<AsyncArchiveFile>? asyncArchives;
}

class ViewPage extends StatefulWidget {
  const ViewPage({Key? key}) : super(key: key);

  @override
  _ViewPageState createState() => _ViewPageState();
}

class _ViewPageState extends State<ViewPage> with TickerProviderStateMixin {
  final ViewExtController controller = Get.find();

  ViewExtState get vState => controller.vState;

  @override
  void initState() {
    super.initState();
    logger.v('initState');
  }

  @override
  void dispose() {
    super.dispose();
    // Get.delete<ViewExtController>();
    // 400.milliseconds.delay(() => Get.delete<ViewExtController>());
  }

  @override
  Widget build(BuildContext context) {
    Widget body = const ViewKeyboardListener(
      child: CupertinoTheme(
        data: CupertinoThemeData(
          brightness: Brightness.dark,
        ),
        child: ImagePlugins(
          child: ImageGestureDetector(
            child: ImageView(),
            // child: Container(
            //   color: Colors.amber,
            // ),
          ),
        ),
      ),
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        statusBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: body,
    );
  }
}

class ViewKeyboardListener extends GetView<ViewExtController> {
  const ViewKeyboardListener({required this.child, Key? key}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      autofocus: true,
      focusNode: FocusNode(),
      onKeyEvent: (KeyEvent event) async {
        if (event is! KeyDownEvent) {
          return;
        }

        // 按键对应的事件
        Map<LogicalKeyboardKey, Function> actionMap = {
          LogicalKeyboardKey.arrowLeft: controller.tapLeft,
          LogicalKeyboardKey.arrowUp: controller.tapLeft,
          LogicalKeyboardKey.arrowRight: controller.tapRight,
          LogicalKeyboardKey.arrowDown: controller.tapRight,
          LogicalKeyboardKey.space: controller.handOnTapCent,
          LogicalKeyboardKey.enter: controller.handOnTapCent,
          LogicalKeyboardKey.escape: Get.back,
          LogicalKeyboardKey.backspace: Get.back,
          LogicalKeyboardKey.equal: controller.scaleUp,
          LogicalKeyboardKey.minus: controller.scaleDown,
          LogicalKeyboardKey.digit0: controller.scaleReset,
          LogicalKeyboardKey.keyP: controller.switchColumnMode,
          LogicalKeyboardKey.keyT: controller.switchShowThumbList,
          LogicalKeyboardKey.keyA: () =>
              controller.tapAutoRead(context, setInv: false),
        };

        logger.d('logicalKey: ${event.logicalKey}');
        actionMap[event.logicalKey]?.call();
      },
      child: child,
    );
  }
}

class ImageView extends StatelessWidget {
  const ImageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ViewExtController>(
      id: idImagePageView,
      builder: (logic) {
        switch (logic.vState.viewMode) {
          case ViewMode.topToBottom:
            return const ImageListView();
          case ViewMode.LeftToRight:
            return const ImagePageView();
          case ViewMode.rightToLeft:
            return const ImagePageView(reverse: true);
          default:
            return const ImagePageView();
        }
      },
    );
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

    logger.v('alignmentL:$alignmentL  alignmentR:$alignmentR');

    double? _flexStart = () {
      try {
        final _curImage = vState.imageMap?[serStart];
        return _curImage!.imageWidth! / _curImage.imageHeight!;
      } on Exception catch (_) {
        final _curImage = vState.imageMap?[serStart];
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
        final _curImage = vState.imageMap?[serStart + 1];
        return _curImage!.imageWidth! / _curImage.imageHeight!;
      } on Exception catch (_) {
        final _curImage = vState.imageMap?[serStart + 1];
        return _curImage!.thumbWidth! / _curImage.thumbHeight!;
      } catch (e) {
        return 1.0;
      }
    }();

    logger.v('_flexStart:$_flexStart  _flexEnd:$_flexEnd');

    final List<Widget> _pageList = <Widget>[
      if (serStart > 0)
        Expanded(
          flex: _flexStart * 1000 ~/ 1,
          child: Container(
            alignment: reverse ? alignmentR : alignmentL,
            child: ViewImage(
              imageSer: serStart,
              enableDoubleTap: false,
              mode: ExtendedImageMode.none,
              // enableSlideOutPage: false,
            ),
          ),
        ),
      if (vState.filecount > serStart)
        Expanded(
          flex: _flexEnd * 1000 ~/ 1,
          child: Container(
            alignment: reverse ? alignmentL : alignmentR,
            child: ViewImage(
              imageSer: serStart + 1,
              enableDoubleTap: false,
              mode: ExtendedImageMode.none,
              // enableSlideOutPage: false,
            ),
          ),
        ),
    ];

    return GestureDetector(
      // onDoubleTap: () {
      //   logger.d('onDoubleTap');
      //   controller.photoViewScaleStateController.scaleState =
      //       PhotoViewScaleState.zoomedOut;
      // },
      onDoubleTapDown: (details) {
        logger.d('onDoubleTapDown');
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: reverse ? _pageList.reversed.toList() : _pageList,
      ),
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
        kBottomBarHeight +
        kSliderBarHeight +
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

  static const lrRatio = 1 / 3;
  static const tbRatio = 1 / 5;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.deferToChild,
      onTapUp: (details) {
        // logger.d('${details.globalPosition} ${details.localPosition}');

        final globalPosition = details.globalPosition;
        if (globalPosition.dx < context.width * (1 - lrRatio) &&
            globalPosition.dx > context.width * lrRatio) {
          if (globalPosition.dy < context.height * tbRatio) {
            controller.tapLeft();
          } else if (globalPosition.dy > context.height * (1 - tbRatio)) {
            controller.tapRight();
          } else {
            controller.handOnTapCent();
          }
        }

        if (globalPosition.dx < context.width * lrRatio) {
          controller.tapLeft();
        }

        if (globalPosition.dx > context.width * (1 - lrRatio)) {
          controller.tapRight();
        }
      },
      onDoubleTap: () {
        logger.d('onDoubleTap');
      },
      child: child,
    );
  }
}
