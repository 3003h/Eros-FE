import 'dart:io';
import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:executor/executor.dart';
import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/common/isolate_download/download_manager.dart';
import 'package:fehviewer/common/service/depth_service.dart';
import 'package:fehviewer/models/base/eh_models.dart';
import 'package:fehviewer/network/gallery_request.dart';
import 'package:fehviewer/pages/gallery/controller/gallery_page_controller.dart';
import 'package:fehviewer/store/floor/dao/gallery_task_dao.dart';
import 'package:fehviewer/store/floor/dao/image_task_dao.dart';
import 'package:fehviewer/store/floor/entity/gallery_image_task.dart';
import 'package:fehviewer/store/floor/entity/gallery_task.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/toast.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sprintf/sprintf.dart' as sp;

Future<String> get defDownloadPath async => GetPlatform.isAndroid
    ? path.join((await getExternalStorageDirectory())!.path, 'Download')
    : path.join(Global.appDocPath, 'Download');

const int _kserlen = 4;

class DownloadController extends GetxController {
  final RxMap<String, GalleryTask> galleryTaskMap = <String, GalleryTask>{}.obs;

  final RxList<GalleryTask> galleryTaskList = <GalleryTask>[].obs;

  final Executor executor = Executor(concurrency: 5);

  final downloadMap = <String, List<GalleryImage>>{};
  final _cancelTokenMap = <String, CancelToken>{};

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

    final String _downloadPath =
        path.join('$gid - ${path.split(title).join('_')}');
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
    }

    final List<GalleryImageTask> _imageTasks =
        await _imageTaskDao.findAllGalleryTaskByGid(galleryTask.gid);

    logger.d('${_imageTasks.map((e) => e.toString()).join('\n')} ');

    showToast('${galleryTask.gid} 下载任务已入队');

    final GalleryPageController _pageController = Get.find(tag: pageCtrlDepth);
    final _fCount = _pageController.firstPageImage.length;
    final _gidStr = _pageController.gid;

    _addImageTask(
      galleryTask: galleryTask,
      imageTasksOri: _imageTasks,
      downloadPath: _fullPath,
      fCount: _fCount,
    );
  }

  GalleryTask galleryTaskCompleIncreasing(int gid) {
    final index = galleryTaskList.indexWhere((element) => element.gid == gid);
    final GalleryTask _oriTask = galleryTaskList[index];
    final int _oricc = _oriTask.completCount ?? 0;

    galleryTaskList[index] = _oriTask.copyWith(
        completCount: _oricc + 1,
        status: _oricc + 1 == _oriTask.fileCount
            ? TaskStatus.complete.value
            : null);

    return galleryTaskList[index];
  }

  /// 更新任务进度
  GalleryTask galleryTaskCountUpdate(int gid, int countComple) {
    logger.d('galleryTaskCountUpdate $gid $countComple');
    final index = galleryTaskList.indexWhere((element) => element.gid == gid);
    galleryTaskList[index] =
        galleryTaskList[index].copyWith(completCount: countComple);

    return galleryTaskList[index];
  }

  /// 更新任务为已完成
  Future<GalleryTask> galleryTaskComplete(int gid) {
    return galleryTaskUpdateStatus(gid, TaskStatus.complete);
  }

  /// 暂停任务
  Future<GalleryTask> galleryTaskPaused(int gid) {
    if (!((_cancelTokenMap['$gid']?.isCancelled) ?? true)) {
      _cancelTokenMap['$gid']?.cancel();
    }

    return galleryTaskUpdateStatus(gid, TaskStatus.paused);
  }

  Future galleryTaskResume(int gid) async {}

  /// 更新任务状态
  Future<GalleryTask> galleryTaskUpdateStatus(
      int gid, TaskStatus status) async {
    final index = galleryTaskList.indexWhere((element) => element.gid == gid);
    galleryTaskList[index] =
        galleryTaskList[index].copyWith(status: status.value);
    logger.i('set $gid status $status');

    final _task = galleryTaskList[index];
    (await getGalleryTaskDao()).updateTask(_task);

    return galleryTaskList[index];
  }

  /// 移除任务
  Future<void> removeDownloadGalleryTask({
    required int index,
  }) async {
    GalleryTaskDao _galleryTaskDao;
    ImageTaskDao _imageTaskDao;

    // 删除文件
    final GalleryTask _task = galleryTaskList[index];
    String? dirpath = _task.dirPath;
    logger.d('dirPath: $dirpath');
    if (dirpath != null) {
      Directory(dirpath).delete(recursive: true);
    }

    if (!((_cancelTokenMap['${_task.gid}']?.isCancelled) ?? true)) {
      _cancelTokenMap['${_task.gid}']?.cancel();
    }

    try {
      _galleryTaskDao = await getGalleryTaskDao();
      _imageTaskDao = await getImageTaskDao();
    } catch (e, stack) {
      logger.e('$e\n$stack ');
      rethrow;
    }

    // 删除数据库记录
    _imageTaskDao.deleteImageTaskByGid(_task.gid);
    _galleryTaskDao.deleteTaskByGid(_task.gid);

    galleryTaskList.removeAt(index);
  }

  void _initDownloadMapByGid(String gid, {List<GalleryImage>? images}) {
    downloadMap[gid] = images ?? [];
  }

  GalleryImage? _getImageObj(String gid, int ser) {
    return downloadMap[gid]?.firstWhereOrNull((element) => element.ser == ser);
  }

  void _addAllImages(String gid, List<GalleryImage> galleryImages) {
    for (final GalleryImage _image in galleryImages) {
      final int? index =
          downloadMap[gid]?.indexWhere((GalleryImage e) => e.ser == _image.ser);
      if (index != null && index != -1) {
        downloadMap[gid]?[index] = _image;
      } else {
        downloadMap[gid]?.add(_image);
      }
    }
  }

  Future _updateImageTasksByGid(String gid,
      {List<GalleryImage>? images}) async {
    final ImageTaskDao _imageTaskDao = await getImageTaskDao();

    final GalleryTaskDao _galleryTaskDao = await getGalleryTaskDao();

    // logger.d(
    //     '_updateImageTasksByGid $gid\n  ${(images ?? downloadMap[gid])?.map((e) => e.toJson()).join('\n')} ');

    // 插入所有任务明细
    final List<GalleryImageTask>? _galleryImageTasks =
        (images ?? downloadMap[gid])
            ?.map((GalleryImage e) => GalleryImageTask(
                  gid: int.parse(gid),
                  token: '',
                  href: e.href,
                  ser: e.ser,
                  imageUrl: e.imageUrl,
                  sourceId: e.sourceId,
                ))
            .toList();

    loggerNoStack.d(
        '_updateImageTasksByGid $gid\n${_galleryImageTasks?.map((e) => e.toString()).join('\n')}');

    if (_galleryImageTasks != null) {
      _imageTaskDao.insertOrReplaceImageTasks(_galleryImageTasks);
    }
  }

  Future _updateImageTask(String gid, GalleryImage images,
      {String? fileName}) async {
    final ImageTaskDao _imageTaskDao = await getImageTaskDao();

    final GalleryTaskDao _galleryTaskDao = await getGalleryTaskDao();

    GalleryImageTask _imageTask = GalleryImageTask(
      gid: int.parse(gid),
      token: '',
      href: images.href,
      ser: images.ser,
      imageUrl: images.imageUrl,
      sourceId: images.sourceId,
      filePath: fileName,
    );

    _imageTaskDao.insertOrReplaceImageTasks([_imageTask]);
  }

  /// 开始下载
  Future<void> _addImageTask({
    required GalleryTask galleryTask,
    required List<GalleryImageTask> imageTasksOri,
    required String downloadPath,
    required int fCount,
    List<GalleryImage>? images,
  }) async {
    logger.d('addTask ${galleryTask.gid} ${galleryTask.title}');

    final ImageTaskDao _imageTaskDao = await getImageTaskDao();

    final GalleryTaskDao _galleryTaskDao = await getGalleryTaskDao();

    final gidStr = '${galleryTask.gid}';

    // 初始化
    _initDownloadMapByGid(gidStr, images: images);

    // 获取所有href信息
    // for (int index = 0; index < filecount; index++) {
    //   await _checkAndGetImages(gidStr, index + 1, filecount, fCount, url);
    // }
    // logger.d('获取所有href信息完成');
    _updateImageTasksByGid(gidStr);

    galleryTaskUpdateStatus(int.parse(gidStr), TaskStatus.running);

    final CancelToken _cancelToken = CancelToken();
    _cancelTokenMap[gidStr] = _cancelToken;

    logger.d('filecount:${galleryTask.fileCount} url:${galleryTask.url}');
    // 下载
    for (int index = 0; index < galleryTask.fileCount; index++) {
      if (imageTasksOri.length > index) {
        final _imageTask = imageTasksOri[index];
        if (_imageTask.status == TaskStatus.complete.value) {
          continue;
        }
      }

      executor.scheduleTask(() async {
        final itemSer = index + 1;

        final GalleryImage? tImage = await _checkAndGetImages(
            gidStr, itemSer, galleryTask.fileCount, fCount, galleryTask.url);

        if (tImage != null) {
          final maxSer = galleryTask.fileCount + 1;

          try {
            await _downloadImage(
              tImage,
              imageTasksOri.length > index ? imageTasksOri[index] : null,
              gidStr,
              downloadPath,
              maxSer,
              cancelToken: _cancelToken,
            );

            // 下载完成 更新数据库明细
            _imageTaskDao.updateImageTaskStatus(
              int.parse(gidStr),
              itemSer,
              TaskStatus.complete.value,
            );

            // 更新ui 完成数+1
            final _task = galleryTaskCompleIncreasing(int.parse(gidStr));

            _galleryTaskDao.updateTask(_task);
          } on DioError catch (e) {
            if (!CancelToken.isCancel(e)) {
              rethrow;
            }

            loggerSimple.d('$itemSer 取消');
          }
        }
      });
    }
  }

  Future _checkAndGetImages(
    String gidStr,
    int itemSer,
    int filecount,
    int firstPageCount,
    String? url, {
    CancelToken? cancelToken,
  }) async {
    GalleryImage? tImage = _getImageObj(gidStr, itemSer);

    if (tImage == null && url != null) {
      loggerSimple.d('ser:$itemSer 所在页尚未获取， 开始获取');
      final images = await _fetchImages(
        ser: itemSer,
        fileCount: filecount,
        firstPageCount: firstPageCount,
        url: url,
        cancelToken: cancelToken,
      );
      loggerSimple.d('images.length: ${images.length}');
      _addAllImages(gidStr, images);
      tImage = _getImageObj(gidStr, itemSer);
    }

    return tImage;
  }

  Future<void> _downloadImage(
    GalleryImage image,
    GalleryImageTask? imageTask,
    String gid,
    String downloadPath,
    int maxSer, {
    CancelToken? cancelToken,
  }) async {
    loggerSimple.d('${image.ser} start');

    String _imageUrl = '';
    GalleryImage _uptImage;
    String _fileName = '';

    // 存在imageTask的 用原url下载
    if (imageTask != null &&
        imageTask.imageUrl != null &&
        (imageTask.imageUrl?.isNotEmpty ?? false)) {
      final String? imageUrl = imageTask.imageUrl;
      loggerSimple.d('${image.ser} DL $imageUrl');

      _imageUrl = imageUrl!;
      _uptImage = image;
      if (imageTask.filePath != null && imageTask.filePath!.isNotEmpty) {
        _fileName = imageTask.filePath!;
      } else {
        _fileName = _getFileName(image, maxSer);
      }
    } else if (image.href != null) {
      // 否则先请求解析html
      final GalleryImage imageFetched = await _fetchImageInfo(
        image.href!,
        itemSer: image.ser,
        oriImage: image,
        gid: gid,
        cancelToken: cancelToken,
      );
      _imageUrl = imageFetched.imageUrl!;
      _uptImage = imageFetched;

      _fileName = _getFileName(imageFetched, maxSer);

      _addAllImages(gid, [imageFetched]);
      _updateImageTask(gid, imageFetched, fileName: _fileName);
    }

    // dio下载
    // await Future.delayed(Duration(milliseconds: 800));

    await Api.download(
      _imageUrl,
      path.join(downloadPath, _fileName),
      cancelToken: cancelToken,
    );

    // 下载完成
    loggerSimple.d('${image.ser} complete');
  }

  String _getFileName(GalleryImage gimage, int maxSer) {
    final String _suffix = path.extension(gimage.imageUrl!);
    // gimage.imageUrl!.substring(gimage.imageUrl!.lastIndexOf('.'));
    final String _fileName = '$maxSer'.length > _kserlen
        ? '${sp.sprintf('%0${'$maxSer'.length}d', [gimage.ser])}$_suffix'
        : '${sp.sprintf('%0${_kserlen}d', [gimage.ser])}$_suffix';
    return _fileName;
  }

  Future<GalleryImage> _fetchImageInfo(
    String href, {
    required int itemSer,
    required GalleryImage oriImage,
    required String gid,
    bool changeSource = false,
    String? sourceId,
    CancelToken? cancelToken,
  }) async {
    final GalleryImage _image = await Api.fetchImageInfo(
      href,
      ser: itemSer,
      refresh: changeSource,
      sourceId: sourceId,
      cancelToken: cancelToken,
    );

    final GalleryImage _imageCopyWith = oriImage.copyWith(
      sourceId: _image.sourceId,
      imageUrl: _image.imageUrl,
      imageWidth: _image.imageWidth,
      imageHeight: _image.imageHeight,
    );

    return _imageCopyWith;
  }

  Future<List<GalleryImage>> _fetchImages({
    required int ser,
    required int fileCount,
    required String url,
    bool isRefresh = false,
    int? firstPageCount,
    CancelToken? cancelToken,
  }) async {
    final int page = firstPageCount != null ? (ser - 1) ~/ firstPageCount : 0;
    loggerSimple.d('ser:$ser 所在页码为$page');

    final List<GalleryImage> _moreImageList = await Api.getGalleryImage(
      url,
      page: page,
      cancelToken: cancelToken,
      refresh: isRefresh, // 刷新画廊后加载缩略图不能从缓存读取，否则在改变每页数量后加载画廊会出错
    );

    return _moreImageList;
  }
}
