import 'package:cached_network_image/cached_network_image.dart';
import 'package:fehviewer/common/controller/image_hide_controller.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/utils/p_hash/phash_base.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
  State<EhNetworkImage> createState() => _EhNetworkImageState();
}

class _EhNetworkImageState extends State<EhNetworkImage> {
  bool showCustomWidget = false;

  @override
  Widget build(BuildContext context) {
    if (Get.find<EhConfigService>().isSiteEx.value || true)
      return NetworkExtendedImage(
        url: widget.imageUrl.dfUrl,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        placeholder: widget.placeholder,
        errorWidget: widget.errorWidget,
        progressIndicatorBuilder: widget.progressIndicatorBuilder,
      );

    final image = EhCachedNetworkImage(
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      imageUrl: widget.imageUrl.dfUrl,
      httpHeaders: widget.httpHeaders,
      placeholder: widget.placeholder,
      errorWidget: widget.errorWidget,
      progressIndicatorBuilder: widget.progressIndicatorBuilder,
      onLoadCompleted: () async {
        // // final hash = pHashHelper.calculatePHash(widget.imageUrl.dfUrl);
        // ImageHideController imageHideController = Get.find();
        // final needHide =
        //     await imageHideController.checkHide(widget.imageUrl.dfUrl);
        // logger.d('needHide $needHide');
        // setState(() {
        //   showCustomWidget = needHide;
        // });
      },
    );

    return showCustomWidget
        ? Container(child: Icon(FontAwesomeIcons.rectangleAd))
        : image;
  }
}
