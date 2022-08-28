import 'dart:io';
import 'dart:math' as math;
import 'dart:math';

import 'package:archive_async/archive_async.dart';
import 'package:blur/blur.dart';
import 'package:extended_image/extended_image.dart';
import 'package:fehviewer/common/controller/image_hide_controller.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/common/service/layout_service.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/network/api.dart';
import 'package:fehviewer/pages/gallery/controller/gallery_page_controller.dart';
import 'package:fehviewer/pages/image_view/controller/view_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

import '../common.dart';
import '../controller/view_controller.dart';

const double kPageViewPadding = 4.0;

class ViewErr509 extends StatelessWidget {
  const ViewErr509({Key? key, required this.ser}) : super(key: key);
  final int ser;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 100,
            width: 100,
            constraints: const BoxConstraints(
              maxHeight: 100,
              maxWidth: 100,
            ),
            alignment: Alignment.center,
            child: Column(
              children: [
                Text(
                  '509',
                  style: TextStyle(
                    fontSize: 20,
                    color: CupertinoColors.systemPink.darkColor,
                  ),
                ),
                Expanded(
                  child: Icon(
                    FontAwesomeIcons.fill,
                    size: 77,
                    color: CupertinoColors.systemPink.darkColor,
                  ),
                ),
              ],
            ),
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

class ViewAD extends StatelessWidget {
  const ViewAD({Key? key, required this.ser}) : super(key: key);
  final int ser;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            constraints: const BoxConstraints(
              maxHeight: 100,
              maxWidth: 100,
            ),
            alignment: Alignment.center,
            child: Column(
              children: [
                Text(
                  '',
                  style: TextStyle(
                    fontSize: 20,
                    color: CupertinoColors.systemPink.darkColor,
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Icon(
                      CupertinoIcons.xmark_shield_fill,
                      size: 80,
                      color: CupertinoColors.systemPink.darkColor,
                    ),
                  ),
                ),
              ],
            ),
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
            size: 60,
            color: Colors.red,
          ),
          Text(
            errInfo ?? '',
            maxLines: 20,
            style: const TextStyle(
                fontSize: 12, color: CupertinoColors.secondarySystemBackground),
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

class ViewLoading extends StatelessWidget {
  const ViewLoading({
    Key? key,
    required this.ser,
    this.duration,
    this.progress,
    this.animationEnabled,
    this.debugLable,
  }) : super(key: key);
  final int ser;
  final Duration? duration;
  final double? progress;
  final bool? animationEnabled;
  final String? debugLable;

  @override
  Widget build(BuildContext context) {
    if (debugLable != null && kDebugMode) {
      logger.v('build ViewLoading $debugLable');
    }
    final _loadWidget = _ViewLoadingCupertion(
      ser: ser,
      progress: progress,
      animationEnabled: animationEnabled ?? true,
    );

    if (duration == null) {
      return _loadWidget;
    } else {
      return FutureBuilder<void>(
          future: Future.delayed(duration ?? const Duration(milliseconds: 100)),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return _loadWidget;
            } else {
              return const SizedBox.shrink();
            }
          });
    }
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
    this.mode = ExtendedImageMode.none,
    this.enableSlideOutPage = false,
  }) : super(key: key);

  final String url;
  final int ser;
  final AnimationController fadeAnimationController;
  final VoidCallback reloadImage;
  final double? imageHeight;
  final double? imageWidth;
  final int retryCount;
  final ValueChanged<ExtendedImageState>? onLoadCompleted;
  final InitGestureConfigHandler initGestureConfigHandler;
  final DoubleTap? onDoubleTap;
  final ExtendedImageMode mode;
  final bool enableSlideOutPage;

  final EhConfigService ehConfigService = Get.find();

  bool get checkPHashHide => ehConfigService.enablePHashCheck;

  bool get checkQRCodeHide => ehConfigService.enableQRCodeCheck;

  @override
  Widget build(BuildContext context) {
    logger.v('ser:$ser, url:$url');

    return ExtendedImage.network(
      url,
      fit: BoxFit.contain,
      handleLoadingProgress: true,
      clearMemoryCacheIfFailed: true,
      enableSlideOutPage: enableSlideOutPage,
      mode: mode,
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

            return _ViewLoadingCupertion(progress: progress, ser: ser);

          ///if you don't want override completed widget
          ///please return null or state.completedWidget
          //return null;
          //return state.completedWidget;
          case LoadState.completed:
            fadeAnimationController.forward();

            onLoadCompleted?.call(state);

            Widget image = FadeTransition(
              opacity: fadeAnimationController,
              child: state.completedWidget,
            );

            if (checkPHashHide || checkQRCodeHide) {
              image = ImageWithHide(
                url: url,
                child: image,
                ser: ser,
                checkPHashHide: checkPHashHide,
                checkQRCodeHide: checkQRCodeHide,
              );
            }

            return image;

          case LoadState.failed:
            logger.d('Failed url: $url');
            fadeAnimationController.reset();

            final reload =
                (controller.vState.errCountMap[ser] ?? 0) < retryCount;
            if (reload) {
              Future.delayed(const Duration(milliseconds: 100))
                  .then((_) => reloadImage());
              controller.vState.errCountMap
                  .update(ser, (int value) => value + 1, ifAbsent: () => 1);
              logger.d('$ser 重试 第 ${controller.vState.errCountMap[ser]} 次');
            }

            if (reload) {
              // return const SizedBox.shrink();
              return _ViewLoadingCupertion(ser: ser);
            } else {
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
            }

          default:
            return null;
        }
      },
    );
  }
}

class ImageExtProvider extends GetView<ViewExtController> {
  ImageExtProvider({
    Key? key,
    required this.image,
    required this.ser,
    required this.fadeAnimationController,
    required this.reloadImage,
    this.imageHeight,
    this.imageWidth,
    this.retryCount = 5,
    this.onLoadCompleted,
    required this.initGestureConfigHandler,
    required this.onDoubleTap,
    this.mode = ExtendedImageMode.none,
    this.enableSlideOutPage = false,
  }) : super(key: key);

  final ImageProvider image;
  final int ser;
  final AnimationController fadeAnimationController;
  final VoidCallback reloadImage;
  final double? imageHeight;
  final double? imageWidth;
  final int retryCount;
  final ValueChanged<ExtendedImageState>? onLoadCompleted;
  final InitGestureConfigHandler initGestureConfigHandler;
  final DoubleTap? onDoubleTap;
  final ExtendedImageMode mode;
  final bool enableSlideOutPage;

  final EhConfigService ehConfigService = Get.find();

  @override
  Widget build(BuildContext context) {
    return ExtendedImage(
      image: image,
      fit: BoxFit.contain,
      handleLoadingProgress: true,
      clearMemoryCacheIfFailed: true,
      enableSlideOutPage: enableSlideOutPage,
      mode: mode,
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

            return _ViewLoadingCupertion(progress: progress, ser: ser);

          case LoadState.completed:
            fadeAnimationController.forward();
            onLoadCompleted?.call(state);

            Widget image = controller.vState.viewMode != ViewMode.topToBottom
                ? Hero(
                    tag: '$ser',
                    child: state.completedWidget,
                    createRectTween: (Rect? begin, Rect? end) =>
                        MaterialRectCenterArcTween(begin: begin, end: end),
                  )
                : state.completedWidget;

            image = FadeTransition(
              opacity: fadeAnimationController,
              child: image,
            );

            return image;

          case LoadState.failed:
            fadeAnimationController.reset();

            // logger.d('Failed e: ${state.lastException}\n${state.lastStack}');

            bool reload = false;
            reload = (controller.vState.errCountMap[ser] ?? 0) < retryCount;
            if (reload) {
              Future.delayed(const Duration(milliseconds: 100))
                  .then((_) => reloadImage());
              controller.vState.errCountMap
                  .update(ser, (int value) => value + 1, ifAbsent: () => 1);
              logger.d('$ser 重试 第 ${controller.vState.errCountMap[ser]} 次');
            }

            if (reload) {
              // return const SizedBox.shrink();
              return _ViewLoadingCupertion(ser: ser);
            } else {
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
            }

          default:
            return null;
        }
      },
    );
  }
}

class ImageWithHide extends StatefulWidget {
  const ImageWithHide({
    Key? key,
    required this.url,
    required this.child,
    required this.ser,
    this.checkPHashHide = false,
    this.checkQRCodeHide = false,
  }) : super(key: key);
  final String url;
  final Widget child;
  final int ser;

  final bool checkPHashHide;
  final bool checkQRCodeHide;

  @override
  State<ImageWithHide> createState() => _ImageWithHideState();
}

class _ImageWithHideState extends State<ImageWithHide> {
  final ImageHideController imageHideController = Get.find();
  late Future<bool> _future;

  final ViewExtController viewController = Get.find();

  ViewExtState get vState => viewController.vState;

  Future<bool> _futureFunc() async {
    if (!widget.checkQRCodeHide) {
      return imageHideController.checkPHashHide(widget.url);
    } else if (!widget.checkPHashHide) {
      return imageHideController.checkQRCodeHide(widget.url);
    }
    return await imageHideController.checkPHashHide(widget.url) ||
        await imageHideController.checkQRCodeHide(widget.url);
  }

  @override
  void initState() {
    super.initState();
    _future = _futureFunc();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool?>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data ?? false) {
              final GalleryImage? _tmpImage = vState.imageMap?[widget.ser];
              if (_tmpImage != null) {
                vState.galleryPageController?.uptImageBySer(
                  ser: widget.ser,
                  imageCallback: (image) => image.copyWith(hide: true),
                );

                Future.delayed(const Duration(milliseconds: 100)).then(
                    (value) => viewController.update(
                        [idSlidePage, '$idImageListView${widget.ser}']));
              }
              return ViewAD(ser: widget.ser);
            } else {
              return widget.child;
            }
          } else {
            return ViewLoading(
              ser: widget.ser,
              progress: 1.0,
              animationEnabled: false,
            );
          }
        });
  }
}

class _ViewLoadingCupertion extends StatelessWidget {
  const _ViewLoadingCupertion({
    Key? key,
    this.progress,
    required this.ser,
    this.animationEnabled = true,
  }) : super(key: key);

  final double? progress;
  final int ser;
  final bool animationEnabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: context.mediaQueryShortestSide,
        minWidth: context.width / 2 - kPageViewPadding,
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                constraints: const BoxConstraints(
                  maxHeight: 100,
                  maxWidth: 100,
                ),
                child: const CupertinoActivityIndicator(
                  radius: 30,
                ),
              ),
              Text(
                progress != null ? '${((progress ?? 0) * 100).round()}' : '',
                style: const TextStyle(
                  color: CupertinoColors.systemGrey6,
                  height: 1,
                  fontSize: 10,
                ),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$ser',
                  style: const TextStyle(
                    color: CupertinoColors.systemGrey6,
                    height: 1,
                  ),
                ).paddingSymmetric(horizontal: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ViewLoading extends StatelessWidget {
  const _ViewLoading({
    Key? key,
    this.progress,
    required this.ser,
    this.animationEnabled = true,
  }) : super(key: key);

  final double? progress;
  final int ser;
  final bool animationEnabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: context.mediaQueryShortestSide,
        minWidth: context.width / 2 - kPageViewPadding,
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            constraints: const BoxConstraints(
              maxHeight: 100,
              maxWidth: 100,
            ),
            child: SleekCircularSlider(
              appearance: CircularSliderAppearance(
                animationEnabled: animationEnabled,
                infoProperties: InfoProperties(
                    mainLabelStyle:
                        const TextStyle(color: CupertinoColors.systemGrey6)),
                customWidths: CustomSliderWidths(progressBarWidth: 10),
              ),
              min: 0,
              max: 100,
              initialValue: (progress ?? 0) * 100,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                    height: 20,
                    width: 20,
                    child: progress == null
                        ? const CupertinoActivityIndicator(radius: 8)
                        : null),
                Text(
                  '$ser',
                  style: const TextStyle(
                    color: CupertinoColors.systemGrey6,
                    height: 1,
                  ),
                ).paddingSymmetric(horizontal: 4),
                const SizedBox(height: 20, width: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ViewTopBar extends GetView<ViewExtController> {
  const ViewTopBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.mediaQueryPadding.top + kTopBarHeight,
      width: context.mediaQuery.size.width,
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: context.mediaQueryPadding.horizontal / 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    MouseRegionClick(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          Get.back();
                        },
                        child: Container(
                          width: 40,
                          height: kTopBarButtonHeight,
                          child: const Icon(
                            FontAwesomeIcons.chevronLeft,
                            color: CupertinoColors.systemGrey6,
                            // size: 24,
                          ),
                        ),
                      ),
                    ),
                    // GetBuilder<ViewExtController>(
                    //   id: idViewTopBar,
                    //   builder: (logic) {
                    //     return Container(
                    //       alignment: Alignment.center,
                    //       height: kTopBarButtonHeight,
                    //       child: Text(
                    //         '${logic.vState.currentItemIndex + 1}/${logic.vState.filecount}',
                    //         style: const TextStyle(
                    //           color: CupertinoColors.systemGrey6,
                    //         ),
                    //       ),
                    //     );
                    //   },
                    // ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (context.width >= kThresholdTabletWidth)
                          ControllerButtonBar(
                            controller: controller,
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            showLable: false,
                            // showLable: false,
                          ),
                        MouseRegionClick(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              Get.toNamed(EHRoutes.readSeting);
                            },
                            child: Container(
                              width: 40,
                              margin: const EdgeInsets.only(right: 8.0),
                              height: kTopBarButtonHeight,
                              child: const Icon(
                                FontAwesomeIcons.ellipsisH,
                                color: CupertinoColors.systemGrey6,
                                // size: 24,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                GetBuilder<ViewExtController>(
                  id: idViewTopBar,
                  builder: (logic) {
                    return Container(
                      alignment: Alignment.center,
                      height: kTopBarButtonHeight,
                      child: Text(
                        '${logic.vState.currentItemIndex + 1}/${logic.vState.filecount}',
                        style: const TextStyle(
                          color: CupertinoColors.systemGrey6,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ).frosted(
        height: context.mediaQueryPadding.top + kTopBarHeight,
        width: context.mediaQuery.size.width,
        blur: 20,
        frostColor: Colors.black,
      ),
    );
  }
}

const _kBottomTextStyle = TextStyle(color: Colors.white, fontSize: 10);

class ViewBottomBar extends GetView<ViewExtController> {
  const ViewBottomBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ViewExtController>(
      id: idViewBottomBar,
      builder: (logic) {
        logic.vState.bottomBarHeight = context.mediaQueryPadding.bottom +
            (context.width < kThresholdTabletWidth ? kBottomBarHeight : 0) +
            kSliderBarHeight +
            (logic.vState.showThumbList ? kThumbListViewHeight : 0);

        return AnimatedContainer(
          height: controller.vState.bottomBarHeight,
          width: context.mediaQuery.size.width,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          child: Column(
            children: [
              // 缩略图栏
              AnimatedContainer(
                height: logic.vState.showThumbList ? kThumbListViewHeight : 0,
                child: const ThumbnailListView(),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              ),
              // 控制栏
              const BottomBarControlWidget(),
            ],
          ).frosted(
            height: context.mediaQueryPadding.bottom +
                kBottomBarHeight +
                kSliderBarHeight +
                kThumbListViewHeight,
            width: context.mediaQuery.size.width,
            blur: 20,
            // frostColor: Colors.grey[700]!,
            frostColor: Colors.black,
          ),
        );
      },
    );
  }
}

class BottomBarControlWidget extends GetView<ViewExtController> {
  const BottomBarControlWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ViewExtController>(
      id: idIconBar,
      builder: (logic) {
        return Padding(
          padding: EdgeInsets.symmetric(
              horizontal: context.mediaQueryPadding.horizontal / 2 + 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 滑动控件
              GetBuilder<ViewExtController>(
                id: idViewPageSlider,
                builder: (logic) {
                  return SizedBox(
                    height: kSliderBarHeight,
                    child: ViewPageSlider(
                      max: logic.vState.filecount - 1.0,
                      sliderValue: min(logic.vState.sliderValue,
                          logic.vState.filecount - 1.0),
                      onChangedEnd: logic.handOnSliderChangedEnd,
                      onChanged: logic.handOnSliderChanged,
                      reverse: logic.vState.viewMode == ViewMode.rightToLeft,
                    ).paddingSymmetric(vertical: 8),
                  );
                },
              ),
              // 按钮栏
              if (context.width < kThresholdTabletWidth)
                ControllerButtonBar(
                  controller: logic,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  // showLable: false,
                ),
            ],
          ),
        );
      },
    );
  }
}

class ControllerButtonBar extends StatelessWidget {
  const ControllerButtonBar({
    Key? key,
    required this.controller,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.max,
    this.showLable = true,
  }) : super(key: key);

  final ViewExtController controller;
  final MainAxisAlignment mainAxisAlignment;
  final MainAxisSize mainAxisSize;
  final bool showLable;

  static const buttonWidth = 44.0;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: <Widget>[
        // 分享按钮
        MouseRegionClick(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              controller.tapShare(context);
            },
            child: Container(
              width: buttonWidth,
              height: kBottomBarButtonHeight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    FontAwesomeIcons.shareFromSquare,
                    color: CupertinoColors.systemGrey6,
                    size: 22,
                  ),
                  // const Spacer(),
                  if (showLable)
                    Expanded(
                      child: Center(
                        child: Text(
                          L10n.of(context).share,
                          style: _kBottomTextStyle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),

        // 双页切换按钮
        MouseRegionClick(
          disable: controller.vState.viewMode == ViewMode.topToBottom,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (controller.vState.viewMode != ViewMode.topToBottom) {
                controller.switchColumnMode();
              }
            },
            child: Container(
              width: buttonWidth,
              height: kBottomBarButtonHeight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GetBuilder<ViewExtController>(
                    id: idViewColumnModeIcon,
                    builder: (logic) {
                      return Icon(
                        FontAwesomeIcons.bookOpen,
                        size: 22,
                        color: () {
                          if (logic.vState.viewMode == ViewMode.topToBottom) {
                            return CupertinoColors.systemGrey;
                          }

                          switch (logic.vState.columnMode) {
                            case ViewColumnMode.single:
                              return CupertinoColors.systemGrey6;
                            case ViewColumnMode.oddLeft:
                              return CupertinoColors.activeBlue;
                            case ViewColumnMode.evenLeft:
                              return CupertinoColors.activeOrange;
                          }
                        }(),
                      );
                    },
                  ),
                  if (showLable)
                    Expanded(
                      child: Center(
                        child: Text(
                          'Double',
                          style: _kBottomTextStyle.copyWith(
                              color: controller.vState.viewMode ==
                                      ViewMode.topToBottom
                                  ? CupertinoColors.systemGrey
                                  : null),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),

        // 自动阅读按钮
        MouseRegionClick(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              controller.tapAutoRead(context);
            },
            onLongPress: () {
              controller.longTapAutoRead(context);
            },
            child: GetBuilder<ViewExtController>(
              id: idAutoReadIcon,
              builder: (logic) {
                return Container(
                  width: buttonWidth,
                  height: kBottomBarButtonHeight,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        FontAwesomeIcons.hourglassHalf,
                        size: 22,
                        color: () {
                          // if (logic.vState.viewMode ==
                          //     ViewMode.topToBottom) {
                          //   return CupertinoColors.systemGrey;
                          // }

                          return logic.vState.autoRead
                              ? CupertinoColors.activeBlue
                              : CupertinoColors.systemGrey6;
                        }(),
                      ),
                      if (showLable)
                        const Expanded(
                          child: Center(
                            child: Text(
                              'Auto',
                              style: _kBottomTextStyle,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        // else
        //   const SizedBox(width: 40),

        // 缩略图预览按钮
        if (true)
          MouseRegionClick(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                controller.switchShowThumbList();
              },
              onLongPress: () {
                vibrateUtil.light();
                controller.thumbScrollTo();
              },
              child: Container(
                width: buttonWidth,
                height: kBottomBarButtonHeight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GetBuilder<ViewExtController>(
                      id: idShowThumbListIcon,
                      builder: (logic) {
                        return Icon(
                          FontAwesomeIcons.images,
                          size: 22,
                          color: logic.vState.showThumbList
                              ? CupertinoColors.activeBlue
                              : CupertinoColors.systemGrey6,
                          // color: CupertinoColors.systemGrey6,
                        );
                      },
                    ),
                    if (showLable)
                      const Expanded(
                        child: Center(
                          child: Text(
                            'Thumb',
                            style: _kBottomTextStyle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

        // else
        //   const SizedBox(width: 40),
      ],
    );
  }
}

class ThumbnailListView extends GetView<ViewExtController> {
  const ThumbnailListView({Key? key}) : super(key: key);

  GalleryPageController? get galleryPageController =>
      controller.vState.galleryPageController;

  static const kBorderWidth = 2.0;
  static const kRadius = 4.0;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ViewExtController>(
      id: idThumbnailListView,
      builder: (logic) {
        return Stack(
          children: [
            Container(
              height: kThumbListViewHeight,
              // padding: const EdgeInsets.symmetric(vertical: 8),
              // padding: EdgeInsets.symmetric(
              //     horizontal: context.width / 2 - kThumbImageWidth / 2 - 2),
              child: ScrollablePositionedList.builder(
                // physics: const ClampingScrollPhysics(),
                // padding: EdgeInsets.symmetric(
                //     horizontal: context.width / 2 - kThumbImageWidth / 2 - 2),
                itemScrollController: logic.thumbScrollController,
                itemPositionsListener: logic.thumbPositionsListener,
                itemCount: controller.vState.filecount,
                scrollDirection: Axis.horizontal,
                reverse: logic.vState.viewMode == ViewMode.rightToLeft,
                itemBuilder: (context, index) {
                  // 缩略图
                  late Widget thumb;
                  switch (logic.vState.loadFrom) {
                    case LoadFrom.download:
                      final path = controller.vState.imagePathList[index];

                      thumb = ExtendedImage.file(
                        File(path),
                        fit: BoxFit.cover,
                      );
                      break;
                    case LoadFrom.gallery:
                      thumb = FutureThumbl(itemSer: index + 1);
                      break;
                    case LoadFrom.archiver:
                      final asyncFile =
                          controller.vState.asyncArchiveFiles[index];
                      // thumb = Container(color: Colors.white);
                      thumb = FutureThumblArchive(
                          gid: controller.vState.gid,
                          asyncArchiveFile: asyncFile);
                      break;
                  }

                  return GestureDetector(
                    onTap: () => logic.jumpToPage(index),
                    child: Obx(() {
                      final isCurrent = index == logic.vState.currentItemIndex;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: kThumbImageWidth,
                        child: Column(
                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: (kThumbListViewHeight / 14).round(),
                              child: Container(
                                alignment: Alignment.center,
                                // child: _buildThumb(isCurrent, thumb),
                                child: AnimatedCrossFade(
                                  firstChild: _buildThumb(false, thumb),
                                  secondChild: _buildThumb(true, thumb),
                                  duration: 400.milliseconds,
                                  crossFadeState: isCurrent
                                      ? CrossFadeState.showSecond
                                      : CrossFadeState.showFirst,
                                ),
                              ),
                            ),
                            if (logic.vState.showThumbList)
                              Expanded(
                                flex: 1,
                                child: Text(
                                  '${index + 1}',
                                  style: _kBottomTextStyle,
                                ),
                              ),
                          ],
                        ),
                      );
                    }),
                  );
                },
              ),
            ),

            // 暂时不使用。改为默认同步
            if (logic.vState.showThumbList && false)
              GestureDetector(
                onTap: () {
                  vibrateUtil.light();
                  logic.switchSyncThumb();
                },
                child: Container(
                  width: 30,
                  height: 30,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: const BorderRadius.all(Radius.circular(40.0)),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    FontAwesomeIcons.lock,
                    size: 20,
                    color: logic.vState.syncThumbList
                        ? CupertinoColors.activeOrange
                        : CupertinoColors.systemGrey6,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Container _buildThumb(bool isCurrent, Widget thumb) {
    return Container(
      decoration: BoxDecoration(
        border: isCurrent
            ? Border.all(
                color: CupertinoColors.systemTeal,
                width: kBorderWidth,
              )
            : null,
        borderRadius: BorderRadius.circular(kRadius + kBorderWidth),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(kRadius),
        child: Container(
          child: MouseRegionClick(child: thumb),
        ),
      ),
    );
  }
}

class FutureThumblArchive extends StatefulWidget {
  const FutureThumblArchive(
      {Key? key, required this.asyncArchiveFile, this.gid})
      : super(key: key);
  final AsyncArchiveFile asyncArchiveFile;
  final String? gid;

  @override
  State<FutureThumblArchive> createState() => _FutureThumblArchiveState();
}

class _FutureThumblArchiveState extends State<FutureThumblArchive> {
  late Future<File> _future;
  final ViewExtController viewExtController = Get.find();

  Future<File> getFileData(String? gid, AsyncArchiveFile file) async {
    return await viewExtController.getArchiveFile(gid, file);
  }

  @override
  void initState() {
    _future = getFileData(widget.gid, widget.asyncArchiveFile);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<File?>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            final _data = snapshot.data;
            logger.v('${_data.runtimeType}');
            if (_data != null) {
              return ExtendedImage.file(
                _data,
                fit: BoxFit.cover,
              );
            } else {
              logger.d('${snapshot.error} ${snapshot.stackTrace}');
              return buildErrorWidget();
            }
          } else {
            return buildPlaceholder();
          }
        });
  }

  Widget buildPlaceholder() {
    return const CupertinoActivityIndicator();
  }

  GestureDetector buildErrorWidget() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _future = getFileData(widget.gid, widget.asyncArchiveFile);
        setState(() {});
      },
      child: const Icon(FontAwesomeIcons.rotateRight,
          color: CupertinoColors.destructiveRed),
    );
  }
}

class FutureThumbl extends StatefulWidget {
  const FutureThumbl({
    Key? key,
    required this.itemSer,
  }) : super(key: key);

  final int itemSer;

  @override
  _FutureThumblState createState() => _FutureThumblState();
}

class _FutureThumblState extends State<FutureThumbl> {
  final ViewExtController logic = Get.find();
  late Future<GalleryImage?> _future;

  @override
  void initState() {
    _future = logic.fetchThumb(widget.itemSer);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<GalleryImage?>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              logger.e('${snapshot.error}\n${snapshot.stackTrace}');
              return builderrorWidget();
            }

            final _image = snapshot.data;
            if (_image != null &&
                _image.thumbUrl != null &&
                _image.thumbUrl!.isNotEmpty) {
              logger.v('${_image.ser}  ${_image.thumbUrl}');

              if (_image.largeThumb ?? false) {
                return EhNetworkImage(
                  imageUrl: _image.thumbUrl ?? '',
                  placeholder: (_, __) {
                    return buildPlaceholder();
                  },
                  errorWidget: (ctx, url, error) {
                    return builderrorWidget();
                  },
                );
              } else {
                return LayoutBuilder(builder:
                    (BuildContext context, BoxConstraints constraints) {
                  final imageSize =
                      Size(_image.thumbWidth!, _image.thumbHeight!);
                  final size =
                      Size(constraints.maxWidth, constraints.maxHeight);
                  final FittedSizes fittedSizes =
                      applyBoxFit(BoxFit.contain, imageSize, size);

                  // logger.d(
                  //     '${fittedSizes.source} ${fittedSizes.destination} $_subWidth $_subHeight');

                  return ExtendedImageRect(
                    url: _image.thumbUrl!,
                    height: fittedSizes.destination.height,
                    width: fittedSizes.destination.width,
                    sourceRect: Rect.fromLTWH(
                      _image.offSet! + 1,
                      1.0,
                      _image.thumbWidth! - 2,
                      _image.thumbHeight! - 2,
                    ),
                    onLoadComplet: () =>
                        logic.handOnLoadCompletExtendedImageRect(
                            url: _image.thumbUrl!),
                  );
                });
              }
            } else {
              logger.d('error ${_image?.ser}');
              return builderrorWidget();
            }
          } else {
            return buildPlaceholder();
          }
        });
  }

  Widget buildPlaceholder() {
    return const CupertinoActivityIndicator();
  }

  GestureDetector builderrorWidget() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _future = logic.fetchThumb(widget.itemSer);
        setState(() {});
      },
      child: const Icon(FontAwesomeIcons.redoAlt,
          color: CupertinoColors.destructiveRed),
    );
  }
}

/// 页面滑条
class ViewPageSlider extends StatefulWidget {
  const ViewPageSlider({
    Key? key,
    required this.max,
    required this.sliderValue,
    required this.onChangedEnd,
    required this.onChanged,
    this.reverse = false,
  }) : super(key: key);

  final double max;
  final double sliderValue;
  final ValueChanged<double> onChangedEnd;
  final ValueChanged<double> onChanged;
  final bool reverse;

  @override
  _ViewPageSliderState createState() => _ViewPageSliderState();
}

class _ViewPageSliderState extends State<ViewPageSlider> {
  late double _value;

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
    final minText = Text(
      '${widget.sliderValue.round() + 1}',
      style: const TextStyle(color: CupertinoColors.systemGrey6),
    ).paddingSymmetric(horizontal: 4);

    final maxText = Text(
      '${widget.max.round() + 1}',
      style: const TextStyle(color: CupertinoColors.systemGrey6),
    ).paddingSymmetric(horizontal: 4);

    return Container(
      child: Row(
        children: <Widget>[
          if (widget.reverse) maxText else minText,
          Expanded(
            child: Transform.rotate(
              angle: widget.reverse ? math.pi : 0.0,
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
                },
              ),
            ),
          ),
          if (widget.reverse) minText else maxText,
        ],
      ),
    );
  }
}

Future<void> showShareActionSheet(
  BuildContext context, {
  String? imageUrl,
  String? origImageUrl,
  String? filePath,
  LoadFrom loadType = LoadFrom.gallery,
}) {
  return showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) {
        final CupertinoActionSheet dialog = CupertinoActionSheet(
          cancelButton: CupertinoActionSheetAction(
              onPressed: () {
                Get.back();
              },
              child: Text(L10n.of(context).cancel)),
          actions: <Widget>[
            CupertinoActionSheetAction(
              onPressed: () async {
                logger.v('保存到手机');
                Get.back();
                final bool rult = await Api.saveImage(
                  context: context,
                  imageUrl: imageUrl,
                  filePath: filePath,
                );
                if (rult) {
                  showToast(L10n.of(context).saved_successfully);
                }
              },
              child: Text(L10n.of(context).save_into_album),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                logger.v('系统分享');
                Get.back();
                Api.shareImageExtended(imageUrl: imageUrl, filePath: filePath);
              },
              child: Text(L10n.of(context).system_share),
            ),
          ],
        );
        return EhDarkCupertinoTheme(child: dialog);
      });
}

Future<void> showImageSheet(
  BuildContext context,
  VoidCallback reload, {
  String? title,
  String? imageUrl,
  String? origImageUrl,
  String? filePath,
}) {
  return showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) {
        final CupertinoActionSheet dialog = CupertinoActionSheet(
          title: title != null ? Text(title) : null,
          cancelButton: CupertinoActionSheetAction(
              onPressed: () {
                Get.back();
              },
              child: Text(L10n.of(context).cancel)),
          actions: <Widget>[
            CupertinoActionSheetAction(
                onPressed: () {
                  reload();
                  Get.back();
                },
                child: Text(L10n.of(context).reload_image)),
            CupertinoActionSheetAction(
                onPressed: () {
                  Get.back();
                  showShareActionSheet(
                    context,
                    imageUrl: imageUrl,
                    filePath: filePath,
                    origImageUrl: origImageUrl,
                  );
                },
                child: Text(L10n.of(context).share_image)),
          ],
        );
        return EhDarkCupertinoTheme(child: dialog);
      });
}
