import 'package:blurhash_ffi/blurhash_ffi.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:eros_fe/common/controller/image_block_controller.dart';
import 'package:eros_fe/index.dart';
import 'package:eros_fe/network/app_dio/dio_file_service.dart';
import 'package:eros_fe/widget/image/rect_image_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http/retry.dart' as retry;
import 'package:octo_image/octo_image.dart';

class EhCachedNetworkImage extends StatelessWidget {
  EhCachedNetworkImage({
    super.key,
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
    this.ser,
    this.blurHash = false,
    this.sourceRect,
  });

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

  final bool blurHash;

  final int? ser;

  final Rect? sourceRect;

  final ImageBlockController imageHideController = Get.find();

  Future<bool> _future() async {
    // if (checkPHashHide && checkQRCodeHide) {
    //   return await imageHideController.checkPHashHide(
    //         imageUrl,
    //         sourceRect: sourceRect,
    //       ) ||
    //       await imageHideController.checkQRCodeHide(
    //         imageUrl,
    //         sourceRect: sourceRect,
    //       );
    // }
    // if (checkPHashHide) {
    //   return await imageHideController.checkPHashHide(imageUrl,
    //       sourceRect: sourceRect);
    // } else {
    //   return await imageHideController.checkQRCodeHide(imageUrl,
    //       sourceRect: sourceRect);
    // }
    bool result = false;
    if (checkPHashHide) {
      result = await imageHideController.checkPHashHide(imageUrl,
          sourceRect: sourceRect);
    }
    if (checkQRCodeHide) {
      result = await imageHideController.checkQRCodeHide(imageUrl,
          sourceRect: sourceRect);
    }
    return result;
  }

  ImageWidgetBuilder get imageWidgetBuilder => (context, imageProvider) {
        if (blurHash) {
          imageProvider = BlurhashTheImage(imageProvider);
        }

        if (sourceRect != null) {
          logger.t('sourceRect $sourceRect');
          imageProvider = RectImageProvider(
            imageProvider,
            sourceRect!,
          );
        }

        final octoImage = OctoImage(
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
                    return octoImage;
                  }
                  final showHidePlaceWidget = snapshot.data ?? false;
                  onHideFlagChanged?.call(showHidePlaceWidget);
                  return showHidePlaceWidget
                      ? Center(
                          child: Icon(
                            CupertinoIcons.xmark_shield_fill,
                            size: 32,
                            color: CupertinoDynamicColor.resolve(
                                CupertinoColors.systemGrey3, context),
                          ),
                        )
                      : octoImage;
                } else {
                  return placeholder?.call(context, imageUrl) ??
                      Container(
                        alignment: Alignment.center,
                        child: const CupertinoActivityIndicator(),
                      );
                  // return octoImage;
                }
              });
        } else {
          return octoImage;
        }
      };

  @override
  Widget build(BuildContext context) {
    final imgHttpHeaders = {
      'Cookie': Global.profile.user.cookie,
      'Host': Uri.parse(imageUrl).host,
      'User-Agent': EHConst.CHROME_USER_AGENT,
      'Accept-Encoding': 'gzip, deflate, br'
    };
    if (httpHeaders != null) {
      imgHttpHeaders.addAll(httpHeaders!);
    }

    final image = CachedNetworkImage(
      cacheManager: imageCacheManager(ser: ser),
      imageBuilder: imageWidgetBuilder,
      httpHeaders: imgHttpHeaders,
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

final imageCacheManagerOld = CacheManager(
  Config(
    'CachedNetworkImage',
    fileService: HttpFileService(
      httpClient: client,
    ),
    // fileService: DioFileService(),
  ),
);

CacheManager imageCacheManager({int? ser}) {
  return CacheManager(
    Config(
      'CachedNetworkImage',
      fileService: DioFileService(ser: ser),
    ),
  );
}

ImageProvider getEhImageProvider(String url, {int? ser}) {
  return CachedNetworkImageProvider(
    url,
    cacheManager: imageCacheManager(ser: ser),
    // cacheKey: buildImageCacheKey(url),
  );
}
