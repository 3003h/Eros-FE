import 'package:archive_async/archive_async.dart';
import 'package:extended_image/extended_image.dart';
import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/models/gallery_image.dart';
import 'package:fehviewer/pages/image_view/view/view_widget.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';

import '../common.dart';
import '../controller/view_controller.dart';
import '../controller/view_state.dart';
import 'image_list_view.dart';
import 'image_page_view.dart';
import 'image_page_view_ex.dart';
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
    logger.v('ViewPage initState');
  }

  @override
  void dispose() {
    super.dispose();
    logger.v('ViewPage dispose');
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
          LogicalKeyboardKey.arrowUp: controller.toPrev,
          LogicalKeyboardKey.arrowRight: controller.tapRight,
          LogicalKeyboardKey.arrowDown: controller.toNext,
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

        logger.v('logicalKey: ${event.logicalKey}');
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
        logger.v('build ImageView');
        switch (logic.vState.viewMode) {
          case ViewMode.topToBottom:
            return const ImageListView();
          case ViewMode.LeftToRight:
            return const ImagePageView();
            return kReleaseMode
                ? const ImagePageView()
                : const ImagePhotoView();
          case ViewMode.rightToLeft:
            return const ImagePageView(reverse: true);
            return kReleaseMode
                ? const ImagePageView(reverse: true)
                : const ImagePhotoView(reverse: true);
          default:
            return const ImagePhotoView();
        }
      },
    );
  }
}

PhotoViewScaleState lisviewScaleStateCycle(PhotoViewScaleState actual) {
  logger.d('actual $actual');
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

class DoublePageView extends StatefulWidget {
  const DoublePageView({
    Key? key,
    required this.pageIndex,
  }) : super(key: key);

  final int pageIndex;

  @override
  State<DoublePageView> createState() => _DoublePageViewState();
}

class _DoublePageViewState extends State<DoublePageView> {
  ViewExtController get controller => Get.find();

  ViewExtState get vState => controller.vState;

  double _ratioStart = 1.0;
  double _ratioEnd = 1.0;
  int serStart = 1;

  bool needResizeS = false;
  bool needResizeE = false;

  double? getRatio(int ser, ViewExtState vState) {
    final size = vState.imageSizeMap[ser];
    if (size != null) {
      logger.d('getRatio $ser ${size.width} ${size.height}');
      return size.width / size.height;
    }

    final GalleryImage? _curImage = vState.imageMap?[ser];
    // logger.d('_curImage $ser ${_curImage?.toJson()}');
    if (_curImage == null) {
      return null;
    }

    if ((_curImage.imageHeight ?? 0) > 0) {
      return (_curImage.imageWidth ?? 0) / _curImage.imageHeight!;
    } else if ((_curImage.thumbHeight ?? 0) > 0) {
      return (_curImage.thumbWidth ?? 0) / _curImage.thumbHeight!;
    } else {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    // 双页阅读
    serStart = vState.columnMode == ViewColumnMode.oddLeft
        ? widget.pageIndex * 2 + 1
        : widget.pageIndex * 2;
    vState.serStart = serStart;
    final ratioStart = getRatio(serStart, vState);
    if (ratioStart == null) {
      needResizeS = true;
    }
    _ratioStart = ratioStart ?? 3 / 4;

    final ratioEnd =
        vState.filecount <= serStart ? 0.0 : getRatio(serStart + 1, vState);
    if (ratioEnd == null) {
      needResizeE = true;
    }
    _ratioEnd = ratioEnd ?? 3 / 4;
  }

  double get _ratioBoth => _ratioStart + _ratioEnd;

  @override
  Widget build(BuildContext context) {
    final reverse = vState.viewMode == ViewMode.rightToLeft;

    logger.v(
        '_ratioStart:$_ratioStart, _ratioEnd:$_ratioEnd, _ratioBoth:$_ratioBoth');

    final List<Widget> _pageList = <Widget>[
      if (serStart > 0)
        AspectRatio(
          aspectRatio: _ratioStart,
          child: buildViewImageStart(),
        ),
      if (vState.filecount > serStart)
        AspectRatio(
          aspectRatio: _ratioEnd,
          child: buildViewImageEnd(),
        ),
    ];

    Widget doubleView = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: reverse ? _pageList.reversed.toList() : _pageList,
    );

    doubleView = AspectRatio(
      aspectRatio: _ratioBoth,
      child: doubleView,
    );

    return GestureDetector(
      onDoubleTapDown: (details) {
        logger.d('onDoubleTapDown');
      },
      child: _pageList.length > 1 ? Center(child: doubleView) : doubleView,
    );
  }

  ViewImage buildViewImageEnd() {
    return ViewImage(
      imageSer: serStart + 1,
      enableDoubleTap: false,
      mode: ExtendedImageMode.none,
      enableSlideOutPage: false,
      imageSizeChanged: (Size size) {
        if (size.width > 0 && size.height > 0 && needResizeE) {
          logger.d('end imageSizeChanged ${serStart + 1} $_ratioEnd');
          _ratioEnd = size.width / size.height;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {});
            needResizeE = false;
          });
        }

        vState.imageSizeMap[serStart + 1] = size;

        controller.vState.galleryPageController?.uptImageBySer(
            ser: serStart + 1,
            imageCallback: (GalleryImage image) {
              return image.copyWith(
                imageWidth: size.width,
                imageHeight: size.height,
              );
            });
      },
    );
  }

  ViewImage buildViewImageStart() {
    return ViewImage(
      imageSer: serStart,
      enableDoubleTap: false,
      mode: ExtendedImageMode.none,
      enableSlideOutPage: false,
      imageSizeChanged: (Size size) {
        if (size.width > 0 && size.height > 0 && needResizeS) {
          _ratioStart = size.width / size.height;
          logger.d('start imageSizeChanged $serStart $_ratioStart');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {});
            needResizeS = false;
          });
        }

        logger.v('${controller.vState.galleryPageController == null}');

        vState.imageSizeMap[serStart] = size;

        controller.vState.galleryPageController?.uptImageBySer(
            ser: serStart,
            imageCallback: (GalleryImage image) {
              return image.copyWith(
                imageWidth: size.width,
                imageHeight: size.height,
              );
            });
      },
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
            controller.toPrev();
          } else if (globalPosition.dy > context.height * (1 - tbRatio)) {
            controller.toNext();
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
