import 'package:cached_network_image/cached_network_image.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:flutter/cupertino.dart';

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
  }) : super(key: key);

  final String imageUrl;
  final double? height;
  final double? width;
  final BoxFit? fit;

  final PlaceholderWidgetBuilder? placeholder;
  final LoadingErrorWidgetBuilder? errorWidget;
  final ProgressIndicatorBuilder? progressIndicatorBuilder;

  @override
  Widget build(BuildContext context) {
    // return NetworkExtendedImage(
    //   url: imageUrl.dfUrl,
    //   width: width,
    //   height: height,
    //   fit: fit,
    //   placeholder: placeholder,
    //   errorWidget: errorWidget,
    //   progressIndicatorBuilder: progressIndicatorBuilder,
    // );

    return EhCachedNetworkImage(
      width: width,
      height: height,
      fit: fit,
      imageUrl: imageUrl.dfUrl,
      placeholder: placeholder,
      errorWidget: errorWidget,
      progressIndicatorBuilder: progressIndicatorBuilder,
    );
  }
}
