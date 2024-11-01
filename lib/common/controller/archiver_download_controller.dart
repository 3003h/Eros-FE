import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:eros_fe/common/service/ehsetting_service.dart';
import 'package:eros_fe/index.dart';
import 'package:eros_fe/pages/tab/controller/download_view_controller.dart';
import 'package:eros_fe/utils/saf_helper.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_storage/shared_storage.dart' as ss;

Future<String> get defDownloadPath async => GetPlatform.isAndroid
    ? path.join((await getExternalStorageDirectory())!.path, 'Download')
    : path.join(Global.appDocPath, 'Download');

const flutterDownloadPortName = 'downloader_send_port';

final regExpResolution = RegExp(r'-(\d+[xX])\.\w+$');

class ArchiverDownloadController extends GetxController {
  final Map<String, DownloadArchiverTaskInfo> archiverTaskMap =
      <String, DownloadArchiverTaskInfo>{};

  final EhSettingService ehSettingService = Get.find();

  @override
  void onInit() {
    super.onInit();
    logger.t('ArchiverDownloadController onInit');
    bindBackgroundIsolate(updateTaskCallback);

    // 初始化 taskMap
    final archiverMap = hiveHelper.getAllArchiverTaskMap() ??
        <String, DownloadArchiverTaskInfo>{};

    archiverTaskMap.clear();
    archiverTaskMap.addAll(archiverMap);

    // 处理archiver任务
    _getArchiverTask();
  }

  @override
  void onClose() {
    unbindBackgroundIsolate();
    super.onClose();
  }

  void bindBackgroundIsolate(DownloadCallback callback) {
    ReceivePort port = ReceivePort();
    bool isSuccess = IsolateNameServer.registerPortWithName(
      port.sendPort,
      flutterDownloadPortName,
    );
    if (!isSuccess) {
      unbindBackgroundIsolate();
      bindBackgroundIsolate(callback);
      return;
    }

    logger.d('flutterDownloaderPort.listen');
    // 设置监听 进行回调
    port.listen(
      (dynamic data) {
        logger.t('^^^ flutterDownloaderPort.listen');
        if (data is int) {
          logger.d('data is int $data');
          return;
        }

        final para = data as List<dynamic>;
        final (taskId, status, progress) =
            (para[0] as String, para[1] as int, para[2] as int);

        logger.t('$taskId $status $progress%');

        // 更新任务状态
        callback(taskId, status, progress);
      },
      onDone: () {
        logger.d('flutterDownloaderPort.onDone');
        port.close();
      },
      onError: (dynamic error) {
        logger.d('flutterDownloaderPort.onError');
        port.close();
      },
    );
    logger.d('FlutterDownloader.registerCallback');
    FlutterDownloader.registerCallback(flutterDownloadCallback, step: 0);
  }

  void unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping(flutterDownloadPortName);
  }

  Future<void> updateTaskCallback(
    String taskId,
    int statusValue,
    int progress,
  ) async {
    // 通过taskId找到任务
    final key = archiverTaskMap.entries
        .firstWhereOrNull((element) => element.value.taskId == taskId)
        ?.key;

    logger.t('updateTask _key $key');

    final status = intToDownloadStatus(statusValue);

    if (key == null) {
      return;
    }

    final List<DownloadTask> tasks = await FlutterDownloader.loadTasks() ?? [];
    final _task = tasks.firstWhereOrNull((e) => e.taskId == taskId);
    final fileName = _task?.filename;
    final url = _task?.url;
    final timeCreated = _task?.timeCreated;

    if (_task != null) {
      logger.t('_task $_task');
    }

    if (fileName != null) {
      logger.t('fileName $fileName');
    }

    final resolution = regExpResolution.firstMatch(fileName ?? '')?.group(1);

    final DownloadArchiverTaskInfo? taskInfo = archiverTaskMap[key];
    if (taskInfo == null) {
      return;
    }

    final task = taskInfo.copyWith(
      status: statusValue.oN,
      progress: progress.oN,
      fileName: fileName != '<null>' ? fileName.oN : null,
      url: url.oN,
      timeCreated: timeCreated.oN,
      resolution: resolution.oN,
    );

    archiverTaskMap[key] = task;

    final tag = task.tag;

    if (status == DownloadTaskStatus.complete && fileName == null) {
      await 200.milliseconds.delay();
      await updateTaskCallback(taskId, statusValue, progress);
    }

    if (status == DownloadTaskStatus.complete &&
        (task.savedDir?.isContentUri ?? false)) {
      final safUri = await copyFileToSAF(task);
      if (safUri != null) {
        logger.d('safUri $safUri');
        final origTaskInfo = archiverTaskMap[key];
        if (origTaskInfo != null) {
          archiverTaskMap[key] = origTaskInfo.copyWith(
            safUri: safUri.toString().oN,
          );
        }
      }
    }
    hiveHelper.putArchiverTask(archiverTaskMap[key]);

    if (Get.isRegistered<DownloadViewController>()) {
      Get.find<DownloadViewController>()
          .update(['${idDownloadArchiverItem}_$tag']);
    }
  }

  Future<Uri?> copyFileToSAF(DownloadArchiverTaskInfo task) async {
    logger.d('copyFileToSAF ${task.fileName}');
    final savePath = task.savedDir;
    final fileName = task.fileName;
    if (fileName == null || savePath == null) {
      return null;
    }
    final tempFilePath = getTempFilePath(savePath, fileName);
    logger.d('tempFilePath $tempFilePath');
    final tempFile = File(tempFilePath);
    if (!tempFile.existsSync()) {
      logger.e('tempFile ${tempFile.path} not exist');
      return null;
    }
    final parentUri = Uri.parse(await _getArchiverDownloadPath());
    try {
      // final result = await ss.createFileAsBytes(
      //   parentUri,
      //   bytes: tempFile.readAsBytesSync(),
      //   mimeType: 'application/zip',
      //   displayName: fileName,
      // );
      // logger.d('write result ${result?.uri}');
      // logger.d('copyFileToSAF success');
      // return result?.uri;
      final result = await safCreateDocumentFileFromPath(
        parentUri,
        sourceFilePath: tempFile.path,
        displayName: fileName,
        mimeType: 'application/zip',
      );
      logger.d('write result $result');
      logger.d('copyFileToSAF success');
      return Uri.parse(result ?? '');
    } catch (e, s) {
      logger.e('copyFileToSAF', error: e, stackTrace: s);
    } finally {
      tempFile.deleteSync();
    }
    return null;
  }

  /// 新增下载任务
  Future<void> downloadArchiverFile({
    required String gid,
    required String dlType,
    required String title,
    required String url,
    String? imgUrl,
    String? galleryUrl,
  }) async {
    final String tag = '$gid$dlType';

    logger.d('downloadArchiverFile $tag');

    if (archiverTaskMap.containsKey(tag)) {
      showToast('Download task already exists');
      return;
    }

    final downloadPath = await _getArchiverDownloadPath();
    logger.d('_downloadPath $downloadPath');

    final String? taskId = await _downloadArchiverFile(url, downloadPath);

    final taskToAdd = kDefDownloadTaskInfo.copyWith(
      tag: tag.oN,
      gid: gid.oN,
      type: dlType.oN,
      taskId: taskId.oN,
      title: title.oN,
      imgUrl: imgUrl.oN,
      galleryUrl: galleryUrl.oN,
      savedDir: downloadPath.oN,
    );

    archiverTaskMap[tag] = taskToAdd;

    _downloadViewAnimateListAdd(index: 0);
    if (Get.isRegistered<DownloadViewController>()) {
      Get.find<DownloadViewController>().update();
    }

    hiveHelper.putArchiverTask(taskToAdd);
    showToast('Download task added');
  }

  void removeTask(String? tag, {bool shouldDeleteContent = true}) {
    final task = archiverTaskMap[tag];
    if (shouldDeleteContent && task != null && task.safUri != null) {
      ss.delete(Uri.parse(task.safUri!));
    }
    archiverTaskMap.remove(tag);
    hiveHelper.removeArchiverTask(tag);
  }

  void _downloadViewAnimateListAdd({int? index}) {
    if (Get.isRegistered<DownloadViewController>()) {
      Get.find<DownloadViewController>()
          .animateArchiverListAddTask(index: index);
    }
  }

  Future<String> _getArchiverDownloadPath() async {
    final customDownloadPath = ehSettingService.downloadLocatino;
    late String dirPath;
    if (GetPlatform.isIOS) {
      dirPath = path.join(Global.appDocPath, 'Download', 'Archiver');
    }

    if (!Platform.isIOS) {
      if (customDownloadPath.isNotEmpty && customDownloadPath.isContentUri) {
        dirPath = customDownloadPath;
      } else {
        dirPath = path.join(customDownloadPath, 'Archiver');
      }
    }

    if (dirPath.isContentUri) {
      final domFile = await ss.findFile(Uri.parse(dirPath), 'Archiver');
      logger.t('domFile name:${domFile?.name}, type:${domFile?.type}');
      if (domFile == null) {
        final parentUri = Uri.parse(customDownloadPath);
        logger.d('parentUri $parentUri');

        // loop until the user grants permission
        await showSAFPermissionRequiredDialog(loop: true, uri: parentUri);

        final result = await ss.createDirectory(parentUri, 'Archiver');
        logger.d('create dir result ${result?.uri}');
        dirPath = result?.uri.toString() ?? '';
      } else {
        dirPath = domFile.uri.toString();
      }
    } else {
      final dir = Directory(dirPath);
      if (!dir.existsSync()) {
        logger.d('create dir $dir');
        dir.createSync(recursive: true);
      }
    }

    return dirPath;
  }

  /// 获取下载路径
  Future<String> _getArchiverDownloadPath_Old() async {
    late String _dirPath;

    if (GetPlatform.isAndroid && ehSettingService.downloadLocatino.isNotEmpty) {
      // 自定义路径
      logger.d('自定义下载路径');
      await requestManageExternalStoragePermission();
      _dirPath = path.join(ehSettingService.downloadLocatino, 'Archiver');
    } else if (GetPlatform.isAndroid) {
      logger.d('无自定义下载路径');
      _dirPath =
          path.join((await getExternalStorageDirectory())!.path, 'Archiver');
    } else {
      _dirPath = path.join(Global.appDocPath, 'Download', 'Archiver');
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

  // 根据 downloadUrl 和 savePath 下载文件
  Future<String?> _downloadArchiverFile(
    String downloadUrl,
    String savePath, {
    String? fileName,
  }) async {
    final Map<String, String> httpHeaders = {
      'Cookie': Global.profile.user.cookie,
    };

    if (savePath.isContentUri) {
      savePath = getTempFilePath(savePath, fileName ?? '');
      logger.d('savePath $savePath');
    }

    return await FlutterDownloader.enqueue(
      url: downloadUrl,
      savedDir: savePath,
      fileName: fileName,
      showNotification: false,
      openFileFromNotification: false,
      headers: httpHeaders,
    );
  }

  String getTempFilePath(String destPath, String fileName) {
    final parentPath = path.join(Global.extStoreTempPath, 'saf_temp_archiver');
    final parentDir = Directory(parentPath);
    if (!parentDir.existsSync()) {
      parentDir.createSync(recursive: true);
    }
    return path.join(Global.extStoreTempPath, 'saf_temp_archiver', fileName);
  }

  /// 不在 archiverDlMap 中的任务
  Future<void> _getArchiverTask() async {
    final List<DownloadTask> tasks = await FlutterDownloader.loadTasks() ?? [];
    logger.t(
        'loadTasks \n${tasks.map((DownloadTask e) => e.toString().split(', ').join('\n')).join('\n----------\n')} ');

    for (final DownloadTask downloadTask in tasks) {
      final int index = archiverTaskMap.entries.toList().indexWhere(
          (MapEntry<String, DownloadArchiverTaskInfo> element) =>
              element.value.taskId == downloadTask.taskId);

      // 不在 archiverTaskMap 中的任务 直接删除任务
      if (index < 0) {
        logger.d(
            'remove task \n${downloadTask.toString().split(', ').join('\n')}');
        FlutterDownloader.remove(
            taskId: downloadTask.taskId, shouldDeleteContent: true);
      } else {
        logger.d(
            'update task \n${downloadTask.toString().split(', ').join('\n')}');
        // 否则,根据 downloadTask 更新 archiverTaskMap 中的数据
        final DownloadArchiverTaskInfo taskInfo = archiverTaskMap.entries
            .firstWhere(
                (element) => element.value.taskId == downloadTask.taskId)
            .value;

        final resolution =
            regExpResolution.firstMatch(downloadTask.filename ?? '')?.group(1);

        final taskInfoP = taskInfo.copyWith(
          status: downloadStatusToInt(downloadTask.status).oN,
          progress: downloadTask.progress.oN,
          fileName: downloadTask.filename.oN,
          savedDir: (downloadTask.savedDir.contains('saf_temp_archiver')
                  ? taskInfo.savedDir
                  : downloadTask.savedDir)
              .oN,
          url: downloadTask.url.oN,
          timeCreated: downloadTask.timeCreated.oN,
          resolution: resolution.oN,
        );

        final tag = taskInfo.tag;
        if (tag != null) {
          archiverTaskMap[tag] = taskInfoP;
        }

        // 更新视图
        Get.find<DownloadViewController>().update([taskInfo.tag ?? '']);
      }
    }
  }
}

/// flutterDownload下载进度回调顶级函数
@pragma('vm:entry-point')
void flutterDownloadCallback(String id, int status, int progress) {
  final sendPort = IsolateNameServer.lookupPortByName(flutterDownloadPortName)!;
  // print('_downloadCallback ${sendPort.runtimeType}');
  // logger.t('$id $status $progress%');

  sendPort.send([id, status, progress]);
}
