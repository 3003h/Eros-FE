import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:executor/executor.dart';
import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/common/isolate_download/download_manager.dart';
import 'package:fehviewer/common/service/depth_service.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/models/base/eh_models.dart';
import 'package:fehviewer/network/gallery_request.dart';
import 'package:fehviewer/pages/gallery/controller/gallery_page_controller.dart';
import 'package:fehviewer/store/floor/dao/gallery_task_dao.dart';
import 'package:fehviewer/store/floor/dao/image_task_dao.dart';
import 'package:fehviewer/store/floor/entity/gallery_image_task.dart';
import 'package:fehviewer/store/floor/entity/gallery_task.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/toast.dart';
import 'package:fehviewer/utils/utility.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sprintf/sprintf.dart' as sp;

import 'download_state.dart';

Future<String> get defDownloadPath async => GetPlatform.isAndroid
    ? path.join((await getExternalStorageDirectory())!.path, 'Download')
    : path.join(Global.appDocPath, 'Download');

const int _kDefNameLen = 4;

class DownloadController extends GetxController {
  final DownloadState dState = DownloadState();

  static Future<GalleryTaskDao> getGalleryTaskDao() async {
    return (await Global.getDatabase()).galleryTaskDao;
  }

  static Future<ImageTaskDao> getImageTaskDao() async {
    return (await Global.getDatabase()).imageTaskDao;
  }

  final EhConfigService ehConfigService = Get.find();

  @override
  void onInit() {
    super.onInit();
    logger.d(
        'DownloadController onInit multiDownload:${ehConfigService.multiDownload}');
    dState.executor = Executor(concurrency: ehConfigService.multiDownload);
    allowMediaScan(ehConfigService.allowMediaScan);
    _initGalleryTasks();
  }

  @override
  void onClose() {
    downloadManagerIsolate.close();
    cancelDownloadStateChkTimer();
    super.onClose();
  }

  void resetConcurrency() {
    // 取消所有任务
    for (final ct in dState.cancelTokenMap.values) {
      if (!ct.isCancelled) {
        ct.cancel();
      }
    }
    cancelDownloadStateChkTimer();
    logger.d('reset multiDownload ${ehConfigService.multiDownload}');
    dState.executor = Executor(concurrency: ehConfigService.multiDownload);

    // 重新加入
    _initGalleryTasks();
  }

  Future<void> _initGalleryTasks() async {
    logger5.d(' _initGalleryTasks');
    GalleryTaskDao _galleryTaskDao;
    ImageTaskDao _imageTaskDao;
    try {
      _galleryTaskDao = await getGalleryTaskDao();
      _imageTaskDao = await getImageTaskDao();
    } catch (e, stack) {
      logger.e('$e\n$stack ');
      rethrow;
    }

    final _tasks = await _galleryTaskDao.findAllGalleryTasks();
    dState.galleryTaskList(_tasks);
    for (final task in _tasks.reversed) {
      if (task.status == TaskStatus.running.value) {
        _startImageTask(galleryTask: task);
        initDownloadStateChkTimer(task.gid);
      }
    }
  }

  /// 获取下载路径
  Future<String> _getGalleryDownloadPath(String custpath) async {
    late final String _dirPath;
    if (GetPlatform.isAndroid && ehConfigService.downloadLocatino.isNotEmpty) {
      _dirPath = path.join(ehConfigService.downloadLocatino, custpath);
    } else if (GetPlatform.isAndroid) {
      _dirPath = path.join(
          (await getExternalStorageDirectory())!.path, 'Download', custpath);
    } else {
      _dirPath = path.join(Global.appDocPath, 'Download', custpath);
    }

    final Directory savedDir = Directory(_dirPath);
    // 判断下载路径是否存在
    final bool hasExisted = savedDir.existsSync();
    // 不存在就新建路径
    if (!hasExisted) {
      savedDir.createSync(recursive: true);
    }

    return _dirPath;
  }

  Future<void> downloadGallery({
    required String url,
    required int fileCount,
    required String title,
    int? gid,
    String? token,
  }) async {
    GalleryTaskDao _galleryTaskDao;
    ImageTaskDao _imageTaskDao;
    try {
      _galleryTaskDao = await getGalleryTaskDao();
      _imageTaskDao = await getImageTaskDao();
    } catch (e, stack) {
      logger.e('$e\n$stack ');
      rethrow;
    }

    int _gid = 0;
    String _token = '';
    if (gid == null || token == null) {
      final RegExpMatch _match =
          RegExp(r'/g/(\d+)/([0-9a-f]{10})/?').firstMatch(url)!;
      _gid = int.parse(_match.group(1)!);
      _token = _match.group(2)!;
    }

    // 先查询任务是否已存在
    bool isNewTask = true;
    final GalleryTask? _oriTask =
        await _galleryTaskDao.findGalleryTaskByGid(gid ?? -1);
    if (_oriTask != null) {
      logger.i('$gid 任务已存在 ');
      logger.d('${_oriTask.toString()} ');
      isNewTask = false;
    }

    final String _downloadPath =
        path.join('$gid - ${path.split(title).join('_')}');
    final String _dirPath = await _getGalleryDownloadPath(_downloadPath);

    // 登记主任务表
    final GalleryTask galleryTask = isNewTask
        ? GalleryTask(
            gid: gid ?? _gid,
            token: token ?? _token,
            url: url,
            title: title,
            fileCount: fileCount,
            dirPath: _dirPath,
            status: TaskStatus.enqueued.value,
          )
        : _oriTask!;

    if (isNewTask) {
      logger.d('add NewTask ${galleryTask.toString()}');
      _galleryTaskDao.insertTask(galleryTask);
      dState.galleryTaskList.insert(0, galleryTask);
      showToast('${galleryTask.gid} Download task start');
    }

    final GalleryPageController _pageController = Get.find(tag: pageCtrlDepth);
    final _fCount = _pageController.firstPageImage.length;

    _startImageTask(
      galleryTask: galleryTask,
      downloadPath: _dirPath,
      fCount: _fCount,
    );
    initDownloadStateChkTimer(galleryTask.gid);
  }

  void initDownloadStateChkTimer(int gid) {
    const int periodSeconds = 5;
    dState.chkTimers[gid] = Timer.periodic(
      const Duration(seconds: periodSeconds),
      (Timer timer) {
        // autoRetryTask(gid);
        totalDownloadSpeed(gid, periodSeconds);
      },
    );
  }

  void autoRetryTask(int gid) {
    // 回调
    logger.d('$gid afterTimer = ' + DateTime.now().toString());
    logger.d('${dState.curComplet[gid]}  ${dState.preComplet[gid]}');
    if (dState.curComplet[gid] == dState.preComplet[gid]) {
      logger.d('reset $gid');
      Future<void>(() => galleryTaskPaused(gid, silent: true))
          .then((_) => Future.delayed(const Duration(microseconds: 2000)))
          .then((_) => galleryTaskResume(gid));
    } else {
      dState.preComplet[gid] = dState.curComplet[gid] ?? 0;
    }
  }

  void totalDownloadSpeed(int gid, int periodSeconds) {
    final int totCurCount = dState.downloadCounts.entries
        .where((element) => element.key.startsWith('${gid}_'))
        .map((e) => e.value)
        .sum;

    final lastCount = dState.lastCounts[gid] ?? 0;
    final speed = (max(totCurCount - lastCount, 0) / periodSeconds).round();
    dState.downloadSpeeds[gid] = renderSize(speed);
    // logger.d('gid:$gid totCount:$totCurCount speed:${renderSize(speed)}');

    dState.lastCounts[gid] = totCurCount;

    if (speed == 0) {
      if (dState.noSpeed[gid] != null) {
        dState.noSpeed[gid] = dState.noSpeed[gid]! + 1;
      } else {
        dState.noSpeed[gid] = 1;
      }

      if ((dState.noSpeed[gid] ?? 0) > dState.retryThreshold) {
        Future<void>(() => galleryTaskPaused(gid, silent: true))
            .then((_) => Future.delayed(const Duration(microseconds: 2000)))
            .then((_) => galleryTaskResume(gid));
      }
    }
  }

  void cancelDownloadStateChkTimer({int? gid}) {
    if (gid != null) {
      dState.chkTimers[gid]?.cancel();
    } else {
      for (final Timer? timer in dState.chkTimers.values) {
        timer?.cancel();
      }
    }
  }

  GalleryTask galleryTaskCompleIncreasing(int gid) {
    final index =
        dState.galleryTaskList.indexWhere((element) => element.gid == gid);
    final GalleryTask _oriTask = dState.galleryTaskList[index];
    final int _oricc = _oriTask.completCount ?? 0;

    dState.galleryTaskList[index] = _oriTask.copyWith(
        completCount: _oricc + 1,
        status: _oricc + 1 == _oriTask.fileCount
            ? TaskStatus.complete.value
            : null);

    return dState.galleryTaskList[index];
  }

  /// 更新任务进度
  GalleryTask galleryTaskUpdate(int gid,
      {int? countComplet, String? coverImg}) {
    logger.v('galleryTaskCountUpdate gid:$gid count:$countComplet');
    dState.curComplet[gid] = countComplet ?? 0;

    final index =
        dState.galleryTaskList.indexWhere((element) => element.gid == gid);
    dState.galleryTaskList[index] = dState.galleryTaskList[index].copyWith(
      completCount: countComplet,
      coverImage: coverImg,
    );

    return dState.galleryTaskList[index];
  }

  /// 更新任务为已完成
  Future<GalleryTask> galleryTaskComplete(int gid) {
    cancelDownloadStateChkTimer(gid: gid);
    dState.downloadSpeeds.remove(gid);
    return galleryTaskUpdateStatus(gid, TaskStatus.complete);
  }

  /// 暂停任务
  Future<GalleryTask?> galleryTaskPaused(int gid, {bool silent = false}) async {
    cancelDownloadStateChkTimer(gid: gid);
    dState.downloadSpeeds.remove(gid);
    if (!((dState.cancelTokenMap['$gid']?.isCancelled) ?? true)) {
      dState.cancelTokenMap['$gid']?.cancel();
    }
    if (silent) {
      return null;
    }

    return galleryTaskUpdateStatus(gid, TaskStatus.paused);
  }

  /// 恢复任务
  Future<void> galleryTaskResume(int gid) async {
    logger.d('galleryTaskResume');
    final _galleryTaskDao = await getGalleryTaskDao();
    final GalleryTask? galleryTask =
        await _galleryTaskDao.findGalleryTaskByGid(gid);
    if (galleryTask != null) {
      await _startImageTask(galleryTask: galleryTask);
      initDownloadStateChkTimer(galleryTask.gid);
    }
  }

  /// 更新任务状态
  Future<GalleryTask> galleryTaskUpdateStatus(
      int gid, TaskStatus status) async {
    final index =
        dState.galleryTaskList.indexWhere((element) => element.gid == gid);
    dState.galleryTaskList[index] =
        dState.galleryTaskList[index].copyWith(status: status.value);
    logger.i('set $gid status $status');

    final _task = dState.galleryTaskList[index];
    (await getGalleryTaskDao()).updateTask(_task);

    return dState.galleryTaskList[index];
  }

  /// 移除任务
  Future<void> removeDownloadGalleryTask({
    required int index,
  }) async {
    GalleryTaskDao _galleryTaskDao;
    ImageTaskDao _imageTaskDao;

    // 删除文件
    final GalleryTask _task = dState.galleryTaskList[index];
    String? dirpath = _task.dirPath;
    logger.d('dirPath: $dirpath');
    if (dirpath != null) {
      Directory(dirpath).delete(recursive: true);
    }

    if (!((dState.cancelTokenMap['${_task.gid}']?.isCancelled) ?? true)) {
      dState.cancelTokenMap['${_task.gid}']?.cancel();
    }

    try {
      _galleryTaskDao = await getGalleryTaskDao();
      _imageTaskDao = await getImageTaskDao();
    } catch (e, stack) {
      logger.e('$e\n$stack ');
      rethrow;
    }

    // 删除数据库记录
    _imageTaskDao.deleteImageTaskByGid(_task.gid);
    _galleryTaskDao.deleteTaskByGid(_task.gid);

    dState.galleryTaskList.removeAt(index);
  }

  void _initDownloadMapByGid(String gid, {List<GalleryImage>? images}) {
    dState.downloadMap[gid] = images ?? [];
  }

  GalleryImage? _getImageObj(String gid, int ser) {
    return dState.downloadMap[gid]
        ?.firstWhereOrNull((element) => element.ser == ser);
  }

  void _addAllImages(String gid, List<GalleryImage> galleryImages) {
    for (final GalleryImage _image in galleryImages) {
      final int? index = dState.downloadMap[gid]
          ?.indexWhere((GalleryImage e) => e.ser == _image.ser);
      if (index != null && index != -1) {
        dState.downloadMap[gid]?[index] = _image;
      } else {
        dState.downloadMap[gid]?.add(_image);
      }
    }
  }

  Future _updateImageTasksByGid(String gid,
      {List<GalleryImage>? images}) async {
    final ImageTaskDao _imageTaskDao = await getImageTaskDao();

    final GalleryTaskDao _galleryTaskDao = await getGalleryTaskDao();

    // logger.d(
    //     '_updateImageTasksByGid $gid\n  ${(images ?? downloadMap[gid])?.map((e) => e.toJson()).join('\n')} ');

    // 插入所有任务明细
    final List<GalleryImageTask>? _galleryImageTasks =
        (images ?? dState.downloadMap[gid])
            ?.map((GalleryImage e) => GalleryImageTask(
                  gid: int.parse(gid),
                  token: '',
                  href: e.href,
                  ser: e.ser,
                  imageUrl: e.imageUrl,
                  sourceId: e.sourceId,
                ))
            .toList();

    // loggerNoStack.d(
    //     '_updateImageTasksByGid $gid\n${_galleryImageTasks?.map((e) => e.toString()).join('\n')}');

    if (_galleryImageTasks != null) {
      _imageTaskDao.insertOrReplaceImageTasks(_galleryImageTasks);
    }
  }

  Future _updateImageTask(String gid, GalleryImage images,
      {String? fileName}) async {
    final ImageTaskDao _imageTaskDao = await getImageTaskDao();

    final GalleryTaskDao _galleryTaskDao = await getGalleryTaskDao();

    final GalleryImageTask _imageTask = GalleryImageTask(
      gid: int.parse(gid),
      token: '',
      href: images.href,
      ser: images.ser,
      imageUrl: images.imageUrl,
      sourceId: images.sourceId,
      filePath: fileName,
    );

    await _imageTaskDao.insertOrReplaceImageTasks([_imageTask]);
  }

  /// 开始下载
  Future<void> _startImageTask({
    required GalleryTask galleryTask,
    String? downloadPath,
    int? fCount,
    List<GalleryImage>? images,
  }) async {
    logger.d('_startImageTask ${galleryTask.gid} ${galleryTask.title}');

    final ImageTaskDao _imageTaskDao = await getImageTaskDao();

    final GalleryTaskDao _galleryTaskDao = await getGalleryTaskDao();

    final List<GalleryImageTask> imageTasksOri =
        await _imageTaskDao.findAllTaskByGid(galleryTask.gid);

    logger.v(
        '${imageTasksOri.where((element) => element.status != TaskStatus.complete.value).map((e) => e.toString()).join('\n')} ');

    final gidStr = '${galleryTask.gid}';

    // 初始化
    _initDownloadMapByGid(gidStr, images: images);

    _updateImageTasksByGid(gidStr);

    galleryTaskUpdateStatus(int.parse(gidStr), TaskStatus.running);

    final CancelToken _cancelToken = CancelToken();
    dState.cancelTokenMap[gidStr] = _cancelToken;

    logger.d('filecount:${galleryTask.fileCount} url:${galleryTask.url}');

    downloadPath ??= galleryTask.dirPath;

    final _completSers = imageTasksOri
        .where((element) => element.status == TaskStatus.complete.value)
        .map((e) => e.ser)
        .toList();

    final int _maxCompletSer =
        _completSers.isNotEmpty ? _completSers.reduce(max) : 0;

    logger.v('_maxCompletSer:$_maxCompletSer');

    // 下载
    for (int index = 0; index < galleryTask.fileCount; index++) {
      final itemSer = index + 1;

      final _oriImageTask =
          imageTasksOri.firstWhereOrNull((element) => element.ser == itemSer);
      if (_oriImageTask?.status == TaskStatus.complete.value) {
        continue;
      }

      logger.v('ser:$itemSer/${imageTasksOri.length}');

      fCount ??= await _fetchFirstPageCount(galleryTask.url!,
          cancelToken: _cancelToken);

      dState.executor.scheduleTask(() async {
        final GalleryImage? tImage = await _checkAndGetImages(
            gidStr, itemSer, galleryTask.fileCount, fCount!, galleryTask.url);

        if (tImage != null) {
          final int maxSer = galleryTask.fileCount + 1;

          try {
            await _downloadImage(
              tImage,
              _oriImageTask,
              gidStr,
              downloadPath!,
              maxSer,
              cancelToken: _cancelToken,
              redownload: itemSer < _maxCompletSer,
              onDownloadComplete: (String fileName) async {
                logger.v('$itemSer complete');

                // 下载完成 更新数据库明细
                // logger.d('下载完成 更新数据库明细');
                await _imageTaskDao.updateImageTaskStatus(
                  galleryTask.gid,
                  itemSer,
                  TaskStatus.complete.value,
                );

                // 更新ui
                final List<GalleryImageTask> listComplete =
                    await _imageTaskDao.finaAllTaskByGidAndStatus(
                        galleryTask.gid, TaskStatus.complete.value);

                final _task = galleryTaskUpdate(
                  galleryTask.gid,
                  countComplet: listComplete.length,
                  coverImg: itemSer == 1 ? fileName : null,
                );
                if (_task.fileCount == listComplete.length) {
                  galleryTaskComplete(galleryTask.gid);
                }

                await _galleryTaskDao.updateTask(_task);
              },
            );
          } on DioError catch (e) {
            if (!CancelToken.isCancel(e)) {
              rethrow;
            }

            // loggerSimple.d('$itemSer Cancel');
          }
        }
      });
    }
  }

  Future _checkAndGetImages(
    String gidStr,
    int itemSer,
    int filecount,
    int firstPageCount,
    String? url, {
    CancelToken? cancelToken,
  }) async {
    GalleryImage? tImage = _getImageObj(gidStr, itemSer);

    if (tImage == null && url != null) {
      loggerSimple.v('ser:$itemSer 所在页尚未获取， 开始获取');
      final images = await _fetchImages(
        ser: itemSer,
        fileCount: filecount,
        firstPageCount: firstPageCount,
        url: url,
        cancelToken: cancelToken,
      );
      loggerSimple.v('images.length: ${images.length}');
      _addAllImages(gidStr, images);
      tImage = _getImageObj(gidStr, itemSer);
    }

    return tImage;
  }

  Future<int> _fetchFirstPageCount(
    String url, {
    CancelToken? cancelToken,
  }) async {
    final List<GalleryImage> _moreImageList = await Api.getGalleryImage(
      url,
      page: 0,
      cancelToken: cancelToken,
      refresh: true, // 刷新画廊后加载缩略图不能从缓存读取，否则在改变每页数量后加载画廊会出错
    );
    return _moreImageList.length;
  }

  Future<void> _downloadImage(
    GalleryImage image,
    GalleryImageTask? imageTask,
    String gid,
    String downloadPath,
    int maxSer, {
    bool redownload = false,
    CancelToken? cancelToken,
    ValueChanged<String>? onDownloadComplete,
  }) async {
    loggerSimple.v('${image.ser} start');
    if (redownload) logger.v('${image.ser} redownload ');

    String _imageUrl = '';
    late GalleryImage _uptImage;
    String _fileName = '';

    // 存在imageTask的 用原url下载
    final bool useOriginalUrl = imageTask != null &&
        imageTask.imageUrl != null &&
        (imageTask.imageUrl?.isNotEmpty ?? false);

    if (useOriginalUrl && !redownload) {
      final String? imageUrl = imageTask.imageUrl;
      loggerSimple.v('${image.ser} DL $imageUrl');

      _imageUrl = imageUrl!;
      _uptImage = image;
      if (imageTask.filePath != null && imageTask.filePath!.isNotEmpty) {
        _fileName = imageTask.filePath!;
      } else {
        _fileName = _getFileName(image, maxSer);
      }
    } else if (image.href != null) {
      // 否则先请求解析html
      final GalleryImage imageFetched = await _fetchImageInfo(
        image.href!,
        itemSer: image.ser,
        oriImage: image,
        gid: gid,
        cancelToken: cancelToken,
        changeSource: redownload,
      );
      _imageUrl = imageFetched.imageUrl!;
      _uptImage = imageFetched;

      _fileName = _getFileName(imageFetched, maxSer);

      _addAllImages(gid, [imageFetched]);
      await _updateImageTask(gid, imageFetched, fileName: _fileName);

      if (redownload)
        logger.v('${imageFetched.href}\n${imageFetched.imageUrl} ');
    }

    final ProgressCallback _progressCallback = (int count, int total) {
      // logger.d('gid:$gid ser:${image.ser}  dlCount:$count');

      dState.downloadCounts['${gid}_${image.ser}'] = count;
    };

    try {
      await Api.download(
        _imageUrl,
        path.join(downloadPath, _fileName),
        cancelToken: cancelToken,
        onDownloadComplete: () => onDownloadComplete?.call(_fileName),
        progressCallback: _progressCallback,
      );
    } on DioError catch (e) {
      if (e.type == DioErrorType.response && e.response?.statusCode == 403) {
        logger.d('403 $gid.${image.ser}下载链接已经失效 需要更新 $image.href');
        final GalleryImage newImageFetched = await _fetchImageInfo(
          image.href!,
          itemSer: image.ser,
          oriImage: image,
          gid: gid,
          cancelToken: cancelToken,
          sourceId: _uptImage.sourceId,
          changeSource: true,
        );

        _imageUrl = newImageFetched.imageUrl!;

        _addAllImages(gid, [newImageFetched]);
        await _updateImageTask(gid, newImageFetched, fileName: _fileName);

        await Api.download(
          _imageUrl,
          path.join(downloadPath, _fileName),
          cancelToken: cancelToken,
          onDownloadComplete: () => onDownloadComplete?.call(_fileName),
          progressCallback: _progressCallback,
        );
      }
    }
  }

  String _getFileName(GalleryImage gimage, int maxSer) {
    final String _suffix = path.extension(gimage.imageUrl!);
    // gimage.imageUrl!.substring(gimage.imageUrl!.lastIndexOf('.'));
    final String _fileName = '$maxSer'.length > _kDefNameLen
        ? '${sp.sprintf('%0${'$maxSer'.length}d', [gimage.ser])}$_suffix'
        : '${sp.sprintf('%0${_kDefNameLen}d', [gimage.ser])}$_suffix';
    return _fileName;
  }

  Future<GalleryImage> _fetchImageInfo(
    String href, {
    required int itemSer,
    required GalleryImage oriImage,
    required String gid,
    bool changeSource = false,
    String? sourceId,
    CancelToken? cancelToken,
  }) async {
    final GalleryImage _image = await Api.fetchImageInfo(
      href,
      refresh: changeSource,
      sourceId: sourceId,
      cancelToken: cancelToken,
    );

    final GalleryImage _imageCopyWith = oriImage.copyWith(
      sourceId: _image.sourceId,
      imageUrl: _image.imageUrl,
      imageWidth: _image.imageWidth,
      imageHeight: _image.imageHeight,
    );

    return _imageCopyWith;
  }

  Future<List<GalleryImage>> _fetchImages({
    required int ser,
    required int fileCount,
    required String url,
    bool isRefresh = false,
    int? firstPageCount,
    CancelToken? cancelToken,
  }) async {
    final int page = firstPageCount != null ? (ser - 1) ~/ firstPageCount : 0;
    loggerSimple.v('ser:$ser 所在页码为$page');

    final List<GalleryImage> _moreImageList = await Api.getGalleryImage(
      url,
      page: page,
      cancelToken: cancelToken,
      refresh: isRefresh, // 刷新画廊后加载缩略图不能从缓存读取，否则在改变每页数量后加载画廊会出错
    );

    return _moreImageList;
  }

  Future<List<GalleryImageTask>> getImageTasks(int gid) async {
    final _imageTaskDao = await getImageTaskDao();
    final List<GalleryImageTask> tasks =
        await _imageTaskDao.findAllTaskByGid(gid);
    return tasks;
  }

  Future<void> allowMediaScan(bool newValue) async {
    final pathSet = dState.galleryTaskList
        .where((elm) => elm.dirPath != null)
        .map((element) => Directory(element.dirPath!).parent.path)
        .toSet();

    // final pathSet = dState.galleryTaskList
    //     .where((elm) => elm.dirPath != null)
    //     .map((element) => element.dirPath!)
    //     .toSet();
    if (newValue) {
      logger.d('delete all .nomedia file');
      for (final dirPath in pathSet) {
        final File noMediaFile = File(path.join(dirPath, '.nomedia'));
        if (noMediaFile.existsSync()) {
          noMediaFile.deleteSync(recursive: true);
        }
      }
    } else {
      logger.d('add .nomedia file \n${pathSet.join('\n')}');
      for (final dirPath in pathSet) {
        final File noMediaFile = File(path.join(dirPath, '.nomedia'));
        if (!noMediaFile.existsSync()) {
          noMediaFile.createSync(recursive: true);
          // noMediaFile.renameSync(path.join(dirPath, '.nomedia'));
        }
      }
    }
  }
}
