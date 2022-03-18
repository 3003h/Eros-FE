import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/fehviewer.dart';

import 'package:fehviewer/pages/tab/controller/download_view_controller.dart';
import 'package:fehviewer/store/floor/dao/gallery_task_dao.dart';
import 'package:fehviewer/store/floor/dao/image_task_dao.dart';
import 'package:fehviewer/store/get_store.dart';

import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

Future<String> get defDownloadPath async => GetPlatform.isAndroid
    ? path.join((await getExternalStorageDirectory())!.path, 'Download')
    : path.join(Global.appDocPath, 'Download');

final ReceivePort flutterDownloaderPort = ReceivePort();
const portName = 'downloader_send_port';

class ArchiverDownloadController extends GetxController {
  final Map<String, DownloadArchiverTaskInfo> _archiverTaskMap =
      <String, DownloadArchiverTaskInfo>{};
  set archiverTaskMap(Map<String, DownloadArchiverTaskInfo> val) {
    _gStore.archiverTaskMap = val;
  }

  Map<String, DownloadArchiverTaskInfo> get archiverTaskMap => _archiverTaskMap;

  final GStore _gStore = Get.find();

  static Future<GalleryTaskDao> getGalleryTaskDao() async {
    return (await Global.getDatabase()).galleryTaskDao;
  }

  static Future<ImageTaskDao> getImageTaskDao() async {
    return (await Global.getDatabase()).imageTaskDao;
  }

  final EhConfigService ehConfigService = Get.find();

  @override
  void onInit() {
    super.onInit();
    logger.d('ArchiverDownloadController onInit');

    IsolateNameServer.registerPortWithName(
        flutterDownloaderPort.sendPort, portName);

    FlutterDownloader.registerCallback(_downloadCallback);

    // 从GS中初始化 archiverDlMap
    final _archiver =
        _gStore.archiverTaskMap ?? <String, DownloadArchiverTaskInfo>{};
    _archiverTaskMap.clear();
    _archiverTaskMap.addAll(_archiver);

    // 处理archiver任务
    _getArchiverTask();
  }

  @override
  void onReady() {
    super.onReady();
    flutterDownloaderPort.listen((dynamic data) {
      logger.d('update listen');
      final dataList = data as List<dynamic>;
      String taskId = dataList[0] as String;
      DownloadTaskStatus status = dataList[1] as DownloadTaskStatus;
      int progress = dataList[2] as int;

      logger.d('$taskId $status $progress');

      // 更新任务状态
      updateTask(taskId, status, progress);
    });
  }

  @override
  void onClose() {
    super.onClose();
    IsolateNameServer.removePortNameMapping(portName);
  }

  void _saveTask() {
    _gStore.archiverTaskMap = _archiverTaskMap;
  }

  void updateTask(String taskId, DownloadTaskStatus status, int progress) {
    // 通过taskId找到任务
    final _key = archiverTaskMap.entries
        .firstWhereOrNull((element) => element.value.taskId == taskId)
        ?.key;
    logger.d('_key $_key');

    if (_key == null) {
      return;
    }

    archiverTaskMap[_key] = archiverTaskMap[_key]!
        .copyWith(status: status.value, progress: progress);

    final _tag = archiverTaskMap[_key]!.tag;
    if (Get.isRegistered<DownloadViewController>()) {
      Get.find<DownloadViewController>()
          .update(['${idDownloadArchiverItem}_$_tag']);
    }
    _saveTask();
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

    if (archiverTaskMap.containsKey(_tag)) {
      showToast('Download task already exists');
      return;
    }

    final _downloadPath = await _getArchiverDownloadPath();

    final String? _taskId = await _downloadArchiverFile(url, _downloadPath);

    archiverTaskMap[_tag] = kDefDownloadTaskInfo.copyWith(
      tag: _tag,
      gid: gid,
      type: dlType,
      taskId: _taskId,
      title: title,
      imgUrl: imgUrl,
      galleryUrl: galleryUrl,
      filePath: _downloadPath,
    );

    _downloadViewAnimateListAdd();
    if (Get.isRegistered<DownloadViewController>()) {
      Get.find<DownloadViewController>().update();
    }
    _saveTask();
    showToast('Download task added');
  }

  void removeTask(String? tag) {
    archiverTaskMap.remove(tag);
    _saveTask();
  }

  void _downloadViewAnimateListAdd() {
    if (Get.isRegistered<DownloadViewController>()) {
      Get.find<DownloadViewController>().animateArchiverListAddTask();
    }
  }

  /// 获取下载路径
  Future<String> _getArchiverDownloadPath() async {
    late String _dirPath;

    if (GetPlatform.isAndroid && ehConfigService.downloadLocatino.isNotEmpty) {
      // 自定义路径
      logger.d('自定义下载路径');
      await requestManageExternalStoragePermission();
      _dirPath = path.join(ehConfigService.downloadLocatino);
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
  Future<String?> _downloadArchiverFile(String downloadUrl, String savePath,
      {String? fileName}) async {
    final Map<String, String> _httpHeaders = {
      'Cookie': Global.profile.user.cookie,
    };
    return await FlutterDownloader.enqueue(
      url: downloadUrl,
      savedDir: savePath,
      fileName: fileName,
      showNotification: false,
      openFileFromNotification: false,
      headers: _httpHeaders,
    );
  }

  /// 不在 archiverDlMap 中的任务
  Future<void> _getArchiverTask() async {
    final List<DownloadTask> tasks = await FlutterDownloader.loadTasks() ?? [];
    // logger.v(
    //     'loadTasks \n${tasks.map((DownloadTask e) => e.toString().split(', ').join('\n')).join('\n----------\n')} ');

    for (final DownloadTask downloadTask in tasks) {
      final int _index = archiverTaskMap.entries.toList().indexWhere(
          (MapEntry<String, DownloadArchiverTaskInfo> element) =>
              element.value.taskId == downloadTask.taskId);

      // 不在 archiverTaskMap 中的任务 直接删除
      if (_index < 0) {
        logger.d(
            'remove task \n${downloadTask.toString().split(', ').join('\n')}');
        FlutterDownloader.remove(
            taskId: downloadTask.taskId, shouldDeleteContent: true);
      } else {
        // 否则更新
        final DownloadArchiverTaskInfo _taskInfo = archiverTaskMap.entries
            .firstWhere(
                (element) => element.value.taskId == downloadTask.taskId)
            .value;

        // 触发ever 保存到GS中
        archiverTaskMap[_taskInfo.tag!] = _taskInfo.copyWith(
          status: downloadTask.status.value,
          progress: downloadTask.progress,
        );

        // 更新视图
        Get.find<DownloadViewController>().update([_taskInfo.tag ?? '']);
      }
    }
  }
}

/// 下载进度回调顶级函数
void _downloadCallback(String id, DownloadTaskStatus status, int progress) {
  // logger.d('$id $status $progress');

  final SendPort send =
      IsolateNameServer.lookupPortByName('downloader_send_port')!;
  send.send([id, status, progress]);
}
