import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:executor/executor.dart';
import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/common/service/controller_tag_service.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/component/exception/error.dart';
import 'package:fehviewer/component/quene_task/quene_task.dart';
import 'package:fehviewer/models/base/eh_models.dart';
import 'package:fehviewer/network/api.dart';
import 'package:fehviewer/network/request.dart';
import 'package:fehviewer/pages/gallery/controller/gallery_page_controller.dart';
import 'package:fehviewer/pages/tab/controller/download_view_controller.dart';
import 'package:fehviewer/store/db/entity/gallery_image_task.dart';
import 'package:fehviewer/store/db/entity/gallery_task.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/toast.dart';
import 'package:fehviewer/utils/utility.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sprintf/sprintf.dart' as sp;

import 'cache_controller.dart';
import 'download_state.dart';

const int _kDefNameLen = 4;

Future<String> get defDownloadPath async => GetPlatform.isAndroid
    ? path.join((await getExternalStorageDirectory())!.path, 'Download')
    : (GetPlatform.isDesktop
        ? path.join((await getDownloadsDirectory())!.path, 'fehviewer')
        : path.join(Global.appDocPath, 'Download'));

class TaskStatus {
  const TaskStatus(this.value);
  final int value;

  static TaskStatus from(int value) => TaskStatus(value);

  static const undefined = TaskStatus(0);
  static const enqueued = TaskStatus(1);
  static const running = TaskStatus(2);
  static const complete = TaskStatus(3);
  static const failed = TaskStatus(4);
  static const canceled = TaskStatus(5);
  static const paused = TaskStatus(6);

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) {
      return true;
    }

    return o is TaskStatus && o.value == value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() {
    return 'TaskStatus{value: $value}';
  }
}

class DownloadController extends GetxController {
  final DownloadState dState = DownloadState();

  final EhConfigService ehConfigService = Get.find();
  final CacheController cacheController = Get.find();

  @override
  void onInit() {
    super.onInit();
    // logger.d(
    //     'DownloadController onInit multiDownload:${ehConfigService.multiDownload}');
    dState.executor = Executor(concurrency: ehConfigService.multiDownload);
    allowMediaScan(ehConfigService.allowMediaScan);
    initGalleryTasks();
  }

  @override
  void onClose() {
    _cancelDownloadStateChkTimer();
    super.onClose();
  }

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
      // logger.d('add .nomedia file \n${pathSet.join('\n')}');
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
    bool downloadOri = false,
  }) async {
    int _gid = 0;
    String _token = '';
    if (gid == null || token == null) {
      final RegExpMatch _match =
          RegExp(r'/g/(\d+)/([0-9a-f]{10})/?').firstMatch(url)!;
      _gid = int.parse(_match.group(1)!);
      _token = _match.group(2)!;
    }

    // 先查询任务是否已存在
    // final GalleryTask? _oriTask =
    //     await galleryTaskDao.findGalleryTaskByGid(gid ?? -1);
    final GalleryTask? _oriTask =
        await isarHelper.findGalleryTaskByGid(gid ?? -1);
    if (_oriTask != null) {
      showToast('Download task existed');
      logger.i('$gid 任务已存在');
      logger.d('${_oriTask.toString()} ');
      return;
    }

    final String _downloadPath = path.join(
        '$gid - ${path.split(title).join('_').replaceAll(RegExp(r'[/:*"<>|,?]'), '_')}');
    final String _dirPath =
        await _getGalleryDownloadPath(custpath: _downloadPath);

    // 登记主任务表
    final GalleryTask galleryTask = GalleryTask(
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
      downloadOrigImage: downloadOri,
    );

    logger.d('add NewTask ${galleryTask.toString()}');
    // galleryTaskDao.insertTask(galleryTask);
    isarHelper.putGalleryTask(galleryTask, replaceOnConflict: false);
    dState.galleryTaskMap[galleryTask.gid] = galleryTask;
    _downloadViewAnimateListAdd();
    showToast('${galleryTask.gid} Download task start');

    _addGalleryTask(
      galleryTask,
      fCount: Get.find<GalleryPageController>(tag: pageCtrlTag)
          .gState
          .firstPageImage
          .length,
    );
  }

  void _downloadViewAnimateListAdd() {
    if (Get.isRegistered<DownloadViewController>()) {
      Get.find<DownloadViewController>().animateGalleryListAddTask();
    }
  }

  /// 更新任务为已完成
  Future<GalleryTask?> galleryTaskComplete(int gid) async {
    if (dState.galleryTaskMap[gid]?.status == TaskStatus.complete.value) {
      return null;
    }
    logger.d('更新任务为已完成');
    _cancelDownloadStateChkTimer(gid: gid);
    if (!((dState.taskCanceltokens[gid]?.isCancelled) ?? true)) {
      dState.taskCanceltokens[gid]?.cancel();
    }

    final galleryTask = await galleryTaskUpdateStatus(gid, TaskStatus.complete);

    // 写入一个任务信息文件 帮助恢复任务用
    _writeTaskInfoFile(galleryTask);

    return galleryTask;
  }

  Future<void> _writeTaskInfoFile(GalleryTask? galleryTask) async {
    if (galleryTask == null) {
      return;
    }

    // final imageTaskList = (await imageTaskDao.findAllTaskByGid(galleryTask.gid))
    //     .map((e) => e.copyWith(imageUrl: ''))
    //     .toList();
    final imageTaskList =
        (await isarHelper.findImageTaskAllByGid(galleryTask.gid))
            .map((e) => e.copyWith(imageUrl: ''))
            .toList();

    String jsonImageTaskList = jsonEncode(imageTaskList);

    final dirPath = galleryTask.realDirPath;
    if (dirPath == null || dirPath.isEmpty) {
      return;
    }
    final File _infoFile = File(path.join(dirPath, '.info'));

    String jsonGalleryTask = jsonEncode(galleryTask.copyWith(dirPath: ''));
    logger.d('_writeTaskInfoFile:\n$jsonGalleryTask\n$jsonImageTaskList');

    _infoFile.writeAsString('$jsonGalleryTask\n$jsonImageTaskList');
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
    // final GalleryTask? galleryTask =
    //     await galleryTaskDao.findGalleryTaskByGid(gid);
    final GalleryTask? galleryTask = await isarHelper.findGalleryTaskByGid(gid);
    if (galleryTask != null) {
      logger.d('恢复任务 $gid');
      _addGalleryTask(galleryTask);
    }
  }

  /// 重下任务
  Future<void> galleryTaskRestart(int gid) async {
    // await imageTaskDao.deleteImageTaskByGid(gid);
    isarHelper.removeImageTask(gid);

    final GalleryTask? galleryTask = await isarHelper.findGalleryTaskByGid(gid);
    if (galleryTask != null) {
      logger.d('重下任务 $gid ${galleryTask.url}');
      cacheController.clearDioCache(
          path: '${Api.getBaseUrl()}${galleryTask.url}');
      final _reTask = galleryTask.copyWith(completCount: 0);
      dState.galleryTaskMap[gid] = _reTask;
      _addGalleryTask(_reTask);
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
        // galleryTaskDao.updateTask(_task);
        isarHelper.putGalleryTask(_task);
      }
    }

    return dState.galleryTaskMap[gid];
  }

  /// 根据gid获取任务
  Future<List<GalleryImageTask>> getImageTasks(int gid) async {
    // final List<GalleryImageTask> tasks =
    //     await imageTaskDao.findAllTaskByGid(gid);
    final List<GalleryImageTask> tasks =
        await isarHelper.findImageTaskAllByGid(gid);
    return tasks;
  }

  /// 移除任务
  Future<void> removeDownloadGalleryTask({
    required int gid,
    bool shouldDeleteContent = true,
  }) async {
    // 删除文件
    final GalleryTask? _task = dState.galleryTaskMap[gid];
    if (_task == null) {
      return;
    }
    String? dirpath = _task.realDirPath;
    logger.d('dirPath: $dirpath');
    if (dirpath != null && shouldDeleteContent) {
      Directory(dirpath).delete(recursive: true);
    }

    if (!((dState.cancelTokenMap[_task.gid]?.isCancelled) ?? true)) {
      dState.cancelTokenMap[_task.gid]?.cancel();
    }

    // 删除数据库记录
    // imageTaskDao.deleteImageTaskByGid(_task.gid);
    // galleryTaskDao.deleteTaskByGid(_task.gid);

    isarHelper.removeImageTask(_task.gid);
    isarHelper.removeGalleryTask(_task.gid);

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
    initGalleryTasks();
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

  // 添加任务队列
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

  // 取消下载任务定时器
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

  // 根据ser获取image信息
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

  /// 下载图片流程控制
  Future<void> _downloadImageFlow(
    GalleryImage image,
    GalleryImageTask? imageTask,
    int gid,
    String downloadPath,
    int maxSer, {
    bool downloadOrigImage = false, // 下载原图
    bool reDownload = false,
    CancelToken? cancelToken,
    ValueChanged<String>? onDownloadComplete,
  }) async {
    loggerSimple.v('${image.ser} start');
    if (reDownload) logger.v('${image.ser} redownload ');

    late String _targetImageUrl;
    late GalleryImage _uptImage;
    String _fileName = '';

    // 存在imageTask的 用原url下载
    final bool useOldUrl = imageTask != null &&
        imageTask.imageUrl != null &&
        (imageTask.imageUrl?.isNotEmpty ?? false);

    final String? imageUrlFromTask = imageTask?.imageUrl;
    // 使用原有url下载
    if (useOldUrl && !reDownload && imageUrlFromTask != null) {
      logger.d('使用原有url下载 ${image.ser} DL $imageUrlFromTask');

      _targetImageUrl = imageUrlFromTask;
      _uptImage = image;
      if (imageTask.filePath != null && imageTask.filePath!.isNotEmpty) {
        _fileName = imageTask.filePath!;
      } else {
        _fileName = _generatFileName(image, maxSer);
      }
    } else if (image.href != null) {
      logger.v('获取新的图片url');
      if (reDownload) {
        logger.d(
            '重下载 ${image.ser}, 清除缓存 ${image.href} , sourceId:${imageTask?.sourceId}');
        cacheController.clearDioCache(path: image.href ?? '');
      }

      // 否则先请求解析html
      final GalleryImage imageFetched = await _fetchImageInfo(
        image.href!,
        itemSer: image.ser,
        image: image,
        gid: gid,
        cancelToken: cancelToken,
        changeSource: reDownload,
        sourceId: imageTask?.sourceId,
      );

      if (imageFetched.imageUrl == null) {
        throw EhError(error: 'get imageUrl error');
      }

      // 目标下载地址
      _targetImageUrl = downloadOrigImage
          ? imageFetched.originImageUrl ?? imageFetched.imageUrl!
          : imageFetched.imageUrl!;
      _uptImage = imageFetched;

      logger.v(
          'downloadOrigImage:$downloadOrigImage\nDownload _targetImageUrl:$_targetImageUrl');

      _fileName = _generatFileName(imageFetched, maxSer);

      _addAllImages(gid, [imageFetched]);
      await _updateImageTask(gid, imageFetched, fileName: _fileName);

      if (reDownload) {
        logger.v('${imageFetched.href}\n${imageFetched.imageUrl} ');
      }
    } else {
      throw EhError(error: 'get image url error');
    }

    // 定义下载进度回调
    final ProgressCallback _progressCallback = (int count, int total) {
      // logger.d('gid:$gid ser:${image.ser}  dlCount:$count');
      dState.downloadCounts['${gid}_${image.ser}'] = count;
    };

    try {
      // 下载图片
      await _downloadToPath(
        _targetImageUrl,
        path.join(downloadPath, _fileName),
        cancelToken: cancelToken,
        onDownloadComplete: () => onDownloadComplete?.call(_fileName),
        progressCallback: _progressCallback,
      );
    } on DioError catch (e) {
      if (e.type == DioErrorType.response && e.response?.statusCode == 403) {
        logger.d('403 $gid.${image.ser}下载链接已经失效 需要更新 ${image.href}');
        final GalleryImage imageFetched = await _fetchImageInfo(
          image.href!,
          itemSer: image.ser,
          image: image,
          gid: gid,
          cancelToken: cancelToken,
          sourceId: _uptImage.sourceId,
          changeSource: true,
        );

        _targetImageUrl = ehConfigService.downloadOrigImage
            ? imageFetched.originImageUrl ?? imageFetched.imageUrl!
            : imageFetched.imageUrl!;

        logger.d('重下载 _targetImageUrl:$_targetImageUrl');

        _addAllImages(gid, [imageFetched]);
        await _updateImageTask(gid, imageFetched, fileName: _fileName);

        await ehDownload(
          url: _targetImageUrl,
          cancelToken: cancelToken,
          onDownloadComplete: () => onDownloadComplete?.call(_fileName),
          progressCallback: _progressCallback,
          savePath: path.join(downloadPath, _fileName),
        );
      }
    }
  }

  // 下载文件到指定路径
  Future _downloadToPath(
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
      await ehDownload(
        url: url,
        savePath: path,
        cancelToken: cancelToken,
        onDownloadComplete: onDownloadComplete,
        progressCallback: progressCallback,
      );
    } else {
      onDownloadComplete?.call();
    }
  }

  // 获取第一页的预览图数量
  Future<int> _fetchFirstPageCount(
    String url, {
    CancelToken? cancelToken,
  }) async {
    final List<GalleryImage> _moreImageList = await getGalleryImage(
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
    required GalleryImage image,
    required int gid,
    bool changeSource = false,
    String? sourceId,
    CancelToken? cancelToken,
  }) async {
    final String? _sourceId = changeSource ? sourceId : '';

    final GalleryImage? _image = await fetchImageInfo(
      href,
      refresh: changeSource,
      sourceId: _sourceId,
      cancelToken: cancelToken,
    );

    logger.v('_image from fetch ${_image?.toJson()}');

    if (_image == null) {
      return image;
    }

    final GalleryImage _imageCopyWith = image.copyWith(
      sourceId: _image.sourceId,
      imageUrl: _image.imageUrl,
      imageWidth: _image.imageWidth,
      imageHeight: _image.imageHeight,
      originImageUrl: _image.originImageUrl,
    );

    return _imageCopyWith;
  }

  Future<List<GalleryImage>> _fetchImages({
    required int ser,
    required int fileCount,
    required String url,
    bool isRefresh = false,
    required int firstPageCount,
    CancelToken? cancelToken,
  }) async {
    logger.v('firstPageCount $firstPageCount');
    final int page = (ser - 1) ~/ firstPageCount;
    logger.v('ser:$ser 所在页码为$page');

    final List<GalleryImage> _moreImageList = await getGalleryImage(
      url,
      page: page,
      cancelToken: cancelToken,
      refresh: isRefresh, // 刷新画廊后加载缩略图不能从缓存读取，否则在改变每页数量后加载画廊会出错
    );

    return _moreImageList;
  }

  // 暂停所有任务
  void _galleryTaskPausedAll() {
    for (final _task in dState.galleryTasks) {
      if (_task.status != TaskStatus.complete.value) {
        galleryTaskPaused(_task.gid);
        _updateDownloadView(['DownloadGalleryItem_${_task.gid}']);
      }
    }
  }

  // 生成文件名
  String _generatFileName(GalleryImage gimage, int maxSer) {
    final String _suffix = path.extension(gimage.imageUrl!);
    // gimage.imageUrl!.substring(gimage.imageUrl!.lastIndexOf('.'));
    final String _fileName = '$maxSer'.length > _kDefNameLen
        ? '${sp.sprintf('%0${'$maxSer'.length}d', [gimage.ser])}$_suffix'
        : '${sp.sprintf('%0${_kDefNameLen}d', [gimage.ser])}$_suffix';
    return _fileName;
  }

  /// 获取下载路径
  Future<String> _getGalleryDownloadPath({String custpath = ''}) async {
    late final String _dirPath;
    late final Directory savedDir;

    if (!GetPlatform.isIOS && ehConfigService.downloadLocatino.isNotEmpty) {
      // 自定义路径
      logger.d('自定义下载路径');
      await requestManageExternalStoragePermission();
      _dirPath = path.join(ehConfigService.downloadLocatino, custpath);
      savedDir = Directory(_dirPath);
    } else if (!GetPlatform.isIOS) {
      logger.d('无自定义下载路径');
      _dirPath = path.join(await defDownloadPath, custpath);
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

  // 根据gid初始化下载任务计时器
  void _initDownloadStateChkTimer(int gid) {
    // 每隔[kPeriodSeconds]时间， 执行一次
    dState.chkTimers[gid] = Timer.periodic(
      const Duration(seconds: kPeriodSeconds),
      (Timer timer) {
        final _task = dState.galleryTaskMap[gid];
        if (_task != null && _task.fileCount == _task.completCount) {
          galleryTaskComplete(gid);
          return;
        }

        if (dState.galleryTaskMap[gid]?.status == TaskStatus.running.value) {
          _totalDownloadSpeed(
            gid,
            maxCount: kMaxCount,
            checkMaxCount: kCheckMaxCount,
            periodSeconds: kPeriodSeconds,
          );
        }
      },
    );
  }

  // 初始化任务列表
  Future<void> initGalleryTasks() async {
    // final _tasks = await galleryTaskDao.findAllGalleryTasks();
    await downloadTaskMigration();
    final _tasks = await isarHelper.findAllGalleryTasks();

    // 添加到map中
    for (final _task in _tasks) {
      dState.galleryTaskMap[_task.gid] = _task;
    }

    // 继续未完成的任务
    for (final task in _tasks) {
      if (task.status == TaskStatus.running.value) {
        logger.d('继续未完成的任务');
        _addGalleryTask(task);
      }
    }
  }

  Future<void> downloadTaskMigration() async {
    final isMigrationed = hiveHelper.getDownloadTaskMigration();
    logger.d('downloadTaskMigration $isMigrationed');
    if (!isMigrationed) {
      logger.d('start download task Migration');
      await restoreGalleryTasks();
      hiveHelper.setDownloadTaskMigration(true);
    }
  }

  // 从当前下载目录恢复下载列表数据
  Future<void> restoreGalleryTasks() async {
    final String _currentDownloadPath = await _getGalleryDownloadPath();
    logger.d('_currentDownloadPath: $_currentDownloadPath');
    final directory = Directory(GetPlatform.isIOS
        ? path.join(Global.appDocPath, _currentDownloadPath)
        : _currentDownloadPath);
    await for (final fs in directory.list()) {
      final infoFile = File(path.join(fs.path, '.info'));
      if (fs is Directory && infoFile.existsSync()) {
        logger.d('infoFile: ${infoFile.path}');
        final info = infoFile.readAsStringSync();
        final infoList = info
            .split('\n')
            .where((element) => element.trim().isNotEmpty)
            .toList();
        if (infoList.length < 2) {
          continue;
        }

        final taskJsonString = infoList[0];
        final imageJsonString = infoList[1];

        try {
          final galleryTask = GalleryTask.fromJson(
                  jsonDecode(taskJsonString) as Map<String, dynamic>)
              .copyWith(dirPath: fs.path);
          final galleryImageTaskList = <GalleryImageTask>[];

          final imageList = jsonDecode(imageJsonString) as List<dynamic>;
          for (final img in imageList) {
            final galleryImageTask =
                GalleryImageTask.fromJson(img as Map<String, dynamic>);
            galleryImageTaskList.add(galleryImageTask);
          }

          // await imageTaskDao.insertOrReplaceImageTasks(galleryImageTaskList);
          await isarHelper.putAllImageTask(galleryImageTaskList);
          // await galleryTaskDao.insertOrReplaceTask(galleryTask);
          await isarHelper.putGalleryTask(galleryTask);
        } catch (e, stack) {
          logger.e('$e\n$stack');
          continue;
        }
      }
    }

    onInit();
  }

  Future<void> rebuildGalleryTasks() async {
    // final _tasks = await galleryTaskDao.findAllGalleryTasks();
    final _tasks = await isarHelper.findAllGalleryTasks();

    _tasks.forEach((task) => _writeTaskInfoFile(task));
  }

  /// 开始下载
  Future<void> _startImageTask({
    required GalleryTask galleryTask,
    int? fCount,
    List<GalleryImage>? images,
  }) async {
    // logger.d('_startImageTask ${galleryTask.gid} ${galleryTask.title}');

    // logger.d('${galleryTask.toString()} ');

    // 如果完成数等于文件数 那么更新状态为完成
    if (galleryTask.completCount == galleryTask.fileCount) {
      logger.d('complete ${galleryTask.gid}  ${galleryTask.title}');

      await galleryTaskComplete(galleryTask.gid);
      _updateDownloadView(['DownloadGalleryItem_${galleryTask.gid}']);
    }

    // 初始化下载计时控制
    _initDownloadStateChkTimer(galleryTask.gid);

    // final List<GalleryImageTask> imageTasksOri =
    //     await imageTaskDao.findAllTaskByGid(galleryTask.gid);
    final List<GalleryImageTask> imageTasksOri =
        await isarHelper.findImageTaskAllByGid(galleryTask.gid);

    logger.v(
        '${imageTasksOri.where((element) => element.status != TaskStatus.complete.value).map((e) => e.toString()).join('\n')} ');

    // 初始化下载Map
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

    // 循环进行下载图片
    for (int index = 0; index < galleryTask.fileCount; index++) {
      final itemSer = index + 1;

      final _oriImageTask =
          imageTasksOri.firstWhereOrNull((element) => element.ser == itemSer);
      if (_oriImageTask?.status == TaskStatus.complete.value) {
        continue;
      }

      logger.v('ser:$itemSer/${imageTasksOri.length}');

      if (fCount == null || fCount < 1) {
        fCount = await _fetchFirstPageCount(galleryTask.url!,
            cancelToken: _cancelToken);
      }

      dState.executor.scheduleTask(() async {
        final GalleryImage? tImage = await _checkAndGetImages(galleryTask.gid,
            itemSer, galleryTask.fileCount, fCount!, galleryTask.url);

        if (tImage != null) {
          final int maxSer = galleryTask.fileCount + 1;

          try {
            await _downloadImageFlow(
              tImage,
              _oriImageTask,
              galleryTask.gid,
              downloadPath!,
              maxSer,
              downloadOrigImage: galleryTask.downloadOrigImage ?? false,
              cancelToken: _cancelToken,
              reDownload: itemSer < _maxCompletSer + 2,
              onDownloadComplete: (String fileName) =>
                  _onDownloadComplete(fileName, galleryTask.gid, itemSer),
            );
          } on DioError catch (e) {
            // 忽略 [DioErrorType.cancel]
            if (!CancelToken.isCancel(e)) {
              rethrow;
            }

            // loggerSimple.d('$itemSer Cancel');
          } on EhError catch (e) {
            if (e.type == EhErrorType.image509) {
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

  // 下载完成回调
  Future _onDownloadComplete(String fileName, int gid, int itemSer) async {
    logger.v('$itemSer complete');

    // 下载完成 更新数据库明细
    logger.v('下载完成 更新数据库明细');
    // await imageTaskDao.updateImageTaskStatus(
    //   gid,
    //   itemSer,
    //   TaskStatus.complete.value,
    // );
    await isarHelper.updateImageTaskStatus(
      gid,
      itemSer,
      TaskStatus.complete.value,
    );

    // 更新ui
    // logger.v('更新ui');
    // final List<GalleryImageTask> listComplete = await imageTaskDao
    //     .finaAllTaskByGidAndStatus(gid, TaskStatus.complete.value);
    final List<GalleryImageTask> listComplete = await isarHelper
        .finaAllTaskByGidAndStatus(gid, TaskStatus.complete.value);

    final GalleryTask? _task = galleryTaskUpdate(
      gid,
      countComplet: listComplete.length,
      coverImg: itemSer == 1 ? fileName : null,
    );
    if (_task?.fileCount == listComplete.length) {
      galleryTaskComplete(gid);
    }

    if (_task != null) {
      // await galleryTaskDao.updateTask(_task);
      await isarHelper.putGalleryTask(_task);
    }
    _updateDownloadView(['DownloadGalleryItem_$gid']);
  }

  /// 自动重试检查
  /// [kRetryThresholdTime] 速度没有变化, 重试该任务
  void _totalDownloadSpeed(
    int gid, {
    int maxCount = 3,
    int checkMaxCount = 10,
    int periodSeconds = 1,
  }) {
    final int totCurCount = dState.downloadCounts.entries
        .where((element) => element.key.startsWith('${gid}_'))
        .map((e) => e.value)
        .sum;

    dState.lastCounts[gid]?.add(totCurCount);

    dState.lastCounts.putIfAbsent(gid, () => [0]);
    final List<int> lastCounts = dState.lastCounts[gid] ?? [0];
    final List<int> lastCountsTopCheck = lastCounts.reversed
        .toList()
        .sublist(0, min(lastCounts.length, checkMaxCount));

    logger
        .v('${lastCountsTopCheck.join(',')}\n${lastCounts.reversed.join(',')}');

    final speedCheck =
        (max(totCurCount - lastCountsTopCheck.reversed.first, 0) /
                (lastCountsTopCheck.length * periodSeconds))
            .round();

    logger.v(
        'speedCheck:${renderSize(speedCheck)}\n${lastCountsTopCheck.join(',')}');

    // 用速度检查是否需要重试
    if (speedCheck == 0) {
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

    // 显示的速度
    final List<int> lastCountsTopShow = lastCounts.reversed
        .toList()
        .sublist(0, min(lastCounts.length, maxCount));
    final speedShow = (max(totCurCount - lastCountsTopShow.reversed.first, 0) /
            (lastCountsTopShow.length * periodSeconds))
        .round();
    logger.v(
        'speedShow:${renderSize(speedShow)}\n${lastCountsTopShow.join(',')}');
    dState.downloadSpeeds[gid] = renderSize(speedShow);
    _updateDownloadView(['DownloadGalleryItem_$gid']);
  }

  void _updateDownloadView([List<Object>? ids]) {
    if (Get.isRegistered<DownloadViewController>()) {
      Get.find<DownloadViewController>().update(ids);
    }
  }

  Future _updateImageTask(int gid, GalleryImage images,
      {String? fileName}) async {
    final GalleryImageTask _imageTask = GalleryImageTask(
      gid: gid,
      token: '',
      href: images.href,
      ser: images.ser,
      imageUrl: images.imageUrl,
      sourceId: images.sourceId,
      filePath: fileName,
    );

    // await imageTaskDao.insertOrReplaceImageTasks([_imageTask]);
    await isarHelper.putImageTask(_imageTask);
  }

  Future _updateImageTasksByGid(int gid, {List<GalleryImage>? images}) async {
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
      // imageTaskDao.insertOrReplaceImageTasks(_galleryImageTasks);
      isarHelper.putAllImageTask(_galleryImageTasks);
    }
  }
}
