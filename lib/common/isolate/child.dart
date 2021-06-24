part of 'download.dart';

/// isoload下载入口函数
/// 在这里进行实际的链接解析，图片文件下载
void _isolateDownload(SendPort sendPort) {
  // logger.d('init _isolateDownload');
  // 创建一个消息接收器
  final ReceivePort _receivePort = ReceivePort();
  sendPort.send(_receivePort.sendPort);

  final bool _inDebugMode = EHUtils().isInDebugMode;

  // 监听父isolate消息
  _receivePort.listen((dynamic message) async {
    try {
      if (message is _RequestProtocol) {
        final _RequestType _requestType = message.requestType!;
        final _RequestBean _requestBean = message.data;

        switch (_requestType) {

          /// 添加下载任务
          /// 接收父线程发过来的画廊信息
          /// 开始获取解析画廊web页面
          /// 解析画廊图片url
          case _RequestType.addTask:
            final GalleryTask _initGalleryTask = _requestBean.galleryTask!;
            logger.d(
                'isolate add task ${_initGalleryTask.gid} ${_initGalleryTask.title}');

            // 获取所有图片页的href链接 通知父线程
            logger.v('获取所有图片页的href链接 通知父线程 start');
            final List<GalleryPreview> _previews =
                await _updateDtl(_requestBean, sendPort);

            // 更新大图url 下载图片 通知父线程
            logger.v('更新大图url 下载图片 通知父线程 start');
            await _fetchAllImageInfo(_requestBean, sendPort, _previews);

            // 测试 发送消息回父isolate
            sendPort.send(
              _ResponseProtocol.complete(
                _ResponseBean(
                  msg:
                      'gid:${_initGalleryTask.gid} => previews[${_previews.length}]',
                  previews: _previews,
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
      // rethrow;
    }
  });
}

Future<List<GalleryPreview>> _updateDtl(
    _RequestBean _requestBean, SendPort sendPort) async {
  // 获取所有图片页的href
  final List<GalleryPreview> _previews = await _fetchAllPreviews(
    url: _requestBean.galleryTask!.url!,
    fileCount: _requestBean.galleryTask!.fileCount,
    appSupportPath: _requestBean.appSupportPath!,
    isSiteEx: _requestBean.isSiteEx!,
    initPreviews: _requestBean.initPreviews,
  );

  // logger.d('${_previews.length}');

  // 发送获取结果到父iso 更新明细库
  sendPort.send(
    _ResponseProtocol.initDtl(
      _ResponseBean(galleryTask: _requestBean.galleryTask, previews: _previews),
    ),
  );

  return _previews;
}

Future<void> _fetchAllImageInfo(
  _RequestBean _requestBean,
  SendPort sendPort,
  List<GalleryPreview> _previews,
) async {
  // 初始化的明细任务 可为空
  final List<GalleryImageTask>? _imageTasks = _requestBean.imageTasks;

  // 依次获取大图url 更新明细
  logger.v('循环处理 依次获取大图url 更新明细');
  for (final GalleryPreview preview in _previews) {
    //
    bool _imageTaskUrlIsNotExist = true;
    late final GalleryImageTask _imageTask;
    if (_imageTasks!.isNotEmpty) {
      _imageTask = _imageTasks
          .firstWhere((GalleryImageTask element) => element.ser == preview.ser);
      _imageTaskUrlIsNotExist =
          _imageTask.imageUrl == null || _imageTask.imageUrl!.isEmpty;
    }

    try {
      if ((preview.largeImageUrl == null || preview.largeImageUrl!.isEmpty) &&
          _imageTaskUrlIsNotExist) {
        logger.d('new get imageUrl ${preview.ser} ');
        final GalleryPreview _info = await _isoParaImageLageInfoFromHtml(
          preview.href!,
          isSiteEx: _requestBean.isSiteEx ?? false,
          appSupportPath: _requestBean.appSupportPath!,
        );
        logger.d('isolate ${preview.ser} => ${_info.largeImageUrl}');
        final String _fileName = _info.largeImageUrl!
            .substring(_info.largeImageUrl!.lastIndexOf('/') + 1);
        logger.d('isolate ${preview.ser} => _fileName $_fileName');

        final ProgessBean _progessBean = ProgessBean(updateImages: [
          GalleryImageTask(
            gid: _requestBean.galleryTask!.gid,
            ser: preview.ser,
            imageUrl: _info.largeImageUrl,
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

        _downloadImage(
          _requestBean,
          sendPort,
          _info.largeImageUrl!,
          _fileName,
          _requestBean.appDocPath!,
          _requestBean.extStorePath!,
          _requestBean.downloadPath!,
        );
      } else if (_imageTask.imageUrl != null &&
          _imageTask.imageUrl!.isNotEmpty) {
        logger.v('re _downloadImage');

        try {
          _downloadImage(
            _requestBean,
            sendPort,
            _imageTask.imageUrl!,
            _imageTask.filePath ?? '',
            _requestBean.appDocPath!,
            _requestBean.extStorePath!,
            _requestBean.downloadPath!,
          );
        } catch (e) {
          logger.e('$e');
        }
      }
    } catch (e, stack) {
      logger.e('$e\n$stack');
      // rethrow;
    }
  }
}

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
  logger.v('savePath $savePath');
  _downLoadFile(
      appSupportPath: _requestBean.appSupportPath!,
      urlPath: largeImageUrl,
      savePath: savePath,
      isSiteEx: _requestBean.isSiteEx ?? false);

  // 发送消息回父 isolate, 更新明细中的下载状态
}

/// 获取所有href
Future<List<GalleryPreview>> _fetchAllPreviews({
  required String url,
  List<GalleryPreview>? initPreviews,
  int? fileCount,
  required String appSupportPath,
  required bool isSiteEx,
}) async {
  if (initPreviews != null &&
      initPreviews.isNotEmpty &&
      initPreviews.length == fileCount) {
    return initPreviews;
  }

  final List<GalleryPreview> _rultList = [];
  _rultList.addAll(initPreviews ?? []);
  int _curPage = 0;
  while (_rultList.length < (fileCount ?? 0)) {
    try {
      final List<GalleryPreview> _moreGalleryPreviewList =
          await _isoFetchGalleryPreview(
        url,
        page: _curPage + 1,
        // refresh: true,
        appSupportPath: appSupportPath,
        isSiteEx: isSiteEx,
      );

      logger
          .d(' _moreGalleryPreviewList len ${_moreGalleryPreviewList.length}');

      // 避免重复添加
      if (_rultList.isEmpty ||
          (_rultList.isNotEmpty &&
              _moreGalleryPreviewList.first.ser > _rultList.last.ser)) {
        logger.d('下载任务 添加图片对象 起始序号${_moreGalleryPreviewList.first.ser}  '
            '数量${_moreGalleryPreviewList.length}');
        _rultList.addAll(_moreGalleryPreviewList);
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
Future<List<GalleryPreview>> _isoFetchGalleryPreview(
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

  return GalleryDetailParser.parseGalleryPreviewFromHtml(response.data!);
}

/// 获取画廊图片的信息
/// [href] 爬取的页面地址 用来解析gid 和 imgkey
/// [page] 索引 从 1 开始
Future<GalleryPreview> _isoParaImageLageInfoFromHtml(
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

  final GalleryPreview _rePreview = GalleryPreview(
      largeImageUrl: imageUrl,
      sourceId: _sourceId,
      largeImageWidth: width,
      largeImageHeight: height,
      ser: -1);

  return _rePreview;
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
    print('downLoadFile response: $response');
  } on DioError catch (e) {
    print('downLoadFile exception: $e');
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
