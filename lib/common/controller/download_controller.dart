import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:eros_fe/common/controller/download/download_monitor.dart' as dm;
import 'package:eros_fe/common/controller/download/download_path_manager.dart';
import 'package:eros_fe/common/controller/download/download_task_manager.dart'
    as dtm;
import 'package:eros_fe/common/controller/download/image_download_processor.dart';
import 'package:eros_fe/common/controller/download/storage_adapter.dart';
import 'package:eros_fe/common/service/controller_tag_service.dart';
import 'package:eros_fe/common/service/ehsetting_service.dart';
import 'package:eros_fe/component/exception/error.dart';
import 'package:eros_fe/component/quene_task/quene_task.dart';
import 'package:eros_fe/index.dart';
import 'package:eros_fe/network/app_dio/pdio.dart';
import 'package:eros_fe/pages/gallery/controller/gallery_page_controller.dart';
import 'package:eros_fe/pages/tab/controller/download_view_controller.dart';
import 'package:eros_fe/store/db/entity/gallery_image_task.dart';
import 'package:eros_fe/store/db/entity/gallery_task.dart';
import 'package:executor/executor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'cache_controller.dart';
import 'download_state.dart'
    hide kPeriodSeconds, kMaxCount, kCheckMaxCount, kRetryThresholdTime;

Future<String> get defDownloadPath async => GetPlatform.isAndroid
    ? await getAndroidDefaultDownloadPath()
    : (GetPlatform.isWindows
        ? path.join((await getDownloadsDirectory())!.path, 'fehviewer')
        : path.join(Global.appDocPath, 'Download'));

Future<String> getAndroidDefaultDownloadPath() async {
  final downloadPath = path.join(Global.extStorePath, 'Download');

  final dir = Directory(downloadPath);
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }
  return downloadPath;
}

// 使用dtm中定义的TaskStatus
typedef TaskStatus = dtm.TaskStatus;

class DownloadController extends GetxController {
  final DownloadState dState = DownloadState();

  final EhSettingService ehSettingService = Get.find();
  final CacheController cacheController = Get.find();

  // 新增的委托类实例
  late final DownloadPathManager pathManager;
  late final dtm.DownloadTaskManager taskManager;
  late final dm.DownloadMonitor downloadMonitor;
  late final ImageDownloadProcessor imageProcessor;
  late final StorageAdapter storageAdapter;

  @override
  void onInit() {
    super.onInit();
    // logger.d(
    //     'DownloadController onInit multiDownload:${ehSettingService.multiDownload}');
    dState.executor = Executor(concurrency: ehSettingService.multiDownload);

    // 初始化委托类
    storageAdapter = StorageAdapter();
    pathManager = DownloadPathManager(ehSettingService);
    taskManager =
        dtm.DownloadTaskManager(dState, storageAdapter: storageAdapter);
    downloadMonitor = dm.DownloadMonitor(dState);
    imageProcessor = ImageDownloadProcessor(dState, cacheController);

    asyncInit();
  }

  @override
  void onClose() {
    _cancelDownloadStateChkTimer();
    super.onClose();
  }

  Future<void> asyncInit() async {
    await pathManager.updateCustomDownloadPath();
    pathManager.allowMediaScan(ehSettingService.allowMediaScan);
    await taskManager.initGalleryTasks(
      addGalleryTaskCallback: _addGalleryTask,
      downloadTaskMigrationCallback: downloadTaskMigration,
    );
  }

  Future<void> updateCustomDownloadPath() async {
    await pathManager.updateCustomDownloadPath();
    restoreGalleryTasks();
  }

  /// 切换允许媒体扫描
  Future<void> allowMediaScan(bool allow) async {
    await pathManager.allowMediaScan(allow);
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
    String? showKey,
  }) async {
    int gid0 = 0;
    String token0 = '';
    if (gid == null || token == null) {
      final RegExpMatch match =
          RegExp(r'/g/(\d+)/([0-9a-f]{10})/?').firstMatch(url)!;
      gid0 = int.parse(match.group(1)!);
      token0 = match.group(2)!;
    }

    // 先查询任务是否已存在
    final GalleryTask? oriTask =
        await isarHelper.findGalleryTaskByGidIsolate(gid ?? -1);
    if (oriTask != null) {
      showToast('Download task existed');
      logger.i('$gid 任务已存在');
      logger.d('${oriTask.toString()} ');
      return;
    }

    final String galleryDirName = path.join(
      '$gid - ${path.split(title).join('_').replaceAll(RegExp(r'[/:*"<>|,?]'), '_')}',
    );
    String dirPath;
    try {
      dirPath = await _getGalleryDownloadPath(dirName: galleryDirName);
    } catch (err, stack) {
      logger.e('创建目录失败', error: err, stackTrace: stack);
      showToast('create Directory error, $err');
      return;
    }

    logger.d('downloadPath:$dirPath');

    // 登记主任务表
    final GalleryTask galleryTask = GalleryTask(
      gid: gid ?? gid0,
      token: token ?? token0,
      url: url,
      title: title,
      fileCount: fileCount,
      dirPath: dirPath,
      status: TaskStatus.enqueued.value,
      addTime: DateTime.now().millisecondsSinceEpoch,
      coverUrl: coverUrl,
      rating: rating,
      category: category,
      uploader: uploader,
      downloadOrigImage: downloadOri,
      showKey: showKey,
    );

    logger.d('add NewTask ${galleryTask.toString()}');
    isarHelper.putGalleryTaskIsolate(galleryTask, replaceOnConflict: false);
    dState.galleryTaskMap[galleryTask.gid] = galleryTask;
    downloadViewAnimateListAdd();
    showToast('${galleryTask.gid} Download task start');

    _addGalleryTask(
      galleryTask,
      fileCount: Get.find<GalleryPageController>(tag: pageCtrlTag)
          .gState
          .firstPageImage
          .length,
    );
  }

  void downloadViewAnimateListAdd() {
    if (Get.isRegistered<DownloadViewController>()) {
      Get.find<DownloadViewController>().animateGalleryListAddTask();
    }
  }

  /// 更新任务为已完成
  Future<GalleryTask?> galleryTaskComplete(int gid) async {
    final task = await taskManager.galleryTaskComplete(
      gid,
      cancelTimerCallback: _cancelDownloadStateChkTimer,
    );
    _updateDownloadView(['DownloadGalleryItem_$gid']);
    return task;
  }

  /// 暂停任务
  Future<GalleryTask?> galleryTaskPaused(int gid, {bool silent = false}) async {
    final task = await taskManager.galleryTaskPaused(
      gid,
      silent: silent,
      cancelTimerCallback: _cancelDownloadStateChkTimer,
    );
    if (!silent) {
      _updateDownloadView(['DownloadGalleryItem_$gid']);
    }
    return task;
  }

  /// 恢复任务
  Future<void> galleryTaskResume(int gid) async {
    await taskManager.galleryTaskResume(
      gid,
      addGalleryTaskCallback: _addGalleryTask,
    );
  }

  /// 重下任务
  Future<void> galleryTaskRestart(int gid) async {
    await taskManager.galleryTaskRestart(
      gid,
      addGalleryTaskCallback: _addGalleryTask,
    );
  }

  /// 更新任务进度
  GalleryTask? galleryTaskUpdate(
    int gid, {
    int? countComplete,
    String? coverImg,
  }) {
    return taskManager.galleryTaskUpdate(
      gid,
      countComplete: countComplete,
      coverImg: coverImg,
    );
  }

  /// 更新任务状态
  Future<GalleryTask?> galleryTaskUpdateStatus(
    int gid,
    TaskStatus status,
  ) async {
    return taskManager.galleryTaskUpdateStatus(gid, status);
  }

  /// 根据gid获取任务
  Future<List<GalleryImageTask>> getImageTasks(int gid) async {
    final List<GalleryImageTask> tasks =
        await isarHelper.findImageTaskAllByGidIsolate(gid);
    return tasks;
  }

  /// 移除任务
  Future<void> removeDownloadGalleryTask({
    required int gid,
    bool shouldDeleteContent = true,
  }) async {
    await taskManager.removeDownloadGalleryTask(
      gid: gid,
      shouldDeleteContent: shouldDeleteContent,
    );
  }

  void resetConcurrency() {
    // 取消所有任务
    for (final ct in dState.cancelTokenMap.values) {
      if (!ct.isCancelled) {
        ct.cancel();
      }
    }
    _cancelDownloadStateChkTimer();
    logger.d('reset multiDownload ${ehSettingService.multiDownload}');
    dState.executor = Executor(concurrency: ehSettingService.multiDownload);

    // 重新加入
    initGalleryTasks();
  }

  void _addAllImages(int gid, List<GalleryImage> galleryImages) {
    for (final GalleryImage image in galleryImages) {
      final int? index = dState.downloadMap[gid]
          ?.indexWhere((GalleryImage e) => e.ser == image.ser);
      if (index != null && index != -1) {
        dState.downloadMap[gid]?[index] = image;
      } else {
        dState.downloadMap[gid]?.add(image);
      }
    }
  }

  // 添加任务队列
  void _addGalleryTask(
    GalleryTask galleryTask, {
    int? fileCount,
    List<GalleryImage>? images,
  }) {
    dState.taskCancelTokens[galleryTask.gid] = TaskCancelToken();
    final showKey = galleryTask.showKey;
    if (showKey != null) {
      _updateShowKey(galleryTask.gid, showKey);
    }
    dState.queueTask.add(
      ({name}) {
        logger.d('excue $name');
        _startImageTask(
          galleryTask: galleryTask,
          fileCount: fileCount,
          images: images,
        );
      },
      taskName: '${galleryTask.gid}',
    );
  }

  // 取消下载任务定时器
  void _cancelDownloadStateChkTimer([int? gid]) {
    downloadMonitor.cancelDownloadStateChkTimer(gid: gid);
  }

  Future<void> checkSafPath(
      {String? uri, bool saveDownloadPath = false}) async {
    await pathManager.checkSafPath(
        uri: uri, saveDownloadPath: saveDownloadPath);
  }

  /// 获取下载路径
  Future<String> _getGalleryDownloadPath({String dirName = ''}) async {
    return pathManager.getGalleryDownloadPath(dirName: dirName);
  }

  GalleryImage? _getImageObj(int gid, int ser) {
    return dState.downloadMap[gid]
        ?.firstWhereOrNull((element) => element.ser == ser);
  }

  int _initDownloadMapByGid(int gid, {List<GalleryImage>? images}) {
    dState.downloadMap[gid] = images ?? [];
    return dState.downloadMap[gid]?.length ?? 0;
  }

  // 根据gid初始化下载任务计时器
  void _initDownloadStateChkTimer(int gid) {
    downloadMonitor.initDownloadStateChkTimer(
      gid,
      onTimerCallback: (int gid, Timer timer) {
        final task = dState.galleryTaskMap[gid];
        if (task != null && task.fileCount == task.completCount) {
          galleryTaskComplete(gid);
          return;
        }

        if (dState.galleryTaskMap[gid]?.status == TaskStatus.running.value) {
          // 分别调用两个拆分后的方法
          _updateDownloadSpeed(
            gid,
            maxCount: dm.kMaxCount,
            periodSeconds: dm.kPeriodSeconds,
          );

          _checkDownloadStall(
            gid,
            checkMaxCount: dm.kCheckMaxCount,
            periodSeconds: dm.kPeriodSeconds,
          );
        }
      },
    );
  }

  // 初始化任务列表
  Future<void> initGalleryTasks() async {
    await taskManager.initGalleryTasks(
      addGalleryTaskCallback: _addGalleryTask,
      downloadTaskMigrationCallback: downloadTaskMigration,
    );
  }

  Future<void> downloadTaskMigration() async {
    final isMigrationed = hiveHelper.getDownloadTaskMigration();
    logger.t('downloadTaskMigration $isMigrationed');
    if (!isMigrationed) {
      logger.d('start download task Migration');
      await restoreGalleryTasks();
      hiveHelper.setDownloadTaskMigration(true);
    }
  }

  Future<void> restoreGalleryTasks({bool init = false}) async {
    await taskManager.restoreGalleryTasks(
      init: init,
      getDownloadPathCallback: _getGalleryDownloadPath,
      restoreTasksWithPathCallback: restoreGalleryTasksWithPath,
      restoreTasksWithSAFCallback: restoreGalleryTasksWithSAF,
      onInitCallback: onInit,
      resetDownloadViewAnimationKeyCallback: resetDownloadViewAnimationKey,
    );
  }

  Future<void> restoreGalleryTasksWithSAF(String currentDownloadPath) async {
    await storageAdapter.restoreGalleryTasksWithSAF(
      currentDownloadPath,
      _loadInfoFile,
    );
  }

  // 从当前下载目录恢复下载列表数据
  Future<void> restoreGalleryTasksWithPath(String currentDownloadPath) async {
    await storageAdapter.restoreGalleryTasksWithPath(
      currentDownloadPath,
      _loadInfoFile,
    );
  }

  Future<void> _loadInfoFile(File infoFile, String dirPath) async {
    await storageAdapter.loadInfoFile(infoFile, dirPath);
  }

  Future<void> rebuildGalleryTasks() async {
    final tasks = await isarHelper.findAllGalleryTasksIsolate();

    for (final task in tasks) {
      if (task.coverImage == null) {
        await isarHelper.updateGalleryTaskCover(task.gid);
      }
      storageAdapter.writeTaskInfoFile(task);
    }
  }

  void _updateShowKey(
    int gid,
    String showKey, {
    bool updateDB = false,
  }) {
    logger.t('update showKey $gid $showKey');
    dState.showKeyMap[gid] = showKey;
    if (!(dState.showKeyCompleteMap[gid]?.isCompleted ?? false)) {
      dState.showKeyCompleteMap[gid]?.complete(true);
    }
    if (updateDB) {
      // 如果直接操作数据库更新，不更新 map 数据，会导致后续状态更新时，直接将 map 中的 task 写入数据库，导致 showKey 丢失
      // 所以这里需要更新 map 数据 ， 数据库的更新由后续状态更新时，自动更新
      // TODO(3003n): 优化状态更新时，任务表的更新逻辑
      final task = dState.galleryTaskMap[gid];
      if (task != null) {
        dState.galleryTaskMap[gid] = task.copyWith(showKey: showKey);
      }
    }
  }

  /// 开始下载
  Future<void> _startImageTask(
      {required GalleryTask galleryTask,
      int? fileCount,
      List<GalleryImage>? images}) async {
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

    final List<GalleryImageTask> imageTasksOri =
        await isarHelper.findImageTaskAllByGidIsolate(galleryTask.gid);

    final completeCount = imageTasksOri
        .where((element) => element.status == TaskStatus.complete.value)
        .length;

    await isarHelper.putGalleryTaskIsolate(
        galleryTask.copyWith(completCount: completeCount));

    logger.t(
        '${imageTasksOri.where((element) => element.status != TaskStatus.complete.value).map((e) => e.toString()).join('\n')} ');

    // 初始化下载Map
    final initCount = _initDownloadMapByGid(galleryTask.gid, images: images);
    logger.t('initCount: $initCount');

    final putCount = await _updateImageTasksByGid(galleryTask.gid);
    logger.t('putCount: $putCount');

    galleryTaskUpdateStatus(galleryTask.gid, TaskStatus.running);

    _clearErrInfo(galleryTask.gid, updateView: false);

    final CancelToken cancelToken = CancelToken();
    dState.cancelTokenMap[galleryTask.gid] = cancelToken;

    logger.t('fileCount:${galleryTask.fileCount} url:${galleryTask.url}');

    final realDirPath = galleryTask.realDirPath;
    if (realDirPath == null) {
      return;
    }

    final String downloadParentPath = realDirPath;

    if (downloadParentPath.isContentUri) {
      logger.d('^^^^^^^^^^ downloadParentPath $downloadParentPath');
    }

    final List<int> completeSerList = imageTasksOri
        .where((element) => element.status == TaskStatus.complete.value)
        .map((e) => e.ser)
        .toList();

    final int maxCompleteSer =
        completeSerList.isNotEmpty ? completeSerList.reduce(max) : 0;

    logger.t('_maxCompleteSer:$maxCompleteSer');

    // 循环进行下载图片
    for (int index = 0; index < galleryTask.fileCount; index++) {
      final itemSer = index + 1;

      final oriImageTask =
          imageTasksOri.firstWhereOrNull((element) => element.ser == itemSer);
      if (oriImageTask?.status == TaskStatus.complete.value) {
        continue;
      }

      logger.t('ser:$itemSer/${imageTasksOri.length}');

      if (fileCount == null || fileCount < 1) {
        fileCount = await imageProcessor.fetchFirstPageCount(
          galleryTask.url!,
          cancelToken: cancelToken,
        );
      }

      logger.t('showKeyMap ${dState.showKeyMap}');
      final showKey = dState.showKeyMap[galleryTask.gid];

      if (index > 0 && showKey == null) {
        logger.d('loop index: $index, showKey of ${galleryTask.gid} is null');

        dState.showKeyCompleteMap[galleryTask.gid] = Completer<bool>.sync();
        await dState.showKeyCompleteMap[galleryTask.gid]?.future;

        logger.t(
            'loop index: $index, showKey of ${galleryTask.gid} is ${dState.showKeyMap[galleryTask.gid]}');
      }

      dState.executor.scheduleTask(() async {
        final GalleryImage? preImage =
            await imageProcessor.checkAndGetImageList(
          galleryTask.gid,
          itemSer,
          galleryTask.fileCount,
          fileCount!,
          galleryTask.url,
          cancelToken: cancelToken,
          addAllImagesCallback: _addAllImages,
          getImageObjCallback: _getImageObj,
        );

        if (preImage != null) {
          final int maxSer = galleryTask.fileCount + 1;

          logger.t(
              'itemSer, _maxCompleteSer + 1: $itemSer, ${maxCompleteSer + 1}');

          try {
            await imageProcessor.downloadImageFlow(
              preImage,
              oriImageTask,
              galleryTask.gid,
              downloadParentPath,
              maxSer,
              showKey: dState.showKeyMap[galleryTask.gid],
              downloadOrigImage: galleryTask.downloadOrigImage ?? false,
              cancelToken: cancelToken,
              reDownload: itemSer > 1 && itemSer < maxCompleteSer + 2,
              onDownloadCompleteWithFileName: (String fileName) =>
                  _onDownloadComplete(
                fileName,
                galleryTask.gid,
                itemSer,
              ),
              putImageTaskCallback: _putImageTask,
            );
          } on DioException catch (e) {
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
              _updateErrInfo(galleryTask.gid, '509');
            }
            rethrow;
          } on HttpException catch (e) {
            logger.e('$e');
            if (e is BadRequestException && e.code == 429) {
              show429Toast();
              _galleryTaskPausedAll();
              dState.executor.close();
              resetConcurrency();
              _updateErrInfo(galleryTask.gid, '429');
            }
            rethrow;
          } catch (e) {
            rethrow;
          }
        }
      });
    }
  }

  void _updateErrInfo(int gid, String error) {
    dState.errInfoMap[gid] = error;
    _updateDownloadView(['DownloadGalleryItem_$gid']);
  }

  void _clearErrInfo(int gid, {bool updateView = true}) {
    dState.errInfoMap.remove(gid);
    if (updateView) {
      _updateDownloadView(['DownloadGalleryItem_$gid']);
    }
  }

  // 下载完成回调
  Future _onDownloadComplete(String fileName, int gid, int itemSer) async {
    logger.t('********** $itemSer complete $fileName');

    // 下载完成 更新数据库明细
    // logger.t('下载完成 更新数据库明细');
    final List<GalleryImageTask> listComplete = kDebugMode
        ? await isarHelper.onDownloadComplete(
            gid,
            itemSer,
            TaskStatus.complete.value,
          )
        : await isarHelper.onDownloadCompleteIsolate(
            gid,
            itemSer,
            TaskStatus.complete.value,
          );

    logger.t(
        'listComplete:  ${listComplete.length}: ${listComplete.map((e) => e.ser).join(',')}');

    final coverImg =
        listComplete.firstWhereOrNull((element) => element.ser == 1)?.filePath;
    logger.t('_onDownloadComplete coverImg: $coverImg');

    final GalleryTask? task = galleryTaskUpdate(
      gid,
      countComplete: listComplete.length,
      coverImg: coverImg,
    );
    if (task?.fileCount == listComplete.length) {
      galleryTaskComplete(gid);
    }

    if (task != null) {
      await isarHelper.putGalleryTask(task);
    }
    _updateDownloadView(['DownloadGalleryItem_$gid']);
  }

  /// 计算并更新下载速度显示
  void _updateDownloadSpeed(int gid,
      {int maxCount = 3, int periodSeconds = 1}) {
    downloadMonitor.updateDownloadSpeed(
      gid,
      maxCount: maxCount,
      periodSeconds: periodSeconds,
    );
    _updateDownloadView(['DownloadGalleryItem_$gid']);
  }

  /// 检查下载是否停滞并处理重试
  void _checkDownloadStall(int gid,
      {int checkMaxCount = 10, int periodSeconds = 1}) {
    downloadMonitor.checkDownloadStall(
      gid,
      checkMaxCount: checkMaxCount,
      periodSeconds: periodSeconds,
      onRetryNeededCallback: (int gid) {
        logger.d('检测到下载停滞，正在重试 gid:$gid, 时间:${DateTime.now()}');

        // 执行重试
        Future<void>(() => galleryTaskPaused(gid, silent: true))
            .then((_) => Future.delayed(const Duration(microseconds: 1000)))
            .then((_) => galleryTaskResume(gid));
      },
    );
  }

  void _updateDownloadView([List<Object>? ids]) {
    if (Get.isRegistered<DownloadViewController>()) {
      Get.find<DownloadViewController>().update(ids);
    }
  }

  void resetDownloadViewAnimationKey() {
    if (Get.isRegistered<DownloadViewController>()) {
      Get.find<DownloadViewController>().animatedGalleryListKey =
          GlobalKey<AnimatedListState>();
    }
  }

  Future<void> _putImageTask(
    int gid,
    GalleryImage image,
    String? fileName,
    int? status,
  ) async {
    // final GalleryImageTask? oriImageTask =
    //     await isarHelper.findImageTaskAllByGidSerIsolate(gid, image.ser);
    final GalleryImageTask? oriImageTask =
        await isarHelper.findImageTaskAllByGidSer(gid, image.ser);

    final GalleryImageTask newImageTask = GalleryImageTask(
      gid: gid,
      token: image.token ?? '',
      href: image.href,
      ser: image.ser,
      imageUrl: image.imageUrl,
      sourceId: image.sourceId,
      filePath: fileName,
      status: status,
    );

    final GalleryImageTask imageTask = oriImageTask?.copyWith(
          token: image.token ?? '',
          href: image.href,
          imageUrl: image.imageUrl,
          sourceId: image.sourceId,
          filePath: fileName,
          status: status,
        ) ??
        newImageTask;

    logger.t(
        'putImageTask => statue:${imageTask.status} name:${imageTask.filePath}');

    if (kDebugMode) {
      await isarHelper.putImageTask(imageTask);
    } else {
      await isarHelper.putImageTaskIsolate(imageTask);
    }
  }

  Future<int> _updateImageTasksByGid(int gid,
      {List<GalleryImage>? images}) async {
    // 插入所有任务明细
    final List<GalleryImageTask>? galleryImageTasks =
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

    if (galleryImageTasks != null) {
      logger.d('插入所有任务明细 $gid ${galleryImageTasks.length}');
      await isarHelper.putAllImageTaskIsolate(galleryImageTasks);
    }

    return galleryImageTasks?.length ?? 0;
  }

  // 暂停所有任务
  void _galleryTaskPausedAll() {
    for (final task in dState.galleryTasks) {
      if (task.status != TaskStatus.complete.value) {
        galleryTaskPaused(task.gid);
        _updateDownloadView(['DownloadGalleryItem_${task.gid}']);
      }
    }
  }
}
