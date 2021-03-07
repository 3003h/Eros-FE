import 'dart:io';
import 'dart:isolate';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:fehviewer/common/controller/download_controller.dart';
import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/common/parser/gallery_detail_parser.dart';
import 'package:fehviewer/common/service/depth_service.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/models/index.dart' hide CacheConfig;
import 'package:fehviewer/network/gallery_request.dart';
import 'package:fehviewer/pages/gallery/controller/gallery_page_controller.dart';
import 'package:fehviewer/store/floor/dao/image_task_dao.dart';
import 'package:fehviewer/store/floor/entity/gallery_image_task.dart';
import 'package:fehviewer/store/floor/entity/gallery_task.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/toast.dart';
import 'package:fehviewer/utils/utility.dart';
import 'package:get/get.dart' hide Response;
import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;

part 'child.dart';

final DownloadManager downloadManager = DownloadManager();

enum _RequestType {
  addTask,
}

enum _ResponseType {
  initDtl,
  progress,
  complete,
  error,
}

class ProgessBean {
  ProgessBean({
    this.totCount,
    this.completCount,
    this.updateImages,
  });

  final int? totCount;
  final int? completCount;
  final List<GalleryImageTask>? updateImages;
}

class _RequestBean {
  _RequestBean({
    this.appSupportPath,
    this.appDocPath,
    this.isSiteEx,
    this.downloadPath,
    this.initPreviews,
    this.galleryTask,
    this.imageTasks,
  });

  final String? appSupportPath;
  final String? appDocPath;
  final bool? isSiteEx;
  final String? downloadPath;
  final List<GalleryPreview>? initPreviews;
  final GalleryTask? galleryTask;
  final List<GalleryImageTask>? imageTasks;
}

class _ResponseBean {
  _ResponseBean({this.previews, this.progess, this.galleryTask, this.msg});

  final List<GalleryPreview>? previews;
  final ProgessBean? progess;
  final GalleryTask? galleryTask;
  final String? msg;
}

class _RequestProtocol {
  const _RequestProtocol({this.requestType, this.data});

  const _RequestProtocol.addTask(this.data)
      : requestType = _RequestType.addTask;

  final _RequestType? requestType;

  final dynamic data;
}

class _ResponseProtocol {
  const _ResponseProtocol({this.responseType, this.data});

  const _ResponseProtocol.initDtl(this.data)
      : responseType = _ResponseType.initDtl;

  const _ResponseProtocol.progress(this.data)
      : responseType = _ResponseType.progress;

  const _ResponseProtocol.complete(this.data)
      : responseType = _ResponseType.complete;

  const _ResponseProtocol.error(this.data) : responseType = _ResponseType.error;

  final _ResponseType? responseType;

  final dynamic data;
}

class DownloadManager {
  final ReceivePort _receivePort = ReceivePort();
  SendPort? _sendPortToChild;
  Isolate? _isolate;

  /// 初始化
  Future<void> init() async {
    if (_receivePort.isBroadcast) {
      return;
    }
    logger.i('isolate DownloadManager init');

    // isolate spawn
    _isolate = await Isolate.spawn(_isolateDownload, _receivePort.sendPort,
        debugName: 'downloadChildIsolate');

    final ImageTaskDao _imageTaskDao =
        await DownloadController.getImageTaskDao();

    // 监听子 isolate 发过来的消息
    _receivePort.listen((dynamic message) async {
      try {
        if (message is SendPort) {
          // 初始化 获取子isolate的 sendPort
          _sendPortToChild = message;
        }

        if (message is _ResponseProtocol) {
          final _ResponseType _responseType = message.responseType!;
          final _ResponseBean _resBean = message.data;
          switch (_responseType) {
            case _ResponseType.initDtl: // 明细更新
              final List<GalleryPreview> _rultPreviews = _resBean.previews!;
              final GalleryTask _galleryTask = _resBean.galleryTask!;
              // 更新状态
              final GalleryPageController _pageController =
                  Get.find(tag: pageCtrlDepth);
              // logger.d(
              //     '${_pageController.previews.length} ${_rultPreviews.length}');

              if (_pageController.previews.length < _rultPreviews.length) {
                logger.d('set pre');
                _pageController.previews.clear();
                _pageController.previews.addAll(_rultPreviews);
              }

              // 明细入库
              // 插入所有任务明细
              final List<GalleryImageTask> _galleryImageTasks = _rultPreviews
                  .map((GalleryPreview e) => GalleryImageTask(
                        gid: _galleryTask.gid,
                        token: _galleryTask.token,
                        href: e.href,
                        ser: e.ser,
                      ))
                  .toList();
              _imageTaskDao.insertImageTasks(_galleryImageTasks);

              logger.v('insert end');

              // 测试插入结果
              final List<GalleryImageTask> _list =
                  await _imageTaskDao.findAllGalleryTaskByGid(_galleryTask.gid);
              logger.d('${_list.map((e) => e.toString()).join('\n')} ');

              break;
            case _ResponseType.progress: // 进度更新
              // 更新 大图 相关信息
              final ProgessBean _progess = _resBean.progess!;
              final GalleryTask _galleryTask = _resBean.galleryTask!;

              final GalleryPageController _pageController =
                  Get.find(tag: pageCtrlDepth);

              logger.v('parent progess '
                  '${_progess.updateImages!.map((e) => e.toString()).join('\n')}');
              for (final _uptImageTask in _progess.updateImages!) {
                final _oriImageTask = await _imageTaskDao.findGalleryTaskByKey(
                    _uptImageTask.gid, _uptImageTask.ser);

                final GalleryImageTask _uptTask = _oriImageTask!.copyWith(
                  imageUrl: _uptImageTask.imageUrl!,
                  filePath: _uptImageTask.filePath!,
                  sourceId: _uptImageTask.sourceId!,
                );
                if (_uptTask != null) {
                  await _imageTaskDao.updateImageTask(_uptTask);

                  // _pageController.previews
                  //     .firstWhere((GalleryPreview element) =>
                  //         element.ser == _uptImageTask.ser)
                  //     .largeImageUrl = _uptImageTask.imageUrl;
                  final _preIndex = _pageController.previews.indexWhere(
                      (GalleryPreview element) =>
                          element.ser == _uptImageTask.ser);
                  _pageController.previews[_preIndex] = _pageController
                      .previews[_preIndex]
                      .copyWith(largeImageUrl: _uptImageTask.imageUrl);
                }
              }

              break;
            case _ResponseType.complete: // 下载完成
              logger.i('${_resBean.msg} ');

              showToast('${_resBean.msg} ');
              break;
            case _ResponseType.error:
              break;
            default:
              break;
          }
        }
      } catch (e, stack) {
        logger.e('$e\n$stack');
        rethrow;
      }
    });
  }

  /// 关闭
  void close() {
    _isolate?.kill(priority: Isolate.immediate);
  }

  void addTask(
      {required GalleryTask galleryTask,
      List<GalleryImageTask>? imageTasks,
      String? downloadPath}) {
    logger.d('addTask ${galleryTask.gid} ${galleryTask.title}');
    final GalleryPageController _pageController = Get.find(tag: pageCtrlDepth);
    final _RequestBean _requestBean = _RequestBean(
      galleryTask: galleryTask,
      imageTasks: imageTasks,
      isSiteEx: Get.find<EhConfigService>().isSiteEx.value ?? false,
      appSupportPath: Global.appSupportPath,
      appDocPath: Global.appDocPath,
      initPreviews: _pageController.firstPagePreview,
      downloadPath: downloadPath,
    );

    _sendPortToChild?.send(_RequestProtocol.addTask(_requestBean));
  }
}
