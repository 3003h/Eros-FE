import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:math' as math;

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:fehviewer/common/controller/download_controller.dart';
import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/common/parser/gallery_detail_parser.dart';
import 'package:fehviewer/common/service/controller_tag_service.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/models/index.dart' hide CacheConfig;
import 'package:fehviewer/network/api.dart';
import 'package:fehviewer/pages/gallery/controller/gallery_page_controller.dart';
import 'package:fehviewer/store/floor/dao/gallery_task_dao.dart';
import 'package:fehviewer/store/floor/dao/image_task_dao.dart';
import 'package:fehviewer/store/floor/entity/gallery_image_task.dart';
import 'package:fehviewer/store/floor/entity/gallery_task.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/toast.dart';
import 'package:get/get.dart' hide Response;
import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;
import 'package:path/path.dart' as path;
import 'package:sprintf/sprintf.dart';

part 'child.dart';
part 'child_dio.dart';
part 'protocol.dart';

final DownloadManagerIsolate downloadManagerIsolate = DownloadManagerIsolate();

class DownloadManagerIsolate {
  factory DownloadManagerIsolate() => _instance;
  DownloadManagerIsolate._();
  static final DownloadManagerIsolate _instance = DownloadManagerIsolate._();

  final ReceivePort _receivePort = ReceivePort();
  SendPort? _sendPortToChild;
  Isolate? _isolate;

  /// 初始化
  Future<void> init() async {
    if (_receivePort.isBroadcast) {
      return;
    }

    // isolate spawn
    _isolate = await Isolate.spawn(_isolateDownload, _receivePort.sendPort,
        debugName: 'downloadChildIsolate');

    final ImageTaskDao _imageTaskDao =
        Get.find<DownloadController>().imageTaskDao;

    final GalleryTaskDao _galleryTaskDao =
        Get.find<DownloadController>().galleryTaskDao;

    // 监听子 isolate 发过来的消息
    _receivePort.listen((dynamic message) => _listenChild(
          message,
          _imageTaskDao,
          _galleryTaskDao,
        ));

    // 下载
    download();
  }

  void download() {
    //任务的周期性执行
    Timer.periodic(Duration(milliseconds: 1000), (timer) {
      // logger.d('download');
    });
  }

  /// 关闭
  void close() {
    _isolate?.kill(priority: Isolate.immediate);
  }

  /// 初始化isolate
  void _initChildIsolate() {
    logger.d(
        'send init isolate \nlogDirectory[$logDirectory] \nlogFileName[$logFileName]');
    final _RequestBean _requestBean = _RequestBean(
      appSupportPath: Global.appSupportPath,
      appDocPath: Global.appDocPath,
      extStorePath: Global.extStorePath,
      loginfo: [logDirectory, logFileName],
    );

    _sendPortToChild?.send(_RequestProtocol.init(_requestBean));
  }

  /// 初始化isolate日志
  // void _initLogger() {
  //   logger.d('send initLogger isolate [$logDirectory] [$logFileName]');
  //   final _RequestBean _requestBean = _RequestBean(
  //     appSupportPath: Global.appSupportPath,
  //     appDocPath: Global.appDocPath,
  //     extStorePath: Global.extStorePath,
  //     loginfo: [logDirectory, logFileName],
  //   );
  //
  //   _sendPortToChild?.send(_RequestProtocol.initLogger(_requestBean));
  // }

  void pauseTask({
    required GalleryTask galleryTask,
  }) {
    logger.d('send pauseTask isolate ${galleryTask.gid}');
    final _RequestBean _requestBean = _RequestBean(
      galleryTask: galleryTask,
    );

    _sendPortToChild?.send(_RequestProtocol.pauseTask(_requestBean));
  }

  void resumeTask({
    required GalleryTask galleryTask,
  }) {
    logger.d('send resumeTask isolate ${galleryTask.gid}');
    final _RequestBean _requestBean = _RequestBean(
      galleryTask: galleryTask,
    );

    _sendPortToChild?.send(_RequestProtocol.resumeTask(_requestBean));
  }

  void cancelTask({
    required GalleryTask galleryTask,
  }) {
    logger.d('send cancelTask isolate ${galleryTask.gid}');
    final _RequestBean _requestBean = _RequestBean(
      galleryTask: galleryTask,
    );

    _sendPortToChild?.send(_RequestProtocol.cancelTask(_requestBean));
  }

  /// 添加任务
  void addTask(
      {required GalleryTask galleryTask,
      List<GalleryImageTask>? imageTasks,
      String? downloadPath}) {
    logger.d('addTask ${galleryTask.gid} ${galleryTask.title}');
    final GalleryPageController _pageController = Get.find(tag: pageCtrlTag);
    final _RequestBean _requestBean = _RequestBean(
      galleryTask: galleryTask,
      imageTasks: imageTasks,
      isSiteEx: Get.find<EhConfigService>().isSiteEx.value,
      appSupportPath: Global.appSupportPath,
      appDocPath: Global.appDocPath,
      extStorePath: Global.extStorePath,
      initImages: _pageController.gState.firstPageImage,
      downloadPath: downloadPath,
    );

    _sendPortToChild?.send(_RequestProtocol.addTask(_requestBean));
  }

  /// 监听子isolate消息 并处理
  Future<void> _listenChild(
    dynamic message,
    ImageTaskDao _imageTaskDao,
    GalleryTaskDao _galleryTaskDao,
  ) async {
    DownloadController _downloadController = Get.find();
    try {
      if (message is SendPort) {
        // 初始化 获取子isolate的 sendPort
        _sendPortToChild = message;
        _initChildIsolate();
      }

      if (message is _ResponseProtocol) {
        final _ResponseType _responseType = message.responseType!;
        final _ResponseBean _resBean = message.data as _ResponseBean;
        switch (_responseType) {

          /// 任务明细初始化
          case _ResponseType.initDtl:
            final List<GalleryImage>? _rultImages = _resBean.images;
            final GalleryTask? _galleryTask = _resBean.galleryTask;
            if (_rultImages == null || _galleryTask == null) {
              break;
            }

            logger.d('任务明细初始化 gid:${_galleryTask.gid}');

            if (Get.isRegistered<GalleryPageController>(tag: pageCtrlTag)) {
              // 更新状态
              final GalleryPageController _pageController =
                  Get.find(tag: pageCtrlTag);

              if (_pageController.gState.images.length < _rultImages.length) {
                logger.v('set pre');
                _pageController.gState.images.clear();
                _pageController.gState.images.addAll(_rultImages);
              }
            }

            // 明细入库
            // 插入所有任务明细
            final List<GalleryImageTask> _galleryImageTasks = _rultImages
                .map((GalleryImage e) => GalleryImageTask(
                      gid: _galleryTask.gid,
                      token: _galleryTask.token,
                      href: e.href,
                      ser: e.ser,
                    ))
                .toList();
            _imageTaskDao.insertImageTasks(_galleryImageTasks);

            logger.v('insert end');

            // 测试 插入结果
            final List<GalleryImageTask> _list =
                await _imageTaskDao.findAllTaskByGid(_galleryTask.gid);
            logger.d('${_list.map((e) => e.toString()).join('\n')} ');

            logger.d('任务明细初始化 gid:${_galleryTask.gid} 完成');

            break;

          /// 进度更新
          case _ResponseType.progress:
            // 更新 大图 相关信息
            final ProgessBean? _progess = _resBean.progess;
            final GalleryTask? _galleryTask = _resBean.galleryTask;

            if (_progess == null || _progess.updateImages == null) {
              break;
            }

            // logger.v('parent progess '
            //     '${_progess.updateImages!.map((e) => e.toString()).join('\n')}');

            for (final _uptImageTask in _progess.updateImages!) {
              _imageTaskDao
                  .findTaskByKey(_uptImageTask.gid, _uptImageTask.ser)
                  .then((GalleryImageTask? _oriImageTask) =>
                      _oriImageTask?.copyWith(
                        imageUrl: _uptImageTask.imageUrl,
                        filePath: _uptImageTask.filePath,
                        sourceId: _uptImageTask.sourceId,
                        status: _uptImageTask.status,
                      ))
                  .then((GalleryImageTask? _uptImageTask) {
                if (_uptImageTask != null &&
                    _uptImageTask.status == TaskStatus.complete.value) {
                  _imageTaskDao.updateImageTask(_uptImageTask);
                }
              });
            }

/*
            for (final _uptImageTask in _progess.updateImages!) {
              final GalleryImageTask? _oriImageTask = await _imageTaskDao
                  .findGalleryTaskByKey(_uptImageTask.gid, _uptImageTask.ser);

              if (_oriImageTask == null) {
                continue;
              }

              final GalleryImageTask _uptTask = _oriImageTask.copyWith(
                imageUrl: _uptImageTask.imageUrl,
                filePath: _uptImageTask.filePath,
                sourceId: _uptImageTask.sourceId,
                status: _uptImageTask.status,
              );
              await _imageTaskDao.updateImageTask(_uptTask);

              // 查询完成的数量 主task更新
              // final _compleImageTasks =
              //     await _imageTaskDao.countImageTaskByGidAndStatus(
              //         _oriImageTask.gid, TaskStatus.complete.value);
              // GalleryTask _task = _downloadController.galleryTaskCountUpdate(
              //     _resBean.galleryTask!.gid, _compleImageTasks.length);
              // await _galleryTaskDao.updateTask(_task);
              //
              // if (_compleImageTasks.length == _resBean.galleryTask?.fileCount) {
              //   GalleryTask _task = _downloadController
              //       .galleryTaskComplete(_resBean.galleryTask!.gid);
              //   await _galleryTaskDao.updateTask(_task);
              // }

              // 可能会有画廊已经退出的情况 _pageController会获取不到
              if (Get.isRegistered<GalleryPageController>(tag: pageCtrlDepth)) {
                final GalleryPageController _pageController =
                    Get.find(tag: pageCtrlDepth);

                final int _preIndex = _pageController.images.indexWhere(
                    (GalleryImage element) => element.ser == _uptImageTask.ser);
                _pageController.images[_preIndex] = _pageController
                    .images[_preIndex]
                    .copyWith(imageUrl: _uptImageTask.imageUrl);
              }
            }
*/

            break;

          /// 明细入队完成
          case _ResponseType.enqueued:
            logger.d('明细入队完成');
            GalleryTask? _task =
                await _downloadController.galleryTaskUpdateStatus(
                    _resBean.galleryTask!.gid, TaskStatus.running);
            if (_task != null) {
              await _galleryTaskDao.updateTask(_task);
            }
            break;

          /// 下载完成
          case _ResponseType.complete:
            // logger.i('${_resBean.msg} ');
            if (_resBean.galleryTask != null) {
              final _compleImageTasks =
                  await _imageTaskDao.finaAllTaskByGidAndStatus(
                      _resBean.galleryTask!.gid, TaskStatus.complete.value);
              if (_compleImageTasks.length == _resBean.galleryTask!.fileCount) {
                final _task = await _downloadController
                    .galleryTaskComplete(_resBean.galleryTask!.gid);
                if (_task != null) {
                  await _galleryTaskDao.updateTask(_task);
                }
              } else {
                logger.d('有未完成的下载');
              }
              // GalleryTask _task = _downloadController
              //     .galleryTaskComplete(_resBean.galleryTask!.gid);
              // await _galleryTaskDao.updateTask(_task);
            }

            showToast('${_resBean.msg} ');
            break;

          /// ERROR
          case _ResponseType.error:
            logger.e('isolate child error:\n${_resBean.msg}\n${_resBean.desc}');
            showToast('error:\n${_resBean.msg} ');
            break;
          default:
            break;
        }
      }
    } catch (e, stack) {
      logger.e('$e\n$stack');
      rethrow;
    }
  }
}
