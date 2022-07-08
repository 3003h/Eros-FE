import 'package:cached_network_image/cached_network_image.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;
import 'package:http/retry.dart' as retry;

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
    this.httpHeaders,
    this.onLoadCompleted,
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

  ProgressIndicatorBuilder? _getProgressIndicatorBuilder() {
    if (progressIndicatorBuilder != null) {
      return (context, url, progress) {
        if ((progress.progress ?? 0.0) >= 1.0) {
          onLoadCompleted?.call();
        }
        return progressIndicatorBuilder!.call(context, url, progress);
      };
    } else if (placeholder != null) {
      return (context, url, progress) {
        if ((progress.progress ?? 0.0) >= 1.0) {
          onLoadCompleted?.call();
        }
        return placeholder!.call(context, url);
      };
    } else {
      return (context, url, progress) {
        if ((progress.progress ?? 0.0) >= 1.0) {
          onLoadCompleted?.call();
        }
        return const SizedBox.shrink();
      };
    }
  }

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
      httpHeaders: _httpHeaders,
      width: width,
      height: height,
      fit: fit,
      imageUrl: imageUrl.dfUrl,
      // placeholder: onLoadCompleted == null ? placeholder : null,
      errorWidget: errorWidget,
      progressIndicatorBuilder: _getProgressIndicatorBuilder(),
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
