import 'package:cached_network_image/cached_network_image.dart';
import 'package:fehviewer/common/global.dart';
import 'package:flutter/cupertino.dart';
import 'package:fehviewer/common/exts.dart';

class EhCachedNetworkImage extends StatelessWidget {
  const EhCachedNetworkImage({
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
    final _httpHeaders = {
      'Cookie': Global.profile.user.cookie ?? '',
      'host': Uri.parse(imageUrl).host,
    };

    return CachedNetworkImage(
      httpHeaders: _httpHeaders,
      width: width,
      height: height,
      fit: BoxFit.cover,
      imageUrl: imageUrl.dfUrl,
      placeholder: placeholder,
      errorWidget: errorWidget,
      progressIndicatorBuilder: progressIndicatorBuilder,
    );
  }
}
