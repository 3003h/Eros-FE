import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/common/isolate/download_manager.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/pages/tab/controller/download_view_controller.dart';
import 'package:fehviewer/store/floor/dao/gallery_task_dao.dart';
import 'package:fehviewer/store/floor/dao/image_task_dao.dart';
import 'package:fehviewer/store/floor/entity/gallery_task.dart';
import 'package:fehviewer/store/get_store.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/toast.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

Future<String> get defDownloadPath async => GetPlatform.isAndroid
    ? path.join((await getExternalStorageDirectory())!.path, 'Download')
    : path.join(Global.appDocPath, 'Download');

class ArchiverDownloadController extends GetxController {
  final RxMap<String, DownloadTaskInfo> archiverTaskMap =
      <String, DownloadTaskInfo>{}.obs;

  final List<String> _archiverDlIdList = <String>[];

  final RxMap<String, GalleryTask> galleryTaskMap = <String, GalleryTask>{}.obs;
  final RxList<GalleryTask> galleryTaskList = <GalleryTask>[].obs;

  final GStore _gStore = Get.find();

  static Future<GalleryTaskDao> getGalleryTaskDao() async {
    return (await Global.getDatabase()).galleryTaskDao;
  }

  static Future<ImageTaskDao> getImageTaskDao() async {
    return (await Global.getDatabase()).imageTaskDao;
  }

  @override
  void onInit() {
    super.onInit();
    logger.d('ArchiverDownloadController onInit');

    FlutterDownloader.registerCallback(_downloadCallback);

    // 从GS中初始化 archiverDlMap
    final Map<String, DownloadTaskInfo> _archivermap =
        _gStore.archiverTaskMap ?? <String, DownloadTaskInfo>{};
    archiverTaskMap(_archivermap);

    ever(archiverTaskMap, (Map<String, DownloadTaskInfo> val) {
      _gStore.archiverTaskMap = val;
    });

    // 处理archiver任务
    _getArchiverTask();
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<void> downloadArchiverFile({
    required String gid,
    required String dlType,
    required String title,
    required String url,
  }) async {
    final String _tag = '$gid$dlType';

    logger.d('$url');

    if (archiverTaskMap.containsKey(_tag)) {
      showToast('下载任务已存在');
      return;
    }

    final String? _taskId = await _downloadFile(url, await _getDownloadPath());

    archiverTaskMap[_tag] = kDefDownloadTaskInfo.copyWith(
      tag: _tag,
      gid: gid,
      type: dlType,
      taskId: _taskId,
      title: title,
    );

    _archiverDlIdList.add(_tag);

    showToast('下载任务已添加');
  }

  /// 获取下载路径
  Future<String> _getDownloadPath() async {
    final String _dirPath = GetPlatform.isAndroid
        ? path.join((await getExternalStorageDirectory())!.path, '')
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
  Future<String?> _downloadFile(String downloadUrl, String savePath,
      {String? fileName}) async {
    final Map<String, String> _httpHeaders = {
      'Cookie': Global.profile.user.cookie ?? '',
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
    // logger.d(
    //     'loadTasks \n${tasks.map((DownloadTask e) => e.toString().split(', ').join('\n')).join('\n----------\n')} ');

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
  final SendPort send =
      IsolateNameServer.lookupPortByName('downloader_send_port')!;
  send.send([id, status, progress]);
}
