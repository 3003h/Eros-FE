import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:fehviewer/common/controller/archiver_download_controller.dart';
import 'package:fehviewer/common/controller/download_controller.dart';
import 'package:fehviewer/common/epub/epub_builder.dart';
import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/common/isolate_download/download_manager.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/pages/tab/view/download_page.dart';
import 'package:fehviewer/route/routes.dart';
import 'package:fehviewer/store/floor/entity/gallery_image_task.dart';
import 'package:fehviewer/store/floor/entity/gallery_task.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/toast.dart';
import 'package:fehviewer/utils/utility.dart';
import 'package:fehviewer/utils/vibrate.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:share/share.dart';

enum DownloadType {
  gallery,
  archiver,
}

typedef FunctionExport = Future Function();

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

  Map<int, String> get downloadSpeedMap =>
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
                    _showExportSheet(task: task);
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

  Future<void> _showExportSheet({GalleryTask? task}) async {
    if (task == null) {
      return;
    }
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

                  _exportZip(context, task);
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
                  _exportEpub(context, task);
                },
                child: const Text(
                  'EPUB',
                ),
              ),
            ],
          );
        });
  }

  Future<String?> _exportZip(BuildContext context, GalleryTask task) async {
    logger.d('export zip , dir path ${task.dirPath}');
    if (task.dirPath == null) {
      return null;
    }

    final _zipPath = await _exportGallery(context, () => _compZip(task));

    if (_zipPath != null) {
      Share.shareFiles([_zipPath]);
    }
  }

  Future<String?> _compZip(GalleryTask task) async {
    final _tempPath = path.join(Global.tempPath, 'export_temp');
    Directory _tempDir = Directory(_tempPath);
    if (_tempDir.existsSync()) {
      _tempDir.deleteSync(recursive: true);
    }
    _tempDir.createSync(recursive: true);

    // 打包zip
    final encoder = ZipFileEncoder();
    final _zipPath =
        path.join(Global.tempPath, 'zip', '${task.gid}_${task.title}.zip');
    encoder.create(_zipPath);

    // 添加文件
    final _galleryDir = Directory(task.realDirPath!);
    for (final _file in _galleryDir.listSync()) {
      if ((await FileSystemEntity.type(_file.path)) ==
          FileSystemEntityType.file) {
        final srcFile = File(_file.path);
        // srcFile.copySync(path.join(_tempPath, path.basename(srcFile.path)));
        // logger.d('${_file.path}');
        encoder.addFile(srcFile);
      }
    }

    encoder.close();
    return _zipPath;
  }

  Future<String?> _exportEpub(BuildContext context, GalleryTask task) async {
    logger.d('export epub , dir path ${task.dirPath}');
    if (task.dirPath == null) {
      return null;
    }

    final _exportFilePath =
        await _exportGallery(context, () => _buildEpub(task));

    if (_exportFilePath != null) {
      Share.shareFiles([_exportFilePath]);
    }
  }

  Future<String?> _buildEpub(GalleryTask task) async {
    final _tempPath = await buildEpub(task);

    // 打包epub文件
    final encoder = ZipFileEncoder();
    final _epubPath =
        path.join(Global.tempPath, 'epub', '${task.gid}_${task.title}.epub');
    encoder.create(_epubPath);
    encoder.addDirectory(Directory(_tempPath), includeDirName: false);
    encoder.close();

    return _epubPath;
  }

  // gallery 暂停任务
  void pauseGalleryDownload(int? gid) {
    if (gid != null) {
      _downloadController.galleryTaskPaused(gid);
    }
    update(['${idDownloadGalleryItem}_$gid']);
  }

  // gallery 恢复任务
  void resumeGalleryDownload(int? gid) {
    if (gid != null) {
      _downloadController.galleryTaskResume(gid);
    }
    update(['${idDownloadGalleryItem}_$gid']);
  }

  Future<String?> _writeTaskInfoFile() async {
    // 创建zip文件
    final encoder = ZipFileEncoder();
    final _zipPath = _getLocalFilePath();
    encoder.create(_zipPath);

    // 添加文件
    final srcFile = File(Global.dbPath);
    encoder.addFile(srcFile);

    encoder.close();
    return _zipPath;
  }

  String _getLocalFilePath() {
    final DateTime _now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyyMMdd_HHmmss');
    final String _nowTime = formatter.format(_now);
    return path.join(Global.appDocPath, 'FEhDownloadTask_$_nowTime.zip');
  }

  Future shareTaskInfoFile() async {
    final _tempFilePath = await _writeTaskInfoFile();
    if (_tempFilePath != null) {
      Share.shareFiles([_tempFilePath]);
    }
  }

  Future exportTaskInfoFile() async {
    try {
      final _tempFilePath = await _writeTaskInfoFile();
      await requestManageExternalStoragePermission();
      if (_tempFilePath != null) {
        final _saveToDirPath = await FilePicker.platform.getDirectoryPath();
        logger.d('$_saveToDirPath');
        if (_saveToDirPath != null) {
          final _dstPath =
              path.join(_saveToDirPath, path.basename(_tempFilePath));
          File(_tempFilePath).copySync(_dstPath);
        }
      }
    } catch (e) {
      showToast('$e');
      rethrow;
    }
  }

  Future importTaskInfoFile() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      final File _file = File(result.files.single.path!);
    }
  }
}

Future<String?> _exportGallery(
  BuildContext context,
  FunctionExport funExport, {
  FunctionExport? funcCancel,
}) async {
  Future<String?> _showExportDialog() async {
    return await showCupertinoDialog<String?>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(L10n.of(context).processing),
          content: GetBuilder<DownloadViewController>(
            initState: (state) async {
              final _path = await funExport();
              Get.back(result: _path);
            },
            builder: (logic) {
              return const CupertinoActivityIndicator(radius: 16);
            },
          ).paddingOnly(top: 10.0),
          actions: [
            CupertinoDialogAction(
              child: Text(
                L10n.of(context).cancel,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.destructiveRed),
              ),
              onPressed: () {
                funcCancel?.call();
                Get.back();
              },
            ),
          ],
        );
      },
    );
  }

  return await _showExportDialog();
}
