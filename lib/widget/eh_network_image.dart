import 'package:cached_network_image/cached_network_image.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class EhNetworkImage extends StatefulWidget {
  const EhNetworkImage({
    Key? key,
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
  }) : super(key: key);

  final String imageUrl;
  final double? height;
  final double? width;
  final BoxFit? fit;

  final Map<String, String>? httpHeaders;

  final PlaceholderWidgetBuilder? placeholder;
  final LoadingErrorWidgetBuilder? errorWidget;
  final ProgressIndicatorBuilder? progressIndicatorBuilder;

  final bool checkHide;
  final ValueChanged<bool>? onHideFlagChanged;

  @override
  State<EhNetworkImage> createState() => _EhNetworkImageState();
}

class _EhNetworkImageState extends State<EhNetworkImage> {
  final EhConfigService ehConfigService = Get.find();
  @override
  Widget build(BuildContext context) {
    if (Get.find<EhConfigService>().isSiteEx.value && false) {
      return NetworkExtendedImage(
        url: widget.imageUrl.handleUrl,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        placeholder: widget.placeholder,
        errorWidget: widget.errorWidget,
        progressIndicatorBuilder: widget.progressIndicatorBuilder,
        checkPHashHide: widget.checkHide,
      );
    }

    return EhCachedNetworkImage(
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      imageUrl: widget.imageUrl.handleUrl,
      httpHeaders: widget.httpHeaders,
      placeholder: widget.placeholder,
      errorWidget: widget.errorWidget,
      progressIndicatorBuilder: widget.progressIndicatorBuilder,
      checkPHashHide: widget.checkHide && ehConfigService.enablePHashCheck,
      checkQRCodeHide: widget.checkHide && ehConfigService.enableQRCodeCheck,
      onHideFlagChanged: widget.onHideFlagChanged,
    );
  }
}
