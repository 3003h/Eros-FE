import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:executor/executor.dart';
import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/common/isolate_download/download_manager.dart';
import 'package:fehviewer/common/service/depth_service.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/component/exception/error.dart';
import 'package:fehviewer/component/quene_task/quene_task.dart';
import 'package:fehviewer/models/base/eh_models.dart';
import 'package:fehviewer/network/gallery_request.dart';
import 'package:fehviewer/network/request.dart';
import 'package:fehviewer/pages/gallery/controller/gallery_page_controller.dart';
import 'package:fehviewer/pages/tab/controller/download_view_controller.dart';
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
import 'package:permission_handler/permission_handler.dart';
import 'package:sprintf/sprintf.dart' as sp;

import 'cache_controller.dart';
import 'download_state.dart';

const int _kDefNameLen = 4;

Future<String> get defDownloadPath async => GetPlatform.isAndroid
    ? path.join((await getExternalStorageDirectory())!.path, 'Download')
    : path.join(Global.appDocPath, 'Download');

class DownloadController extends GetxController {
  final DownloadState dState = DownloadState();

  final EhConfigService ehConfigService = Get.find();
  final CacheController cacheController = Get.find();

  /// 允许媒体扫描
  Future<void> allowMediaScan(bool newValue) async {
    final pathSet = dState.galleryTasks
        .where((elm) => elm.realDirPath != null)
        .map((element) => Directory(element.realDirPath!).parent.path)
        .toSet();

    if (newValue) {
      logger.d('delete all .nomedia file');
      for (final dirPath in pathSet) {
        final File noMediaFile = File(path.join(dirPath, '.nomedia'));
        if (await noMediaFile.exists()) {
          noMediaFile.delete(recursive: true);
        }
      }
    } else {
      logger.d('add .nomedia file \n${pathSet.join('\n')}');
      for (final dirPath in pathSet) {
        final File noMediaFile = File(path.join(dirPath, '.nomedia'));
        // if (!noMediaFile.existsSync()) {
        //   noMediaFile.createSync(recursive: true);
        //   // noMediaFile.renameSync(path.join(dirPath, '.nomedia'));
        // }
        if (!await noMediaFile.exists()) {
          noMediaFile.create(recursive: true);
        }
      }
    }
  }

  /// 下载画廊
  Future<void> downloadGallery({
    required String url,
    required int fileCount,
    required String title,
    int? gid,
    String? token,
    String? coverUrl,
    double? rating,
    String? category,
    String? uploader,
  }) async {
    final _galleryTaskDao = await getGalleryTaskDao();

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
      showToast('Download task existed');
      logger.i('$gid 任务已存在');
      logger.d('${_oriTask.toString()} ');
      isNewTask = false;
      return;
    }

    final String _downloadPath = path.join(
        '$gid - ${path.split(title).join('_').replaceAll(RegExp(r'[/:*"<>|,?]'), '_')}');
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
            addTime: DateTime.now().millisecondsSinceEpoch,
            coverUrl: coverUrl,
            rating: rating,
            category: category,
            uploader: uploader,
          )
        : _oriTask!;

    if (isNewTask) {
      logger.d('add NewTask ${galleryTask.toString()}');
      _galleryTaskDao.insertTask(galleryTask);
      dState.galleryTaskMap[galleryTask.gid] = galleryTask;
      _downloadViewAnimateListAdd();
      showToast('${galleryTask.gid} Download task start');
    }

    final GalleryPageController _pageController = Get.find(tag: pageCtrlDepth);
    final _fCount = _pageController.firstPageImage.length;

    logger.d('新任务');
    _addGalleryTask(
      galleryTask,
      fCount: _fCount,
    );
  }

  void _downloadViewAnimateListAdd() {
    if (Get.isRegistered<DownloadViewController>()) {
      Get.find<DownloadViewController>().animateGalleryListAddTask();
    }
  }

  /// 更新任务为已完成
  Future<GalleryTask?> galleryTaskComplete(int gid) {
    _cancelDownloadStateChkTimer(gid: gid);
    if (!((dState.taskCanceltokens[gid]?.isCancelled) ?? true)) {
      dState.taskCanceltokens[gid]?.cancel();
    }
    return galleryTaskUpdateStatus(gid, TaskStatus.complete);
  }

  /// 暂停任务
  Future<GalleryTask?> galleryTaskPaused(int gid, {bool silent = false}) async {
    // logger.d('galleryTaskPaused $gid');
    _cancelDownloadStateChkTimer(gid: gid);
    logger.v('${dState.cancelTokenMap[gid]?.isCancelled}');
    if (!((dState.cancelTokenMap[gid]?.isCancelled) ?? true)) {
      dState.cancelTokenMap[gid]?.cancel();
    }
    if (silent) {
      return null;
    }

    return galleryTaskUpdateStatus(gid, TaskStatus.paused);
  }

  /// 恢复任务
  Future<void> galleryTaskResume(int gid) async {
    final _galleryTaskDao = await getGalleryTaskDao();
    final GalleryTask? galleryTask =
        await _galleryTaskDao.findGalleryTaskByGid(gid);
    if (galleryTask != null) {
      logger.d('恢复任务 $gid');
      _addGalleryTask(galleryTask);
    }
  }

  /// 更新任务进度
  GalleryTask? galleryTaskUpdate(int gid,
      {int? countComplet, String? coverImg}) {
    logger.v('galleryTaskCountUpdate gid:$gid count:$countComplet');
    dState.curComplet[gid] = countComplet ?? 0;

    if (!dState.galleryTaskMap.containsKey(gid)) {
      return null;
    }

    dState.galleryTaskMap[gid] = dState.galleryTaskMap[gid]!.copyWith(
      completCount: countComplet,
      coverImage: coverImg,
    );

    return dState.galleryTaskMap[gid];
  }

  /// 更新任务状态
  Future<GalleryTask?> galleryTaskUpdateStatus(
      int gid, TaskStatus status) async {
    if (dState.galleryTaskMap.containsKey(gid) &&
        dState.galleryTaskMap[gid] != null) {
      dState.galleryTaskMap[gid] =
          dState.galleryTaskMap[gid]!.copyWith(status: status.value);
      logger.v('set $gid status $status');

      final _task = dState.galleryTaskMap[gid];
      if (_task != null) {
        (await getGalleryTaskDao()).updateTask(_task);
      }
    }

    return dState.galleryTaskMap[gid];
  }

  /// 根据gid获取任务
  Future<List<GalleryImageTask>> getImageTasks(int gid) async {
    final _imageTaskDao = await getImageTaskDao();
    final List<GalleryImageTask> tasks =
        await _imageTaskDao.findAllTaskByGid(gid);
    return tasks;
  }

  @override
  void onClose() {
    downloadManagerIsolate.close();
    _cancelDownloadStateChkTimer();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
    logger.d(
        'DownloadController onInit multiDownload:${ehConfigService.multiDownload}');
    dState.executor = Executor(concurrency: ehConfigService.multiDownload);
    allowMediaScan(ehConfigService.allowMediaScan);
    _initGalleryTasks();
  }

  /// 移除任务
  Future<void> removeDownloadGalleryTask({
    required int gid,
  }) async {
    GalleryTaskDao _galleryTaskDao;
    ImageTaskDao _imageTaskDao;

    // 删除文件
    final GalleryTask? _task = dState.galleryTaskMap[gid];
    if (_task == null) {
      return;
    }
    String? dirpath = _task.realDirPath;
    logger.d('dirPath: $dirpath');
    if (dirpath != null) {
      Directory(dirpath).delete(recursive: true);
    }

    if (!((dState.cancelTokenMap[_task.gid]?.isCancelled) ?? true)) {
      dState.cancelTokenMap[_task.gid]?.cancel();
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

    dState.galleryTaskMap.remove(gid);
  }

  void resetConcurrency() {
    // 取消所有任务
    for (final ct in dState.cancelTokenMap.values) {
      if (!ct.isCancelled) {
        ct.cancel();
      }
    }
    _cancelDownloadStateChkTimer();
    logger.d('reset multiDownload ${ehConfigService.multiDownload}');
    dState.executor = Executor(concurrency: ehConfigService.multiDownload);

    // 重新加入
    _initGalleryTasks();
  }

  void _addAllImages(int gid, List<GalleryImage> galleryImages) {
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

  void _addGalleryTask(
    GalleryTask galleryTask, {
    int? fCount,
    List<GalleryImage>? images,
  }) {
    dState.taskCanceltokens[galleryTask.gid] = TaskCancelToken();
    dState.queueTask.add(
      ({name}) {
        logger.d('excue $name');
        _startImageTask(
          galleryTask: galleryTask,
          fCount: fCount,
          images: images,
        );
      },
      taskName: '${galleryTask.gid}',
    );
  }

  // void _autoRetryTask(int gid) {
  //   // 回调
  //   logger.d('$gid afterTimer = ' + DateTime.now().toString());
  //   logger.d('${dState.curComplet[gid]}  ${dState.preComplet[gid]}');
  //   if (dState.curComplet[gid] == dState.preComplet[gid]) {
  //     logger.d('reset $gid');
  //     Future<void>(() => galleryTaskPaused(gid, silent: true))
  //         .then((_) => Future.delayed(const Duration(microseconds: 2000)))
  //         .then((_) => galleryTaskResume(gid));
  //   } else {
  //     dState.preComplet[gid] = dState.curComplet[gid] ?? 0;
  //   }
  // }

  void _cancelDownloadStateChkTimer({int? gid}) {
    if (gid != null) {
      dState.downloadSpeeds.remove(gid);
      dState.noSpeed.remove(gid);
      dState.chkTimers[gid]?.cancel();
    } else {
      for (final Timer? timer in dState.chkTimers.values) {
        timer?.cancel();
      }
      dState.downloadSpeeds.clear();
      dState.noSpeed.clear();
    }
  }

  Future<GalleryImage?> _checkAndGetImages(
    int gid,
    int itemSer,
    int filecount,
    int firstPageCount,
    String? url, {
    CancelToken? cancelToken,
  }) async {
    GalleryImage? tImage = _getImageObj(gid, itemSer);

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
      _addAllImages(gid, images);
      tImage = _getImageObj(gid, itemSer);
    }

    return tImage;
  }

  Future<void> _downloadImage(
    GalleryImage image,
    GalleryImageTask? imageTask,
    int gid,
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
      if (redownload) {
        cacheController.clearDioCache(path: image.href ?? '');
      }

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
      await _download(
        _imageUrl,
        path.join(downloadPath, _fileName),
        cancelToken: cancelToken,
        onDownloadComplete: () => onDownloadComplete?.call(_fileName),
        progressCallback: _progressCallback,
      );
    } on DioError catch (e) {
      if (e.type == DioErrorType.response && e.response?.statusCode == 403) {
        logger.d('403 $gid.${image.ser}下载链接已经失效 需要更新 ${image.href}');
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

  Future _download(
    String url,
    String path, {
    CancelToken? cancelToken,
    VoidCallback? onDownloadComplete,
    ProgressCallback? progressCallback,
  }) async {
    bool formCache = false;
    // 根据url读取缓存 存在的话直接将缓存写文件
    try {
      formCache =
          await Api.saveImageFromExtendedCache(imageUrl: url, savePath: path);
    } catch (e) {
      logger.e('$e');
      formCache = false;
    }

    if (!formCache) {
      await Api.download(
        url,
        path,
        cancelToken: cancelToken,
        onDownloadComplete: onDownloadComplete,
        progressCallback: progressCallback,
      );
    } else {
      onDownloadComplete?.call();
    }
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

  Future<GalleryImage> _fetchImageInfo(
    String href, {
    required int itemSer,
    required GalleryImage oriImage,
    required int gid,
    bool changeSource = false,
    String? sourceId,
    CancelToken? cancelToken,
  }) async {
    final GalleryImage? _image = await fetchImageInfo(
      href,
      // refresh: changeSource,
      sourceId: sourceId,
      cancelToken: cancelToken,
    );

    if (_image == null) {
      return oriImage;
    }

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

  void _galleryTaskPausedAll() {
    for (final _task in dState.galleryTasks) {
      if (_task.status != TaskStatus.complete.value) {
        galleryTaskPaused(_task.gid);
        _updateDownloadView(['DownloadGalleryItem_${_task.gid}']);
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

  /// 获取下载路径
  Future<String> _getGalleryDownloadPath(String custpath) async {
    late final String _dirPath;
    late final Directory savedDir;
    if (GetPlatform.isAndroid && ehConfigService.downloadLocatino.isNotEmpty) {
      // 自定义路径
      logger.d('自定义下载路径');
      await requestPermission();
      _dirPath = path.join(ehConfigService.downloadLocatino, custpath);
      savedDir = Directory(_dirPath);
    } else if (GetPlatform.isAndroid) {
      logger.d('无自定义下载路径');
      _dirPath = path.join(
          (await getExternalStorageDirectory())!.path, 'Download', custpath);
      savedDir = Directory(_dirPath);
    } else {
      logger.d('iOS');
      // iOS 记录的为相对路径 不记录doc的实际路径
      _dirPath = path.join('Download', custpath);
      savedDir = Directory(path.join(Global.appDocPath, _dirPath));
    }

    // 判断下载路径是否存在
    final bool hasExisted = savedDir.existsSync();
    // 不存在就新建路径
    if (!hasExisted) {
      savedDir.createSync(recursive: true);
    }

    return _dirPath;
  }

  GalleryImage? _getImageObj(int gid, int ser) {
    return dState.downloadMap[gid]
        ?.firstWhereOrNull((element) => element.ser == ser);
  }

  void _initDownloadMapByGid(int gid, {List<GalleryImage>? images}) {
    dState.downloadMap[gid] = images ?? [];
  }

  void _initDownloadStateChkTimer(int gid) {
    dState.chkTimers[gid] = Timer.periodic(
      const Duration(seconds: periodSeconds),
      (Timer timer) {
        final _task = dState.galleryTaskMap[gid];
        if (_task != null && _task.fileCount == _task.completCount) {
          galleryTaskComplete(gid);
          return;
        }

        if (dState.galleryTaskMap[gid]?.status == TaskStatus.running.value) {
          _totalDownloadSpeed(gid, maxCount, periodSeconds);
        }
      },
    );
  }

  Future<void> _initGalleryTasks() async {
    logger5.v(' _initGalleryTasks');
    GalleryTaskDao _galleryTaskDao;
    // ImageTaskDao _imageTaskDao;
    try {
      _galleryTaskDao = await getGalleryTaskDao();
      // _imageTaskDao = await getImageTaskDao();
    } catch (e, stack) {
      logger.e('$e\n$stack ');
      rethrow;
    }

    final _tasks = await _galleryTaskDao.findAllGalleryTasks();
    // dState.galleryTaskList(_tasks);

    // 添加到map中
    for (final _task in _tasks) {
      dState.galleryTaskMap[_task.gid] = _task;
    }

    // 继续未完成的任务
    for (final task in _tasks) {
      if (task.status == TaskStatus.running.value) {
        // _startImageTask(galleryTask: task);
        logger.d('继续未完成的任务');
        _addGalleryTask(task);
      }
    }
  }

  /// 开始下载
  Future<void> _startImageTask({
    required GalleryTask galleryTask,
    int? fCount,
    List<GalleryImage>? images,
  }) async {
    // logger.d('_startImageTask ${galleryTask.gid} ${galleryTask.title}');

    // logger.d('${galleryTask.toString()} ');

    if (galleryTask.completCount == galleryTask.fileCount) {
      logger.d('complete ${galleryTask.gid}  ${galleryTask.title}');

      await galleryTaskComplete(galleryTask.gid);
      _updateDownloadView(['DownloadGalleryItem_${galleryTask.gid}']);
    }

    _initDownloadStateChkTimer(galleryTask.gid);

    final ImageTaskDao _imageTaskDao = await getImageTaskDao();
    final GalleryTaskDao _galleryTaskDao = await getGalleryTaskDao();

    final List<GalleryImageTask> imageTasksOri =
        await _imageTaskDao.findAllTaskByGid(galleryTask.gid);

    logger.v(
        '${imageTasksOri.where((element) => element.status != TaskStatus.complete.value).map((e) => e.toString()).join('\n')} ');

    // 初始化
    _initDownloadMapByGid(galleryTask.gid, images: images);

    _updateImageTasksByGid(galleryTask.gid);

    galleryTaskUpdateStatus(galleryTask.gid, TaskStatus.running);

    final CancelToken _cancelToken = CancelToken();
    dState.cancelTokenMap[galleryTask.gid] = _cancelToken;

    logger.v('filecount:${galleryTask.fileCount} url:${galleryTask.url}');

    final String? downloadPath = galleryTask.realDirPath;

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
        final GalleryImage? tImage = await _checkAndGetImages(galleryTask.gid,
            itemSer, galleryTask.fileCount, fCount!, galleryTask.url);

        if (tImage != null) {
          final int maxSer = galleryTask.fileCount + 1;

          try {
            await _downloadImage(
              tImage,
              _oriImageTask,
              galleryTask.gid,
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

                final GalleryTask? _task = galleryTaskUpdate(
                  galleryTask.gid,
                  countComplet: listComplete.length,
                  coverImg: itemSer == 1 ? fileName : null,
                );
                if (_task?.fileCount == listComplete.length) {
                  galleryTaskComplete(galleryTask.gid);
                }

                if (_task != null) {
                  await _galleryTaskDao.updateTask(_task);
                }
              },
            );
          } on DioError catch (e) {
            // 忽略 [DioErrorType.cancel]
            if (!CancelToken.isCancel(e)) {
              rethrow;
            }

            // loggerSimple.d('$itemSer Cancel');
          } on EhError catch (e) {
            if (e.type == EhErrorType.image509) {
              // logger.e('image509');
              show509Toast();
              _galleryTaskPausedAll();
              dState.executor.close();
              resetConcurrency();
            }
            rethrow;
          } catch (e) {
            rethrow;
          }
        }
      });
    }
  }

  /// 自动重试检查
  /// [kRetryThresholdTime] 秒内速度没有变化, 重试该任务
  void _totalDownloadSpeed(int gid, int maxCount, int periodSeconds) {
    final int totCurCount = dState.downloadCounts.entries
        .where((element) => element.key.startsWith('${gid}_'))
        .map((e) => e.value)
        .sum;

    dState.lastCounts[gid]?.add(totCurCount);

    dState.lastCounts.putIfAbsent(gid, () => [0]);
    final List<int> lastCounts = dState.lastCounts[gid] ?? [0];
    final List<int> lastCountsTop = lastCounts.reversed
        .toList()
        .sublist(0, min(lastCounts.length, maxCount));

    logger.v('${lastCountsTop.join(',')}\n${lastCounts.reversed.join(',')}');

    final speed = (max(totCurCount - lastCountsTop.reversed.first, 0) /
            (lastCountsTop.length * periodSeconds))
        .round();

    dState.downloadSpeeds[gid] = renderSize(speed);

    loggerSimple.v('speed:${renderSize(speed)}\n${lastCountsTop.join(',')}');

    _updateDownloadView(['DownloadGalleryItem_$gid']);

    if (speed == 0) {
      if (dState.noSpeed[gid] != null) {
        dState.noSpeed[gid] = dState.noSpeed[gid]! + 1;
      } else {
        dState.noSpeed[gid] = 1;
      }

      if ((dState.noSpeed[gid] ?? 0) > kRetryThresholdTime) {
        logger.d('$gid retry = ' + DateTime.now().toString());
        Future<void>(() => galleryTaskPaused(gid, silent: true))
            .then((_) => Future.delayed(const Duration(microseconds: 1000)))
            .then((_) => galleryTaskResume(gid));
      }
    }
  }

  void _updateDownloadView(List<Object>? ids) {
    if (Get.isRegistered<DownloadViewController>()) {
      Get.find<DownloadViewController>().update(ids);
    }
  }

  Future _updateImageTask(int gid, GalleryImage images,
      {String? fileName}) async {
    final ImageTaskDao _imageTaskDao = await getImageTaskDao();

    // final GalleryTaskDao _galleryTaskDao = await getGalleryTaskDao();

    final GalleryImageTask _imageTask = GalleryImageTask(
      gid: gid,
      token: '',
      href: images.href,
      ser: images.ser,
      imageUrl: images.imageUrl,
      sourceId: images.sourceId,
      filePath: fileName,
    );

    await _imageTaskDao.insertOrReplaceImageTasks([_imageTask]);
  }

  Future _updateImageTasksByGid(int gid, {List<GalleryImage>? images}) async {
    final ImageTaskDao _imageTaskDao = await getImageTaskDao();

    // final GalleryTaskDao _galleryTaskDao = await getGalleryTaskDao();

    // logger.d(
    //     '_updateImageTasksByGid $gid\n  ${(images ?? downloadMap[gid])?.map((e) => e.toJson()).join('\n')} ');

    // 插入所有任务明细
    final List<GalleryImageTask>? _galleryImageTasks =
        (images ?? dState.downloadMap[gid])
            ?.map((GalleryImage e) => GalleryImageTask(
                  gid: gid,
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

  static Future<GalleryTaskDao> getGalleryTaskDao() async {
    return (await Global.getDatabase()).galleryTaskDao;
  }

  static Future<ImageTaskDao> getImageTaskDao() async {
    return (await Global.getDatabase()).imageTaskDao;
  }
}
