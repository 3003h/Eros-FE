import 'dart:math';

import 'package:dio/dio.dart';
import 'package:extended_image/extended_image.dart';
import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/models/base/eh_models.dart';
import 'package:fehviewer/pages/image_view_ext/controller/view_ext_state.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/utility.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/view_ext_contorller.dart';
import 'view_ext.dart';

typedef DoubleClickAnimationListener = void Function();

class ViewImageExt extends StatefulWidget {
  const ViewImageExt({
    Key? key,
    required this.imageSer,
  }) : super(key: key);

  final int imageSer;

  @override
  _ViewImageExtState createState() => _ViewImageExtState();
}

class _ViewImageExtState extends State<ViewImageExt>
    with TickerProviderStateMixin {
  final ViewExtController controller = Get.find();
  late AnimationController _doubleClickAnimationController;
  Animation<double>? _doubleClickAnimation;
  late DoubleClickAnimationListener _doubleClickAnimationListener;
  // List<double> doubleTapScales = <double>[1.0, 2.0, 3.0];

  late AnimationController _fadeAnimationController;

  ViewExtState get vState => controller.vState;

  @override
  void initState() {
    _doubleClickAnimationController = AnimationController(
        duration: const Duration(milliseconds: 150), vsync: this);

    _fadeAnimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));

    if (vState.loadType == LoadType.network) {
      controller.imageFuture = controller.fetchImage(widget.imageSer);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    final InitGestureConfigHandler _initGestureConfigHandler =
        (ExtendedImageState state) {
      double? initialScale = 1.0;

      if (state.extendedImageInfo != null) {
        initialScale = initScale(
            size: size,
            initialScale: initialScale,
            imageSize: Size(state.extendedImageInfo!.image.width.toDouble(),
                state.extendedImageInfo!.image.height.toDouble()));
        // logger.d('initialScale $initialScale');
      }
      return GestureConfig(
          inPageView: true,
          initialScale: 1,
          // maxScale: max(initialScale!, 5.0),
          maxScale: 10.0,
          // animationMaxScale: max(initialScale, 5.0),
          animationMaxScale: 10.0,
          initialAlignment: InitialAlignment.center,
          //you can cache gesture state even though page view page change.
          //remember call clearGestureDetailsCache() method at the right time.(for example,this page dispose)
          cacheGesture: false);
    };

    final DoubleTap onDoubleTap = (ExtendedImageGestureState state) {
      ///you can use define pointerDownPosition as you can,
      ///default value is double tap pointer down postion.
      final Offset? pointerDownPosition = state.pointerDownPosition;
      final double begin = state.gestureDetails!.totalScale ?? 0.0;
      double end;

      //remove old
      _doubleClickAnimation?.removeListener(_doubleClickAnimationListener);

      //stop pre
      _doubleClickAnimationController.stop();

      //reset to use
      _doubleClickAnimationController.reset();

      // logger.d('begin[$begin]  doubleTapScales[1]${doubleTapScales[1]}');

      if ((begin - vState.doubleTapScales[0]).abs() < 0.0005) {
        end = vState.doubleTapScales[1];
      } else if ((begin - vState.doubleTapScales[1]).abs() < 0.0005 &&
          vState.doubleTapScales.length > 2) {
        end = vState.doubleTapScales[2];
      } else {
        end = vState.doubleTapScales[0];
      }

      // logger.d('to Scales $end');

      _doubleClickAnimationListener = () {
        state.handleDoubleTap(
            scale: _doubleClickAnimation!.value,
            doubleTapPosition: pointerDownPosition);
      };
      _doubleClickAnimation = _doubleClickAnimationController
          .drive(Tween<double>(begin: begin, end: end));

      _doubleClickAnimation!.addListener(_doubleClickAnimationListener);

      _doubleClickAnimationController.forward();
    };

    if (vState.loadType == LoadType.file) {
      /// 从已下载查看的形式
      final path = vState.imagePathList[widget.imageSer - 1];

      final Widget image = ExtendedImage.file(
        File(path),
        fit: BoxFit.contain,
        enableSlideOutPage: true,
        mode: ExtendedImageMode.gesture,
        initGestureConfigHandler: _initGestureConfigHandler,
        onDoubleTap: onDoubleTap,
        loadStateChanged: (ExtendedImageState state) {
          if (state.extendedImageLoadState == LoadState.completed) {
            final ImageInfo? imageInfo = state.extendedImageInfo;
            controller.setScale100(imageInfo!, size);
          }
        },
      );

      return image.paddingSymmetric(horizontal: 2.0);
    } else {
      /// 在线查看的形式
      Widget image = GetBuilder<ViewExtController>(
        builder: (ViewExtController controller) {
          final ViewExtState vState = controller.vState;

          return FutureBuilder<GalleryImage?>(
              future: controller.imageFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError || snapshot.data == null) {
                    String _errInfo = '';
                    if (snapshot.error is DioError) {
                      final DioError dioErr = snapshot.error as DioError;
                      logger.e('${dioErr.error}');
                      _errInfo = dioErr.type.toString();
                    } else {
                      _errInfo = snapshot.error.toString();
                    }

                    if ((vState.errCountMap[widget.imageSer] ?? 0) <
                        vState.retryCount) {
                      Future.delayed(const Duration(milliseconds: 100)).then(
                          (_) => controller.reloadImage(widget.imageSer,
                              changeSource: true));
                      vState.errCountMap.update(
                          widget.imageSer, (int value) => value + 1,
                          ifAbsent: () => 1);

                      logger.v('${vState.errCountMap}');
                      logger.d(
                          '${widget.imageSer} 重试 第 ${vState.errCountMap[widget.imageSer]} 次');
                    }
                    if ((vState.errCountMap[widget.imageSer] ?? 0) >=
                        vState.retryCount) {
                      return ViewError(ser: widget.imageSer, errInfo: _errInfo);
                    } else {
                      return const SizedBox.shrink();
                    }
                  }
                  final GalleryImage? _image = snapshot.data;

                  /*Widget image = ExtendedImage.network(
                    _image?.imageUrl ?? '',
                    fit: BoxFit.contain,
                    enableSlideOutPage: true,
                    mode: ExtendedImageMode.gesture,
                    initGestureConfigHandler: _initGestureConfigHandler,
                    onDoubleTap: onDoubleTap,
                    loadStateChanged: (ExtendedImageState state) {
                      if (state.extendedImageLoadState == LoadState.completed) {
                        final ImageInfo? imageInfo = state.extendedImageInfo;
                        _setScale100(imageInfo!);
                      }
                    },
                  );*/

                  Widget image = ImageExt(
                    url: _image?.imageUrl ?? '',
                    onDoubleTap: onDoubleTap,
                    ser: widget.imageSer,
                    reloadImage: () => controller.reloadImage(widget.imageSer,
                        changeSource: true),
                    fadeAnimationController: _fadeAnimationController,
                    initGestureConfigHandler: _initGestureConfigHandler,
                    // onLoadCompleted: () {},
                  );

                  if (Global.inDebugMode) {
                    image = Stack(
                      alignment: Alignment.center,
                      // fit: widget.expand ? StackFit.expand : StackFit.loose,
                      fit: StackFit.expand,
                      children: [
                        image,
                        Positioned(
                          left: 4,
                          child: Text('${_image?.ser ?? ''}',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color:
                                      CupertinoColors.secondarySystemBackground,
                                  shadows: <Shadow>[
                                    Shadow(
                                      color: Colors.black,
                                      offset: Offset(1, 1),
                                      blurRadius: 2,
                                    )
                                  ])),
                        ),
                      ],
                    );
                  }

                  return image;
                } else {
                  return ViewLoading(
                    ser: widget.imageSer,
                  );
                  // return const CupertinoActivityIndicator(
                  //   radius: 20,
                  // );
                }
              });
        },
      );

      return image;
    }
  }
}
