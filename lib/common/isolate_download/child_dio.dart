part of 'download_manager.dart';

const int _connectTimeout = 20000;
const int _receiveTimeout = 10000;

class IsolateDioEH {
  IsolateDioEH._({this.appSupportPath}) {
    _options = BaseOptions(
      baseUrl: EHConst.EH_BASE_URL,
      connectTimeout: _connectTimeout,
      receiveTimeout: _receiveTimeout,
      //设置请求头
      headers: <String, String>{
        'User-Agent': EHConst.CHROME_USER_AGENT,
        'Accept': EHConst.CHROME_ACCEPT,
        'Accept-Language': EHConst.CHROME_ACCEPT_LANGUAGE,
      },
      contentType: Headers.formUrlEncodedContentType,
      responseType: ResponseType.json,
    );

    // this.appSupportPath ??= appSupportPath;

    _dio = Dio(_options);

    // Cookie管理
    final PersistCookieJar cookieJar =
        PersistCookieJar(storage: FileStorage(appSupportPath));
    final CookieManager _cookieManager = CookieManager(cookieJar);
    _dio.interceptors.add(_cookieManager);

    /// 缓存
    /// 在ioslae中使用磁盘缓存会有问题，暂时跳过磁盘缓存
    _dio.interceptors.add(DioCacheManager(
      CacheConfig(
        skipDiskCache: true,
        maxMemoryCacheCount: 1000,
        databasePath: appSupportPath,
        baseUrl: EHConst.EH_BASE_URL,
      ),
    ).interceptor as Interceptor);
  }
  factory IsolateDioEH.getInstance() => _instance;
  static final IsolateDioEH _instance = IsolateDioEH._();

  late String? appSupportPath;

  late BaseOptions _options;

  late Dio _dio;
}

Dio _getIsolateDio({
  bool isSiteEx = false,
  bool download = false,
  required String appSupportPath,
}) {
  Dio _dio;
  BaseOptions _options;

  final String _baseUrl = EHConst.getBaseSite(isSiteEx);
  _options = BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: _connectTimeout,
      receiveTimeout: _receiveTimeout,
      //设置请求头
      headers: <String, String>{
        'User-Agent': EHConst.CHROME_USER_AGENT,
        'Accept': EHConst.CHROME_ACCEPT,
        'Accept-Language': EHConst.CHROME_ACCEPT_LANGUAGE,
      },
      //默认值是"application/json; charset=utf-8",Headers.formUrlEncodedContentType会自动编码请求体.
      contentType: Headers.formUrlEncodedContentType,
      //共有三种方式json,bytes(响应字节),stream（响应流）,plain
      responseType: ResponseType.json);
  _dio = Dio(_options);

  // Cookie管理
  final PersistCookieJar cookieJar =
      PersistCookieJar(storage: FileStorage(appSupportPath));
  final CookieManager _cookieManager = CookieManager(cookieJar);
  _dio.interceptors.add(_cookieManager);

  /// 缓存
  /// 在ioslae中使用磁盘缓存会有问题，暂时跳过磁盘缓存
  _dio.interceptors.add(DioCacheManager(
    CacheConfig(
      skipDiskCache: true,
      maxMemoryCacheCount: 1000,
      databasePath: appSupportPath,
      baseUrl: Api.getBaseUrl(isSiteEx: isSiteEx),
    ),
  ).interceptor as Interceptor);

  if (false) {
    _dio.interceptors.add(InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
      // _dlCountStream.listen((int event) {
      //   logger.d('event dlCount $event');
      //   if (event < 3) {
      //     _incrementTask();
      //     _dio.interceptors.requestLock.unlock();
      //     handler.next(options);
      //   } else {
      //     _dio.interceptors.requestLock.lock();
      //   }
      // });

      _dio.interceptors.requestLock.lock();
      _dlCountStream.listen((int event) {
        logger.d('event dlCount $event');
        if (event < 3) {
          _incrementTask();
          handler.next(options);
          _dio.interceptors.requestLock.unlock();
        }
      });
    }));
  }

  // 锁定控制
  /*_dio.interceptors.add(InterceptorsWrapper(
      onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
    // We use a new Dio(to avoid dead lock) instance to request token.
    // tokenDio.get('/token').then((response) {
    //   //Set the token to headers
    //   options.headers['token'] = response.data['data']['token'];
    //   handler.next(options); //continue
    // }).catchError((error, stackTrace) {
    //   handler.reject(error, true);
    // }).whenComplete(() => _dio.interceptors.requestLock.unlock());

    //任务的周期性执行
    // Timer.periodic(Duration(milliseconds: 200), (timer) {
    //   logger.d('dio numCurrentDownloadTasks $dlCount');
    //   // count++;
    //   if (dlCount > 3) {
    //     _dio.interceptors.requestLock.lock();
    //   } else {
    //     //当执行count>3时，取消timer中的任务
    //     timer.cancel();
    //     handler.next(options);
    //     _dio.interceptors.requestLock.unlock();
    //   }
    // });
  }));*/

  return _dio;
}

/// 获取画廊缩略图
/// [inUrl] 画廊的地址
/// [page] 缩略图页码
Future<List<GalleryImage>> _isoFetchGalleryImage(
  String inUrl, {
  required String appSupportPath,
  bool isSiteEx = false,
  int page = 0,
  bool refresh = false,
  CancelToken? cancelToken,
}) async {
  final PersistCookieJar cookieJar =
      PersistCookieJar(storage: FileStorage(appSupportPath));
  final String _baseUrl = EHConst.getBaseSite(isSiteEx);
  final String url = inUrl + '?p=$page';

  final List<Cookie> cookies =
      await cookieJar.loadForRequest(Uri.parse(_baseUrl));
  cookies.add(Cookie('nw', '1'));
  cookieJar.saveFromResponse(Uri.parse(_baseUrl), cookies);

  // final Dio _isolateDio = _getIsolateDio(
  //   isSiteEx: isSiteEx,
  //   appSupportPath: appSupportPath,
  // );
  final Dio _isolateDio = isSiteEx ? exDio : ehDio;

  Response<String> response;
  try {
    response = await _isolateDio.get<String>(url,
        options: Api.getCacheOptions(forceRefresh: refresh),
        cancelToken: cancelToken);
  } on DioError catch (e, stack) {
    logger.e('getHttp exception: $e\n$stack');
    rethrow;
  }

  // logger.d('${response.data}');

  return GalleryDetailParser.parseGalleryImageFromHtml(response.data!);
}

/// 获取画廊图片的信息
/// [href] 爬取的页面地址 用来解析gid 和 imgkey
/// [page] 索引 从 1 开始
Future<GalleryImage> _isoParaImageLageInfoFromHtml(
  String href, {
  bool refresh = false,
  bool isSiteEx = false,
  required String appSupportPath,
}) async {
  final String url = href;

  // final Dio _isolateDio = _getIsolateDio(
  //   isSiteEx: isSiteEx,
  //   appSupportPath: appSupportPath,
  // );
  final Dio _isolateDio = isSiteEx ? exDio : ehDio;

  Response<String> response;
  try {
    response = await _isolateDio.get<String>(url,
        options: Api.getCacheOptions(forceRefresh: refresh));
  } on DioError catch (e, stack) {
    // logger.e('getHttp exception: $e\n$stack');
    rethrow;
  } catch (e) {
    rethrow;
  }

  final Document document = parse(response.data);

  // logger.d('res $response');

  final RegExp regImageUrl = RegExp('<img[^>]*src=\"([^\"]+)\" style');
  final String imageUrl =
      regImageUrl.firstMatch(response.data!)?.group(1) ?? '';

  // logger.d('imageUrl $imageUrl');

  final String _sourceId = RegExp(r"nl\('(.*?)'\)")
          .firstMatch(
              document.querySelector('#loadfail')!.attributes['onclick']!)
          ?.group(1) ??
      '';

  final RegExpMatch? _xy =
      RegExp(r'::\s+(\d+)\s+x\s+(\d+)\s+::').firstMatch(response.data!);
  final double? width = double.parse(_xy?.group(1) ?? '0');
  final double? height = double.parse(_xy?.group(2) ?? '0');

  final GalleryImage _reImage = GalleryImage(
      imageUrl: imageUrl,
      sourceId: _sourceId,
      imageWidth: width,
      imageHeight: height,
      ser: -1);

  return _reImage;
}

//下载文件
Future<Response<dynamic>?> _downLoadFile(
    {required String appSupportPath,
    bool isSiteEx = false,
    required String urlPath,
    required String savePath}) async {
  late Response<dynamic> response;

  // final Dio _isolateDio = _getIsolateDio(
  //   isSiteEx: isSiteEx,
  //   appSupportPath: appSupportPath,
  // );

  final Dio _isolateDio = isSiteEx ? exDlDio : ehDlDio;

  try {
    response = await _isolateDio.download(
      urlPath,
      savePath,
      onReceiveProgress: (int count, int total) {
        // logger.d('$count / $total');
      },
      options: Options(
        receiveTimeout: 0,
      ),
    );
    // logger.d('downLoadFile response: $response');
  } on DioError catch (e) {
    logger.e('downLoadFile exception: $e');
    rethrow;
  } finally {
    // logger.d('numCurrentDownloadTasks $numCurrentDownloadTasks');
    _decrementTask();
  }
  return response;
}

/// 获取下载路径
Future<String> _getDownloadPath(String appDocPath, String extStorePath) async {
  final String _dirPath = GetPlatform.isAndroid
      ? path.join(extStorePath, 'Download')
      : path.join(appDocPath, 'Download');
  // : Global.appDocPath;

  final Directory savedDir = Directory(_dirPath);
  // 判断下载路径是否存在
  final bool hasExisted = savedDir.existsSync();
  // 不存在就新建路径
  if (!hasExisted) {
    savedDir.createSync(recursive: true);
  }

  return _dirPath;
}
