import 'package:cached_network_image/cached_network_image.dart';
import 'package:eros_fe/common/service/ehsetting_service.dart';
import 'package:eros_fe/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class EhNetworkImage extends StatefulWidget {
  const EhNetworkImage({
    super.key,
    required this.imageUrl,
    this.height,
    this.width,
    this.fit,
    this.placeholder,
    this.errorWidget,
    this.progressIndicatorBuilder,
    this.httpHeaders,
    this.checkHide = false,
    this.onHideFlagChanged,
    this.blurHash = false,
    this.sourceRect,
  });

  final String imageUrl;
  final double? height;
  final double? width;
  final BoxFit? fit;

  final bool blurHash;

  final Map<String, String>? httpHeaders;

  final PlaceholderWidgetBuilder? placeholder;
  final LoadingErrorWidgetBuilder? errorWidget;
  final ProgressIndicatorBuilder? progressIndicatorBuilder;

  final bool checkHide;
  final ValueChanged<bool>? onHideFlagChanged;

  final Rect? sourceRect;

  @override
  State<EhNetworkImage> createState() => _EhNetworkImageState();
}

class _EhNetworkImageState extends State<EhNetworkImage> {
  final EhSettingService ehSettingService = Get.find();
  @override
  Widget build(BuildContext context) {
    // if (Get.find<EhSettingService>().isSiteEx.value && false) {
    //   return NetworkExtendedImage(
    //     url: widget.imageUrl.handleUrl,
    //     width: widget.width,
    //     height: widget.height,
    //     fit: widget.fit,
    //     placeholder: widget.placeholder,
    //     errorWidget: widget.errorWidget,
    //     progressIndicatorBuilder: widget.progressIndicatorBuilder,
    //     checkPHashHide: widget.checkHide,
    //   );
    // }

    // if (widget.sourceRect != null) {
    //   return ExtendedImageRect(
    //     width: widget.width,
    //     height: widget.height,
    //     fit: widget.fit,
    //     url: widget.imageUrl.handleUrl,
    //     httpHeaders: widget.httpHeaders,
    //     sourceRect: widget.sourceRect,
    //   );
    // }

    return EhCachedNetworkImage(
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      imageUrl: widget.imageUrl.handleUrl,
      httpHeaders: widget.httpHeaders,
      placeholder: widget.placeholder,
      errorWidget: widget.errorWidget,
      progressIndicatorBuilder: widget.progressIndicatorBuilder,
      checkPHashHide: widget.checkHide && ehSettingService.enablePHashCheck,
      checkQRCodeHide: widget.checkHide && ehSettingService.enableQRCodeCheck,
      onHideFlagChanged: widget.onHideFlagChanged,
      blurHash: widget.blurHash,
      sourceRect: widget.sourceRect,
    );
  }
}
