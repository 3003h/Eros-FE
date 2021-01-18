import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/store/gallery_store.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class DownloadController extends GetxController {
  // key DownloadTaskInfo.tag
  final RxMap<String, DownloadTaskInfo> archiverTaskMap =
      <String, DownloadTaskInfo>{}.obs;

  final List<String> _archiverDlIdList = <String>[];

  final GStore _gStore = Get.find();

  Future<void> downloadArchiverFile({
    @required String gid,
    @required String dlType,
    @required String title,
    @required String url,
  }) async {
    final String _tag = '$gid$dlType';

    logger.d('$url');

    if (archiverTaskMap.containsKey(_tag)) {
      showToast('下载任务已存在');
      return;
    }

    // url =
    //     'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4';

    String fileName;
    // if (GetPlatform.isIOS) {
    //   fileName = '${title}_$dlType.zip';
    // }

    final String _taskId =
        await _downloadFile(url, await _getDownloadPath(), fileName: fileName);

    archiverTaskMap[_tag] = DownloadTaskInfo()
      ..tag = _tag
      ..gid = gid
      ..type = dlType
      ..taskId = _taskId
      ..title = title;

    _archiverDlIdList.add(_tag);

    showToast('下载任务已添加');
  }

  final ReceivePort _port = ReceivePort();

  @override
  void onInit() {
    super.onInit();

    _bindBackgroundIsolate();
    FlutterDownloader.registerCallback(_downloadCallback, stepSize: 2);

    // 从GS中初始化 archiverDlMap
    final Map<String, DownloadTaskInfo> _archivermap =
        _gStore.archiverTaskMap ?? <String, DownloadTaskInfo>{};
    archiverTaskMap(_archivermap);

    ever(archiverTaskMap, (Map<String, DownloadTaskInfo> val) {
      _gStore.archiverTaskMap = val;
    });

    // 读取所有任务
    _prepare();
  }

  @override
  void onClose() {
    _unbindBackgroundIsolate();
    super.onClose();
  }

  void _bindBackgroundIsolate() {
    final bool isSuccess = IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    if (!isSuccess) {
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate();
      return;
    }

    _port.listen((dynamic data) {
      final String id = data[0];
      final DownloadTaskStatus status = data[1];
      final int progress = data[2];
      _updateItem(id, status, progress);
    });
  }

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  /// 不在 archiverDlMap 中的任务
  Future<void> _prepare() async {
    final List<DownloadTask> tasks = await FlutterDownloader.loadTasks();
    logger.d(
        'loadTasks \n${tasks.map((DownloadTask e) => e.toString().split(', ').join('\n')).join('\n----------\n')} ');

    for (final DownloadTask downloadTask in tasks) {
      final int _index = archiverTaskMap.entries.toList().indexWhere(
          (MapEntry<String, DownloadTaskInfo> element) =>
              element.value.taskId == downloadTask.taskId);

      // 不在 archiverTaskMap 中的任务 直接删除
      if (_index < 0) {
        logger.d(
            'remove task \n${downloadTask.toString().split(', ').join('\n')}');
        FlutterDownloader.remove(
            taskId: downloadTask.taskId, shouldDeleteContent: true);
      } else {
        // 否则更新
        final DownloadTaskInfo _taskInfo = archiverTaskMap.entries
            .firstWhere((MapEntry<String, DownloadTaskInfo> element) =>
                element.value.taskId == downloadTask.taskId)
            .value;

        // 触发ever 保存到GS中
        archiverTaskMap[_taskInfo.tag] = _taskInfo
          ..status = downloadTask.status.value
          ..progress = downloadTask.progress;

        update([_taskInfo.tag]);
      }
    }
  }

  /// 更新任务状态
  Future<void> _updateItem(
      String id, DownloadTaskStatus status, int progress) async {
    // 根据taskid 从数据库中 获取任务数据
    final DownloadTask _task = (await FlutterDownloader.loadTasksWithRawQuery(
            query: "SELECT * FROM task WHERE task_id='$id'"))
        .first;

    logger.d(
        'Background Isolate Callback: _task ($id) is in status ($status) and process ($progress)');

    final DownloadTaskInfo _taskInfo = archiverTaskMap.entries
        .firstWhere((MapEntry<String, DownloadTaskInfo> element) =>
            element.value.taskId == id)
        .value;

    _taskInfo
      ..progress = progress
      ..status = status.value;

    if (_task.filename != null &&
        _task.filename != 'null' &&
        _task.filename != '<null>' &&
        _task.filename.trim().isNotEmpty) {
      logger.d('${_task.filename} ');
      _taskInfo.title = _task.filename;
    }

    // 触发ever 保存到GS中
    archiverTaskMap[_taskInfo.tag] = _taskInfo;

    update([_taskInfo.tag]);
  }

  /// 获取下载路径
  Future<String> _getDownloadPath() async {
    final String _dirPath = GetPlatform.isAndroid
        ? path.join((await getExternalStorageDirectory()).path, 'Download')
        : path.join(Global.appDocPath, 'Download', 'Archiver');
    // : Global.appDocPath;

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
  Future<String> _downloadFile(String downloadUrl, String savePath,
      {String fileName}) async {
    return await FlutterDownloader.enqueue(
      url: downloadUrl,
      savedDir: savePath,
      fileName: fileName,
      showNotification: false,
      openFileFromNotification: false,
    );
  }
}

void _downloadCallback(String id, DownloadTaskStatus status, int progress) {
  final SendPort send =
      IsolateNameServer.lookupPortByName('downloader_send_port');
  send.send([id, status, progress]);
}
