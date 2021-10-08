import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/models/base/eh_models.dart';
import 'package:fehviewer/pages/tab/controller/search_page_controller.dart';
import 'package:fehviewer/utils/logger.dart';

import 'app_dio/pdio.dart';
import 'gallery_request.dart';

Options getCacheOptions({bool forceRefresh = false, Options? options}) {
  return buildCacheOptions(
    const Duration(days: 5),
    maxStale: const Duration(days: 7),
    forceRefresh: forceRefresh,
    options: options,
  );
}

Future<GallerysAndMaxpage?> getPopular({
  int? page,
  String? fromGid,
  String? serach,
  int? cats,
  bool refresh = false,
  SearchType searchType = SearchType.normal,
  CancelToken? cancelToken,
  String? favcat,
  String? toplist,
}) async {
  DioHttpClient dioHttpClient = DioHttpClient(dioConfig: ehDioConfig);
  DioHttpResponse httpResponse = await dioHttpClient.get(
    '/popular',
    httpTransformer: GalleryListHttpTransformer(),
  );

  if (httpResponse.ok && httpResponse.data is GallerysAndMaxpage) {
    return httpResponse.data as GallerysAndMaxpage;
  }
}

Future<GalleryItem?> getGalleryDetail({
  required String inUrl,
  bool refresh = false,
  CancelToken? cancelToken,
}) async {
  final PersistCookieJar cookieJar = await Api.cookieJar;
  final List<Cookie> cookies =
      await cookieJar.loadForRequest(Uri.parse(Api.getBaseUrl()));
  cookies.add(Cookie('nw', '1'));
  cookieJar.saveFromResponse(Uri.parse(Api.getBaseUrl()), cookies);

  DioHttpClient dioHttpClient = DioHttpClient(dioConfig: ehDioConfig);
  DioHttpResponse httpResponse = await dioHttpClient.get(
    inUrl,
    httpTransformer: GalleryHttpTransformer(),
    options: getCacheOptions(forceRefresh: refresh),
  );
  logger.v('httpResponse.ok ${httpResponse.ok}');
  if (httpResponse.ok && httpResponse.data is GalleryItem) {
    return httpResponse.data as GalleryItem;
  }
}

Future<GalleryImage?> fetchImageInfo(
  String href, {
  bool refresh = false,
  String? sourceId,
  CancelToken? cancelToken,
}) async {
  final Map<String, dynamic> _params = {
    if (sourceId != null && sourceId.trim().isNotEmpty) 'nl': sourceId,
  };

  DioHttpClient dioHttpClient = DioHttpClient(dioConfig: ehDioConfig);
  DioHttpResponse httpResponse = await dioHttpClient.get(
    href,
    queryParameters: _params,
    httpTransformer: GalleryImageHttpTransformer(),
    options: getCacheOptions(forceRefresh: refresh),
  );

  if (httpResponse.ok && httpResponse.data is GalleryImage) {
    return (httpResponse.data as GalleryImage).copyWith(href: href);
  }
}

Future<List<GalleryImage>> getGalleryImage(
  String inUrl, {
  int? page,
  bool refresh = false,
  CancelToken? cancelToken,
}) async {
  final Map<String, dynamic> _params = {
    if (page != null) 'p': page,
  };
  DioHttpClient dioHttpClient = DioHttpClient(dioConfig: ehDioConfig);

  DioHttpResponse httpResponse = await dioHttpClient.get(
    inUrl,
    queryParameters: _params,
    httpTransformer: GalleryImageListHttpTransformer(),
    options: getCacheOptions(forceRefresh: refresh),
  );

  if (httpResponse.ok && httpResponse.data is List<GalleryImage>) {
    return httpResponse.data as List<GalleryImage>;
  } else {
    return [];
  }
}
