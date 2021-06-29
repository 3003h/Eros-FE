import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/common/isolate/download.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/pages/tab/controller/download_view_controller.dart';
import 'package:fehviewer/store/floor/dao/gallery_task_dao.dart';
import 'package:fehviewer/store/floor/dao/image_task_dao.dart';
import 'package:fehviewer/store/floor/entity/gallery_image_task.dart';
import 'package:fehviewer/store/floor/entity/gallery_task.dart';
import 'package:fehviewer/store/get_store.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/toast.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

part 'download_controller_gallery.dart';

Future<String> get defDownloadPath async => GetPlatform.isAndroid
    ? path.join((await getExternalStorageDirectory())!.path, 'Download')
    : path.join(Global.appDocPath, 'Download');

class DownloadController extends GetxController {
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
    logger.d('DownloadController onInit');

    // _bindBackgroundIsolate();
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

    _initGalleryTasks();
  }

  @override
  void onClose() {
    // _unbindBackgroundIsolate();
    downloadManager.close();
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

/*
  Future<void> downloadGallery({
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
    final GalleryTask? _oriTask =
        await _galleryTaskDao.findGalleryTaskByGid(gid ?? -1);
    if (_oriTask != null) {
      logger.e('$gid 任务已存在');
      showToast('下载任务已存在');
      logger.d('${_oriTask.toString()} ');
      return;
    }

    // 登记主任务表
    final GalleryTask galleryTask = GalleryTask(
      gid: gid ?? _gid,
      token: token ?? _token,
      url: url,
      title: title,
      fileCount: fileCount,
      dirPath: '',
    );
    logger.d('add task ${galleryTask.toString()}');
    try {
      _galleryTaskDao.insertTask(galleryTask);
    } catch (e, stack) {
      logger.e('$e\n$stack ');
      rethrow;
    }

    showToast('${galleryTask.gid} 下载任务已入队');

    // 翻页, 获取所有大图页的href
    final GalleryPageController _pageController = Get.find(tag: pageCtrlDepth);
    final List<GalleryImage> _allImages = await _getAllImages(
        url: url,
        fileCount: fileCount,
        initImages: _pageController.firstPageImage);

    logger.d('${_allImages.length}');

    // 插入任务明细
    final List<GalleryImageTask> _galleryImageTasks = _allImages
        .map((GalleryImage e) => GalleryImageTask(
              gid: galleryTask.gid,
              token: galleryTask.token,
              href: e.href,
              ser: e.ser,
            ))
        .toList();
    _imageTaskDao.insertImageTasks(_galleryImageTasks);

    final List<GalleryImageTask> _list =
        await _imageTaskDao.findAllGalleryTaskByGid(galleryTask.gid);
    logger.d('${_list.map((e) => e.toString()).join('\n')} ');

    // test
    final String _downloadPath =
        path.join(await _getDownloadPath(), galleryTask.title);
    // 不存在就新建路径
    if (!Directory(_downloadPath).existsSync()) {
      Directory(_downloadPath).createSync(recursive: true);
    }

    for (final GalleryImageTask imageTask in _list) {
      FlutterDownloader.enqueue(
          url: imageTask.imageUrl ?? '', savedDir: _downloadPath);
    }
  }


  Future<List<GalleryImage>> _getAllImages({
    required String url,
    List<GalleryImage>? initImages,
    int? fileCount,
  }) async {
    if (initImages != null &&
        initImages.isNotEmpty &&
        initImages.length == fileCount) {
      return initImages;
    }

    final List<GalleryImage> _rultList = [];
    _rultList.addAll(initImages ?? []);
    int _curPage = 0;
    while (_rultList.length < (fileCount ?? 0)) {
      try {
        final List<GalleryImage> _moreGalleryImageList =
            await Api.getGalleryImage(
          url,
          page: _curPage + 1,
          // cancelToken: cancelToken,
          refresh: true,
        );

        // 避免重复添加
        if (_moreGalleryImageList.first.ser > _rultList.last.ser) {
          logger.d('下载任务 添加图片对象 起始序号${_moreGalleryImageList.first.ser}  '
              '数量${_moreGalleryImageList.length}');
          _rultList.addAll(_moreGalleryImageList);
        }
        // 成功后才+1
        _curPage++;
      } catch (e, stack) {
        showToast('$e');
        logger.e('$e\n$stack');
        rethrow;
      }
    }

    return _rultList;
  }

  final ReceivePort _port = ReceivePort();

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
      _updateTask(id, status, progress);
    });
  }

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  /// 更新任务状态
  Future<void> _updateTask(
      String id, DownloadTaskStatus status, int progress) async {
    final List<DownloadTask> _tasks =
        await FlutterDownloader.loadTasksWithRawQuery(
                query: "SELECT * FROM task WHERE task_id='$id'") ??
            [];

    // 根据taskid 从数据库中 获取任务数据
    final DownloadTask? _task = _tasks.isNotEmpty ? _tasks.first : null;

    logger.d(
        'Background Isolate Callback: _task ($id) is in status ($status) and process ($progress)');

    final exist =
        archiverTaskMap.entries.any((element) => element.value.taskId == id);

    if (!exist) {
      return;
    }

    DownloadTaskInfo? _taskInfo = archiverTaskMap.entries
        .firstWhere((MapEntry<String, DownloadTaskInfo?> element) =>
            element.value?.taskId == id)
        .value;

    _taskInfo = _taskInfo.copyWith(progress: progress, status: status.value);

    if (_task != null &&
        _task.filename != 'null' &&
        _task.filename != '<null>' &&
        _task.filename != null &&
        _task.filename!.trim().isNotEmpty) {
      logger.d('${_task.filename} ');
      // _taskInfo.title = _task.filename;
      _taskInfo = _taskInfo.copyWith(title: _task.filename);
    }

    // 触发ever 保存到GS中
    archiverTaskMap[_taskInfo.tag!] = _taskInfo;

    // 更新视图
    Get.find<DownloadViewController>().update([_taskInfo.tag ?? '']);
  }

 */

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

  /// 获取下载路径
  Future<String> _getGalleryDownloadPath(String custpath) async {
    final String _dirPath = GetPlatform.isAndroid
        ? path.join(
            (await getExternalStorageDirectory())!.path, 'Download', custpath)
        : path.join(Global.appDocPath, 'Download', custpath);
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
        return;
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

    downloadManager.addTask(
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
    // logger.d('galleryTaskCompleIncreasing $gid');
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

/// 下载进度回调顶级函数
void _downloadCallback(String id, DownloadTaskStatus status, int progress) {
  final SendPort send =
      IsolateNameServer.lookupPortByName('downloader_send_port')!;
  send.send([id, status, progress]);
}
