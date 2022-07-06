import 'package:cached_network_image/cached_network_image.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class EhNetworkImage extends StatelessWidget {
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
  }) : super(key: key);

  final String imageUrl;
  final double? height;
  final double? width;
  final BoxFit? fit;

  final Map<String, String>? httpHeaders;

  final PlaceholderWidgetBuilder? placeholder;
  final LoadingErrorWidgetBuilder? errorWidget;
  final ProgressIndicatorBuilder? progressIndicatorBuilder;

  @override
  Widget build(BuildContext context) {
    if (Get.find<EhConfigService>().isSiteEx.value && false)
      return NetworkExtendedImage(
        url: imageUrl.dfUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: placeholder,
        errorWidget: errorWidget,
        progressIndicatorBuilder: progressIndicatorBuilder,
      );

    return EhCachedNetworkImage(
      width: width,
      height: height,
      fit: fit,
      imageUrl: imageUrl.dfUrl,
      httpHeaders: httpHeaders,
      placeholder: placeholder,
      errorWidget: errorWidget,
      progressIndicatorBuilder: progressIndicatorBuilder,
    );
  }
}
