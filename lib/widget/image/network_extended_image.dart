import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:eros_fe/common/controller/image_block_controller.dart';
import 'package:eros_fe/index.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class NetworkExtendedImage extends StatefulWidget {
  const NetworkExtendedImage({
    Key? key,
    required this.url,
    this.height,
    this.width,
    this.fit,
    this.retries = 3,
    this.placeholder,
    this.errorWidget,
    this.progressIndicatorBuilder,
    this.httpHeaders,
    this.cancelToken,
    this.heroTag,
    this.onLoadCompleted,
    this.checkPHashHide = false,
    this.checkQRCodeHide = false,
  }) : super(key: key);
  final String url;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final int retries;
  final Map<String, String>? httpHeaders;

  final PlaceholderWidgetBuilder? placeholder;
  final LoadingErrorWidgetBuilder? errorWidget;
  final ProgressIndicatorBuilder? progressIndicatorBuilder;
  final CancellationToken? cancelToken;
  final Object? heroTag;
  final VoidCallback? onLoadCompleted;
  final bool checkPHashHide;
  final bool checkQRCodeHide;

  @override
  _NetworkExtendedImageState createState() => _NetworkExtendedImageState();
}

class _NetworkExtendedImageState extends State<NetworkExtendedImage>
    with SingleTickerProviderStateMixin {
  Map<String, String> _httpHeaders = {};
  late AnimationController animationController;
  ImageBlockController imageHideController = Get.find();

  @override
  void initState() {
    super.initState();
    _httpHeaders = {
      'Cookie': Global.profile.user.cookie,
      'host': Uri.parse(widget.url).host,
      'User-Agent': EHConst.CHROME_USER_AGENT,
      'Accept-Encoding': 'gzip, deflate, br'
    };

    if (widget.httpHeaders != null) {
      _httpHeaders.addAll(widget.httpHeaders!);
    }

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 0),
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExtendedImage.network(
      widget.url.handleUrl,
      width: widget.width,
      height: widget.height,
      headers: _httpHeaders,
      retries: widget.retries,
      timeLimit: const Duration(seconds: 6),
      timeRetry: const Duration(milliseconds: 300),
      cancelToken: widget.cancelToken,
      fit: widget.fit,
      enableLoadState: false,
      loadStateChanged: (ExtendedImageState state) {
        switch (state.extendedImageLoadState) {
          case LoadState.loading:
            return widget.placeholder?.call(context, widget.url.handleUrl) ??
                Container(
                  alignment: Alignment.center,
                  child: const CupertinoActivityIndicator(),
                );
          case LoadState.completed:
            animationController.forward();
            widget.onLoadCompleted?.call();

            Widget _image;
            if (widget.heroTag != null) {
              return Hero(tag: widget.heroTag!, child: state.completedWidget);
            } else {
              _image = FadeTransition(
                opacity: animationController,
                child: state.completedWidget,
              );
            }

            // return _image;

            logger.t(
                'widget.checkPHashHide   widget.checkQRCodeHide ${widget.checkPHashHide}  ${widget.checkQRCodeHide}');
            if (widget.checkPHashHide || widget.checkQRCodeHide) {
              Future<bool> _future() async {
                if (!widget.checkQRCodeHide) {
                  return await imageHideController
                      .checkPHashHide(widget.url.handleUrl);
                } else if (!widget.checkPHashHide) {
                  return await imageHideController
                      .checkQRCodeHide(widget.url.handleUrl);
                }
                return await imageHideController
                        .checkPHashHide(widget.url.handleUrl) ||
                    await imageHideController
                        .checkQRCodeHide(widget.url.handleUrl);
              }

              return FutureBuilder<bool>(
                  future: _future(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      final showCustomWidget = snapshot.data ?? false;
                      return showCustomWidget
                          ? const Center(
                              child: Icon(FontAwesomeIcons.rectangleAd))
                          : _image;
                    } else if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return widget.placeholder
                              ?.call(context, widget.url.handleUrl) ??
                          Container(
                            alignment: Alignment.center,
                            child: const CupertinoActivityIndicator(),
                          );
                      // return _image;
                    }
                    return _image;
                  });
            }

            return _image;

          case LoadState.failed:
            return Container(
              alignment: Alignment.center,
              child: const Icon(
                Icons.error,
                color: Colors.red,
              ),
            );
          default:
            return null;
        }
      },
    );
  }
}

class ExtendedImageRect extends StatefulWidget {
  const ExtendedImageRect({
    Key? key,
    required this.url,
    this.sourceRect,
    this.height,
    this.width,
    this.fit,
    this.onLoadComplet,
    this.httpHeaders,
  }) : super(key: key);
  final String url;
  final Rect? sourceRect;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final VoidCallback? onLoadComplet;
  final Map<String, String>? httpHeaders;

  @override
  _ExtendedImageRectState createState() => _ExtendedImageRectState();
}

class _ExtendedImageRectState extends State<ExtendedImageRect> {
  Map<String, String> _httpHeaders = {};

  @override
  void initState() {
    super.initState();
    _httpHeaders = {
      'Cookie': Global.profile.user.cookie,
      'host': Uri.parse(widget.url).host,
      'User-Agent': EHConst.CHROME_USER_AGENT,
      'Accept-Encoding': 'gzip, deflate, br'
    };
    if (widget.httpHeaders != null) {
      _httpHeaders.addAll(widget.httpHeaders!);
    }
  }

  Future<ImageInfo> getImageInfo(ImageProvider imageProvider) {
    Completer<ImageInfo> completer = Completer();
    imageProvider.resolve(ImageConfiguration()).addListener(
      ImageStreamListener(
        (ImageInfo info, bool _) {
          completer.complete(info);
        },
      ),
    );
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
        cacheManager: imageCacheManager(ser: null),
        imageBuilder: (BuildContext context, ImageProvider imageProvider) {
          return FutureBuilder(
              future: getImageInfo(imageProvider),
              builder:
                  (BuildContext context, AsyncSnapshot<ImageInfo> snapshot) {
                if (snapshot.data != null) {
                  return ExtendedRawImage(
                    image: snapshot.data!.image,
                    width: widget.sourceRect?.width,
                    height: widget.sourceRect?.height,
                    fit: BoxFit.fill,
                    sourceRect: widget.sourceRect,
                  );
                } else {
                  return Center(
                    child: Container(
                      alignment: Alignment.center,
                      color: CupertinoDynamicColor.resolve(
                          CupertinoColors.systemGrey5.withOpacity(0.2),
                          context),
                      child: const CupertinoActivityIndicator(),
                    ),
                  );
                }
              });
        },
        httpHeaders: _httpHeaders,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        imageUrl: widget.url.handleUrl,
        placeholder: (BuildContext context, String url) {
          return Center(
            child: Container(
              alignment: Alignment.center,
              color: CupertinoDynamicColor.resolve(
                  CupertinoColors.systemGrey5.withOpacity(0.2), context),
              child: const CupertinoActivityIndicator(),
            ),
          );
        },
        errorWidget: (
          BuildContext context,
          String url,
          dynamic error,
        ) {
          return Container(
            alignment: Alignment.center,
            child: const Icon(
              Icons.error,
              color: Colors.red,
            ),
          );
        });
  }
}
