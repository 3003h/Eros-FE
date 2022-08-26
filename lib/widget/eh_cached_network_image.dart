import 'package:cached_network_image/cached_network_image.dart';
import 'package:fehviewer/common/controller/image_hide_controller.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http/retry.dart' as retry;
import 'package:octo_image/octo_image.dart';

class EhCachedNetworkImage extends StatelessWidget {
  EhCachedNetworkImage({
    Key? key,
    required this.imageUrl,
    this.height,
    this.width,
    this.fit,
    this.placeholder,
    this.errorWidget,
    this.progressIndicatorBuilder,
    this.httpHeaders,
    this.onLoadCompleted,
    this.checkPHashHide = false,
    this.checkQRCodeHide = false,
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
  final VoidCallback? onLoadCompleted;
  final bool checkPHashHide;
  final bool checkQRCodeHide;
  final ValueChanged<bool>? onHideFlagChanged;

  final ImageHideController imageHideController = Get.find();

  Future<bool> _future() async {
    if (checkPHashHide && checkQRCodeHide) {
      return await imageHideController.checkPHashHide(imageUrl) ||
          await imageHideController.checkQRCodeHide(imageUrl);
    }
    if (checkPHashHide) {
      return await imageHideController.checkPHashHide(imageUrl);
    } else {
      return await imageHideController.checkQRCodeHide(imageUrl);
    }
  }

  ImageWidgetBuilder get imageWidgetBuilder => (context, imageProvider) {
        final _image = OctoImage(
          image: imageProvider,
          width: width,
          height: height,
          fit: fit,
        );
        if (checkPHashHide || checkQRCodeHide) {
          return FutureBuilder<bool>(
              future: _future(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    return _image;
                  }
                  final showHidePlaceWidget = snapshot.data ?? false;
                  onHideFlagChanged?.call(showHidePlaceWidget);
                  return showHidePlaceWidget
                      ? Container(
                          child: Center(
                            child: Icon(
                              CupertinoIcons.xmark_shield_fill,
                              size: 32,
                              color: CupertinoDynamicColor.resolve(
                                  CupertinoColors.systemGrey3, context),
                            ),
                          ),
                        )
                      : _image;
                } else {
                  return placeholder?.call(context, imageUrl) ??
                      Container(
                        alignment: Alignment.center,
                        child: const CupertinoActivityIndicator(),
                      );
                  // return _image;
                }
              });
        } else {
          return _image;
        }
      };

  @override
  Widget build(BuildContext context) {
    final _httpHeaders = {
      'Cookie': Global.profile.user.cookie,
      'Host': Uri.parse(imageUrl).host,
      'User-Agent': EHConst.CHROME_USER_AGENT,
      'Accept-Encoding': 'gzip, deflate, br'
    };
    if (httpHeaders != null) {
      _httpHeaders.addAll(httpHeaders!);
    }

    final image = CachedNetworkImage(
      cacheManager: imageCacheManager,
      imageBuilder: imageWidgetBuilder,
      httpHeaders: _httpHeaders,
      width: width,
      height: height,
      fit: fit,
      imageUrl: imageUrl.handleUrl,
      placeholder: placeholder,
      errorWidget: errorWidget,
      progressIndicatorBuilder: progressIndicatorBuilder,
    );

    return image;
  }
}

final client = retry.RetryClient(
  http.Client(),
);

final imageCacheManager = CacheManager(
  Config(
    'CachedNetworkImage',
    fileService: HttpFileService(
      httpClient: client,
    ),
  ),
);
