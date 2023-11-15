import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:fehviewer/common/service/ehsetting_service.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/pages/tab/controller/download_view_controller.dart';
import 'package:fehviewer/utils/saf_helper.dart';
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
    final _archiver = hiveHelper.getAllArchiverTaskMap() ??
        <String, DownloadArchiverTaskInfo>{};

    archiverTaskMap.clear();
    archiverTaskMap.addAll(_archiver);

    // 处理archiver任务
    _getArchiverTask();
  }

  @override
  void onClose() {
    unbindBackgroundIsolate();
    super.onClose();
  }

  void bindBackgroundIsolate(DownloadCallback callback) {
    ReceivePort _port = ReceivePort();
    bool isSuccess = IsolateNameServer.registerPortWithName(
      _port.sendPort,
      flutterDownloadPortName,
    );
    if (!isSuccess) {
      unbindBackgroundIsolate();
      bindBackgroundIsolate(callback);
      return;
    }

    logger.d('flutterDownloaderPort.listen');
    // 设置监听 进行回调
    _port.listen(
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
        _port.close();
      },
      onError: (dynamic error) {
        logger.d('flutterDownloaderPort.onError');
        _port.close();
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
    final _key = archiverTaskMap.entries
        .firstWhereOrNull((element) => element.value.taskId == taskId)
        ?.key;

    logger.t('updateTask _key $_key');

    final status = intToDownloadStatus(statusValue);

    if (_key == null) {
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

    final _resolution = regExpResolution.firstMatch(fileName ?? '')?.group(1);

    final DownloadArchiverTaskInfo? _taskInfo = archiverTaskMap[_key];
    if (_taskInfo == null) {
      return;
    }

    final task = _taskInfo.copyWith(
      status: statusValue,
      progress: progress,
      fileName: fileName != '<null>' ? fileName : null,
      url: url,
      timeCreated: timeCreated,
      resolution: _resolution,
    );

    archiverTaskMap[_key] = task;

    final _tag = task.tag;

    if (status == DownloadTaskStatus.complete && fileName == null) {
      await 200.milliseconds.delay();
      await updateTaskCallback(taskId, statusValue, progress);
    }

    if (status == DownloadTaskStatus.complete &&
        (task.savedDir?.isContentUri ?? false)) {
      final safUri = await copyFileToSAF(task);
      if (safUri != null) {
        logger.d('safUri $safUri');
        final _taskInfo = archiverTaskMap[_key];
        if (_taskInfo != null) {
          archiverTaskMap[_key] = _taskInfo.copyWith(
            safUri: safUri.toString(),
          );
        }
      }
    }
    hiveHelper.putArchiverTask(archiverTaskMap[_key]);

    if (Get.isRegistered<DownloadViewController>()) {
      Get.find<DownloadViewController>()
          .update(['${idDownloadArchiverItem}_$_tag']);
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
    final String _tag = '$gid$dlType';

    logger.d('downloadArchiverFile $_tag');

    if (archiverTaskMap.containsKey(_tag)) {
      showToast('Download task already exists');
      return;
    }

    final _downloadPath = await _getArchiverDownloadPath();
    logger.d('_downloadPath $_downloadPath');

    final String? _taskId = await _downloadArchiverFile(url, _downloadPath);

    archiverTaskMap[_tag] = kDefDownloadTaskInfo.copyWith(
      tag: _tag,
      gid: gid,
      type: dlType,
      taskId: _taskId,
      title: title,
      imgUrl: imgUrl,
      galleryUrl: galleryUrl,
      savedDir: _downloadPath,
    );

    _downloadViewAnimateListAdd(index: 0);
    if (Get.isRegistered<DownloadViewController>()) {
      Get.find<DownloadViewController>().update();
    }
    hiveHelper.putArchiverTask(archiverTaskMap[_tag]!);
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
      final _dir = Directory(dirPath);
      if (!_dir.existsSync()) {
        logger.d('create dir $_dir');
        _dir.createSync(recursive: true);
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
    final Map<String, String> _httpHeaders = {
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
      headers: _httpHeaders,
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
      final int _index = archiverTaskMap.entries.toList().indexWhere(
          (MapEntry<String, DownloadArchiverTaskInfo> element) =>
              element.value.taskId == downloadTask.taskId);

      // 不在 archiverTaskMap 中的任务 直接删除任务
      if (_index < 0) {
        logger.d(
            'remove task \n${downloadTask.toString().split(', ').join('\n')}');
        FlutterDownloader.remove(
            taskId: downloadTask.taskId, shouldDeleteContent: true);
      } else {
        // 否则,根据 downloadTask 更新 archiverTaskMap 中的数据
        final DownloadArchiverTaskInfo _taskInfo = archiverTaskMap.entries
            .firstWhere(
                (element) => element.value.taskId == downloadTask.taskId)
            .value;

        final _resolution =
            regExpResolution.firstMatch(downloadTask.filename ?? '')?.group(1);

        archiverTaskMap[_taskInfo.tag!] = _taskInfo.copyWith(
          status: downloadStatusToInt(downloadTask.status),
          progress: downloadTask.progress,
          fileName: downloadTask.filename,
          savedDir: downloadTask.savedDir.contains('saf_temp_archiver')
              ? null
              : downloadTask.savedDir,
          url: downloadTask.url,
          timeCreated: downloadTask.timeCreated,
          resolution: _resolution,
        );

        // 更新视图
        Get.find<DownloadViewController>().update([_taskInfo.tag ?? '']);
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
