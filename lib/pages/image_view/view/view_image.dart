import 'dart:io';

import 'package:dio/dio.dart';
import 'package:eros_fe/common/service/ehsetting_service.dart';
import 'package:eros_fe/component/exception/error.dart';
import 'package:eros_fe/const/const.dart';
import 'package:eros_fe/models/base/eh_models.dart';
import 'package:eros_fe/network/app_dio/pdio.dart';
import 'package:eros_fe/pages/image_view/controller/view_state.dart';
import 'package:eros_fe/utils/logger.dart';
import 'package:eros_fe/utils/utility.dart';
import 'package:eros_fe/utils/vibrate.dart';
import 'package:eros_fe/widget/image/extended_saf_image_privider.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../common.dart';
import '../controller/view_controller.dart';
import 'view_widget.dart';

typedef DoubleClickAnimationListener = void Function();

class ViewImage extends StatefulWidget {
  const ViewImage({
    super.key,
    required this.imageSer,
    this.initialScale = 1.0,
    this.enableDoubleTap = true,
    this.mode = ExtendedImageMode.gesture,
    this.enableSlideOutPage = true,
    this.imageSizeChanged,
  });

  final int imageSer;
  final double initialScale;
  final bool enableDoubleTap;
  final ExtendedImageMode mode;
  final bool enableSlideOutPage;
  final ValueChanged<Size>? imageSizeChanged;

  @override
  State<ViewImage> createState() => _ViewImageState();
}

class _ViewImageState extends State<ViewImage> with TickerProviderStateMixin {
  final ViewExtController controller = Get.find();
  final EhSettingService ehSettingService = Get.find();

  late AnimationController _doubleClickAnimationController;
  Animation<double>? _doubleClickAnimation;
  late DoubleClickAnimationListener _doubleClickAnimationListener;

  late AnimationController _fadeAnimationController;

  ViewExtState get vState => controller.vState;

  bool get checkPHashHide => ehSettingService.enablePHashCheck;

  bool get checkQRCodeHide => ehSettingService.enableQRCodeCheck;

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
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

        final imageInfo = state.extendedImageInfo;
        if (imageInfo != null) {
          initialScale = initScale(
              size: size,
              initialScale: initialScale,
              imageSize: Size(imageInfo.image.width.toDouble(),
                  imageInfo.image.height.toDouble()));

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
        ///default value is double tap pointer down position.
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
    Widget image = () {
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
    }();

    // return _image();

    return Obx(() {
      return HeroMode(
        enabled: widget.imageSer == controller.vState.currentItemIndex + 1,
        child: image,
      );
    });
  }

  /// 本地图片文件 构建Widget
  Widget fileImage(String path) {
    final Size size = MediaQuery.of(context).size;

    Widget? loadStateChanged(ExtendedImageState state) {
      final ImageInfo? imageInfo = state.extendedImageInfo;
      widget.imageSizeChanged?.call(Size(
          imageInfo?.image.width.toDouble() ?? 0.0,
          imageInfo?.image.height.toDouble() ?? 0.0));
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
                createRectTween: (Rect? begin, Rect? end) =>
                    MaterialRectCenterArcTween(begin: begin, end: end),
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
          // progress: progress,
          duration: vState.viewMode != ViewMode.topToBottom
              ? const Duration(milliseconds: 100)
              : null,
          debugLabel: '### Widget fileImage 加载图片文件',
        );
      }
      return null;
    }

    return path.isContentUri
        ? ExtendedImage(
            image: ExtendedSafImageProvider(Uri.parse(path)),
            fit: BoxFit.contain,
            clearMemoryCacheWhenDispose: true,
            enableMemoryCache: false,
            filterQuality: FilterQuality.medium,
            enableSlideOutPage: widget.enableSlideOutPage,
            mode: widget.mode,
            initGestureConfigHandler: _initGestureConfigHandler,
            onDoubleTap: widget.enableDoubleTap ? _onDoubleTap : null,
            loadStateChanged: loadStateChanged,
          )
        : ExtendedImage(
            image: ExtendedFileImageProvider(File(path)),
            fit: BoxFit.contain,
            clearMemoryCacheWhenDispose: true,
            enableMemoryCache: false,
            filterQuality: FilterQuality.medium,
            enableSlideOutPage: widget.enableSlideOutPage,
            mode: widget.mode,
            initGestureConfigHandler: _initGestureConfigHandler,
            onDoubleTap: widget.enableDoubleTap ? _onDoubleTap : null,
            loadStateChanged: loadStateChanged,
          );
  }

  /// 归档页查看
  Widget archiverImage() {
    return FutureBuilder<File?>(
        future: controller.imageArchiveFutureMap[widget.imageSer],
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError || snapshot.data == null) {
              String errInfo = '';
              logger.e('${snapshot.error.runtimeType}');
              if (snapshot.error is EhError) {
                final EhError ehErr = snapshot.error as EhError;
                logger.e('$ehErr');
                errInfo = ehErr.type.toString();
                if (ehErr.type == EhErrorType.image509) {
                  return ViewErr509(ser: widget.imageSer);
                }
              } else if (snapshot.error is HttpException) {
                final HttpException e = snapshot.error as HttpException;
                if (e is BadRequestException && e.code == 429) {
                  return ViewErr429(ser: widget.imageSer);
                } else {
                  errInfo = e.message;
                }
              } else {
                logger.e(
                    'other error: ${snapshot.error}\n${snapshot.stackTrace}');
                errInfo = snapshot.error.toString();
              }

              if ((vState.errCountMap[widget.imageSer] ?? 0) <
                  vState.retryCount) {
                Future.delayed(const Duration(milliseconds: 100))
                    .then((_) => controller.initArchiveFuture(widget.imageSer));
                vState.errCountMap.update(
                    widget.imageSer, (int value) => value + 1,
                    ifAbsent: () => 1);

                logger.t('${vState.errCountMap}');
                logger.d(
                    '${widget.imageSer} 重试 第 ${vState.errCountMap[widget.imageSer]} 次');
              }
              if ((vState.errCountMap[widget.imageSer] ?? 0) >=
                  vState.retryCount) {
                return ViewError(ser: widget.imageSer, errInfo: errInfo);
              } else {
                return ViewLoading(
                  debugLabel: 'archiverImage 重试',
                  ser: widget.imageSer,
                  duration: vState.viewMode != ViewMode.topToBottom
                      ? const Duration(milliseconds: 50)
                      : null,
                );
              }
            }
            final File file = snapshot.data!;

            Widget image = fileImage(file.path);

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
  }

  /// 网络图片 （从画廊页查看）
  Widget getViewImage() {
    // 长按菜单
    return GetBuilder<ViewExtController>(
        id: '$idImageListView${widget.imageSer}',
        builder: (logic) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onLongPress: () async {
              logger.t('long press');
              vibrateUtil.medium();
              final GalleryImage? currentImage =
                  vState.pageState?.imageMap[widget.imageSer];

              logger.d('_currentImage ${currentImage?.toJson()}');

              // TODO(3003h): 对于已下载的图片，保存到相册时，从已下载读取.
              showImageSheet(
                context,
                () =>
                    controller.reloadImage(widget.imageSer, changeSource: true),
                imageUrl: currentImage?.imageUrl ?? '',
                filePath: currentImage?.filePath ?? currentImage?.tempPath,
                origImageUrl: currentImage?.originImageUrl,
                title: '${vState.pageState?.mainTitle} [${widget.imageSer}]',
                ser: widget.imageSer,
                gid: vState.pageState?.gid,
                filename: currentImage?.filename,
                isLocal: vState.loadFrom == LoadFrom.download ||
                    vState.loadFrom == LoadFrom.archiver,
              );
            },
            child: _buildViewImageWidgetProvider(),
          );
        });
  }

  Widget _buildViewImageWidget() {
    final GalleryImage? imageFromState =
        vState.pageState?.imageMap[widget.imageSer];
    logger.t('imageFromState ${imageFromState?.toJson()}');

    if (imageFromState?.hide ?? false) {
      return ViewAD(ser: widget.imageSer);
    }

    if ((imageFromState?.completeCache ?? false) &&
        !(imageFromState?.changeSource ?? false)) {
      // 图片文件已下载 加载显示本地图片文件
      if (imageFromState?.tempPath?.isNotEmpty ?? false) {
        logger.t('${widget.imageSer} filePath 不为空，加载图片文件');
        return fileImage(imageFromState!.tempPath!);
      }

      if (imageFromState?.imageUrl != null &&
          (imageFromState?.downloadProcess == null)) {
        controller.downloadImage(
            ser: widget.imageSer,
            url: imageFromState!.imageUrl!,
            onError: (e) {
              _buildErr(e);
            });

        return _buildDownloadImage(debugLable: 'FutureBuilder 外');
      }
    }

    logger.d('return FutureBuilder ser:${widget.imageSer}');
    return FutureBuilder<GalleryImage?>(
        future: controller.imageFutureMap[widget.imageSer],
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError || snapshot.data == null) {
              return _buildErr(snapshot.error);
            }
            final GalleryImage? imageData = snapshot.data;

            // 图片文件已下载 加载显示本地图片文件
            if (imageData?.filePath?.isNotEmpty ?? false) {
              logger.d('file... ${imageData?.filePath}');
              return fileImage(imageData!.filePath!);
            }

            if (imageData?.tempPath?.isNotEmpty ?? false) {
              logger.d('file... ${imageData?.tempPath}');
              return fileImage(imageData!.tempPath!);
            }

            if (imageData?.imageUrl != null) {
              logger.d('downloadImage...');

              controller.downloadImage(
                ser: widget.imageSer,
                url: imageData!.imageUrl!,
                reset: true,
              );
            }

            Widget image = _buildDownloadImage(debugLable: 'FutureBuilder内');

            return image;
          } else {
            return ViewLoading(
              debugLabel: 'FutureBuilder 加载画廊页数据',
              ser: widget.imageSer,
              duration: vState.viewMode != ViewMode.topToBottom
                  ? const Duration(milliseconds: 200)
                  : null,
            );
          }
        });
  }

  Widget _buildViewImageWidgetProvider() {
    final GalleryImage? imageFromState =
        vState.pageState?.imageMap[widget.imageSer];
    logger.t('imageFromState ${imageFromState?.toJson()}');

    if (imageFromState?.hide ?? false) {
      return ViewAD(ser: widget.imageSer);
    }

    logger.t('return FutureBuilder ser:${widget.imageSer}');
    return FutureBuilder<GalleryImage?>(
        future: controller.imageFutureMap[widget.imageSer],
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError || snapshot.data == null) {
              logger.e('${snapshot.error}\n${snapshot.stackTrace}');
              return _buildErr(snapshot.error);
            }
            final GalleryImage? imageData = snapshot.data;

            final GalleryImage? currentImageData =
                vState.pageState?.imageMap[widget.imageSer];

            // logger.d(
            //     'currentImageData ${currentImageData?.toJson()}\nimageData ${imageData?.toJson()}');

            // 图片文件已下载 加载显示本地图片文件
            if (imageData?.filePath?.isNotEmpty ?? false) {
              logger.d('图片文件已下载 file... ${imageData?.filePath}');
              controller.vState.galleryPageController?.uptImageBySer(
                ser: widget.imageSer,
                imageCallback: (image) => image.copyWith(
                  filePath: imageData?.filePath.oN,
                ),
              );
              return fileImage(imageData!.filePath!);
            }

            if (imageData?.tempPath?.isNotEmpty ?? false) {
              logger.t('tempPath file... ${imageData?.tempPath}');
              controller.vState.galleryPageController?.uptImageBySer(
                ser: widget.imageSer,
                imageCallback: (image) => image.copyWith(
                  tempPath: imageData?.tempPath.oN,
                ),
              );
              return fileImage(imageData!.tempPath!);
            }

            // 常规情况 加载网络图片

            // 图片加载完成
            void onLoadCompleted(ExtendedImageState state) {
              final ImageInfo? imageInfo = state.extendedImageInfo;
              controller.setScale100(imageInfo!, context.mediaQuerySize);

              widget.imageSizeChanged?.call(Size(
                  imageInfo.image.width.toDouble(),
                  imageInfo.image.height.toDouble()));

              if (imageData != null) {
                final GalleryImage? tmpImage = vState.imageMap?[imageData.ser];
                if (tmpImage != null && !(tmpImage.completeHeight ?? false)) {
                  vState.galleryPageController?.uptImageBySer(
                    ser: imageData.ser,
                    imageCallback: (image) =>
                        image.copyWith(completeHeight: true.oN),
                  );

                  logger.t('upt _tmpImage ${tmpImage.ser}');
                  Future.delayed(const Duration(milliseconds: 100)).then(
                      (value) => controller.update(
                          [idSlidePage, '$idImageListView${imageData.ser}']));
                }
              }

              controller.onLoadCompleted(widget.imageSer);
            }

            // if (kReleaseMode) {
            //   logger.d('ImageExt');
            //   return ImageExt(
            //     url: imageData?.imageUrl ?? '',
            //     onDoubleTap: widget.enableDoubleTap ? _onDoubleTap : null,
            //     ser: widget.imageSer,
            //     mode: widget.mode,
            //     enableSlideOutPage: widget.enableSlideOutPage,
            //     reloadImage: () =>
            //         controller.reloadImage(widget.imageSer, changeSource: true),
            //     fadeAnimationController: _fadeAnimationController,
            //     initGestureConfigHandler: _initGestureConfigHandler,
            //     onLoadCompleted: onLoadCompleted,
            //   );
            // }

            logger.t('ImageExtProvider');
            Widget image = ImageExtProvider(
              image: ExtendedResizeImage.resizeIfNeeded(
                provider: ExtendedNetworkImageProvider(
                  imageData?.imageUrl ?? '',
                  timeLimit: const Duration(seconds: 10),
                  cache: true,
                ),
              ),
              // image: EhCheckHideImage(
              //   checkQRCodeHide: checkQRCodeHide,
              //   checkPHashHide: checkPHashHide,
              //   imageProvider: ExtendedNetworkImageProvider(
              //     imageData?.imageUrl ?? '',
              //     timeLimit: const Duration(seconds: 10),
              //     cache: true,
              //   ),
              // ),
              onDoubleTap: widget.enableDoubleTap ? _onDoubleTap : null,
              ser: widget.imageSer,
              mode: widget.mode,
              enableSlideOutPage: widget.enableSlideOutPage,
              reloadImage: () =>
                  controller.reloadImage(widget.imageSer, changeSource: true),
              fadeAnimationController: _fadeAnimationController,
              initGestureConfigHandler: _initGestureConfigHandler,
              onLoadCompleted: onLoadCompleted,
            );

            return image;
          } else {
            return ViewLoading(
              debugLabel: 'FutureBuilder 加载画廊页数据',
              ser: widget.imageSer,
              duration: vState.viewMode != ViewMode.topToBottom
                  ? const Duration(milliseconds: 200)
                  : null,
            );
          }
        });
  }

  Widget _buildErr(Object? e) {
    String errInfo = '';
    logger.e('${e.runtimeType}');
    if (e is DioException) {
      final DioException dioErr = e;
      logger.e('${dioErr.error}');
      errInfo = dioErr.type.toString();
    } else if (e is EhError) {
      final EhError ehErr = e;
      logger.e('$ehErr');
      errInfo = ehErr.type.toString();
      if (ehErr.type == EhErrorType.image509) {
        return ViewErr509(ser: widget.imageSer);
      }
    } else if (e is HttpException) {
      if (e is BadRequestException && e.code == 429) {
        return ViewErr429(ser: widget.imageSer);
      } else {
        errInfo = e.message;
      }
    } else {
      errInfo = e.toString();
    }

    if ((vState.errCountMap[widget.imageSer] ?? 0) < vState.retryCount) {
      Future.delayed(const Duration(milliseconds: 100)).then(
          (_) => controller.reloadImage(widget.imageSer, changeSource: true));
      vState.errCountMap
          .update(widget.imageSer, (int value) => value + 1, ifAbsent: () => 1);

      logger.t('${vState.errCountMap}');
      logger.d(
          '${widget.imageSer} 重试 第 ${vState.errCountMap[widget.imageSer]} 次');
    }
    if ((vState.errCountMap[widget.imageSer] ?? 0) >= vState.retryCount) {
      return ViewError(ser: widget.imageSer, errInfo: errInfo);
    } else {
      return ViewLoading(
        debugLabel: '重试',
        ser: widget.imageSer,
        duration: vState.viewMode != ViewMode.topToBottom
            ? const Duration(milliseconds: 100)
            : null,
      );
    }
  }

  Widget _buildDownloadImage({String? debugLable}) {
    if (kDebugMode && debugLable != null) {
      logger.d('_buildDownloadImage $debugLable');
    }
    return GetBuilder<ViewExtController>(
      id: '${idProcess}_${widget.imageSer}',
      builder: (controller) {
        final image = controller.vState.imageMap?[widget.imageSer];
        if (image == null) {
          return const SizedBox.shrink();
        }

        if (image.errorInfo?.isNotEmpty ?? false) {
          return ViewError(
            ser: widget.imageSer,
            errInfo: image.errorInfo,
          );
        }

        final process = image.downloadProcess ?? 0.0;
        if (process < 1.0) {
          return ViewLoading(
            ser: widget.imageSer,
            progress: process,
          );
        } else {
          return fileImage(image.tempPath!);
        }
      },
    );
  }
}
