import 'package:extended_image/extended_image.dart';
import 'package:fehviewer/common/service/depth_service.dart';
import 'package:fehviewer/pages/gallery/controller/gallery_page_controller.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liquid_progress_indicator_ns/liquid_progress_indicator.dart';
import '../controller/view_ext_contorller.dart';

const double kPageViewPadding = 4.0;

class ViewError extends StatelessWidget {
  const ViewError({Key? key, required this.ser, this.errInfo})
      : super(key: key);
  final int ser;
  final String? errInfo;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      constraints: BoxConstraints(
        maxHeight: context.width * 0.8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error,
            size: 50,
            color: Colors.red,
          ),
          Text(
            errInfo ?? '',
            style: const TextStyle(
                fontSize: 10, color: CupertinoColors.secondarySystemBackground),
          ),
          Text(
            '$ser',
            style: const TextStyle(
                color: CupertinoColors.secondarySystemBackground),
          ),
        ],
      ),
    );
  }
}

class ImageExt extends GetView<ViewExtController> {
  ImageExt({
    Key? key,
    required this.url,
    required this.ser,
    required this.fadeAnimationController,
    required this.reloadImage,
    this.imageHeight,
    this.imageWidth,
    this.retryCount = 5,
    this.onLoadCompleted,
    required this.initGestureConfigHandler,
    required this.onDoubleTap,
  }) : super(key: key);

  final String url;
  final int ser;
  final AnimationController fadeAnimationController;
  final VoidCallback reloadImage;
  final double? imageHeight;
  final double? imageWidth;
  final int retryCount;
  final VoidCallback? onLoadCompleted;
  final InitGestureConfigHandler initGestureConfigHandler;
  final DoubleTap onDoubleTap;

  final GalleryPageController _pageController = Get.find(tag: pageCtrlDepth);

  @override
  Widget build(BuildContext context) {
    if (false)
      return ExtendedImage.network(
        url,
        fit: BoxFit.contain,
        enableSlideOutPage: true,
        handleLoadingProgress: true,
        clearMemoryCacheIfFailed: true,
        mode: ExtendedImageMode.gesture,
        initGestureConfigHandler: initGestureConfigHandler,
        onDoubleTap: onDoubleTap,
        loadStateChanged: (ExtendedImageState state) {
          if (state.extendedImageLoadState == LoadState.loading) {}

          if (state.extendedImageLoadState == LoadState.completed) {
            final ImageInfo? imageInfo = state.extendedImageInfo;
            controller.setScale100(imageInfo!, context.mediaQuerySize);
          }
        },
      );

    return ExtendedImage.network(
      url,
      fit: BoxFit.contain,
      handleLoadingProgress: true,
      clearMemoryCacheIfFailed: true,
      enableSlideOutPage: true,
      mode: ExtendedImageMode.gesture,
      timeLimit: const Duration(seconds: 10),
      initGestureConfigHandler: initGestureConfigHandler,
      onDoubleTap: onDoubleTap,
      loadStateChanged: (ExtendedImageState state) {
        switch (state.extendedImageLoadState) {
          case LoadState.loading:
            fadeAnimationController.reset();
            final ImageChunkEvent? loadingProgress = state.loadingProgress;
            final double? progress = loadingProgress?.expectedTotalBytes != null
                ? (loadingProgress?.cumulativeBytesLoaded ?? 0) /
                    (loadingProgress?.expectedTotalBytes ?? 1)
                : null;

            // 下载进度回调
            return Container(
              constraints: BoxConstraints(
                maxHeight: context.mediaQueryShortestSide,
                minWidth: context.width / 2 - kPageViewPadding,
              ),
              alignment: Alignment.center,
              // margin: const EdgeInsets.symmetric(vertical: 50, horizontal: 50),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    height: 70,
                    width: 70,
                    // constraints: const BoxConstraints(minWidth: 70, maxHeight: 70),
                    child: LiquidCircularProgressIndicator(
                      value: progress ?? 0.0,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Color.fromARGB(255, 163, 199, 100)),
                      backgroundColor: const Color.fromARGB(255, 50, 50, 50),
                      // borderColor: Colors.teal[900],
                      // borderWidth: 2.0,
                      direction: Axis.vertical,
                      center: progress != null
                          ? Text(
                              '${progress * 100 ~/ 1}%',
                              style: TextStyle(
                                color: progress < 0.5
                                    ? CupertinoColors.white
                                    : CupertinoColors.black,
                                fontSize: 12,
                                height: 1,
                              ),
                            )
                          : Container(),
                      borderColor: Colors.transparent,
                      borderWidth: 0.0,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      '$ser',
                      style: const TextStyle(
                        color: CupertinoColors.systemGrey6,
                        height: 1,
                      ),
                    ),
                  )
                ],
              ),
            );

          ///if you don't want override completed widget
          ///please return null or state.completedWidget
          //return null;
          //return state.completedWidget;
          case LoadState.completed:
            fadeAnimationController.forward();

            final ImageInfo? imageInfo = state.extendedImageInfo;
            controller.setScale100(imageInfo!, context.mediaQuerySize);

            onLoadCompleted?.call();

            // return null;
            return FadeTransition(
              opacity: fadeAnimationController,
              child: state.completedWidget,
            );

          case LoadState.failed:
            logger.d('Failed $url');
            fadeAnimationController.reset();

            if ((_pageController.errCountMap[ser] ?? 0) < retryCount) {
              Future.delayed(const Duration(milliseconds: 100))
                  .then((_) => reloadImage());
              _pageController.errCountMap
                  .update(ser, (int value) => value + 1, ifAbsent: () => 1);
              logger.d('${ser} 重试 第 ${_pageController.errCountMap[ser]} 次');
            }

            return Container(
              alignment: Alignment.center,
              constraints: BoxConstraints(
                maxHeight: context.width * 0.8,
              ),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error,
                      size: 50,
                      color: Colors.red,
                    ),
                    const Text(
                      'Load image failed',
                      style: TextStyle(
                          fontSize: 10,
                          color: CupertinoColors.secondarySystemBackground),
                    ),
                    Text(
                      '${ser + 1}',
                      style: const TextStyle(
                          color: CupertinoColors.secondarySystemBackground),
                    ),
                  ],
                ),
                onTap: () {
                  // state.reLoadImage();
                  reloadImage();
                },
              ),
            );
            break;
          default:
            return null;
        }
      },
    );
  }
}
