import 'package:fehviewer/common/controller/archiver_download_controller.dart';
import 'package:fehviewer/common/controller/download_controller.dart';
import 'package:fehviewer/common/isolate_download/download_manager.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/pages/tab/view/download_page.dart';
import 'package:fehviewer/route/routes.dart';
import 'package:fehviewer/store/floor/entity/gallery_image_task.dart';
import 'package:fehviewer/store/floor/entity/gallery_task.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/vibrate.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';

enum DownloadType {
  gallery,
  archiver,
}

const String idDownloadGalleryView = 'DownloadGalleryView';
const String idDownloadArchiverView = 'DownloadArchiverView';
const String idDownloadGalleryItem = 'DownloadGalleryItem';
const String idDownloadArchiverItem = 'DownloadArchiverItem';

class DownloadViewController extends GetxController {
  final ArchiverDownloadController _archiverDownloadController = Get.find();
  final DownloadController _downloadController = Get.find();

  final GlobalKey<AnimatedListState> animatedGalleryListKey =
      GlobalKey<AnimatedListState>();

  final GlobalKey<AnimatedListState> animatedArchiverListKey =
      GlobalKey<AnimatedListState>();

  late String tabTag;

  @override
  void onInit() {
    super.onInit();
    tabTag = EHRoutes.download;
  }

  List<DownloadType> pageList = <DownloadType>[
    DownloadType.gallery,
    DownloadType.archiver,
  ];

  List<DownloadTaskInfo> get archiverTasks =>
      _archiverDownloadController.archiverTaskMap.entries
          .map((MapEntry<String, DownloadTaskInfo> e) => e.value)
          .toList();

  Map<int, GalleryTask> get galleryTaskMap =>
      _downloadController.dState.galleryTaskMap;

  List<GalleryTask> get galleryTasks {
    final tasks = _downloadController.dState.galleryTasks;
    tasks.sort((GalleryTask a, GalleryTask b) {
      return (b.addTime ?? 0) - (a.addTime ?? 0);
    });
    return tasks;
  }

  Map<int, String> get downloadSpeeds =>
      _downloadController.dState.downloadSpeeds;

  Future<List<GalleryImageTask>> getImageTasks(int gid) async {
    return await _downloadController.getImageTasks(gid);
  }

  // Archiver暂停任务
  Future<void> pauseArchiverDownload({required String? taskId}) async {
    if (taskId != null) FlutterDownloader.pause(taskId: taskId);
  }

  // Archiver取消任务
  Future<void> cancelArchiverDownload({required String? taskId}) async {
    if (taskId != null) FlutterDownloader.cancel(taskId: taskId);
  }

  // Archiver恢复任务
  Future<void> resumeArchiverDownload(int index) async {
    final String? _oriTaskid = archiverTasks[index].taskId;
    final int? _oriStatus = archiverTasks[index].status;

    String? _newTaskId = '';
    if (_oriStatus == DownloadTaskStatus.paused.value) {
      _newTaskId = await FlutterDownloader.resume(taskId: _oriTaskid ?? '');
    } else if (_oriStatus == DownloadTaskStatus.failed.value) {
      await FlutterDownloader.retry(taskId: _oriTaskid ?? '');
    }

    logger.d('oritaskid $_oriTaskid,  newID $_newTaskId');
    if (_newTaskId != null &&
        _newTaskId.isNotEmpty &&
        archiverTasks[index].tag != null) {
      _archiverDownloadController.archiverTaskMap[archiverTasks[index].tag!] =
          _archiverDownloadController
              .archiverTaskMap[archiverTasks[index].tag!]!
              .copyWith(taskId: _newTaskId);
    }
  }

  // Archiver重试任务
  Future<void> retryArchiverDownload(int index) async {
    final String? _oriTaskid = archiverTasks[index].taskId;
    final int? _oriStatus = archiverTasks[index].status;

    String? _newTaskId = '';
    if (_oriStatus == DownloadTaskStatus.paused.value) {
      _newTaskId = await FlutterDownloader.retry(taskId: _oriTaskid ?? '');
    } else if (_oriStatus == DownloadTaskStatus.failed.value) {
      await FlutterDownloader.retry(taskId: _oriTaskid ?? '');
    }

    logger.d('oritaskid $_oriTaskid,  newID $_newTaskId');
    if (_newTaskId != null &&
        _newTaskId.isNotEmpty &&
        archiverTasks[index].tag != null) {
      _archiverDownloadController.archiverTaskMap[archiverTasks[index].tag!] =
          _archiverDownloadController
              .archiverTaskMap[archiverTasks[index].tag!]!
              .copyWith(taskId: _newTaskId);
    }
  }

  // Archiver移除任务
  void removeArchiverTask(int index) {
    final String? _oriTaskid = archiverTasks[index].taskId;
    final String? _tag = archiverTasks[index].tag;

    animatedArchiverListKey.currentState?.removeItem(
        index,
        (context, animation) =>
            downloadArchiverDelItemBuilder(context, index, animation));

    // _archiverDownloadController.archiverTaskMap.remove(_tag);
    _archiverDownloadController.removeTask(_tag);
    FlutterDownloader.remove(
        taskId: _oriTaskid ?? '', shouldDeleteContent: true);
    update([idDownloadArchiverView]);
  }

  // Gallery 移除任务
  void removeGalleryTask(int index) {
    final GalleryTask _task = galleryTasks[index];
    _downloadController.removeDownloadGalleryTask(gid: _task.gid);
    animatedGalleryListKey.currentState?.removeItem(
        index,
        (context, animation) =>
            downloadDelItemBuilder(context, index, animation));
    update([idDownloadGalleryView]);
  }

  void animateGalleryListAddTask() {
    animatedGalleryListKey.currentState?.insertItem(galleryTasks.length - 1);
  }

  void animateArchiverListAddTask() {
    animatedArchiverListKey.currentState?.insertItem(archiverTasks.length - 1);
  }

  void onLongPress(
    int index, {
    DownloadType type = DownloadType.gallery,
    GalleryTask? task,
  }) {
    vibrateUtil.heavy();
    _showLongPressSheet(index, type, task: task);
  }

  /// 长按菜单
  Future<void> _showLongPressSheet(
    int taskIndex,
    DownloadType type, {
    GalleryTask? task,
  }) async {
    final BuildContext context = Get.context!;

    await showCupertinoModalPopup<void>(
        context: context,
        builder: (BuildContext context) {
          return CupertinoActionSheet(
            cancelButton: CupertinoActionSheetAction(
                onPressed: () {
                  Get.back();
                },
                child: Text(L10n.of(context).cancel)),
            actions: <Widget>[
              // 导出
              if (task?.status == TaskStatus.complete.value)
                CupertinoActionSheetAction(
                  onPressed: () {
                    Get.back();
                    _showExportSheet(taskIndex);
                  },
                  child: Text(
                    L10n.of(context).export,
                  ),
                ),
              // 删除下载项
              CupertinoActionSheetAction(
                onPressed: () {
                  type == DownloadType.archiver
                      ? removeArchiverTask(taskIndex)
                      : removeGalleryTask(taskIndex);
                  Get.back();
                },
                child: Text(
                  L10n.of(context).delete,
                  style: const TextStyle(color: CupertinoColors.destructiveRed),
                ),
              ),
            ],
          );
        });
  }

  Future<void> _showExportSheet(int taskIndex) async {
    await showCupertinoModalPopup<void>(
        context: Get.context!,
        builder: (BuildContext context) {
          return CupertinoActionSheet(
            cancelButton: CupertinoActionSheetAction(
                onPressed: () {
                  Get.back();
                },
                child: Text(L10n.of(context).cancel)),
            actions: <Widget>[
              // ZIP
              CupertinoActionSheetAction(
                onPressed: () {
                  logger.d('导出zip');
                  Get.back();
                },
                child: const Text(
                  'ZIP',
                ),
              ),
              // ZIP
              CupertinoActionSheetAction(
                onPressed: () {
                  logger.d('导出epub');
                  Get.back();
                },
                child: const Text(
                  'EPUB',
                ),
              ),
            ],
          );
        });
  }

  // gallery 暂停任务
  void pauseGalleryDownload(int? gid) {
    if (gid != null) _downloadController.galleryTaskPaused(gid);
    update(['${idDownloadGalleryItem}_$gid']);
  }

  // gallery 恢复任务
  void resumeGalleryDownload(int? gid) {
    if (gid != null) _downloadController.galleryTaskResume(gid);
    update(['${idDownloadGalleryItem}_$gid']);
  }
}
