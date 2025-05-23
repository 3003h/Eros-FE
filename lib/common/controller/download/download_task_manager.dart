import 'dart:io';

import 'package:eros_fe/common/controller/cache_controller.dart';
import 'package:eros_fe/common/controller/download/storage_adapter.dart';
import 'package:eros_fe/common/controller/download_state.dart';
import 'package:eros_fe/index.dart';
import 'package:eros_fe/network/api.dart';
import 'package:eros_fe/store/db/entity/gallery_task.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_storage/shared_storage.dart' as ss;

@immutable
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
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is TaskStatus && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() {
    return 'TaskStatus{value: $value}';
  }
}

class DownloadTaskManager {
  DownloadTaskManager(this.dState, {StorageAdapter? storageAdapter})
      : storageAdapter = storageAdapter ?? StorageAdapter();
  final DownloadState dState;
  final CacheController cacheController = Get.find();
  final StorageAdapter storageAdapter;

  /// 更新任务为已完成
  Future<GalleryTask?> galleryTaskComplete(int gid,
      {Function? cancelTimerCallback}) async {
    if (dState.galleryTaskMap[gid]?.status == TaskStatus.complete.value) {
      return null;
    }
    logger.t('更新任务为已完成');
    // 调用传入的回调取消定时器
    if (cancelTimerCallback != null) {
      Function.apply(cancelTimerCallback, [gid]);
    }

    if (!(dState.taskCancelTokens[gid]?.isCancelled ?? true)) {
      dState.taskCancelTokens[gid]?.cancel();
    }

    final galleryTask = await galleryTaskUpdateStatus(gid, TaskStatus.complete);

    // 写入任务信息文件
    await storageAdapter.writeTaskInfoFile(galleryTask);

    return galleryTask;
  }

  /// 暂停任务
  Future<GalleryTask?> galleryTaskPaused(int gid,
      {bool silent = false, Function? cancelTimerCallback}) async {
    // 调用传入的回调取消定时器
    if (cancelTimerCallback != null) {
      Function.apply(cancelTimerCallback, [gid]);
    }

    logger.t('${dState.cancelTokenMap[gid]?.isCancelled}');
    if (!(dState.cancelTokenMap[gid]?.isCancelled ?? true)) {
      dState.cancelTokenMap[gid]?.cancel();
    }
    if (silent) {
      return null;
    }

    return galleryTaskUpdateStatus(gid, TaskStatus.paused);
  }

  /// 恢复任务
  Future<void> galleryTaskResume(int gid,
      {Function? addGalleryTaskCallback}) async {
    final GalleryTask? galleryTask =
        await isarHelper.findGalleryTaskByGidIsolate(gid);
    if (galleryTask != null) {
      logger.d('恢复任务 $gid showKey:${galleryTask.showKey}');
      if (addGalleryTaskCallback != null) {
        Function.apply(addGalleryTaskCallback, [galleryTask]);
      }
    }
  }

  /// 重下任务
  Future<void> galleryTaskRestart(int gid,
      {Function? addGalleryTaskCallback}) async {
    isarHelper.removeImageTask(gid);

    final GalleryTask? galleryTask =
        await isarHelper.findGalleryTaskByGidIsolate(gid);
    if (galleryTask != null) {
      logger.d('重下任务 $gid ${galleryTask.url}');
      cacheController.clearDioCache(
          path: '${Api.getBaseUrl()}${galleryTask.url}');
      final reTask = galleryTask.copyWith(completCount: 0);
      dState.galleryTaskMap[gid] = reTask;
      if (addGalleryTaskCallback != null) {
        Function.apply(addGalleryTaskCallback, [reTask]);
      }
    }
  }

  /// 更新任务进度
  GalleryTask? galleryTaskUpdate(
    int gid, {
    int? countComplete,
    String? coverImg,
  }) {
    logger.t('galleryTaskCountUpdate gid:$gid count:$countComplete');
    dState.curComplete[gid] = countComplete ?? 0;

    if (!dState.galleryTaskMap.containsKey(gid)) {
      return null;
    }

    dState.galleryTaskMap[gid] = dState.galleryTaskMap[gid]!.copyWith(
      completCount: countComplete,
      coverImage: coverImg,
    );

    final task = dState.galleryTaskMap[gid];
    if (task != null) {
      isarHelper.putGalleryTaskIsolate(task);
    }

    return dState.galleryTaskMap[gid];
  }

  /// 更新任务状态
  Future<GalleryTask?> galleryTaskUpdateStatus(
    int gid,
    TaskStatus status,
  ) async {
    if (dState.galleryTaskMap.containsKey(gid) &&
        dState.galleryTaskMap[gid] != null) {
      dState.galleryTaskMap[gid] =
          dState.galleryTaskMap[gid]!.copyWith(status: status.value);
      logger.t('set $gid status $status');

      final task = dState.galleryTaskMap[gid];
      if (task != null) {
        isarHelper.putGalleryTaskIsolate(task);
      }
    }

    return dState.galleryTaskMap[gid];
  }

  /// 移除任务
  Future<void> removeDownloadGalleryTask({
    required int gid,
    bool shouldDeleteContent = true,
  }) async {
    // 查找任务
    final GalleryTask? task = dState.galleryTaskMap[gid];
    if (task == null) {
      return;
    }

    // 取消任务
    if (!(dState.cancelTokenMap[task.gid]?.isCancelled ?? true)) {
      dState.cancelTokenMap[task.gid]?.cancel();
    }

    dState.galleryTaskMap.remove(gid);

    // 删除文件
    String? dirPath = task.realDirPath;
    logger.t('dirPath: $dirPath');
    if (dirPath != null && shouldDeleteContent) {
      if (dirPath.isContentUri) {
        // SAF
        ss.delete(Uri.parse(dirPath));
      } else {
        final dir = Directory(dirPath);
        // if (await dir.exists()) {
        //   await dir.delete(recursive: true);
        // }
        dir.exists().then((value) => dir.delete(recursive: true));
      }
    }

    // 删除数据库记录
    isarHelper.removeImageTask(task.gid);
    isarHelper.removeGalleryTask(task.gid);
  }

  // 初始化任务列表
  Future<void> initGalleryTasks(
      {Function? addGalleryTaskCallback,
      Function? downloadTaskMigrationCallback}) async {
    if (downloadTaskMigrationCallback != null) {
      await Function.apply(downloadTaskMigrationCallback, []);
    }

    final tasks = await isarHelper.findAllGalleryTasksIsolate();

    // 添加到map中
    for (final task in tasks) {
      dState.galleryTaskMap[task.gid] = task;
    }

    // 继续未完成的任务
    for (final task in tasks) {
      if (task.status == TaskStatus.running.value) {
        logger.d('继续未完成的任务');
        if (addGalleryTaskCallback != null) {
          Function.apply(addGalleryTaskCallback, [task]);
        }
      }
    }
  }

  Future<void> restoreGalleryTasks({
    bool init = false,
    Function? getDownloadPathCallback,
    Function? restoreTasksWithPathCallback,
    Function? restoreTasksWithSAFCallback,
    Function? onInitCallback,
    Function? resetDownloadViewAnimationKeyCallback,
  }) async {
    if (getDownloadPathCallback == null) {
      return;
    }

    final String currentDownloadPath =
        await Function.apply(getDownloadPathCallback, []);
    logger.d('_currentDownloadPath: $currentDownloadPath');

    if (currentDownloadPath.isContentUri) {
      if (restoreTasksWithSAFCallback != null) {
        await Function.apply(
            restoreTasksWithSAFCallback, [currentDownloadPath]);
      }
    } else {
      if (restoreTasksWithPathCallback != null) {
        await Function.apply(
            restoreTasksWithPathCallback, [currentDownloadPath]);
      }
    }

    if (init) {
      if (onInitCallback != null) {
        Function.apply(onInitCallback, []);
      }
      if (resetDownloadViewAnimationKeyCallback != null) {
        Function.apply(resetDownloadViewAnimationKeyCallback, []);
      }
    }
  }
}
