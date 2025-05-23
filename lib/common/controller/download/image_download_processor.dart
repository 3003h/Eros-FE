import 'dart:io';

import 'package:dio/dio.dart';
import 'package:eros_fe/common/controller/cache_controller.dart';
import 'package:eros_fe/common/controller/download/download_task_manager.dart';
import 'package:eros_fe/common/controller/download_state.dart';
import 'package:eros_fe/component/exception/error.dart';
import 'package:eros_fe/index.dart';
import 'package:eros_fe/network/api.dart';
import 'package:eros_fe/network/request.dart';
import 'package:eros_fe/store/db/entity/gallery_image_task.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:shared_storage/shared_storage.dart' as ss;
import 'package:sprintf/sprintf.dart' as sp;

const int _kDefNameLen = 4;

/// 用于传递下载信息的数据类
class ImageDownloadInfo {
  ImageDownloadInfo({
    required this.imageUrl,
    required this.updatedImage,
    required this.fileNameWithoutExtension,
  });
  final String imageUrl;
  final GalleryImage updatedImage;
  final String fileNameWithoutExtension;
}

class ImageDownloadProcessor {
  ImageDownloadProcessor(this.dState, this.cacheController);
  final DownloadState dState;
  final CacheController cacheController;

  /// 下载图片流程控制
  Future<void> downloadImageFlow(
    GalleryImage image,
    GalleryImageTask? imageTask,
    int gid,
    String downloadParentPath,
    int maxSer, {
    bool downloadOrigImage = false,
    bool reDownload = false,
    CancelToken? cancelToken,
    ValueChanged<String>? onDownloadCompleteWithFileName,
    String? showKey,
    Future<void> Function(
            int gid, GalleryImage image, String? fileName, int? status)?
        putImageTaskCallback,
  }) async {
    loggerSimple.t('${image.ser} start');
    if (reDownload) {
      logger.t('${image.ser} redownload ');
    }

    // 获取下载URL和更新后的图片信息
    final downloadInfo = await getImageDownloadInfo(
      image,
      imageTask,
      gid,
      maxSer,
      downloadOrigImage: downloadOrigImage,
      reDownload: reDownload,
      cancelToken: cancelToken,
      showKey: showKey,
      updateShowKeyCallback: (gid, showKey, {updateDB}) {
        dState.showKeyMap[gid] = showKey;
        if (!(dState.showKeyCompleteMap[gid]?.isCompleted ?? false)) {
          dState.showKeyCompleteMap[gid]?.complete(true);
        }
      },
    );

    // 定义下载进度回调
    void progressCallback(int count, int total) {
      dState.downloadCounts['${gid}_${image.ser}'] = count;
    }

    try {
      // 下载图片
      await downloadToPath(
        downloadInfo.imageUrl,
        downloadParentPath,
        downloadInfo.fileNameWithoutExtension,
        cancelToken: cancelToken,
        onDownloadCompleteWithFileName: (fileName) async {
          if (putImageTaskCallback != null) {
            await putImageTaskCallback(
              gid,
              downloadInfo.updatedImage,
              fileName,
              TaskStatus.complete.value,
            );
          }
          onDownloadCompleteWithFileName?.call(fileName);
        },
        progressCallback: progressCallback,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        await handleExpiredLink(
          image,
          gid,
          downloadParentPath,
          downloadInfo.fileNameWithoutExtension,
          downloadOrigImage,
          cancelToken,
          progressCallback,
          onDownloadCompleteWithFileName,
          downloadInfo.updatedImage.sourceId,
          showKey,
          putImageTaskCallback: putImageTaskCallback,
        );
      } else {
        rethrow;
      }
    }
  }

  /// 获取下载URL和更新的图片信息
  Future<ImageDownloadInfo> getImageDownloadInfo(
    GalleryImage image,
    GalleryImageTask? imageTask,
    int gid,
    int maxSer, {
    bool downloadOrigImage = false,
    bool reDownload = false,
    CancelToken? cancelToken,
    String? showKey,
    Function? updateShowKeyCallback,
    Function? addAllImagesCallback,
    Function? putImageTaskCallback,
  }) async {
    late String imageUrl;
    late GalleryImage updatedImage;
    late String fileNameWithoutExtension;

    // 存在imageTask的 用原url下载
    final bool useOldUrl = imageTask != null &&
        imageTask.imageUrl != null &&
        (imageTask.imageUrl?.isNotEmpty ?? false);
    final String? imageUrlFromTask = imageTask?.imageUrl;

    // 使用原有url下载
    if (useOldUrl && !reDownload && imageUrlFromTask != null) {
      logger.t('使用原有url下载 ${image.ser} DL $imageUrlFromTask');

      imageUrl = imageUrlFromTask;
      updatedImage = image;
      if (imageTask.filePath != null && imageTask.filePath!.isNotEmpty) {
        fileNameWithoutExtension =
            path.basenameWithoutExtension(imageTask.filePath!);
      } else {
        fileNameWithoutExtension = genFileNameWithoutExtension(image, maxSer);
      }
    } else if (image.href != null) {
      logger.t('获取新的图片url');
      if (reDownload) {
        logger.d(
            '重下载 ${image.ser}, 清除缓存 ${image.href} , sourceId:${imageTask?.sourceId}');
        cacheController.clearDioCache(path: image.href ?? '');
      }

      // 否则先请求解析新的图片地址
      final GalleryImage imageFetched = await fetchImageInfo(
        image.href!,
        itemSer: image.ser,
        image: image,
        gid: gid,
        cancelToken: cancelToken,
        changeSource: reDownload,
        sourceId: imageTask?.sourceId,
        showKey: showKey,
      );

      if (imageFetched.imageUrl == null) {
        throw EhError(error: 'get imageUrl error');
      }
      // 更新 showkey
      final showKey0 = imageFetched.showKey;
      if (showKey0 != null && updateShowKeyCallback != null) {
        updateShowKeyCallback(gid, showKey0, updateDB: true);
      }

      // 目标下载地址
      imageUrl = downloadOrigImage
          ? imageFetched.originImageUrl ?? imageFetched.imageUrl!
          : imageFetched.imageUrl!;
      updatedImage = imageFetched;

      logger.t(
          'downloadOrigImage:$downloadOrigImage\nDownload imageUrl:$imageUrl');

      fileNameWithoutExtension =
          genFileNameWithoutExtension(imageFetched, maxSer);
      logger.t('fileNameWithoutExtension:$fileNameWithoutExtension');

      if (addAllImagesCallback != null) {
        addAllImagesCallback(gid, [imageFetched]);
      }

      if (putImageTaskCallback != null) {
        await putImageTaskCallback(
            gid, imageFetched, null, TaskStatus.running.value);
      }

      if (reDownload) {
        logger.t('${imageFetched.href}\n${imageFetched.imageUrl} ');
      }
    } else {
      throw EhError(error: 'get image url error');
    }

    return ImageDownloadInfo(
      imageUrl: imageUrl,
      updatedImage: updatedImage,
      fileNameWithoutExtension: fileNameWithoutExtension,
    );
  }

  /// 处理过期链接
  Future<void> handleExpiredLink(
    GalleryImage image,
    int gid,
    String downloadParentPath,
    String fileNameWithoutExtension,
    bool downloadOrigImage,
    CancelToken? cancelToken,
    ProgressCallback progressCallback,
    ValueChanged<String>? onDownloadCompleteWithFileName,
    String? sourceId,
    String? showKey, {
    Function? addAllImagesCallback,
    Future<void> Function(
            int gid, GalleryImage image, String? fileName, int? status)?
        putImageTaskCallback,
  }) async {
    logger.d('403 $gid.${image.ser}下载链接已经失效 需要更新 ${image.href}');
    final GalleryImage imageFetched = await fetchImageInfo(
      image.href!,
      itemSer: image.ser,
      image: image,
      gid: gid,
      cancelToken: cancelToken,
      sourceId: sourceId,
      changeSource: true,
      showKey: showKey,
    );

    // 更新 showkey
    final showKey0 = imageFetched.showKey;
    if (showKey0 != null) {
      dState.showKeyMap[gid] = showKey0;
      if (!(dState.showKeyCompleteMap[gid]?.isCompleted ?? false)) {
        dState.showKeyCompleteMap[gid]?.complete(true);
      }
    }

    final newImageUrl = downloadOrigImage
        ? imageFetched.originImageUrl ?? imageFetched.imageUrl!
        : imageFetched.imageUrl!;

    logger.d('重下载 imageUrl:$newImageUrl');

    if (addAllImagesCallback != null) {
      addAllImagesCallback(gid, [imageFetched]);
    }

    if (putImageTaskCallback != null) {
      await putImageTaskCallback(
          gid, imageFetched, null, TaskStatus.running.value);
    }

    await downloadToPath(
      newImageUrl,
      downloadParentPath,
      fileNameWithoutExtension,
      cancelToken: cancelToken,
      onDownloadCompleteWithFileName: (fileName) async {
        if (putImageTaskCallback != null) {
          await putImageTaskCallback(
            gid,
            imageFetched,
            fileName,
            TaskStatus.complete.value,
          );
        }
        onDownloadCompleteWithFileName?.call(fileName);
      },
      progressCallback: progressCallback,
    );
  }

  /// 下载文件到指定路径
  Future<void> downloadToPath(
    String url,
    String parentPath,
    String fileNameWithoutExtension, {
    CancelToken? cancelToken,
    ValueChanged<String>? onDownloadCompleteWithFileName,
    ProgressCallback? progressCallback,
  }) async {
    // 根据url读取缓存 存在的话直接将缓存写文件
    try {
      final filePath = await Api.saveImageFromExtendedCache(
        imageUrl: url,
        parentPath: parentPath,
        fileNameWithoutExtension: fileNameWithoutExtension,
      );
      if (filePath != null) {
        logger.d('从缓存读取文件 $filePath');
        onDownloadCompleteWithFileName?.call(path.basename(filePath));
        return;
      }
    } catch (e) {
      logger.e('$e');
    }

    // 缓存不存在的话下载
    String realSaveFullPath = '';
    String tempSavePath = '';
    String savePathBuild(Headers headers) {
      logger.t('headers:\n$headers');
      final contentDisposition = headers.value('content-disposition');
      logger.t('contentDisposition $contentDisposition');
      final filename =
          contentDisposition?.split(RegExp(r"filename(=|\*=UTF-8'')")).last ??
              '';
      final fileNameDecode =
          Uri.decodeFull(filename).replaceAll('/', '_').replaceAll('"', '');

      late String ext;
      if (fileNameDecode.isEmpty) {
        logger.t('url: $url');
        ext = path.extension(url);
      } else {
        logger.t(
            'fileNameDecode: $fileNameDecode, fileBaseNameNotExt: $fileNameWithoutExtension');
        ext = path.extension(fileNameDecode);
      }

      if (parentPath.isContentUri) {
        // temp save path ,临时下载路径，完成后再复制到SAF路径
        tempSavePath = path.join(
          Global.extStoreTempPath,
          'temp_download',
          '${generateUuidv4()}_$fileNameWithoutExtension$ext',
        );
        logger.t('SAF temp savePath:$tempSavePath');
        return tempSavePath;
      } else {
        realSaveFullPath =
            path.join(parentPath, '$fileNameWithoutExtension$ext');
        return realSaveFullPath;
      }
    }

    // 调用 request 下载文件
    await ehDownload(
      url: url,
      savePathBuilder: savePathBuild,
      cancelToken: cancelToken,
      onDownloadComplete: () async {
        logger.t('onDownloadComplete');

        if (parentPath.isContentUri && tempSavePath.isNotEmpty) {
          // read file
          final File file = File(tempSavePath);

          // 限定 [0-9a-zA-Z]
          final extension = path
              .extension(tempSavePath)
              .replaceAll(RegExp(r'[^0-9a-zA-Z.]'), '');

          logger.t('extension $extension');

          final parentUri = Uri.parse(parentPath);

          // SAF write file
          final fileName = '$fileNameWithoutExtension$extension';

          file
              .readAsBytes()
              .then((bytes) {
                ss.createFileAsBytes(
                  parentUri,
                  mimeType: '*/*',
                  displayName: fileName,
                  bytes: bytes,
                );
              })
              .then((value) => file.delete())
              .whenComplete(
                  () => onDownloadCompleteWithFileName?.call(fileName));
        } else {
          logger.t('normal realSaveFullPath $realSaveFullPath');
          onDownloadCompleteWithFileName?.call(path.basename(realSaveFullPath));
        }
      },
      progressCallback: progressCallback,
    );
  }

  /// 根据ser获取image信息
  Future<GalleryImage?> checkAndGetImageList(
    int gid,
    int itemSer,
    int fileCount,
    int firstPageCount,
    String? url, {
    CancelToken? cancelToken,
    Function? addAllImagesCallback,
    Function? getImageObjCallback,
  }) async {
    GalleryImage? tImage;
    if (getImageObjCallback != null) {
      tImage = await Function.apply(getImageObjCallback, [gid, itemSer]);
    }

    if (tImage == null && url != null) {
      loggerSimple.t('ser:$itemSer 所在页尚未获取， 开始获取');
      final imageList = await fetchImageList(
        ser: itemSer,
        fileCount: fileCount,
        firstPageCount: firstPageCount,
        url: url,
        cancelToken: cancelToken,
      );
      loggerSimple.t('imageList.length: ${imageList.length}');
      if (addAllImagesCallback != null) {
        addAllImagesCallback(gid, imageList);
      }
      if (getImageObjCallback != null) {
        tImage = await Function.apply(getImageObjCallback, [gid, itemSer]);
      }
    }

    return tImage;
  }

  /// 获取第一页的预览图数量
  Future<int> fetchFirstPageCount(
    String url, {
    CancelToken? cancelToken,
  }) async {
    final List<GalleryImage> moreImageList = await getGalleryImageList(
      url,
      page: 0,
      cancelToken: cancelToken,
      refresh: true, // 刷新画廊后加载缩略图不能从缓存读取，否则在改变每页数量后加载画廊会出错
    );
    return moreImageList.length;
  }

  /// 获取图片信息
  Future<GalleryImage> fetchImageInfo(
    String href, {
    required int itemSer,
    required GalleryImage image,
    required int gid,
    bool changeSource = false,
    String? sourceId,
    CancelToken? cancelToken,
    String? showKey,
  }) async {
    final String? sourceId0 = changeSource ? sourceId : '';

    GalleryImage? image0;

    try {
      image0 = await fetchImageInfoByApi(
        href,
        refresh: changeSource,
        sourceId: sourceId0,
        cancelToken: cancelToken,
        showKey: showKey,
      );
    } on EhError catch (e) {
      logger.e('获取图片信息失败 $e');
      if (e.type == EhErrorType.keyMismatch) {
        logger.d('showkey 不匹配，更新 showkey');
        // 需要外部传入回调函数来更新showkey
        image0 = await fetchImageInfoByApi(
          href,
          refresh: changeSource,
          sourceId: sourceId0,
          cancelToken: cancelToken,
        );
      } else {
        rethrow;
      }
    } catch (e) {
      logger.e('获取图片信息失败 $e');
      rethrow;
    }

    logger.t('_image from fetch ${image0?.toJson()}');

    if (image0 == null) {
      return image;
    }

    final GalleryImage imageCopyWith = image.copyWith(
      sourceId: image0.sourceId.oN,
      imageUrl: image0.imageUrl.oN,
      imageWidth: image0.imageWidth.oN,
      imageHeight: image0.imageHeight.oN,
      originImageUrl: image0.originImageUrl.oN,
      filename: image0.filename.oN,
      showKey: image0.showKey.oN,
    );

    return imageCopyWith;
  }

  /// 获取图片列表
  Future<List<GalleryImage>> fetchImageList({
    required int ser,
    required int fileCount,
    required String url,
    bool isRefresh = false,
    required int firstPageCount,
    CancelToken? cancelToken,
  }) async {
    logger.t('firstPageCount $firstPageCount');
    final int page = (ser - 1) ~/ firstPageCount;
    logger.t('ser:$ser 所在页码为$page');

    final List<GalleryImage> moreImageList = await getGalleryImageList(
      url,
      page: page,
      cancelToken: cancelToken,
      refresh: isRefresh, // 刷新画廊后加载缩略图不能从缓存读取，否则在改变每页数量后加载画廊会出错
    );

    logger.t('获取到的图片列表 ${moreImageList.length}');

    return moreImageList;
  }

  /// 生成文件名
  String genFileNameWithoutExtension(GalleryImage galleryImage, int maxSer) {
    final String fileNameWithoutExtension = '$maxSer'.length > _kDefNameLen
        ? sp.sprintf('%0${'$maxSer'.length}d', [galleryImage.ser])
        : sp.sprintf('%0${_kDefNameLen}d', [galleryImage.ser]);
    return fileNameWithoutExtension;
  }
}
