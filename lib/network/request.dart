import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:fehviewer/common/controller/advance_search_controller.dart';
import 'package:fehviewer/common/controller/user_controller.dart';
import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/common/parser/gallery_detail_parser.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/models/base/eh_models.dart';
import 'package:fehviewer/pages/gallery/controller/archiver_controller.dart';
import 'package:fehviewer/pages/tab/fetch_list.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart' hide FormData;

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

Future<GalleryList?> getGallery({
  int? page,
  String? fromGid,
  String? serach,
  int? cats,
  bool refresh = false,
  CancelToken? cancelToken,
  GalleryListType? galleryListType,
  String? toplist,
  String? favcat,
  ValueChanged<List<Favcat>>? favCatList,
}) async {
  final AdvanceSearchController _searchController = Get.find();
  DioHttpClient dioHttpClient = DioHttpClient(dioConfig: ehDioConfig);

  await checkCookie();

  logger.v('df ${ehDioConfig}');

  late final String _url;
  switch (galleryListType) {
    case GalleryListType.watched:
      _url = '/watched';
      break;
    case GalleryListType.toplist:
      _url = '${EHConst.EH_BASE_URL}/toplist.php';
      break;
    case GalleryListType.favorite:
      _url = '/favorites.php';
      break;
    case GalleryListType.popular:
      _url = '/popular';
      break;
    default:
      _url = '/';
  }

  final isTopList = galleryListType == GalleryListType.toplist;
  final isFav = galleryListType == GalleryListType.favorite;
  final isPopular = galleryListType == GalleryListType.popular;

  final Map<String, dynamic> _params = <String, dynamic>{
    if (!isTopList && !isPopular) 'page': page ?? 0,
    if (isTopList) 'p': page ?? 0,
    if (!isTopList && !isPopular && !isFav) 'f_cats': cats,
    if (!isTopList && !isPopular && fromGid != null) 'from': fromGid,
    if (!isTopList && !isPopular && serach != null) 'f_search': serach,
    if (isTopList && toplist != null && toplist.isNotEmpty) 'tl': toplist,
    if (isFav && favcat != null && favcat != 'a' && favcat.isNotEmpty)
      'favcat': favcat,
  };

  /// 高级搜索处理
  if (!isTopList && !isPopular && !isFav && _searchController.enableAdvance) {
    _params['advsearch'] = 1;
    _params.addAll(_searchController.advanceSearchMap);
  }

  if (serach != null && isFav) {
    _params.addAll(_searchController.favSearchMap);
  }

  logger.d('${_params}');

  DioHttpResponse httpResponse = await dioHttpClient.get(
    _url,
    queryParameters: _params,
    httpTransformer:
        isFav ? FavoriteListHttpTransformer() : GalleryListHttpTransformer(),
    options: getCacheOptions(forceRefresh: refresh),
    cancelToken: cancelToken,
  );

  if (httpResponse.error is ListDisplayModeException) {
    logger.d(' inline_set dml');
    _params['inline_set'] = 'dm_l';

    httpResponse = await dioHttpClient.get(
      _url,
      queryParameters: _params,
      httpTransformer:
          isFav ? FavoriteListHttpTransformer() : GalleryListHttpTransformer(),
      options: getCacheOptions(forceRefresh: true),
      cancelToken: cancelToken,
    );
  }

  if (httpResponse.error is FavOrderException) {
    final _order = (httpResponse.error as FavOrderException).order;
    _params['inline_set'] = _order;
    _params.removeWhere((key, value) => key == 'page');
    httpResponse = await dioHttpClient.get(
      _url,
      queryParameters: _params,
      httpTransformer:
          isFav ? FavoriteListHttpTransformer() : GalleryListHttpTransformer(),
      options: getCacheOptions(forceRefresh: true),
      cancelToken: cancelToken,
    );
  }

  if (httpResponse.ok && httpResponse.data is GalleryList) {
    return httpResponse.data as GalleryList;
  }
}

Future checkCookie() async {
  final PersistCookieJar cookieJar = await Api.cookieJar;
  final List<Cookie> cookies =
      await cookieJar.loadForRequest(Uri.parse(Api.getBaseUrl()));
  cookies.add(Cookie('nw', '1'));

  final UserController userController = Get.find();
  final EhConfigService ehConfigService = Get.find();

  if (userController.isLogin) {
    final List<String> _c = Global.profile.user.cookie?.split(';') ?? [];

    final List<Cookie> _cookies =
        _c.map((e) => Cookie.fromSetCookieValue(e)).toList();

    cookies.addAll(_cookies);

    cookieJar.saveFromResponse(Uri.parse(Api.getBaseUrl()), cookies);

    final sp = cookies.firstWhereOrNull((element) => element.name == 'sp');
    if (ehConfigService.selectProfile.isNotEmpty &&
        (sp == null || sp.value.isEmpty)) {
      cookies.add(Cookie('sp', ehConfigService.selectProfile));
    }

    // logger.d('cookies:${cookies.join('\n')}');
  }
}

Future<void> showCookie() async {
  final PersistCookieJar cookieJar = await Api.cookieJar;
  final List<Cookie> cookies =
      await cookieJar.loadForRequest(Uri.parse(Api.getBaseUrl()));
  logger.d('showCookie: \n${cookies.join('\n')}');
}

Future<void> cleanCookie(String name) async {
  final PersistCookieJar cookieJar = await Api.cookieJar;
  final List<Cookie> cookies =
      await cookieJar.loadForRequest(Uri.parse(Api.getBaseUrl()));
  cookies.removeWhere((element) => element.name == name);
  logger.d('after remove: \n${cookies.join('\n')}');
  await cookieJar.delete(Uri.parse(Api.getBaseUrl()));
  await cookieJar.saveFromResponse(Uri.parse(Api.getBaseUrl()), cookies);
  logger.d('showCookie: \n${cookies.join('\n')}');
}

Future<void> setCookie(String name, String value) async {
  final PersistCookieJar cookieJar = await Api.cookieJar;
  final List<Cookie> cookies =
      await cookieJar.loadForRequest(Uri.parse(Api.getBaseUrl()));
  final _cookie = cookies.firstWhereOrNull((element) => element.name == name);
  if (_cookie != null) {
    _cookie.value = value;
  } else {
    cookies.add(Cookie(name, value));
  }
  // logger.d('after remove: \n${cookies.join('\n')}');
  // await cookieJar.delete(Uri.parse(Api.getBaseUrl()));
  // await cookieJar.saveFromResponse(Uri.parse(Api.getBaseUrl()), cookies);
}

Future<String?> getCookieValue(String name) async {
  final PersistCookieJar cookieJar = await Api.cookieJar;
  final List<Cookie> cookies =
      await cookieJar.loadForRequest(Uri.parse(Api.getBaseUrl()));
  final _cookie = cookies.firstWhereOrNull((element) => element.name == name);
  return _cookie?.value;
}

Future<GalleryItem?> getGalleryDetail({
  required String url,
  bool refresh = false,
  CancelToken? cancelToken,
}) async {
  await checkCookie();

  DioHttpClient dioHttpClient = DioHttpClient(dioConfig: ehDioConfig);
  DioHttpResponse httpResponse = await dioHttpClient.get(
    url,
    httpTransformer: GalleryHttpTransformer(),
    options: getCacheOptions(forceRefresh: refresh),
    cancelToken: cancelToken,
  );
  logger.v('httpResponse.ok ${httpResponse.ok}');
  if (httpResponse.ok && httpResponse.data is GalleryItem) {
    return httpResponse.data as GalleryItem;
  } else {
    // logger.e('${httpResponse.error}');
    if (httpResponse.error?.code == 404) {
      final errMsg = parseErrGallery(httpResponse.error?.data as String? ?? '');
      logger.d('errMsg: $errMsg');
      throw BadRequestException(
          code: httpResponse.error?.code, message: errMsg);
    }
    throw httpResponse.error ?? UnknownException();
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

  String mpvSer = '1';
  final isMpv = regGalleryMpvPageUrl.hasMatch(href);
  if (isMpv) {
    mpvSer = regGalleryMpvPageUrl.firstMatch(href)?.group(3) ?? '1';
  }

  logger.v('url $href  isMpv:$isMpv');

  DioHttpClient dioHttpClient = DioHttpClient(dioConfig: ehDioConfig);
  DioHttpResponse httpResponse = await dioHttpClient.get(
    href,
    queryParameters: _params,
    httpTransformer: isMpv
        ? GalleryMpvImageHttpTransformer(mpvSer, sourceId: sourceId)
        : GalleryImageHttpTransformer(),
    options: getCacheOptions(forceRefresh: refresh),
    cancelToken: cancelToken,
  );

  if (httpResponse.ok && httpResponse.data is GalleryImage) {
    return (httpResponse.data as GalleryImage).copyWith(href: href);
  } else {
    logger.d('${httpResponse.error.runtimeType}');
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
    cancelToken: cancelToken,
  );

  if (httpResponse.ok && httpResponse.data is List<GalleryImage>) {
    return httpResponse.data as List<GalleryImage>;
  } else {
    return [];
  }
}

Future<ArchiverProvider> getArchiver(
  String url, {
  bool refresh = true,
}) async {
  DioHttpClient dioHttpClient = DioHttpClient(dioConfig: ehDioConfig);

  DioHttpResponse httpResponse = await dioHttpClient.get(
    url,
    httpTransformer: GalleryArchiverHttpTransformer(),
    options: getCacheOptions(forceRefresh: refresh),
  );

  if (httpResponse.ok && httpResponse.data is ArchiverProvider) {
    return httpResponse.data as ArchiverProvider;
  } else {
    return ArchiverProvider();
  }
}

Future<String> postArchiverRemoteDownload(
  String url,
  String resolution,
) async {
  DioHttpClient dioHttpClient = DioHttpClient(dioConfig: ehDioConfig);

  final formData = FormData.fromMap({
    'hathdl_xres': resolution.trim(),
  });

  DioHttpResponse httpResponse = await dioHttpClient.post(
    url,
    data: formData,
    httpTransformer: GalleryArchiverRemoteDownloadResponseTransformer(),
    options: getCacheOptions(forceRefresh: true),
  );

  if (httpResponse.ok && httpResponse.data is String) {
    return httpResponse.data as String;
  } else {
    return '';
  }
}

Future<String> postArchiverLocalDownload(
  String url, {
  String? dltype,
  String? dlcheck,
}) async {
  final formData = FormData.fromMap({
    if (dltype != null) 'dltype': dltype.trim(),
    if (dlcheck != null) 'dlcheck': dlcheck.trim(),
  });
  DioHttpClient dioHttpClient = DioHttpClient(dioConfig: ehDioConfig);

  DioHttpResponse httpResponse = await dioHttpClient.post(
    url,
    data: formData,
    httpTransformer: GalleryArchiverLocalDownloadResponseTransformer(),
    options: getCacheOptions(forceRefresh: true),
  );

  if (httpResponse.ok && httpResponse.data is String) {
    return httpResponse.data as String;
  } else {
    return '';
  }
}

Future<EhSettings?> getUconfig(
    {bool refresh = false, String? selectProfile}) async {
  await checkCookie();

  await showCookie();

  DioHttpClient dioHttpClient = DioHttpClient(dioConfig: ehDioConfig);
  final String url = '${Api.getBaseUrl()}/uconfig.php';

  late DioHttpResponse httpResponse;
  for (int i = 0; i < 3; i++) {
    logger.d('getUconfig sp:$selectProfile idx:$i');
    httpResponse = await dioHttpClient.get(
      url,
      httpTransformer: UconfigHttpTransformer(),
      options: getCacheOptions(forceRefresh: refresh || i > 0),
    );

    if (selectProfile == null) {
      break;
    }

    if (httpResponse.ok && httpResponse.data is EhSettings) {
      if (httpResponse.data.profileSelected == selectProfile) {
        break;
      }
    }
  }

  if (httpResponse.ok && httpResponse.data is EhSettings) {
    return httpResponse.data as EhSettings;
  }
}

Future<EhSettings?> postEhProfile({
  String? profileSet,
  String? action,
  String? name,
  Map<String, dynamic>? paramMap,
  bool refresh = true,
}) async {
  await checkCookie();
  final dataMap = {
    if (action != null) 'profile_action': action,
    if (name != null) 'profile_name': name,
    if (profileSet != null) 'profile_set': profileSet.trim(),
  };
  // final _dataString =
  //     dataMap.entries.map((e) => '${e.key}=${e.value}').join('&');
  // logger.d('_dataString: $_dataString');
  final formData = FormData.fromMap(paramMap ?? dataMap);
  DioHttpClient dioHttpClient = DioHttpClient(dioConfig: ehDioConfig);
  const String url = '/uconfig.php';

  DioHttpResponse httpResponse = await dioHttpClient.post(
    url,
    data: formData,
    // data: _dataString,
    httpTransformer: UconfigHttpTransformer(),
    options: getCacheOptions(forceRefresh: refresh),
  );

  if (httpResponse.ok && httpResponse.data is EhSettings) {
    return httpResponse.data as EhSettings;
  }
}

Future<EhSettings?> changeEhProfile(String profileSet,
    {bool refresh = true}) async {
  // await cleanCookie('sp');
  return await postEhProfile(
    profileSet: profileSet,
    action: '',
    refresh: refresh,
  );
}

Future<EhSettings?> deleteEhProfile(String profileSet,
    {bool refresh = true}) async {
  // await cleanCookie('sp');
  return await postEhProfile(
    profileSet: profileSet,
    action: 'delete',
    refresh: refresh,
  );
}

Future<EhSettings?> createEhProfile(String name, {bool refresh = true}) async {
  // await cleanCookie('sp');
  return await postEhProfile(
    action: 'create',
    name: name,
    refresh: refresh,
  );
}

Future<EhSettings?> renameEhProfile(String profileSet, String name,
    {bool refresh = true}) async {
  return await postEhProfile(
    action: 'rename',
    profileSet: profileSet,
    name: name,
    refresh: refresh,
  );
}

Future<EhSettings?> setDefauleEhProfile(String profileSet,
    {bool refresh = true}) async {
  return await postEhProfile(
    profileSet: profileSet,
    action: 'default',
    refresh: refresh,
  );
}

Future<EhSettings?> applyEhProfile(Map<String, dynamic> paramMap) async {
  return await postEhProfile(
    paramMap: paramMap,
  );
}

Future<T?> getEhApi<T>({
  required String data,
  bool refresh = false,
  HttpTransformer? httpTransformer,
}) async {
  const String url = '/api.php';
  await checkCookie();
  DioHttpClient dioHttpClient = DioHttpClient(dioConfig: ehDioConfig);

  DioHttpResponse httpResponse = await dioHttpClient.post(
    url,
    data: data,
    httpTransformer: httpTransformer,
    options: getCacheOptions(forceRefresh: refresh),
  );

  if (httpResponse.ok && httpResponse.data is T) {
    return httpResponse.data as T;
  }
}

Future<GalleryImage?> mpvLoadImageDispatch({
  required int gid,
  required String mpvkey,
  required int page,
  required String imgkey,
  String? sourceId,
}) async {
  final Map reqMap = {
    'imgkey': imgkey,
    'method': 'imagedispatch',
    'gid': gid,
    'page': page,
    'mpvkey': mpvkey,
    if (sourceId != null) 'nl': sourceId,
  };
  final String reqJsonStr = jsonEncode(reqMap);

  return await getEhApi<GalleryImage>(
    data: reqJsonStr,
    httpTransformer: ImageDispatchTransformer(),
  );
}

Future<void> ehDownload({
  required String url,
  required String savePath,
  CancelToken? cancelToken,
  bool? errToast,
  bool deleteOnError = true,
  VoidCallback? onDownloadComplete,
  ProgressCallback? progressCallback,
}) async {
  await checkCookie();

  late final String downloadUrl;
  DioHttpClient dioHttpClient = DioHttpClient(dioConfig: ehDioConfig);
  if (!url.startsWith(RegExp(r'https?://'))) {
    downloadUrl = '${Api.getBaseUrl()}/$url';
  } else {
    downloadUrl = url;
  }
  logger.d('downloadUrl $downloadUrl');
  try {
    await dioHttpClient.download(
      downloadUrl,
      savePath,
      deleteOnError: deleteOnError,
      onReceiveProgress: (int count, int total) {
        progressCallback?.call(count, total);
        if (count == total) {
          onDownloadComplete?.call();
        }
      },
      cancelToken: cancelToken,
    );
  } on CancelException catch (e) {
    logger.d('cancel');
  } on Exception catch (e) {
    rethrow;
  }
}
