part of 'download_manager.dart';

String? appSupportPath;
String? appDocPath;
String? extStorePath;

late final Dio exDio;
late final Dio ehDio;
late final Dio exDlDio;
late final Dio ehDlDio;

int downloadPoolSize = 0;
int dlCount = 0;
void _incrementTask() {
  dlCount++;
  _dlCountSink.add(dlCount);
}

void _decrementTask() {
  dlCount--;
  _dlCountSink.add(dlCount);
}

///定义一个Controller
final StreamController<int> _dlCountController = StreamController<int>();

///获取 StreamSink 做 add 入口
final StreamSink<int> _dlCountSink = _dlCountController.sink;

///获取 Stream 用于监听
Stream<int> _dlCountStream = _dlCountController.stream.asBroadcastStream();

/// isoload下载入口函数
/// 在这里进行实际的链接解析，图片文件下载
void _isolateDownload(SendPort sendPort) {
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

          /// init
          case _RequestType.init:
            // initLogger
            final List<String?>? _loginfo = _requestBean.loginfo;
            logger.d(_loginfo);
            if (_loginfo != null && _loginfo.length >= 2) {
              initLogger(directory: _loginfo[0], fileName: _loginfo[1]);
              logger.d('init _isolate Logger');
            }

            appSupportPath ??= _requestBean.appSupportPath;
            appDocPath ??= _requestBean.appDocPath;
            extStorePath ??= _requestBean.extStorePath;

            if (appSupportPath == null) {
              break;
            }

            // init Dio
            ehDio = _getIsolateDio(appSupportPath: appSupportPath!);
            ehDlDio =
                _getIsolateDio(appSupportPath: appSupportPath!, download: true);
            exDio =
                _getIsolateDio(appSupportPath: appSupportPath!, isSiteEx: true);
            exDlDio = _getIsolateDio(
                appSupportPath: appSupportPath!,
                isSiteEx: true,
                download: true);

            _dlCountSink.add(dlCount);

            break;

          /// 添加下载任务
          /// 接收父线程发过来的画廊信息
          /// 开始获取解析画廊web页面
          /// 解析画廊图片url
          case _RequestType.addTask:
            logger.d('_RequestType.addTask');
            final GalleryTask _initGalleryTask = _requestBean.galleryTask!;
            logger.d(
                'isolate add task ${_initGalleryTask.gid} ${_initGalleryTask.title}');

            // 获取所有图片页的href链接
            final List<GalleryImage> _images =
                await _updateDtl(_requestBean, sendPort);

            // 更新大图url 异步下载图片
            await _downloadImageAll(_requestBean, sendPort, _images);

            // 通知父线程 下载任务入队完成
            sendPort.send(
              _ResponseProtocol.enqueued(
                _ResponseBean(
                  msg:
                      'gid:${_initGalleryTask.gid} => images[${_images.length}]',
                  images: _images,
                  galleryTask: _initGalleryTask,
                ),
              ),
            );

            break;
          default:
            break;
        }
      }
    } catch (e, stack) {
      logger5.e('$e\n$stack');
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
  final List<GalleryImage> _images = await _fetchImageInfoList(
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

/// 图片下载任务
Future<void> _downloadImageAll(
  _RequestBean _requestBean,
  SendPort sendPort,
  List<GalleryImage> _images,
) async {
  // 初始化的明细任务列表
  final List<GalleryImageTask>? _imageTasks = _requestBean.imageTasks;

  // 循环下载处理
  logger.v('循环 获取大图url并下载');
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
        logger.d('${image.ser} start');
        await _getUrlAndDownloadOneImage(
          _requestBean,
          sendPort,
          image,
          maxSer: _images.map((e) => e.ser).reduce(math.max),
        );
        logger.d('${image.ser} end');
      } else if (_imageTask != null &&
          _imageTask.imageUrl != null &&
          _imageTask.imageUrl != null &&
          _imageTask.imageUrl!.isNotEmpty) {
        // 重新下载图片
        _reDownloadOneImage(
          _requestBean,
          sendPort,
          image,
          _imageTask,
        );
      }
    } catch (e, stack) {
      rethrow;
    }
  }
}

Future<void> _getUrlAndDownloadOneImage(
  _RequestBean _requestBean,
  SendPort sendPort,
  GalleryImage image, {
  int? maxSer,
}) async {
  const int _kserlen = 4;

  late final GalleryImage _info;

  try {
    // logger.d('new get imageUrl ${image.ser} ');
    _info = await _isoParaImageLageInfoFromHtml(
      image.href!,
      isSiteEx: _requestBean.isSiteEx ?? false,
      appSupportPath: _requestBean.appSupportPath!,
    );
  } on DioError catch (e) {
    rethrow;
  } catch (e) {
    rethrow;
  }

  final String _suffix =
      _info.imageUrl!.substring(_info.imageUrl!.lastIndexOf('.'));
  final String _fileName = maxSer != null && '$maxSer'.length > _kserlen
      ? '${sprintf('%0${'$maxSer'.length}d', [image.ser])}$_suffix'
      : '${sprintf('%0${_kserlen}d', [image.ser])}$_suffix';

  // logger.d('isolate gid[${_requestBean.galleryTask?.gid}] ${image.ser}\n'
  //     'url:[${_info.imageUrl}]\n'
  //     'fileName [$_fileName]');

  final ProgessBean _progessBeanEnqueued = ProgessBean(updateImages: [
    GalleryImageTask(
      gid: _requestBean.galleryTask!.gid,
      ser: image.ser,
      imageUrl: _info.imageUrl,
      sourceId: _info.sourceId,
      filePath: _fileName,
      token: '',
      status: TaskStatus.enqueued.value,
    ),
  ]);

  /// 发送消息回父 isolate, 更新明细中的largeImageUrl,sourceId,_fileName
  sendPort.send(
    _ResponseProtocol.progress(
      _ResponseBean(
        progess: _progessBeanEnqueued,
        galleryTask: _requestBean.galleryTask,
      ),
    ),
  );

  /// 开始下载
  try {
    // 测试
    /*await _downloadImage(
      _requestBean,
      sendPort,
      _info.imageUrl!,
      _fileName,
      _requestBean.appDocPath!,
      _requestBean.extStorePath!,
      _requestBean.downloadPath!,
    );*/
    await Future.delayed(Duration(seconds: 1));
  } on DioError catch (e) {
    if (e.response?.statusCode == 403) {
      logger.e('403');
    }
    if (e.type == DioErrorType.connectTimeout) {
      logger.e('连接超时 ${_info.ser} retry');
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

  logger.v('download imageUrl ${image.ser} complete');

  /// 单条任务下载完成
  final ProgessBean _progessBeanComplete = ProgessBean(updateImages: [
    GalleryImageTask(
      gid: _requestBean.galleryTask!.gid,
      ser: image.ser,
      token: '',
      status: TaskStatus.complete.value,
    ),
  ]);

  sendPort.send(
    _ResponseProtocol.progress(
      _ResponseBean(
        progess: _progessBeanComplete,
        galleryTask: _requestBean.galleryTask,
      ),
    ),
  );
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
      _getUrlAndDownloadOneImage(_requestBean, sendPort, image);
    }
  } catch (e) {
    rethrow;
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

  // logger.d('$')
  await _downLoadFile(
      appSupportPath: _requestBean.appSupportPath!,
      urlPath: largeImageUrl,
      savePath: savePath,
      isSiteEx: _requestBean.isSiteEx ?? false);

  // 发送消息回父 isolate, 更新明细中的下载状态
}

/// 获取所有href
Future<List<GalleryImage>> _fetchImageInfoList({
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
        refresh: true,
        appSupportPath: appSupportPath,
        isSiteEx: isSiteEx,
      );

      logger.d(
          'page ${_curPage + 1}  _moreGalleryImageList len ${_moreGalleryImageList.length}');

      if (_moreGalleryImageList.isEmpty) {
        logger.e('_moreGalleryImageList.isEmpty');
        continue;
      }

      // 避免重复添加
      if (_rultList.isEmpty ||
          (_rultList.isNotEmpty &&
              _moreGalleryImageList.first.ser > _rultList.last.ser)) {
        logger.d('下载任务 添加图片对象 起始序号${_moreGalleryImageList.first.ser}  '
            '数量${_moreGalleryImageList.length}');
        _rultList.addAll(_moreGalleryImageList);

        // 成功后才+1
        _curPage++;
      } else {
        break;
      }
    } catch (e, stack) {
      logger.e('$e\n$stack');
      rethrow;
    }
  }

  return _rultList;
}
