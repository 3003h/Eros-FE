import 'package:dio/dio.dart';
import 'package:executor/executor.dart';
import 'package:fehviewer/common/service/depth_service.dart';
import 'package:fehviewer/models/base/eh_models.dart';
import 'package:fehviewer/network/gallery_request.dart';
import 'package:fehviewer/pages/gallery/controller/gallery_page_controller.dart';
import 'package:fehviewer/store/floor/entity/gallery_image_task.dart';
import 'package:fehviewer/store/floor/entity/gallery_task.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:get/get.dart';
import 'package:collection/collection.dart';

final DownloadManager downloadManager = DownloadManager();

class DownloadManager {
  factory DownloadManager() => _instance;

  DownloadManager._();

  static final DownloadManager _instance = DownloadManager._();

  final executor = Executor(concurrency: 5);

  final downloadMap = <String, List<GalleryImage>>{};

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

  /// 开始下载
  Future<void> startTask(
      {required GalleryTask galleryTask,
      required List<GalleryImageTask> imageTasksOri,
      String? downloadPath}) async {
    logger.d('addTask ${galleryTask.gid} ${galleryTask.title}');

    final GalleryPageController _pageController = Get.find(tag: pageCtrlDepth);
    final filecount = _pageController.filecount;
    final url = _pageController.galleryItem.url;
    final fCount = _pageController.firstPageImage.length;
    final gidStr = _pageController.gid;

    // 初始化
    _initDownloadMapByGid(_pageController.gid, images: _pageController.images);

    logger.d('filecount:$filecount url:$url');
    // 下载
    for (int index = 0; index < filecount; index++) {
      executor.scheduleTask(() async {
        final itemSer = index + 1;
        GalleryImage? tImage = _getImageObj(gidStr, itemSer);

        if (tImage == null && url != null) {
          loggerSimple.d('ser:$itemSer 所在页尚未获取， 开始获取');
          final images = await _fetchImages(
            ser: itemSer,
            fileCount: filecount,
            firstPageCount: fCount,
            url: url,
          );
          loggerSimple.d('images.length: ${images.length}');
          _addAllImages(gidStr, images);
          tImage = _getImageObj(gidStr, itemSer);
        }

        if (tImage != null) {
          // 第一页的
          await _downloadImage(tImage);
        }
      });
    }
  }

  Future<void> _downloadImage(GalleryImage image) async {
    loggerSimple.d('${image.ser} ${image.href} start');
    await Future.delayed(Duration(milliseconds: 500));
    loggerSimple.d('${image.ser} ${image.href} complete');
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
