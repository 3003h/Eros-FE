import 'package:fehviewer/common/controller/archiver_download_controller.dart';
import 'package:fehviewer/common/controller/download_controller.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/models/index.dart';
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

class DownloadViewController extends GetxController {
  final ArchiverDownloadController _archiverDownloadController = Get.find();
  final DownloadController _downloadController = Get.find();

  PageController pageController = PageController();

  void handOnPageChange(int value) {
    viewType = pageList[value];
  }

  List<DownloadType> pageList = <DownloadType>[
    DownloadType.gallery,
    DownloadType.archiver,
  ];

  final Rx<DownloadType> _viewType = DownloadType.gallery.obs;

  DownloadType get viewType => _viewType.value;

  set viewType(DownloadType val) {
    final int _index = pageList.indexOf(val);
    pageController.animateToPage(_index,
        duration: const Duration(milliseconds: 300), curve: Curves.ease);
    _viewType.value = val;
  }

  List<DownloadTaskInfo> get archiverTasks =>
      _archiverDownloadController.archiverTaskMap.entries
          .map((MapEntry<String, DownloadTaskInfo> e) => e.value)
          .toList();

  List<GalleryTask> get galleryTasks => _downloadController.galleryTaskList;

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
    if (_newTaskId != null && archiverTasks[index].tag != null) {
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
    if (_newTaskId != null && archiverTasks[index].tag != null) {
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
    _archiverDownloadController.archiverTaskMap.remove(_tag);
    FlutterDownloader.remove(
        taskId: _oriTaskid ?? '', shouldDeleteContent: true);
  }

  // Gallery 移除任务
  void removeGalleryTask(int index) {
    _downloadController.removeDownloadGalleryTask(index: index);
  }

  void onLongPress(int index, {DownloadType type = DownloadType.gallery}) {
    vibrateUtil.heavy();
    _showLongPressSheet(index, type);
  }

  /// 长按菜单
  Future<void> _showLongPressSheet(int taskIndex, DownloadType type) async {
    final BuildContext context = Get.context!;

    await showCupertinoModalPopup<void>(
        context: context,
        builder: (BuildContext context) {
          return CupertinoActionSheet(
            cancelButton: CupertinoActionSheetAction(
                onPressed: () {
                  Get.back();
                },
                child: Text(S.of(context).cancel)),
            actions: <Widget>[
              CupertinoActionSheetAction(
                onPressed: () {
                  type == DownloadType.archiver
                      ? removeArchiverTask(taskIndex)
                      : removeGalleryTask(taskIndex);
                  Get.back();
                },
                child: const Text('删除任务'),
              ),
            ],
          );
        });
  }
}
