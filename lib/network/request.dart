import 'dart:convert';
import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:fehviewer/common/controller/advance_search_controller.dart';
import 'package:fehviewer/common/controller/user_controller.dart';
import 'package:fehviewer/common/parser/eh_parser.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/component/exception/error.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/pages/gallery/controller/archiver_controller.dart';
import 'package:fehviewer/pages/gallery/controller/torrent_controller.dart';
import 'package:fehviewer/pages/tab/fetch_list.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide FormData, Response;

import 'api.dart';
import 'app_dio/pdio.dart';

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
  Map<String, dynamic>? advanceSearchParam,
}) async {
  final AdvanceSearchController _searchController = Get.find();
  DioHttpClient dioHttpClient = DioHttpClient(dioConfig: ehDioConfig);

  await checkCookie();

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

  logger.v('advanceSearchParam $advanceSearchParam');

  /// 高级搜索处理
  if (advanceSearchParam != null) {
    if (advanceSearchParam.isNotEmpty) {
      _params['advsearch'] = 1;
      _params.addAll(advanceSearchParam);
    }
  } else if (!isTopList &&
      !isPopular &&
      !isFav &&
      _searchController.enableAdvance) {
    _params['advsearch'] = 1;
    _params.addAll(_searchController.advanceSearchMap);
  }

  if (serach != null && isFav) {
    _params.addAll(_searchController.favSearchMap);
  }

  logger.v('url:$_url ${_params}');

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
  } else {
    logger.e('${httpResponse.error.runtimeType}');
    throw httpResponse.error ?? EhError(error: 'getGallery error');
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
    logger.v('Global.profile.user.cookie: ${Global.profile.user.cookie}');

    final List<String> _c = Global.profile.user.cookie.split(';');

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
  // logger.d('showCookie: \n${cookies.join('\n')}');
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

Future<GalleryProvider?> getGalleryDetail({
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
  if (httpResponse.ok && httpResponse.data is GalleryProvider) {
    return httpResponse.data as GalleryProvider;
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
    logger.d('error.runtimeType: ${httpResponse.error.runtimeType}');
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

// Future<ArchiverProvider> getArchiver(
//   String url, {
//   bool refresh = true,
// }) async {
//   DioHttpClient dioHttpClient = DioHttpClient(dioConfig: ehDioConfig);
//
//   DioHttpResponse httpResponse = await dioHttpClient.get(
//     url,
//     httpTransformer: GalleryArchiverHttpTransformer(),
//     options: getCacheOptions(forceRefresh: refresh),
//   );
//
//   if (httpResponse.ok && httpResponse.data is ArchiverProvider) {
//     return httpResponse.data as ArchiverProvider;
//   } else {
//     return ArchiverProvider();
//   }
// }

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

Future<EhSettings?> getEhSettings(
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

Future<EhMytags?> getMyTags(
    {bool refresh = false, String? selectTagset}) async {
  await checkCookie();

  await showCookie();

  DioHttpClient dioHttpClient = DioHttpClient(dioConfig: ehDioConfig);
  final String url = '${Api.getBaseUrl()}/mytags';

  final Map<String, dynamic> _params = {
    if (selectTagset != null) 'tagset': selectTagset,
  };

  late DioHttpResponse httpResponse;
  for (int i = 0; i < 3; i++) {
    httpResponse = await dioHttpClient.get(
      url,
      queryParameters: _params,
      httpTransformer: MyTagsHttpTransformer(),
      options: getCacheOptions(forceRefresh: refresh || i > 0),
    );

    if (selectTagset == null) {
      break;
    }

    if (httpResponse.ok && httpResponse.data is EhMytags) {
      break;
    }
  }

  if (httpResponse.ok && httpResponse.data is EhMytags) {
    return httpResponse.data as EhMytags;
  }
  return null;
}

Future<bool> actionDeleteUserTag({
  List<String> usertags = const [],
}) async {
  final dataMap = {
    'usertag_action': 'mass',
    'modify_usertags[]': usertags,
  };

  return await actionMytags(dataMap: dataMap);
}

Future<bool> actionRenameTagSet({
  required String tagsetname,
}) async {
  final dataMap = {
    'tagset_action': 'rename',
    'tagset_name': tagsetname,
  };

  return await actionMytags(dataMap: dataMap);
}

Future<bool> actionCreatTagSet({
  required String tagsetname,
}) async {
  final dataMap = {
    'tagset_action': 'create',
    'tagset_name': tagsetname,
  };

  return await actionMytags(dataMap: dataMap);
}

Future<bool> actionDeleteTagSet({
  String? tagset,
}) async {
  final dataMap = {
    'tagset_action': 'delete',
  };

  return await actionMytags(
    dataMap: dataMap,
    queryParameters: {
      'tagset': tagset ?? '',
    },
  );
}

Future<bool> actionNewUserTag({
  required String tagName,
  String? tagColor,
  String? tagWeight,
  bool? tagWatch,
  bool? tagHide,
  String? tagset,
}) async {
  final dataMap = {
    'usertag_action': 'add',
    'tagname_new': tagName,
    'tagcolor_new': tagColor ?? '',
    'tagweight_new': tagWeight ?? '',
    'tagwatch_new': tagWatch ?? false ? 'on' : '',
    'taghide_new': tagHide ?? false ? 'on' : '',
    'usertag_target': '0'
  };

  return await actionMytags(
    dataMap: dataMap,
    queryParameters: {
      'tagset': tagset ?? '',
    },
  );
}

Future<bool> actionMytags({
  required Map<String, Object> dataMap,
  Map<String, dynamic>? queryParameters,
}) async {
  await checkCookie();
  const url = '/mytags';

  final formData = FormData.fromMap(dataMap);

  DioHttpClient dioHttpClient = DioHttpClient(dioConfig: ehDioConfig);

  DioHttpResponse httpResponse = await dioHttpClient.post(
    url,
    queryParameters: queryParameters,
    data: formData,
    httpTransformer: TagActionTransformer(),
    options: getCacheOptions(forceRefresh: true)
      ..followRedirects = false
      ..validateStatus = (status) => (status ?? 0) < 500,
  );

  if (httpResponse.ok && httpResponse.data is bool) {
    return httpResponse.data as bool;
  } else {
    return false;
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
  return null;
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
  logger.v('downloadUrl $downloadUrl');
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

Future<User?> userLogin(String username, String passwd) async {
  const String url = 'https://forums.e-hentai.org/index.php';

  DioHttpClient dioHttpClient = DioHttpClient(dioConfig: ehDioConfig);

  final FormData formData = FormData.fromMap({
    'UserName': username,
    'PassWord': passwd,
    'submit': 'Log me in',
    'temporary_https': 'off',
    'CookieDate': '365',
  });

  DioHttpResponse httpResponse = await dioHttpClient.post(
    url,
    queryParameters: {'act': 'Login', 'CODE': '01'},
    data: formData,
    httpTransformer: UserLoginTransformer(),
    options: getCacheOptions(forceRefresh: true)
      ..headers?['referer'] =
          'https://forums.e-hentai.org/index.php?act=Login&CODE=00',
  );

  if (httpResponse.ok && httpResponse.data is User) {
    return httpResponse.data as User;
  } else {
    throw httpResponse.error ?? HttpException('login error');
  }
}

Future<User?> getUserInfo(String userId) async {
  const String url = 'https://forums.e-hentai.org/index.php';

  DioHttpClient dioHttpClient = DioHttpClient(dioConfig: ehDioConfig);

  DioHttpResponse httpResponse = await dioHttpClient.get(
    url,
    queryParameters: {'showuser': userId},
    httpTransformer: UserInfoPageTransformer(),
    options: getCacheOptions(forceRefresh: true)
      ..headers?['referer'] = 'https://forums.e-hentai.org/index.php',
  );

  if (httpResponse.ok && httpResponse.data is User) {
    return httpResponse.data as User;
  } else {
    throw httpResponse.error ?? HttpException('get user info error');
  }
}

Future<bool?> postComment({
  required String gid,
  required String token,
  required String comment,
  String? commentId,
  bool isEdit = false,
  GalleryProvider? inGalleryItem,
}) async {
  if (utf8.encode(comment).length < 10) {
    showToast('Your comment is too short.');
    throw EhError(type: EhErrorType.def, error: 'Your comment is too short.');
  }

  final String url = '/g/$gid/$token';
  DioHttpClient dioHttpClient = DioHttpClient(dioConfig: ehDioConfig);

  final data = FormData.fromMap({
    isEdit ? 'commenttext_edit' : 'commenttext_new': comment,
    if (isEdit && commentId != null) 'edit_comment': int.parse(commentId),
  });

  DioHttpResponse httpResponse = await dioHttpClient.post(
    url,
    data: data,
    httpTransformer: HttpTransformerBuilder(
      (response) {
        logger.d('statusCode ${response.statusCode}');
        return DioHttpResponse<bool>.success(response.statusCode == 302);
      },
    ),
    options: getCacheOptions(forceRefresh: true)
      ..followRedirects = false
      ..validateStatus = (status) => (status ?? 0) < 500,
  );

  if (httpResponse.ok && httpResponse.data is bool) {
    return httpResponse.data as bool;
  } else {
    throw httpResponse.error ?? HttpException('error');
  }
}

Future<void> galleryAddfavorite(
  String gid,
  String token, {
  String favcat = 'favdel',
  String favnote = '',
}) async {
  const String url = '/gallerypopups.php';
  DioHttpClient dioHttpClient = DioHttpClient(dioConfig: ehDioConfig);

  final Map<String, dynamic> _params = {
    'gid': gid,
    't': token,
    'act': 'addfav',
  };

  final FormData formData = FormData.fromMap({
    'favcat': favcat,
    'update': '1',
  });

  DioHttpResponse httpResponse = await dioHttpClient.post(
    url,
    queryParameters: _params,
    data: formData,
    options: getCacheOptions(forceRefresh: true),
  );
}

Future<Map> getTranslateTagDBInfo(String url) async {
  DioHttpClient dioHttpClient = DioHttpClient(dioConfig: ehDioConfig);
  DioHttpResponse httpResponse = await dioHttpClient.get(url);
  if (httpResponse.ok && httpResponse.data is Map) {
    return httpResponse.data as Map;
  } else {
    throw httpResponse.error ?? HttpException('getTranslateTagDBInfo error');
  }
}

/// 获取里站cookie
Future<void> getExIgneous() async {
  const String url = '${EHConst.EX_BASE_URL}/uconfig.php';
  DioHttpClient dioHttpClient = DioHttpClient(dioConfig: ehDioConfig);
  DioHttpResponse httpResponse = await dioHttpClient.get(
    url,
    options: getCacheOptions(forceRefresh: true),
  );
  if (!httpResponse.ok) {
    throw httpResponse.error ?? HttpException('getExIgneous error');
  }
}

Future<String> getTorrentToken(
  String gid,
  String gtoken, {
  bool refresh = false,
}) async {
  DioHttpClient dioHttpClient = DioHttpClient(dioConfig: ehDioConfig);
  const url = '/gallerytorrents.php';
  final Map<String, dynamic> _params = {
    'gid': gid,
    't': gtoken,
  };

  DioHttpResponse httpResponse = await dioHttpClient.get(
    url,
    queryParameters: _params,
    options: getCacheOptions(forceRefresh: refresh),
    httpTransformer: HttpTransformerBuilder(
      (response) {
        final RegExp rTorrentTk =
            RegExp(r'http://ehtracker.org/(\d{7})/announce');
        final String torrentToken =
            rTorrentTk.firstMatch(response.data as String)?.group(1) ?? '';
        return DioHttpResponse<String>.success(torrentToken);
      },
    ),
  );

  if (httpResponse.ok && httpResponse.data is String) {
    return httpResponse.data as String;
  } else {
    throw httpResponse.error ?? HttpException('get Torrent Token error');
  }
}

Future<TorrentProvider> getTorrent(
  String url, {
  bool refresh = true,
}) async {
  DioHttpClient dioHttpClient = DioHttpClient(dioConfig: ehDioConfig);
  DioHttpResponse httpResponse = await dioHttpClient.get(
    url,
    options: getCacheOptions(forceRefresh: refresh),
    httpTransformer: HttpTransformerBuilder(
      (response) async {
        final torrentProvider =
            await compute(parseTorrent, response.data as String);
        return DioHttpResponse<TorrentProvider>.success(torrentProvider);
      },
    ),
  );
  if (httpResponse.ok && httpResponse.data is TorrentProvider) {
    return httpResponse.data as TorrentProvider;
  } else {
    throw httpResponse.error ?? HttpException('get Torrent error');
  }
}

Future<ArchiverProvider> getArchiver(
  String url, {
  bool refresh = true,
}) async {
  DioHttpClient dioHttpClient = DioHttpClient(dioConfig: ehDioConfig);
  DioHttpResponse httpResponse = await dioHttpClient.get(
    url,
    options: getCacheOptions(forceRefresh: refresh),
    httpTransformer: HttpTransformerBuilder(
      (response) async {
        final archiverProvider =
            await compute(parseArchiver, response.data as String);
        return DioHttpResponse<ArchiverProvider>.success(archiverProvider);
      },
    ),
  );
  if (httpResponse.ok && httpResponse.data is ArchiverProvider) {
    return httpResponse.data as ArchiverProvider;
  } else {
    throw httpResponse.error ?? HttpException('get Archiver error');
  }
}

Future<String> postEhApi(
  String data, {
  bool forceRefresh = true,
}) async {
  const String url = '/api.php';
  DioHttpClient dioHttpClient = DioHttpClient(dioConfig: ehDioConfig);
  DioHttpResponse httpResponse = await dioHttpClient.post(
    url,
    data: data,
    options: getCacheOptions(forceRefresh: forceRefresh),
  );
  if (httpResponse.ok && httpResponse.data is String) {
    return httpResponse.data as String;
  } else {
    throw httpResponse.error ?? HttpException('postEhApi error');
  }
}
