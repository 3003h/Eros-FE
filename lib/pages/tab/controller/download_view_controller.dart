import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:fehviewer/common/controller/archiver_download_controller.dart';
import 'package:fehviewer/common/controller/download_controller.dart';
import 'package:fehviewer/common/epub/epub_builder.dart';
import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/const/const.dart';
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
import 'package:flutter/foundation.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:restart_app/restart_app.dart';
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

const String viewTypeStoreKey = 'DownloadView.viewType';

class DownloadViewController extends GetxController {
  late final ArchiverDownloadController _archiverDownloadController;

  final DownloadController _downloadController = Get.find();

  late GlobalKey<AnimatedListState> animatedGalleryListKey =
      GlobalKey<AnimatedListState>();

  final GlobalKey<AnimatedListState> animatedArchiverListKey =
      GlobalKey<AnimatedListState>();

  late String tabTag;

  final _viewType = DownloadType.gallery.obs;
  DownloadType get viewType => _viewType.value;
  set viewType(DownloadType val) => _viewType.value = val;

  @override
  void onInit() {
    super.onInit();
    if (GetPlatform.isMobile) {
      _archiverDownloadController = Get.find();
    }
    tabTag = EHRoutes.download;

    viewType = EnumToString.fromString(DownloadType.values,
            hiveHelper.getString(viewTypeStoreKey) ?? '') ??
        viewType;
    ever<DownloadType>(
        _viewType, (val) => hiveHelper.setString(viewTypeStoreKey, val.name));
  }

  List<DownloadType> pageList = <DownloadType>[
    DownloadType.gallery,
    DownloadType.archiver,
  ];

  List<DownloadArchiverTaskInfo> get archiverTasks =>
      _archiverDownloadController.archiverTaskMap.entries
          .map((e) => e.value)
          .toList()
          .reversed
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

    String? _newTaskId;
    if (_oriStatus == DownloadTaskStatus.paused.value) {
      _newTaskId = await FlutterDownloader.resume(taskId: _oriTaskid ?? '');
    } else if (_oriStatus == DownloadTaskStatus.failed.value) {
      _newTaskId = await FlutterDownloader.retry(taskId: _oriTaskid ?? '');
    }

    if (_newTaskId == null) {
      return;
    }

    logger.d('oriTaskid $_oriTaskid,  newTaskId $_newTaskId');
    if (_newTaskId.isNotEmpty && archiverTasks[index].tag != null) {
      _archiverDownloadController.archiverTaskMap[archiverTasks[index].tag!] =
          _archiverDownloadController
              .archiverTaskMap[archiverTasks[index].tag!]!
              .copyWith(taskId: _newTaskId);
    }
  }

  // Archiver重试任务
  Future<void> retryArchiverDownload(int index) async {
    logger.d('Archiver重试任务');
    final _oriTask = archiverTasks[index];
    final String? _oriTaskid = _oriTask.taskId;
    final int? _oriStatus = archiverTasks[index].status;

    String? _newTaskId;
    if (_oriStatus == DownloadTaskStatus.paused.value) {
      _newTaskId = await FlutterDownloader.retry(taskId: _oriTaskid ?? '');
    } else if (_oriStatus == DownloadTaskStatus.failed.value) {
      _newTaskId = await FlutterDownloader.retry(taskId: _oriTaskid ?? '');
    }

    if (_newTaskId == null || _newTaskId.isEmpty) {
      // await retryArchiverDownload(index);
      logger.d('url ${_oriTask.gid} ${_oriTask.url}');
      return;
    }

    logger.d('oriTaskid $_oriTaskid, newTaskid $_newTaskId');
    if (_newTaskId.isNotEmpty && archiverTasks[index].tag != null) {
      _archiverDownloadController.archiverTaskMap[archiverTasks[index].tag!] =
          _archiverDownloadController
              .archiverTaskMap[archiverTasks[index].tag!]!
              .copyWith(taskId: _newTaskId);
    }
  }

  // Archiver移除任务
  void removeArchiverTask(
    int index, {
    bool shouldDeleteContent = true,
  }) {
    final String? _oriTaskid = archiverTasks[index].taskId;
    final String? _tag = archiverTasks[index].tag;

    animatedArchiverListKey.currentState?.removeItem(
        index,
        (context, animation) =>
            downloadArchiverDelItemBuilder(context, index, animation));

    // _archiverDownloadController.archiverTaskMap.remove(_tag);
    _archiverDownloadController.removeTask(_tag);
    FlutterDownloader.remove(
      taskId: _oriTaskid ?? '',
      shouldDeleteContent: shouldDeleteContent,
    );
    update([idDownloadArchiverView]);
  }

  // 打开Archiver文件
  Future<void> openArchiverTaskFile(int index) async {
    final String? _oriTaskid = archiverTasks[index].taskId;

    // final _result = await OpenFile.open('');
    FlutterDownloader.open(
      taskId: _oriTaskid ?? '',
    );
  }

  // 导出Archiver文件
  Future<void> exportArchiverTaskFile(int index) async {
    final String? _oriTaskid = archiverTasks[index].taskId;

    // final _result = await OpenFile.open('');
    FlutterDownloader.open(
      taskId: _oriTaskid ?? '',
    );
  }

  // Gallery 移除任务
  void removeGalleryTask(
    int index, {
    bool shouldDeleteContent = true,
  }) {
    final GalleryTask _task = galleryTasks[index];
    _downloadController.removeDownloadGalleryTask(
      gid: _task.gid,
      shouldDeleteContent: shouldDeleteContent,
    );
    animatedGalleryListKey.currentState?.removeItem(
        index,
        (context, animation) =>
            downloadDelItemBuilder(context, index, animation));
    update([idDownloadGalleryView]);
  }

  void animateGalleryListAddTask() {
    animatedGalleryListKey.currentState?.insertItem(galleryTasks.length - 1);
  }

  void animateArchiverListAddTask({int? index}) {
    animatedArchiverListKey.currentState
        ?.insertItem(index ?? archiverTasks.length - 1);
  }

  void onLongPress(
    int index, {
    DownloadType type = DownloadType.gallery,
    GalleryTask? task,
  }) {
    vibrateUtil.medium();
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
              if (type == DownloadType.archiver)
                CupertinoActionSheetAction(
                  onPressed: () {
                    Get.back();
                    openArchiverTaskFile(taskIndex);
                  },
                  child: Text(
                    L10n.of(context).open_with_other_apps,
                  ),
                ),
              // gallery重新下载
              if (type == DownloadType.gallery)
                CupertinoActionSheetAction(
                  onPressed: () {
                    Get.back();
                    restartGalleryDownload(task?.gid);
                  },
                  child: Text(
                    L10n.of(context).redownload,
                  ),
                ),
              // gallery导出
              if (type == DownloadType.gallery &&
                  task?.status == TaskStatus.complete.value)
                CupertinoActionSheetAction(
                  onPressed: () {
                    Get.back();
                    _showExportSheet(task: task);
                  },
                  child: Text(
                    L10n.of(context).export,
                  ),
                ),
              // if (type == DownloadType.archiver &&
              //     archiverTasks[taskIndex].status ==
              //         DownloadTaskStatus.complete.value)
              //   CupertinoActionSheetAction(
              //     onPressed: () {
              //       Get.back();
              //       exportArchiverTaskFile(taskIndex);
              //     },
              //     child: Text(
              //       L10n.of(context).export,
              //     ),
              //   ),
              // 删除
              CupertinoActionSheetAction(
                onPressed: () {
                  Get.back();
                  _showDeleteDialog(taskIndex, type);
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

  Future<void> _showDeleteDialog(int taskIndex, DownloadType type) async {
    return showCupertinoDialog<void>(
      context: Get.overlayContext!,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(L10n.of(context).delete_task),
          // content: const Text('Import and Export download task'),
          actions: [
            CupertinoDialogAction(
              onPressed: () async {
                Get.back();
                type == DownloadType.archiver
                    ? removeArchiverTask(taskIndex, shouldDeleteContent: false)
                    : removeGalleryTask(taskIndex, shouldDeleteContent: false);
              },
              child: Text(
                L10n.of(context).delete_task_only,
                style: const TextStyle(color: CupertinoColors.destructiveRed),
              ),
            ),
            CupertinoDialogAction(
              onPressed: () async {
                Get.back();
                type == DownloadType.archiver
                    ? removeArchiverTask(taskIndex)
                    : removeGalleryTask(taskIndex);
              },
              child: Text(
                L10n.of(context).delete_task_and_content,
                style: const TextStyle(color: CupertinoColors.destructiveRed),
              ),
            ),
            CupertinoDialogAction(
              onPressed: () async {
                Get.back();
              },
              child: Text(L10n.of(context).cancel),
            ),
          ],
        );
      },
    );
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
    loggerTime.d('start buildEpub');
    final _tempEpubPath = await buildEpub(task);
    loggerTime.d('end buildEpub');

    final title = task.title.replaceAll(RegExp(r'[/:*"<>|]'), '_');

    // 打包epub文件
    final _epubPath =
        path.join(Global.tempPath, 'epub', '${task.gid}_$title.epub');
    // compactZip(_epubPath, _tempEpubPath);
    await compute(isolateCompactDirToZip, [_epubPath, _tempEpubPath]);

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

  // gallery 重新下载
  void restartGalleryDownload(int? gid) {
    if (gid != null) {
      _downloadController.galleryTaskRestart(gid);
    }
    update(['${idDownloadGalleryItem}_$gid']);
  }

  Future<String?> _writeTaskInfoFile() async {
    // 创建zip文件
    final encoder = ZipFileEncoder();
    final _zipPath = _getLocalFilePath();
    encoder.create(_zipPath);

    // 临时db
    final tempDBPath = path.join(Global.tempPath, 'export', EHConst.DB_NAME);
    final tempDBFile = File(tempDBPath);
    if (tempDBFile.existsSync()) {
      tempDBFile.deleteSync(recursive: true);
    }

    final ehDb = await Global.getDatabase();
    final allImageTasks = await ehDb.imageTaskDao.findAllTasks();
    final allTasks = await ehDb.galleryTaskDao.findAllGalleryTasks();

    // 导出任务数据表到临时db中
    final tempDB = await Global.getDatabase(path: tempDBPath);
    await tempDB.imageTaskDao.insertOrReplaceImageTasks(allImageTasks);
    await tempDB.galleryTaskDao.insertOrReplaceTasks(allTasks);
    tempDB.close();

    // 添加文件
    encoder.addFile(tempDBFile);

    encoder.close();
    return _zipPath;
  }

  Future<void> _readTaskInfoFile(File importFile) async {
    final decoder = ZipDecoder();
    final archive = decoder.decodeBytes(importFile.readAsBytesSync());
    final archivePath = path.join(Global.tempPath, 'archive');

    for (final file in archive) {
      final filename = file.name;
      if (file.isFile && filename == EHConst.DB_NAME) {
        final data = file.content as List<int>;
        File(path.join(archivePath, filename))
          ..createSync(recursive: true)
          ..writeAsBytesSync(data);
      } else {
        Directory(path.join(archivePath, filename)).create(recursive: true);
      }
    }

    final _pathImportDB = path.join(archivePath, EHConst.DB_NAME);
    final _importDBFile = File(_pathImportDB);
    if (!_importDBFile.existsSync()) {
      return;
    }

    final importDb = await Global.getDatabase(path: _pathImportDB);
    final allImageTasks = await importDb.imageTaskDao.findAllTasks();
    final allTasks = await importDb.galleryTaskDao.findAllGalleryTasks();

    logger.d('import task ${allTasks.length}');

    // 从临时db导入任务数据
    final ehDB = await Global.getDatabase();

    final taskMap = <int, GalleryTask?>{};
    final taskCompletMap = <int, int>{};

    // 导入 imagetask
    for (final imageTask in allImageTasks) {
      late GalleryTask? _task;
      if (taskMap[imageTask.gid] != null) {
        _task = taskMap[imageTask.gid];
      } else {
        _task = allTasks
            .firstWhereOrNull((element) => element.gid == imageTask.gid);
        taskMap[imageTask.gid] = _task;
      }
      if (_task == null || _task.realDirPath == null) {
        continue;
      }

      final _filePath = path.join(_task.realDirPath!, imageTask.filePath);
      // logger.d(_filePath);

      taskCompletMap.putIfAbsent(imageTask.gid, () => 0);
      if (File(_filePath).existsSync()) {
        // logger.d(
        //     'insertOrReplaceImageTask complete ${imageTask.gid}/${imageTask.filePath}');
        await ehDB.imageTaskDao.insertOrReplaceImageTask(
            imageTask.copyWith(status: TaskStatus.complete.value));
        taskCompletMap.update(imageTask.gid, (val) => val + 1,
            ifAbsent: () => 1);
      } else {
        // logger.d(
        //     'insertOrReplaceImageTask enqueued ${imageTask.gid}/${imageTask.filePath}');
        await ehDB.imageTaskDao.insertOrReplaceImageTask(
            imageTask.copyWith(status: TaskStatus.enqueued.value));
      }
    }

    // 导入task
    final allOriTasks = await ehDB.galleryTaskDao.findAllGalleryTasks();
    for (final task in allTasks) {
      GalleryTask? _oriTask =
          allOriTasks.firstWhereOrNull((element) => element.gid == task.gid);
      // 插入新的任务
      if (_oriTask == null) {
        final _task = task.copyWith(
          coverImage: '',
          status: TaskStatus.paused.value,
          completCount: taskCompletMap[task.gid] ?? 0,
        );
        logger.d('insert ${_task.toString()}');
        await ehDB.galleryTaskDao.insertTask(_task);
        _downloadController.dState.galleryTaskMap[_task.gid] = _task;
        animateGalleryListAddTask();
      }
    }
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
    await requestManageExternalStoragePermission();

    final FilePickerResult? result = await FilePicker.platform.pickFiles();
    logger.d('import file $result');
    if (result != null) {
      final File _file = File(result.files.single.path!);
      await _readTaskInfoFile(_file);
      _downloadController.initGalleryTasks();
      update([idDownloadGalleryView]);
      // await _showRestartAppDialog();

      // 更新 animatedGalleryListKey
      animatedGalleryListKey = GlobalKey<AnimatedListState>();
    }
  }
}

Future<void> _showRestartAppDialog() async {
  return showCupertinoDialog<void>(
    context: Get.overlayContext!,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return CupertinoAlertDialog(
        title: const Text('Restart App'),
        content: const Text('重启应用以生效?'),
        actions: [
          CupertinoDialogAction(
            onPressed: () async {
              Get.back();
              await Restart.restartApp();
              // await FlutterRestart.restartApp();
            },
            child: const Text('Restart Now'),
          ),
          CupertinoDialogAction(
            onPressed: () async {
              Get.back();
            },
            child: Text(L10n.of(context).cancel),
          ),
        ],
      );
    },
  );
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
