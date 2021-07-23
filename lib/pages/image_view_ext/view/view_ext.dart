import 'package:extended_image/extended_image.dart';
import 'package:fehviewer/common/service/depth_service.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/network/gallery_request.dart';
import 'package:fehviewer/pages/gallery/controller/gallery_page_controller.dart';
import 'package:fehviewer/route/routes.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liquid_progress_indicator_ns/liquid_progress_indicator.dart';

import '../common.dart';
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

class ViewLoading extends StatelessWidget {
  const ViewLoading({Key? key, required this.ser}) : super(key: key);
  final int ser;

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
        children: <Widget>[
          Text(
            '$ser',
            style: const TextStyle(
              fontSize: 50,
              color: CupertinoColors.systemGrey6,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const CupertinoActivityIndicator(),
              const SizedBox(width: 5),
              Text(
                '${S.of(context).loading}...',
                style: const TextStyle(
                  color: CupertinoColors.systemGrey6,
                ),
              ),
            ],
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

class ViewTopBar extends StatelessWidget {
  const ViewTopBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.7),
      height: context.mediaQueryPadding.top + kTopBarHeight,
      width: context.mediaQuery.size.width,
      padding: EdgeInsets.symmetric(
          horizontal: context.mediaQueryPadding.horizontal / 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
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
          GetBuilder<ViewExtController>(
            id: idViewTopBar,
            builder: (logic) {
              return Container(
                alignment: Alignment.center,
                height: kBottomBarHeight,
                child: Text(
                  '${logic.vState.currentItemIndex + 1}/${logic.vState.filecount}',
                  style: const TextStyle(
                    color: CupertinoColors.systemGrey6,
                  ),
                ),
              );
            },
          ),
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
    );
  }
}

const _kBottomTextStyle = TextStyle(color: Colors.white, fontSize: 10);

class ViewBottomBar extends GetView<ViewExtController> {
  const ViewBottomBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.7),
      height: context.mediaQueryPadding.bottom + kTopBarHeight * 2,
      width: context.mediaQuery.size.width,
      padding: EdgeInsets.symmetric(
          horizontal: context.mediaQueryPadding.horizontal / 2 + 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GetBuilder<ViewExtController>(
            id: idViewPageSlider,
            builder: (logic) {
              return SizedBox(
                height: kBottomBarHeight,
                child: ViewPageSlider(
                  max: logic.vState.filecount - 1.0,
                  sliderValue: logic.vState.sliderValue,
                  onChangedEnd: logic.handOnSliderChangedEnd,
                  onChanged: logic.handOnSliderChanged,
                ).paddingSymmetric(vertical: 8),
              );
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              // 分享按钮
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  controller.share(context);
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
                        style: _kBottomTextStyle,
                      ),
                    ],
                  ),
                ),
              ),

              // 自动阅读按钮
              if (1 == 1)
                GestureDetector(
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
                        width: 40,
                        height: kBottomBarHeight,
                        child: Column(
                          children: [
                            Icon(
                              LineIcons.hourglassHalf,
                              size: 26,
                              color: logic.vState.autoRead
                                  ? CupertinoColors.activeBlue
                                  : CupertinoColors.systemGrey6,
                            ),
                            const Spacer(),
                            const Text(
                              'Auto',
                              style: _kBottomTextStyle,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                )
              else
                const SizedBox.shrink(),

              // 双页切换按钮
              if (1 == 1)
                GestureDetector(
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
                        GetBuilder<ViewExtController>(
                          id: idViewColumnModeIcon,
                          builder: (logic) {
                            return Icon(
                              LineIcons.bookOpen,
                              size: 26,
                              color: () {
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
                        const Spacer(),
                        const Text(
                          '双页',
                          style: _kBottomTextStyle,
                        ),
                      ],
                    ),
                  ),
                )
              else
                const SizedBox.shrink(),
            ],
          ),
        ],
      ),
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
  }) : super(key: key);

  final double max;
  final double sliderValue;
  final ValueChanged<double> onChangedEnd;
  final ValueChanged<double> onChanged;

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
    return Container(
      child: Row(
        children: <Widget>[
          Text(
            '${widget.sliderValue.round() + 1}',
            style: const TextStyle(color: CupertinoColors.systemGrey6),
          ).paddingSymmetric(horizontal: 4),
          Expanded(
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
                }),
          ),
          Text(
            '${widget.max.round() + 1}',
            style: const TextStyle(color: CupertinoColors.systemGrey6),
          ).paddingSymmetric(horizontal: 4),
        ],
      ),
    );
  }
}

Future<void> showShareActionSheet(
  BuildContext context, {
  String? imageUrl,
  String? filePath,
  LoadType loadType = LoadType.network,
}) {
  return showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) {
        final CupertinoActionSheet dialog = CupertinoActionSheet(
          cancelButton: CupertinoActionSheetAction(
              onPressed: () {
                Get.back();
              },
              child: Text(S.of(context).cancel)),
          actions: <Widget>[
            CupertinoActionSheetAction(
                onPressed: () async {
                  logger.v('保存到手机');
                  Get.back();
                  final bool rult = await Api.saveImage(context,
                      imageUrl: imageUrl, filePath: filePath);
                  if (rult) {
                    showToast(S.of(context).saved_successfully);
                  }
                },
                child: Text(S.of(context).save_into_album)),
            CupertinoActionSheetAction(
                onPressed: () {
                  logger.v('系统分享');
                  Get.back();
                  Api.shareImageExtended(
                      imageUrl: imageUrl, filePath: filePath);
                },
                child: Text(S.of(context).system_share)),
          ],
        );
        return dialog;
      });
}

Future<void> showImageSheet(
    BuildContext context, String imageUrl, VoidCallback reload,
    {String? title}) {
  return showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) {
        final CupertinoActionSheet dialog = CupertinoActionSheet(
          title: title != null ? Text(title) : null,
          cancelButton: CupertinoActionSheetAction(
              onPressed: () {
                Get.back();
              },
              child: Text(S.of(context).cancel)),
          actions: <Widget>[
            CupertinoActionSheetAction(
                onPressed: () {
                  reload();
                  Get.back();
                },
                child: Text(S.of(context).reload_image)),
            CupertinoActionSheetAction(
                onPressed: () {
                  Get.back();
                  showShareActionSheet(context, imageUrl: imageUrl);
                },
                child: Text(S.of(context).share_image)),
          ],
        );
        return dialog;
      });
}
