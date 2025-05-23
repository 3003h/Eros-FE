import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:eros_fe/common/controller/download/download_monitor.dart' as dm;
import 'package:eros_fe/common/controller/download/download_path_manager.dart';
import 'package:eros_fe/common/controller/download/download_task_manager.dart'
    as dtm;
import 'package:eros_fe/common/controller/download/gallery_slot_manager.dart';
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
  late final GallerySlotManager gallerySlotManager;

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

    // 初始化画廊槽位管理器
    gallerySlotManager = GallerySlotManager(
      maxConcurrentGalleries: ehSettingService.concurrentGalleries,
      onStartGallery: _startGalleryDownload,
      onUpdateStatus: galleryTaskUpdateStatus,
    );

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

    // 使用_addGalleryTask添加到槽位管理器
    _addGalleryTask(
      galleryTask,
      groupCount: Get.find<GalleryPageController>(tag: pageCtrlTag)
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
    logger.d('画廊任务完成: gid=$gid');
    final task = await taskManager.galleryTaskComplete(
      gid,
      cancelTimerCallback: _cancelDownloadStateChkTimer,
    );
    _updateDownloadView(['DownloadGalleryItem_$gid']);

    // 通知槽位管理器状态变化
    logger.d('通知槽位管理器画廊任务完成: gid=$gid');
    await gallerySlotManager.onGalleryStatusChanged(gid, TaskStatus.complete);
    logger.d('槽位管理器处理完成: gid=$gid');

    return task;
  }

  /// 暂停任务
  Future<GalleryTask?> galleryTaskPaused(int gid, {bool silent = false}) async {
    logger.d('画廊任务暂停: gid=$gid, silent=$silent');
    final task = await taskManager.galleryTaskPaused(
      gid,
      silent: silent,
      cancelTimerCallback: _cancelDownloadStateChkTimer,
    );
    if (!silent) {
      _updateDownloadView(['DownloadGalleryItem_$gid']);
    }

    // 通知槽位管理器状态变化
    logger.d('通知槽位管理器画廊任务暂停: gid=$gid');
    await gallerySlotManager.onGalleryStatusChanged(gid, TaskStatus.paused);
    logger.d('槽位管理器处理完成: gid=$gid');

    return task;
  }

  /// 恢复任务
  Future<void> galleryTaskResume(int gid) async {
    logger.d('画廊任务恢复: gid=$gid');

    // 先标记为enqueued，确保槽位管理器能正确处理此任务
    await galleryTaskUpdateStatus(gid, TaskStatus.enqueued);

    // 恢复任务，addGalleryTask会将任务添加到槽位管理器
    await taskManager.galleryTaskResume(
      gid,
      addGalleryTaskCallback: _addGalleryTask,
    );

    // 注意：现在不再直接通知槽位管理器状态为running
    // 由槽位管理器自己管理状态变更，在合适的时候启动任务
    logger.d('恢复任务完成: gid=$gid');
  }

  /// 重下任务
  Future<void> galleryTaskRestart(int gid) async {
    loggerSimple.d('重启任务开始: gid=$gid');

    // 先尝试暂停正在进行的任务（如果有）
    // 这将取消现有下载和计时器
    if (dState.galleryTaskMap.containsKey(gid) &&
        dState.galleryTaskMap[gid]?.status == TaskStatus.running.value) {
      loggerSimple.d('先暂停当前运行中的任务: gid=$gid');
      await galleryTaskPaused(gid, silent: true);
    }

    // 取消特定任务的所有网络请求
    if (dState.cancelTokenMap.containsKey(gid) &&
        !(dState.cancelTokenMap[gid]?.isCancelled ?? true)) {
      loggerSimple.d('取消现有下载请求: gid=$gid');
      dState.cancelTokenMap[gid]?.cancel();
    }

    // 取消该任务的计时器
    _cancelDownloadStateChkTimer(gid);

    // 调用taskManager执行任务重启
    loggerSimple.d('执行任务重启: gid=$gid');
    await taskManager.galleryTaskRestart(
      gid,
      addGalleryTaskCallback: _addGalleryTask,
    );

    loggerSimple.d('重启任务完成: gid=$gid');
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
    logger.d('更新任务状态: gid=$gid, 新状态=$status (${status.value})');

    // 获取当前任务状态和信息用于记录
    GalleryTask? oldTask = dState.galleryTaskMap[gid];
    int? oldStatus = oldTask?.status;
    logger.d('当前任务: gid=$gid, 旧状态=${oldStatus}, 任务=${oldTask?.title}');

    // 通过taskManager更新状态
    final task = await taskManager.galleryTaskUpdateStatus(gid, status);

    logger.d('状态更新完成: gid=$gid, 任务=${task?.title}, 新状态=${task?.status}');
    return task;
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
    loggerSimple.d('重置并发设置开始');

    // 记录当前正在运行的任务GID列表，用于后续恢复
    final List<int> runningTaskGids = dState.galleryTasks
        .where((task) => task.status == TaskStatus.running.value)
        .map((task) => task.gid)
        .toList();
    loggerSimple.d('当前运行中的任务: $runningTaskGids');

    // 重置UI状态，将所有运行中的任务临时标记为入队状态
    for (final gid in runningTaskGids) {
      if (dState.galleryTaskMap.containsKey(gid)) {
        GalleryTask? oldTask = dState.galleryTaskMap[gid];
        dState.galleryTaskMap[gid] =
            oldTask!.copyWith(status: TaskStatus.enqueued.value);
        _updateDownloadView(['DownloadGalleryItem_$gid']);
      }
    }

    // 取消所有网络请求
    for (final ct in dState.cancelTokenMap.values) {
      if (!ct.isCancelled) {
        ct.cancel();
      }
    }
    dState.cancelTokenMap.clear();

    // 取消所有计时器
    _cancelDownloadStateChkTimer();

    // 关闭旧的executor以释放资源
    loggerSimple.d('关闭旧的executor');
    try {
      dState.executor.close();
      loggerSimple.d('旧的executor已关闭');
    } catch (e) {
      loggerSimple.e('关闭executor出错: $e');
    }

    // 创建新的executor
    loggerSimple.d('创建新的executor，并发数: ${ehSettingService.multiDownload}');
    dState.executor = Executor(concurrency: ehSettingService.multiDownload);

    // 设置槽位管理器的并发数
    loggerSimple.d('设置槽位管理器的并发数: ${ehSettingService.concurrentGalleries}');
    gallerySlotManager
        .setMaxConcurrentGalleries(ehSettingService.concurrentGalleries);

    // 清空当前槽位状态和队列
    gallerySlotManager.resetState();

    // 清除下载缓存信息，确保重新开始不受旧状态影响
    dState.curComplete.clear();
    dState.lastCounts.clear();
    dState.noSpeed.clear();
    dState.downloadSpeeds.clear();
    dState.preComplete.clear();

    // 保存数据库中的状态更改
    for (final gid in runningTaskGids) {
      if (dState.galleryTaskMap.containsKey(gid)) {
        isarHelper.putGalleryTaskIsolate(dState.galleryTaskMap[gid]!);
      }
    }

    // 重新初始化所有任务
    loggerSimple.d('重新初始化所有任务');
    initGalleryTasks();

    loggerSimple.d('重置并发设置完成');
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
    int? groupCount,
    List<GalleryImage>? images,
  }) {
    logger.d('添加画廊任务: gid=${galleryTask.gid}, 标题=${galleryTask.title}');
    dState.taskCancelTokens[galleryTask.gid] = TaskCancelToken();
    final showKey = galleryTask.showKey;
    if (showKey != null) {
      _updateShowKey(galleryTask.gid, showKey);
    }

    // 使用槽位管理器添加任务，保存 groupCount 和 images 信息
    dState.galleryTaskExtraInfo[galleryTask.gid] = {
      'groupCount': groupCount,
      'images': images,
    };
    loggerSimple.d('将任务交给槽位管理器: gid=${galleryTask.gid}');
    gallerySlotManager.addGalleryTask(galleryTask);
    loggerSimple.d('槽位管理器处理完成: gid=${galleryTask.gid}');
  }

  // 启动画廊下载
  void _startGalleryDownload(GalleryTask galleryTask) {
    loggerSimple.d('槽位管理器请求启动画廊下载: gid=${galleryTask.gid}');
    final extraInfo = dState.galleryTaskExtraInfo[galleryTask.gid];
    final int? groupCount = extraInfo?['groupCount'] as int?;
    final List<GalleryImage>? images =
        extraInfo?['images'] as List<GalleryImage>?;

    loggerSimple.d(
        '准备添加任务到队列: gid=${galleryTask.gid}, fileCount=${galleryTask.fileCount}, groupCount=$groupCount}');
    dState.queueTask.add(
      ({name}) {
        logger.d('队列执行任务: $name, gid=${galleryTask.gid}');
        _startImageTask(
          galleryTask: galleryTask,
          groupCount: groupCount,
          images: images,
        );
        logger.d('_startImageTask执行完成: gid=${galleryTask.gid}');
      },
      taskName: '${galleryTask.gid}',
    );
    logger.d('任务已添加到队列: gid=${galleryTask.gid}');
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
    logger.d('获取图片对象: gid=$gid, ser=$ser');
    logger.d(
        'downloadMap: ${dState.downloadMap[gid]?.map((e) => e.ser).join(',')}');
    return dState.downloadMap[gid]
        ?.firstWhereOrNull((element) => element.ser == ser);
  }

  int _initDownloadMapByGid(int gid, {List<GalleryImage>? images}) {
    dState.downloadMap[gid] = images ?? [];
    return dState.downloadMap[gid]?.length ?? 0;
  }

  // 根据gid初始化下载任务计时器
  void _initDownloadStateChkTimer(int gid) {
    loggerSimple.d('初始化下载计时器: gid=$gid');

    // 直接提供回调函数，取代download_monitor内部默认实现
    // 这样可以避免重复调用checkDownloadStall和updateDownloadSpeed
    downloadMonitor.initDownloadStateChkTimer(
      gid,
      onTimerCallback: (int gid, Timer timer) {
        final task = dState.galleryTaskMap[gid];
        if (task != null && task.fileCount == task.completCount) {
          galleryTaskComplete(gid);
          return;
        }

        if (dState.galleryTaskMap[gid]?.status == TaskStatus.running.value) {
          // 更新下载速度显示
          downloadMonitor.updateDownloadSpeed(
            gid,
            maxCount: dm.kMaxCount,
            periodSeconds: dm.kPeriodSeconds,
          );

          // 检查下载停滞状态
          downloadMonitor.checkDownloadStall(
            gid,
            checkMaxCount: dm.kCheckMaxCount,
            periodSeconds: dm.kPeriodSeconds,
            onRetryNeededCallback: (int gid) {
              logger.d('检测到下载停滞，正在重试 gid:$gid, 时间:${DateTime.now()}');

              // 执行重试
              Future<void>(() => galleryTaskPaused(gid, silent: true))
                  .then(
                      (_) => Future.delayed(const Duration(microseconds: 1000)))
                  .then((_) => galleryTaskResume(gid));
            },
          );

          // 更新UI
          _updateDownloadView(['DownloadGalleryItem_$gid']);
        }
      },
    );
  }

  // 初始化任务列表
  Future<void> initGalleryTasks() async {
    loggerSimple.d('开始初始化任务列表');

    await taskManager.initGalleryTasks(
      addGalleryTaskCallback: _addGalleryTask,
      downloadTaskMigrationCallback: downloadTaskMigration,
    );

    // 额外处理：找出所有应该继续的任务（已入队或运行中）
    final List<GalleryTask> tasksToResume = dState.galleryTasks
        .where((task) =>
            task.status == TaskStatus.enqueued.value ||
            task.status == TaskStatus.running.value)
        .toList();

    loggerSimple.d('找到需要继续的任务: ${tasksToResume.length}个');

    // 确保槽位管理器有这些任务的记录
    for (final task in tasksToResume) {
      loggerSimple.d('检查任务: gid=${task.gid}, 状态=${task.status}');
      if (!gallerySlotManager.isGalleryActive(task.gid) &&
          !gallerySlotManager.isGalleryWaiting(task.gid)) {
        loggerSimple.d('重新添加任务到槽位管理器: gid=${task.gid}');
        _addGalleryTask(task);
      } else {
        loggerSimple.d('任务已在槽位管理器中: gid=${task.gid}');
      }
    }

    loggerSimple.d('任务初始化完成');
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
  Future<void> _startImageTask({
    required GalleryTask galleryTask,
    int? groupCount,
    List<GalleryImage>? images,
  }) async {
    logger.d(
        '开始下载任务: gid=${galleryTask.gid}, 标题=${galleryTask.title}, 状态=${galleryTask.status}');

    // 如果完成数等于文件数 那么更新状态为完成
    if (galleryTask.completCount == galleryTask.fileCount) {
      logger.d(
          '任务已完成: gid=${galleryTask.gid}, 完成数=${galleryTask.completCount}/${galleryTask.fileCount}');
      await galleryTaskComplete(galleryTask.gid);
      _updateDownloadView(['DownloadGalleryItem_${galleryTask.gid}']);
      return;
    }

    // 初始化下载计时控制
    logger.d('初始化下载计时器: gid=${galleryTask.gid}');
    _initDownloadStateChkTimer(galleryTask.gid);

    final List<GalleryImageTask> imageTasksOri =
        await isarHelper.findImageTaskAllByGidIsolate(galleryTask.gid);
    logger.d('获取已有图片任务: gid=${galleryTask.gid}, 任务数=${imageTasksOri.length}');

    final completeCount = imageTasksOri
        .where((element) => element.status == TaskStatus.complete.value)
        .length;
    logger.d(
        '已完成图片数: gid=${galleryTask.gid}, 完成数=$completeCount/${imageTasksOri.length}');

    await isarHelper.putGalleryTaskIsolate(
        galleryTask.copyWith(completCount: completeCount));

    // 初始化下载Map
    final initCount = _initDownloadMapByGid(galleryTask.gid, images: images);
    logger.d('初始化下载Map: gid=${galleryTask.gid}, 初始数量=$initCount');

    final putCount = await _updateImageTasksByGid(galleryTask.gid);
    logger.d('更新图片任务到数据库: gid=${galleryTask.gid}, 更新数量=$putCount');

    logger.d('更新任务状态为running: gid=${galleryTask.gid}');
    galleryTaskUpdateStatus(galleryTask.gid, TaskStatus.running);

    _clearErrInfo(galleryTask.gid, updateView: false);

    final CancelToken cancelToken = CancelToken();
    dState.cancelTokenMap[galleryTask.gid] = cancelToken;

    final realDirPath = galleryTask.realDirPath;
    if (realDirPath == null) {
      logger.e('下载路径为空: gid=${galleryTask.gid}');
      return;
    }

    final String downloadParentPath = realDirPath;
    logger.d('下载父目录: gid=${galleryTask.gid}, path=$downloadParentPath');

    final List<int> completeSerList = imageTasksOri
        .where((element) => element.status == TaskStatus.complete.value)
        .map((e) => e.ser)
        .toList();

    final int maxCompleteSer =
        completeSerList.isNotEmpty ? completeSerList.reduce(max) : 0;
    logger.d('最大已完成序号: gid=${galleryTask.gid}, maxCompleteSer=$maxCompleteSer');

    // 循环进行下载图片
    logger.d('开始循环下载: gid=${galleryTask.gid}, 文件总数=${galleryTask.fileCount}');
    for (int index = 0; index < galleryTask.fileCount; index++) {
      final itemSer = index + 1;

      final oriImageTask =
          imageTasksOri.firstWhereOrNull((element) => element.ser == itemSer);
      if (oriImageTask?.status == TaskStatus.complete.value) {
        logger.t('图片已完成，跳过: gid=${galleryTask.gid}, ser=$itemSer');
        continue;
      }

      logger.t(
          '准备下载图片: gid=${galleryTask.gid}, ser=$itemSer/${galleryTask.fileCount}');

      if (groupCount == null || groupCount < 1) {
        logger.d('获取首页图片数量: gid=${galleryTask.gid}, url=${galleryTask.url}');
        groupCount = await imageProcessor.fetchFirstPageCount(
          galleryTask.url!,
          cancelToken: cancelToken,
        );
        logger.d('获取首页图片数量结果: gid=${galleryTask.gid}, fileCount=$groupCount');
      }

      final showKey = dState.showKeyMap[galleryTask.gid];

      if (index > 0 && showKey == null) {
        logger.d('等待showKey: gid=${galleryTask.gid}, index=$index');
        dState.showKeyCompleteMap[galleryTask.gid] = Completer<bool>.sync();
        await dState.showKeyCompleteMap[galleryTask.gid]?.future;
        logger.d(
            '获取到showKey: gid=${galleryTask.gid}, showKey=${dState.showKeyMap[galleryTask.gid]}');
      }

      dState.executor.scheduleTask(() async {
        logger.d('开始处理图片任务: gid=${galleryTask.gid}, ser=$itemSer');
        final GalleryImage? preImage =
            await imageProcessor.checkAndGetImageList(
          galleryTask.gid,
          itemSer,
          galleryTask.fileCount,
          groupCount!,
          galleryTask.url,
          cancelToken: cancelToken,
          addAllImagesCallback: _addAllImages,
          getImageObjCallback: _getImageObj,
        );

        if (preImage != null) {
          logger.t(
              '获取到图片信息: gid=${galleryTask.gid}, ser=$itemSer, imageUrl=${preImage.imageUrl}');
          final int maxSer = galleryTask.fileCount + 1;

          try {
            logger.t('开始下载图片: gid=${galleryTask.gid}, ser=$itemSer');
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
            logger.t('下载图片完成: gid=${galleryTask.gid}, ser=$itemSer');
          } on DioException catch (e) {
            // 忽略 [DioErrorType.cancel]
            if (!CancelToken.isCancel(e)) {
              logger.e(
                  '下载图片Dio错误: gid=${galleryTask.gid}, ser=$itemSer, error=$e');
              rethrow;
            }
            logger.t('下载图片取消: gid=${galleryTask.gid}, ser=$itemSer');
          } on EhError catch (e) {
            logger
                .e('下载图片EH错误: gid=${galleryTask.gid}, ser=$itemSer, error=$e');
            if (e.type == EhErrorType.image509) {
              show509Toast();
              _galleryTaskPausedAll();
              dState.executor.close();
              resetConcurrency();
              _updateErrInfo(galleryTask.gid, '509');
            }
            rethrow;
          } on HttpException catch (e) {
            logger.e(
                '下载图片HTTP错误: gid=${galleryTask.gid}, ser=$itemSer, error=$e');
            if (e is BadRequestException && e.code == 429) {
              show429Toast();
              _galleryTaskPausedAll();
              dState.executor.close();
              resetConcurrency();
              _updateErrInfo(galleryTask.gid, '429');
            }
            rethrow;
          } catch (e) {
            logger
                .e('下载图片未知错误: gid=${galleryTask.gid}, ser=$itemSer, error=$e');
            rethrow;
          }
        } else {
          logger.e('获取图片信息失败: gid=${galleryTask.gid}, ser=$itemSer');
        }
      });
    }
    logger.d('所有图片任务已加入队列: gid=${galleryTask.gid}');
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
    loggerSimple.d('画廊项目下载完成: gid=$gid, 序号=$itemSer, 文件=$fileName');

    // 下载完成 更新数据库明细
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

    loggerSimple.d(
        '已完成图片: gid=$gid, 数量=${listComplete.length}, 序号列表=${listComplete.map((e) => e.ser).join(',')}');

    final coverImg =
        listComplete.firstWhereOrNull((element) => element.ser == 1)?.filePath;
    loggerSimple.t('封面图片: gid=$gid, 路径=$coverImg');

    final GalleryTask? task = galleryTaskUpdate(
      gid,
      countComplete: listComplete.length,
      coverImg: coverImg,
    );

    if (task != null) {
      loggerSimple.d(
          '检查画廊是否完成: gid=$gid, 已完成=${listComplete.length}/${task.fileCount}');

      if (task.fileCount == listComplete.length) {
        loggerSimple
            .d('画廊任务全部完成: gid=$gid, ${listComplete.length}/${task.fileCount}');
        galleryTaskComplete(gid);
      } else {
        loggerSimple
            .d('画廊任务部分完成: gid=$gid, ${listComplete.length}/${task.fileCount}');
      }
    } else {
      logger.e('无法更新画廊任务: gid=$gid, 任务不存在');
    }

    if (task != null) {
      await isarHelper.putGalleryTask(task);
    }
    _updateDownloadView(['DownloadGalleryItem_$gid']);
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

  /// 设置同时下载的画廊数
  void setConcurrentGalleries(int count) {
    logger
        .d('请求设置同时下载画廊数: $count, 当前值: ${ehSettingService.concurrentGalleries}');

    if (count > 0 && count <= 5) {
      final int oldValue = ehSettingService.concurrentGalleries;
      ehSettingService.concurrentGalleries = count;
      logger.d('设置同时下载画廊数成功: $oldValue -> $count');

      logger.d('更新槽位管理器最大并发数: $count');
      gallerySlotManager.setMaxConcurrentGalleries(count);
      logger.d(
          '槽位管理器更新完成, 当前活动画廊: ${gallerySlotManager.activeGalleriesCount}, 等待数: ${gallerySlotManager.waitingCount}');
    } else {
      logger.e('设置同时下载画廊数失败: 值超出范围(1-5): $count');
    }
  }

  /// 设置最大下载图片线程数
  void setMultiDownload(int count) {
    loggerSimple
        .d('请求设置最大下载图片线程数: $count, 当前值: ${ehSettingService.multiDownload}');

    if (count > 0 && count <= 32) {
      final int oldValue = ehSettingService.multiDownload;
      ehSettingService.multiDownload = count;
      loggerSimple.d('设置最大下载图片线程数成功: $oldValue -> $count');

      // 重置并发设置，应用新的线程数
      resetConcurrency();
    } else {
      logger.e('设置最大下载图片线程数失败: 值超出范围(1-32): $count');
    }
  }
}
