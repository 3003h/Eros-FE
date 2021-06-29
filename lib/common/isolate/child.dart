part of 'download.dart';

/// isoload下载入口函数
/// 在这里进行实际的链接解析，图片文件下载
void _isolateDownload(SendPort sendPort) {
  // try {
  //   initLogger(isolate: true);
  //   logger.d('init _isolateDownload only ConsoleOutput');
  // } catch (e, stack) {
  //   sendPort.send(
  //     _ResponseProtocol.error(
  //       _ResponseBean(
  //         msg: '$e\n$stack',
  //       ),
  //     ),
  //   );
  // }

  // 创建一个消息接收器
  final ReceivePort _receivePort = ReceivePort();
  sendPort.send(_receivePort.sendPort);

  // 监听父isolate消息
  _receivePort.listen((dynamic message) async {
    try {
      if (message is _RequestProtocol) {
        final _RequestType _requestType = message.requestType!;
        final _RequestBean _requestBean = message.data;

        switch (_requestType) {

          /// initLogger
          case _RequestType.initLogger:
            final List<String?>? _loginfo = _requestBean.loginfo;
            print(_loginfo);
            if (_loginfo != null && _loginfo.length >= 2) {
              initLogger(directory: _loginfo[0], fileName: _loginfo[1]);
              logger.d('init _isolate Logger');
            }
            break;

          /// 添加下载任务
          /// 接收父线程发过来的画廊信息
          /// 开始获取解析画廊web页面
          /// 解析画廊图片url
          case _RequestType.addTask:
            print('_RequestType.addTask');
            final GalleryTask _initGalleryTask = _requestBean.galleryTask!;
            logger.d(
                'isolate add task ${_initGalleryTask.gid} ${_initGalleryTask.title}');

            // 获取所有图片页的href链接 通知父线程
            logger.v('获取所有图片页的href链接 通知父线程 start');
            final List<GalleryImage> _images =
                await _updateDtl(_requestBean, sendPort);

            // 更新大图url 下载图片 通知父线程
            logger.v('更新大图url 下载图片 通知父线程 start');
            await _downloadAllImage(_requestBean, sendPort, _images);

            // 测试 发送消息回父isolate
            sendPort.send(
              _ResponseProtocol.complete(
                _ResponseBean(
                  msg:
                      'gid:${_initGalleryTask.gid} => images[${_images.length}]',
                  images: _images,
                ),
              ),
            );
            break;
          default:
            break;
        }
      }
    } catch (e, stack) {
      logger.e('$e\n$stack');
      sendPort.send(
        _ResponseProtocol.error(
          _ResponseBean(
            msg: '$e',
            desc: '$stack',
          ),
        ),
      );
      // rethrow;
    }
  });
}

Future<List<GalleryImage>> _updateDtl(
    _RequestBean _requestBean, SendPort sendPort) async {
  // 获取所有图片页的href
  final List<GalleryImage> _images = await _fetchAllImages(
    url: _requestBean.galleryTask!.url!,
    fileCount: _requestBean.galleryTask!.fileCount,
    appSupportPath: _requestBean.appSupportPath!,
    isSiteEx: _requestBean.isSiteEx!,
    initImages: _requestBean.initImages,
  );

  logger.d('获取所有图片页的href完成 ${_images.length}');

  // 发送获取结果到父iso 更新明细库
  sendPort.send(
    _ResponseProtocol.initDtl(
      _ResponseBean(galleryTask: _requestBean.galleryTask, images: _images),
    ),
  );

  return _images;
}

Future<void> _fetchAndDownloadOneImage(
  _RequestBean _requestBean,
  SendPort sendPort,
  GalleryImage image, {
  int? maxSer,
}) async {
  const int _kserlen = 4;

  // logger.d('new get imageUrl ${preview.ser} ');
  final GalleryImage _info = await _isoParaImageLageInfoFromHtml(
    image.href!,
    isSiteEx: _requestBean.isSiteEx ?? false,
    appSupportPath: _requestBean.appSupportPath!,
  );

  // final String _fileName =
  //     _info.largeImageUrl!.substring(_info.largeImageUrl!.lastIndexOf('/') + 1);
  final String _suffix =
      _info.imageUrl!.substring(_info.imageUrl!.lastIndexOf('.'));
  final String _fileName = maxSer != null && '$maxSer'.length > _kserlen
      ? '${sprintf('%0${'$maxSer'.length}d', [image.ser])}$_suffix'
      : '${sprintf('%0${_kserlen}d', [image.ser])}$_suffix';

  logger.d('isolate gid[${_requestBean.galleryTask?.gid}] ${image.ser}\n'
      'url:[${_info.imageUrl}]\n'
      'fileName [$_fileName]');

  final ProgessBean _progessBean = ProgessBean(updateImages: [
    GalleryImageTask(
      gid: _requestBean.galleryTask!.gid,
      ser: image.ser,
      imageUrl: _info.imageUrl,
      sourceId: _info.sourceId,
      filePath: _fileName,
      token: '',
    ),
  ]);
  // 发送消息回父 isolate, 更新明细中的largeImageUrl,sourceId,_fileName
  sendPort.send(
    _ResponseProtocol.progress(
      _ResponseBean(
        progess: _progessBean,
        galleryTask: _requestBean.galleryTask,
      ),
    ),
  );

  /// 开始下载
  try {
    await _downloadImage(
      _requestBean,
      sendPort,
      _info.imageUrl!,
      _fileName,
      _requestBean.appDocPath!,
      _requestBean.extStorePath!,
      _requestBean.downloadPath!,
    );
  } on DioError catch (e) {
    if (e.response?.statusCode == 403) {
      logger.e('403');
    }
    if (e.type == DioErrorType.connectTimeout) {
      logger.e('连接超时 retry');
      await _downloadImage(
        _requestBean,
        sendPort,
        _info.imageUrl!,
        _fileName,
        _requestBean.appDocPath!,
        _requestBean.extStorePath!,
        _requestBean.downloadPath!,
      );
    }
  } catch (e) {
    rethrow;
  }
}

Future<void> _reDownloadOneImage(
  _RequestBean _requestBean,
  SendPort sendPort,
  GalleryImage image,
  GalleryImageTask _imageTask,
) async {
  logger.d('re _downloadImage');

  try {
    await _downloadImage(
      _requestBean,
      sendPort,
      _imageTask.imageUrl!,
      _imageTask.filePath ?? '',
      _requestBean.appDocPath!,
      _requestBean.extStorePath!,
      _requestBean.downloadPath!,
    );
  } on DioError catch (e) {
    if (e.response?.statusCode == 403) {
      logger.e('403 ${_imageTask.gid}.${image.ser}下载链接已经失效 需要更新');
      _fetchAndDownloadOneImage(_requestBean, sendPort, image);
    }
  } catch (e) {
    rethrow;
  }
}

Future<void> _downloadAllImage(
  _RequestBean _requestBean,
  SendPort sendPort,
  List<GalleryImage> _images,
) async {
  // 初始化的明细任务 可为空
  final List<GalleryImageTask>? _imageTasks = _requestBean.imageTasks;

  // 依次获取大图url 更新明细
  logger.v('循环处理 依次获取大图url 更新明细');
  for (final GalleryImage image in _images) {
    //
    bool _imageTaskUrlIsNotExist = true;
    GalleryImageTask? _imageTask;
    if (_imageTasks!.isNotEmpty) {
      _imageTask = _imageTasks
          .firstWhere((GalleryImageTask element) => element.ser == image.ser);
      _imageTaskUrlIsNotExist =
          _imageTask.imageUrl == null || _imageTask.imageUrl!.isEmpty;
    }

    try {
      if ((image.imageUrl == null || image.imageUrl!.isEmpty) &&
          _imageTaskUrlIsNotExist) {
        // 首次获取url 并且下载图片
        _fetchAndDownloadOneImage(_requestBean, sendPort, image,
            maxSer: _images.map((e) => e.ser).reduce(math.max));
      } else if (_imageTask != null &&
          _imageTask.imageUrl != null &&
          _imageTask.imageUrl != null &&
          _imageTask.imageUrl!.isNotEmpty) {
        // 重新下载图片
        _reDownloadOneImage(_requestBean, sendPort, image, _imageTask);
      }
    } catch (e, stack) {
      // logger.e('$e\n$stack');
      // sendPort.send(
      //   _ResponseProtocol.error(
      //     _ResponseBean(
      //       msg: '$e\n$stack',
      //     ),
      //   ),
      // );
      rethrow;
    }
  }
}

/// 下载单张图片
Future<void> _downloadImage(
  _RequestBean _requestBean,
  SendPort sendPort,
  String largeImageUrl,
  String fileName,
  String appDocPath,
  String extStorePath,
  String downloadPath,
) async {
  final String dlPath = await _getDownloadPath(appDocPath, extStorePath);
  // 下载图片
  final String savePath = path.join(downloadPath, fileName);
  // logger.v('savePath $savePath');
  await _downLoadFile(
      appSupportPath: _requestBean.appSupportPath!,
      urlPath: largeImageUrl,
      savePath: savePath,
      isSiteEx: _requestBean.isSiteEx ?? false);

  // 发送消息回父 isolate, 更新明细中的下载状态
}

/// 获取所有href
Future<List<GalleryImage>> _fetchAllImages({
  required String url,
  List<GalleryImage>? initImages,
  int? fileCount,
  required String appSupportPath,
  required bool isSiteEx,
}) async {
  if (initImages != null &&
      initImages.isNotEmpty &&
      initImages.length == fileCount) {
    return initImages;
  }

  final List<GalleryImage> _rultList = [];
  _rultList.addAll(initImages ?? []);
  int _curPage = 0;
  while (_rultList.length < (fileCount ?? 0)) {
    try {
      final List<GalleryImage> _moreGalleryImageList =
          await _isoFetchGalleryImage(
        url,
        page: _curPage + 1,
        // refresh: true,
        appSupportPath: appSupportPath,
        isSiteEx: isSiteEx,
      );

      logger.d(' _moreGalleryImageList len ${_moreGalleryImageList.length}');

      // 避免重复添加
      if (_rultList.isEmpty ||
          (_rultList.isNotEmpty &&
              _moreGalleryImageList.first.ser > _rultList.last.ser)) {
        logger.d('下载任务 添加图片对象 起始序号${_moreGalleryImageList.first.ser}  '
            '数量${_moreGalleryImageList.length}');
        _rultList.addAll(_moreGalleryImageList);
      }
      // 成功后才+1
      _curPage++;
    } catch (e, stack) {
      logger.e('$e\n$stack');
      rethrow;
    }
  }

  return _rultList;
}

const int _connectTimeout = 20000;
const int _receiveTimeout = 10000;

Future<Dio> _getIsolateDio(
    {bool isSiteEx = false, required String appSupportPath}) async {
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
  ).interceptor);

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

  final Dio _isolateDio = await _getIsolateDio(
    isSiteEx: isSiteEx,
    appSupportPath: appSupportPath,
  );

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

  final Dio _isolateDio = await _getIsolateDio(
    isSiteEx: isSiteEx,
    appSupportPath: appSupportPath,
  );

  Response<String> response;
  try {
    response = await _isolateDio.get<String>(url,
        options: Api.getCacheOptions(forceRefresh: refresh));
  } on DioError catch (e, stack) {
    logger.e('getHttp exception: $e\n$stack');
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

  final Dio _isolateDio = await _getIsolateDio(
    isSiteEx: isSiteEx,
    appSupportPath: appSupportPath,
  );

  try {
    response = await _isolateDio.download(
      urlPath,
      savePath,
      onReceiveProgress: (int count, int total) {
        // print('$count / $total');
      },
      options: Options(
        receiveTimeout: 0,
      ),
    );
    // print('downLoadFile response: $response');
  } on DioError catch (e) {
    logger.e('downLoadFile exception: $e');
    rethrow;
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
