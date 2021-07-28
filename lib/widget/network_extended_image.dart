import 'package:extended_image/extended_image.dart';
import 'package:fehviewer/common/exts.dart';
import 'package:fehviewer/common/global.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NetworkExtendedImage extends StatefulWidget {
  const NetworkExtendedImage({
    Key? key,
    required this.url,
    this.height,
    this.width,
    this.fit,
    this.retries = 3,
  }) : super(key: key);
  final String url;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final int retries;

  @override
  _NetworkExtendedImageState createState() => _NetworkExtendedImageState();
}

class _NetworkExtendedImageState extends State<NetworkExtendedImage>
    with SingleTickerProviderStateMixin {
  Map<String, String> _httpHeaders = {};
  late AnimationController animationController;

  @override
  void initState() {
    super.initState();
    _httpHeaders = {
      'Cookie': Global.profile.user.cookie ?? '',
      'host': Uri.parse(widget.url).host,
    };

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
      widget.url.dfUrl,
      width: widget.width,
      height: widget.height,
      headers: _httpHeaders,
      retries: widget.retries,
      fit: widget.fit,
      // enableLoadState: false,
      loadStateChanged: (ExtendedImageState state) {
        switch (state.extendedImageLoadState) {
          case LoadState.loading:
            // return null;
            return Container(
              alignment: Alignment.center,
              color: CupertinoDynamicColor.resolve(
                  CupertinoColors.systemGrey5, context),
              child: const CupertinoActivityIndicator(),
            );
          case LoadState.completed:
            animationController.forward();

            return ExtendedRawImage(
              fit: BoxFit.contain,
              image: state.extendedImageInfo?.image,
            );

            return FadeTransition(
              opacity: animationController,
              child: ExtendedRawImage(
                fit: BoxFit.contain,
                image: state.extendedImageInfo?.image,
              ),
            );
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
