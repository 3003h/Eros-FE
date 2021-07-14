import 'dart:io';

import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/common/isolate_download/download_manager.dart';
import 'package:fehviewer/store/floor/dao/gallery_task_dao.dart';
import 'package:fehviewer/store/floor/dao/image_task_dao.dart';
import 'package:fehviewer/store/floor/entity/gallery_image_task.dart';
import 'package:fehviewer/store/floor/entity/gallery_task.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/toast.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

Future<String> get defDownloadPath async => GetPlatform.isAndroid
    ? path.join((await getExternalStorageDirectory())!.path, 'Download')
    : path.join(Global.appDocPath, 'Download');

class DownloadControllerI extends GetxController {
  final RxMap<String, GalleryTask> galleryTaskMap = <String, GalleryTask>{}.obs;
  final RxList<GalleryTask> galleryTaskList = <GalleryTask>[].obs;

  static Future<GalleryTaskDao> getGalleryTaskDao() async {
    return (await Global.getDatabase()).galleryTaskDao;
  }

  static Future<ImageTaskDao> getImageTaskDao() async {
    return (await Global.getDatabase()).imageTaskDao;
  }

  @override
  void onInit() {
    super.onInit();
    logger.d('DownloadController onInit');

    _initGalleryTasks();
  }

  @override
  void onClose() {
    downloadManagerIsolate.close();
    super.onClose();
  }

  Future<void> _initGalleryTasks() async {
    GalleryTaskDao _galleryTaskDao;
    ImageTaskDao _imageTaskDao;
    try {
      _galleryTaskDao = await getGalleryTaskDao();
      _imageTaskDao = await getImageTaskDao();
    } catch (e, stack) {
      logger.e('$e\n$stack ');
      rethrow;
    }

    final _tasks = await _galleryTaskDao.findAllGalleryTasks();
    galleryTaskList(_tasks);
  }

  /// 获取下载路径
  Future<String> _getGalleryDownloadPath(String custpath) async {
    final String _dirPath = GetPlatform.isAndroid
        ? path.join(
            (await getExternalStorageDirectory())!.path, 'Download', custpath)
        : path.join(Global.appDocPath, 'Download', custpath);

    final Directory savedDir = Directory(_dirPath);
    // 判断下载路径是否存在
    final bool hasExisted = savedDir.existsSync();
    // 不存在就新建路径
    if (!hasExisted) {
      savedDir.createSync(recursive: true);
    }

    return _dirPath;
  }

  /// Isolate下载
  Future<void> downloadGalleryIsolate({
    required String url,
    required int fileCount,
    required String title,
    int? gid,
    String? token,
  }) async {
    GalleryTaskDao _galleryTaskDao;
    ImageTaskDao _imageTaskDao;
    try {
      _galleryTaskDao = await getGalleryTaskDao();
      _imageTaskDao = await getImageTaskDao();
    } catch (e, stack) {
      logger.e('$e\n$stack ');
      rethrow;
    }

    int _gid = 0;
    String _token = '';
    if (gid == null || token == null) {
      final RegExpMatch _match =
          RegExp(r'/g/(\d+)/([0-9a-f]{10})/?').firstMatch(url)!;
      _gid = int.parse(_match.group(1)!);
      _token = _match.group(2)!;
    }

    // 先查询任务是否已存在
    try {
      final GalleryTask? _oriTask =
          await _galleryTaskDao.findGalleryTaskByGid(gid ?? -1);
      if (_oriTask != null) {
        logger.e('$gid 任务已存在');
        showToast('下载任务已存在');
        logger.d('${_oriTask.toString()} ');
        // return;
      }
    } catch (e, stack) {
      logger.e('$e\n$stack');
      rethrow;
    }

    final String _downloadPath = path.join('$gid - $title');
    final String _fullPath = await _getGalleryDownloadPath(_downloadPath);

    // 登记主任务表
    final GalleryTask galleryTask = GalleryTask(
      gid: gid ?? _gid,
      token: token ?? _token,
      url: url,
      title: title,
      fileCount: fileCount,
      dirPath: _fullPath,
      status: TaskStatus.enqueued.value,
    );
    logger.d('add task ${galleryTask.toString()}');
    try {
      _galleryTaskDao.insertTask(galleryTask);
      galleryTaskList.insert(0, galleryTask);
    } catch (e, stack) {
      logger.e('$e\n$stack ');
      // rethrow;
    }

    final List<GalleryImageTask> _imageTasks =
        await _imageTaskDao.findAllGalleryTaskByGid(galleryTask.gid);

    showToast('${galleryTask.gid} 下载任务已入队');

    downloadManagerIsolate.addTask(
      galleryTask: galleryTask,
      imageTasks: _imageTasks,
      downloadPath: _fullPath,
    );
  }

  /// 移除Isolate下载
  Future<void> removeDownloadGalleryTaskIsolate({
    required int index,
  }) async {
    GalleryTaskDao _galleryTaskDao;
    ImageTaskDao _imageTaskDao;
    try {
      _galleryTaskDao = await getGalleryTaskDao();
      _imageTaskDao = await getImageTaskDao();
    } catch (e, stack) {
      logger.e('$e\n$stack ');
      rethrow;
    }

    // 删除文件
    final GalleryTask _task = galleryTaskList[index];
    String? path = _task.dirPath;
    logger.d('dirPath: $path');
    if (path != null) {
      Directory(path).delete(recursive: true);
    }

    // 删除数据库记录
    _imageTaskDao.deleteImageTaskByGid(_task.gid);
    _galleryTaskDao.deleteTaskByGid(_task.gid);

    galleryTaskList.removeAt(index);
  }

  GalleryTask galleryTaskCompleIncreasing(int gid) {
    final index = galleryTaskList.indexWhere((element) => element.gid == gid);
    final GalleryTask _oriTask = galleryTaskList[index];
    final int _oricc = _oriTask.completCount ?? 0;
    // logger.d('_oricc $_oricc');

    galleryTaskList[index] = _oriTask.copyWith(
        completCount: _oricc + 1,
        status: _oricc + 1 == _oriTask.fileCount
            ? TaskStatus.complete.value
            : null);

    return galleryTaskList[index];
  }

  GalleryTask galleryTaskCountUpdate(int gid, int countComple) {
    logger.d('galleryTaskCountUpdate $gid $countComple');
    final index = galleryTaskList.indexWhere((element) => element.gid == gid);
    galleryTaskList[index] =
        galleryTaskList[index].copyWith(completCount: countComple);

    return galleryTaskList[index];
  }

  GalleryTask galleryTaskComplete(int gid) {
    final index = galleryTaskList.indexWhere((element) => element.gid == gid);
    galleryTaskList[index] =
        galleryTaskList[index].copyWith(status: TaskStatus.complete.value);
    logger.i('$gid 下载完成');

    return galleryTaskList[index];
  }

  GalleryTask galleryTaskUpdateStatus(int gid, TaskStatus status) {
    final index = galleryTaskList.indexWhere((element) => element.gid == gid);
    galleryTaskList[index] =
        galleryTaskList[index].copyWith(status: status.value);
    logger.i('set $gid status $status');

    return galleryTaskList[index];
  }
}
