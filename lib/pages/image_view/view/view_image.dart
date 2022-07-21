import 'dart:io';

import 'package:dio/dio.dart';
import 'package:extended_image/extended_image.dart';
import 'package:fehviewer/common/controller/image_hide_controller.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/component/exception/error.dart';
import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/models/base/eh_models.dart';
import 'package:fehviewer/pages/image_view/controller/view_state.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/utility.dart';
import 'package:fehviewer/utils/vibrate.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../common.dart';
import '../controller/view_controller.dart';
import 'view_widget.dart';

typedef DoubleClickAnimationListener = void Function();

class ViewImage extends StatefulWidget {
  const ViewImage({
    Key? key,
    required this.imageSer,
    this.initialScale = 1.0,
    this.enableDoubleTap = true,
    this.mode = ExtendedImageMode.gesture,
    this.enableSlideOutPage = true,
  }) : super(key: key);

  final int imageSer;
  final double initialScale;
  final bool enableDoubleTap;
  final ExtendedImageMode mode;
  final bool enableSlideOutPage;

  @override
  _ViewImageState createState() => _ViewImageState();
}

class _ViewImageState extends State<ViewImage> with TickerProviderStateMixin {
  final ViewExtController controller = Get.find();
  final EhConfigService ehConfigService = Get.find();

  late AnimationController _doubleClickAnimationController;
  Animation<double>? _doubleClickAnimation;
  late DoubleClickAnimationListener _doubleClickAnimationListener;

  late AnimationController _fadeAnimationController;

  ViewExtState get vState => controller.vState;

  bool get checkPHashHide => ehConfigService.enablePHashCheck;
  bool get checkQRCodeHide => ehConfigService.enableQRCodeCheck;

  @override
  void initState() {
    _doubleClickAnimationController = AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this);

    _fadeAnimationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: vState.fade ? 200 : 0));
    vState.fade = true;

    if (vState.loadFrom == LoadFrom.gallery) {
      controller.initFuture(widget.imageSer);
    }

    if (vState.loadFrom == LoadFrom.archiver) {
      controller.initArchiveFuture(widget.imageSer);
    }

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      controller.vState.fade = true;
      controller.vState.needRebuild = false;
    });

    vState.doubleTapScales[0] = widget.initialScale;

    super.initState();
  }

  @override
  void dispose() {
    _doubleClickAnimationController.dispose();
    _fadeAnimationController.dispose();
    super.dispose();
  }

  InitGestureConfigHandler get _initGestureConfigHandler =>
      (ExtendedImageState state) {
        final Size size = MediaQuery.of(context).size;
        double? initialScale = widget.initialScale;

        final _imageInfo = state.extendedImageInfo;
        if (_imageInfo != null) {
          initialScale = initScale(
              size: size,
              initialScale: initialScale,
              imageSize: Size(_imageInfo.image.width.toDouble(),
                  _imageInfo.image.height.toDouble()));

          vState.doubleTapScales[0] = initialScale ?? vState.doubleTapScales[0];
          vState.doubleTapScales[1] = initialScale != null
              ? initialScale * 2
              : vState.doubleTapScales[1];
        }
        return GestureConfig(
          inPageView: true,
          initialScale: initialScale ?? 1.0,
          maxScale: 10.0,
          // animationMaxScale: max(initialScale, 5.0),
          animationMaxScale: 10.0,
          initialAlignment: InitialAlignment.center,
          cacheGesture: false,
          hitTestBehavior: HitTestBehavior.opaque,
        );
      };

  /// 双击事件
  DoubleTap get _onDoubleTap => (ExtendedImageGestureState state) {
        ///you can use define pointerDownPosition as you can,
        ///default value is double tap pointer down postion.
        final Offset? pointerDownPosition = state.pointerDownPosition;
        final double begin = state.gestureDetails?.totalScale ?? 0.0;
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
              scale: _doubleClickAnimation?.value ?? 1.0,
              doubleTapPosition: pointerDownPosition);
        };
        _doubleClickAnimation = _doubleClickAnimationController.drive(
            Tween<double>(begin: begin, end: end)
                .chain(CurveTween(curve: Curves.easeInOutCubic)));

        _doubleClickAnimation?.addListener(_doubleClickAnimationListener);

        _doubleClickAnimationController.forward();
      };

  @override
  Widget build(BuildContext context) {
    switch (vState.loadFrom) {
      case LoadFrom.download:
        // 从已下载查看
        final path = vState.imagePathList[widget.imageSer - 1];
        return fileImage(path);
      case LoadFrom.gallery:
        // 从画廊页查看
        return getViewImage();
      case LoadFrom.archiver:
        return archiverImage();
      default:
        return const Text('None');
    }
  }

  /// 本地图片文件 构建Widget
  Widget fileImage(String path) {
    final Size size = MediaQuery.of(context).size;
    return ExtendedImage.file(
      File(path),
      fit: BoxFit.contain,
      enableSlideOutPage: widget.enableSlideOutPage,
      mode: widget.mode,
      initGestureConfigHandler: _initGestureConfigHandler,
      onDoubleTap: widget.enableDoubleTap ? _onDoubleTap : null,
      loadStateChanged: (ExtendedImageState state) {
        final ImageInfo? imageInfo = state.extendedImageInfo;
        if (state.extendedImageLoadState == LoadState.completed ||
            imageInfo != null) {
          // 加载完成 显示图片
          controller.setScale100(imageInfo!, size);

          // 重新设置图片容器大小
          if (vState.imageSizeMap[widget.imageSer] == null) {
            vState.imageSizeMap[widget.imageSer] = Size(
                imageInfo.image.width.toDouble(),
                imageInfo.image.height.toDouble());
            Future.delayed(const Duration(milliseconds: 100)).then((value) =>
                controller.update(['$idImageListView${widget.imageSer}']));
          }

          controller.onLoadCompleted(widget.imageSer);

          return controller.vState.viewMode != ViewMode.topToBottom
              ? Hero(
                  tag: '${widget.imageSer}',
                  child: state.completedWidget,
                  createRectTween: (Rect? begin, Rect? end) {
                    final tween =
                        MaterialRectCenterArcTween(begin: begin, end: end);
                    return tween;
                  },
                )
              : state.completedWidget;
        } else if (state.extendedImageLoadState == LoadState.loading) {
          // 显示加载中
          final ImageChunkEvent? loadingProgress = state.loadingProgress;
          final double? progress = loadingProgress?.expectedTotalBytes != null
              ? (loadingProgress?.cumulativeBytesLoaded ?? 0) /
                  (loadingProgress?.expectedTotalBytes ?? 1)
              : null;

          return ViewLoading(
            ser: widget.imageSer,
            progress: progress,
            duration: vState.viewMode != ViewMode.topToBottom
                ? const Duration(milliseconds: 50)
                : null,
          );
        }
      },
    );
  }

  /// 本地图片文件 构建Widget
  Widget providerImage(ImageProvider imageProvider, String url, int ser) {
    final Size size = MediaQuery.of(context).size;
    return ExtendedImage(
      image: imageProvider,
      fit: BoxFit.contain,
      enableSlideOutPage: widget.enableSlideOutPage,
      mode: widget.mode,
      initGestureConfigHandler: _initGestureConfigHandler,
      onDoubleTap: widget.enableDoubleTap ? _onDoubleTap : null,
      loadStateChanged: (ExtendedImageState state) {
        final ImageInfo? imageInfo = state.extendedImageInfo;
        if (state.extendedImageLoadState == LoadState.completed ||
            imageInfo != null) {
          // 加载完成 显示图片
          controller.setScale100(imageInfo!, size);

          // 重新设置图片容器大小
          if (vState.imageSizeMap[widget.imageSer] == null) {
            vState.imageSizeMap[widget.imageSer] = Size(
                imageInfo.image.width.toDouble(),
                imageInfo.image.height.toDouble());
            Future.delayed(const Duration(milliseconds: 100)).then((value) =>
                controller.update(['$idImageListView${widget.imageSer}']));
          }

          controller.onLoadCompleted(widget.imageSer);

          Widget image = controller.vState.viewMode != ViewMode.topToBottom
              ? Hero(
                  tag: '${widget.imageSer}',
                  child: state.completedWidget,
                  createRectTween: (Rect? begin, Rect? end) {
                    final tween =
                        MaterialRectCenterArcTween(begin: begin, end: end);
                    return tween;
                  },
                )
              : state.completedWidget;

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
        } else if (state.extendedImageLoadState == LoadState.loading) {
          return null;
          // 显示加载中
          final ImageChunkEvent? loadingProgress = state.loadingProgress;
          final double? progress = loadingProgress?.expectedTotalBytes != null
              ? (loadingProgress?.cumulativeBytesLoaded ?? 0) /
                  (loadingProgress?.expectedTotalBytes ?? 1)
              : null;

          return ViewLoading(
            ser: widget.imageSer,
            progress: progress,
            duration: vState.viewMode != ViewMode.topToBottom
                ? const Duration(milliseconds: 50)
                : null,
          );
        }
      },
    );
  }

  /// 归档页查看
  Widget archiverImage() {
    return GetBuilder<ViewExtController>(
      builder: (ViewExtController controller) {
        final ViewExtState vState = controller.vState;

        return FutureBuilder<File?>(
            future: controller.imageArchiveFutureMap[widget.imageSer],
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError || snapshot.data == null) {
                  String _errInfo = '';
                  logger.e('${snapshot.error.runtimeType}');
                  if (snapshot.error is EhError) {
                    final EhError ehErr = snapshot.error as EhError;
                    logger.e('$ehErr');
                    _errInfo = ehErr.type.toString();
                    if (ehErr.type == EhErrorType.image509) {
                      return ViewErr509(ser: widget.imageSer);
                    }
                  } else {
                    logger.e(
                        'other error: ${snapshot.error}\n${snapshot.stackTrace}');
                    _errInfo = snapshot.error.toString();
                  }

                  if ((vState.errCountMap[widget.imageSer] ?? 0) <
                      vState.retryCount) {
                    Future.delayed(const Duration(milliseconds: 100)).then(
                        (_) => controller.initArchiveFuture(widget.imageSer));
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
                    return ViewLoading(
                      ser: widget.imageSer,
                      duration: vState.viewMode != ViewMode.topToBottom
                          ? const Duration(milliseconds: 50)
                          : null,
                    );
                  }
                }
                final File _file = snapshot.data!;

                Widget image = fileImage(_file.path);

                return image;
              } else {
                return ViewLoading(
                  ser: widget.imageSer,
                  duration: vState.viewMode != ViewMode.topToBottom
                      ? const Duration(milliseconds: 50)
                      : null,
                );
              }
            });
      },
    );
  }

  /// 网络图片 （从画廊页查看）
  Widget getViewImage() {
    return GetBuilder<ViewExtController>(
      builder: (ViewExtController controller) {
        final ViewExtState vState = controller.vState;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onLongPress: () async {
            logger.v('long press');
            vibrateUtil.medium();
            final GalleryImage? _currentImage =
                vState.pageState.imageMap[widget.imageSer];
            showImageSheet(
                context,
                () =>
                    controller.reloadImage(widget.imageSer, changeSource: true),
                imageUrl: _currentImage?.imageUrl ?? '',
                filePath: _currentImage?.filePath,
                origImageUrl: _currentImage?.originImageUrl,
                title: '${vState.pageState.title} [${widget.imageSer}]');
          },
          child: _buildFutureImage(),
        );
      },
    );
  }

  Widget _buildFutureImage() {
    final GalleryImage? _image = vState.pageState.imageMap[widget.imageSer];
    logger.v('_image ${_image?.toJson()}');

    if (_image?.hide ?? false) {
      return ViewAD(ser: widget.imageSer);
    }

    if ((_image?.completeCache ?? false) && !(_image?.changeSource ?? false)) {
      final imageProvider =
          ExtendedNetworkImageProvider(_image!.imageUrl!, cache: true);
      // logger.d('return providerImage ${widget.imageSer}');
      return providerImage(imageProvider, _image.imageUrl!, widget.imageSer);
    }

    // logger.d('return FutureBuilder ${widget.imageSer}');
    return FutureBuilder<GalleryImage?>(
        future: controller.imageFutureMap[widget.imageSer],
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError || snapshot.data == null) {
              String _errInfo = '';
              logger.e('${snapshot.error.runtimeType}');
              if (snapshot.error is DioError) {
                final DioError dioErr = snapshot.error as DioError;
                logger.e('${dioErr.error}');
                _errInfo = dioErr.type.toString();
              } else if (snapshot.error is EhError) {
                final EhError ehErr = snapshot.error as EhError;
                logger.e('$ehErr');
                _errInfo = ehErr.type.toString();
                if (ehErr.type == EhErrorType.image509) {
                  return ViewErr509(ser: widget.imageSer);
                }
              } else {
                logger.e(
                    'other error: ${snapshot.error}\n${snapshot.stackTrace}');
                _errInfo = snapshot.error.toString();
              }

              if ((vState.errCountMap[widget.imageSer] ?? 0) <
                  vState.retryCount) {
                Future.delayed(const Duration(milliseconds: 100)).then((_) =>
                    controller.reloadImage(widget.imageSer,
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
                return ViewLoading(
                  ser: widget.imageSer,
                  duration: vState.viewMode != ViewMode.topToBottom
                      ? const Duration(milliseconds: 200)
                      : null,
                );
              }
            }
            final GalleryImage? _image = snapshot.data;

            // 图片文件已下载 加载显示本地图片文件
            if (_image != null &&
                _image.filePath != null &&
                _image.filePath!.isNotEmpty) {
              if (vState.imageMap[widget.imageSer] != null) {
                vState.galleryPageController.uptImageBySer(
                    ser: _image.ser,
                    image: vState.imageMap[widget.imageSer]!
                        .copyWith(filePath: _image.filePath!));
              }
              return fileImage(_image.filePath!);
            }

            // 图片未下载 调用网络图片组件加载
            // logger.d('图片未下载 调用网络图片组件加载');
            Widget image = ImageExt(
              url: _image?.imageUrl ?? '',
              onDoubleTap: widget.enableDoubleTap ? _onDoubleTap : null,
              ser: widget.imageSer,
              mode: widget.mode,
              enableSlideOutPage: widget.enableSlideOutPage,
              reloadImage: () =>
                  controller.reloadImage(widget.imageSer, changeSource: true),
              fadeAnimationController: _fadeAnimationController,
              initGestureConfigHandler: _initGestureConfigHandler,
              onLoadCompleted: (ExtendedImageState state) {
                final ImageInfo? imageInfo = state.extendedImageInfo;
                controller.setScale100(imageInfo!, context.mediaQuerySize);

                if (_image != null) {
                  final GalleryImage? _tmpImage = vState.imageMap[_image.ser];
                  if (_tmpImage != null) {
                    vState.galleryPageController.uptImageBySer(
                      ser: _image.ser,
                      image: _tmpImage.copyWith(completeHeight: true),
                    );

                    logger.v('upt _tmpImage ${_tmpImage.ser}');
                    Future.delayed(const Duration(milliseconds: 100)).then(
                        (value) => controller.update(
                            [idSlidePage, '$idImageListView${_image.ser}']));
                  }
                }

                controller.onLoadCompleted(widget.imageSer);
              },
            );

            return image;
          } else {
            return ViewLoading(
              ser: widget.imageSer,
              duration: vState.viewMode != ViewMode.topToBottom
                  ? const Duration(milliseconds: 200)
                  : null,
            );
          }
        });
  }
}
