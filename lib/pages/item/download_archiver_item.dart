import 'dart:io';

import 'package:eros_fe/common/controller/gallerycache_controller.dart';
import 'package:eros_fe/common/controller/webdav_controller.dart';
import 'package:eros_fe/common/service/theme_service.dart';
import 'package:eros_fe/index.dart';
import 'package:eros_fe/network/api.dart';
import 'package:eros_fe/pages/tab/controller/download_view_controller.dart';
import 'package:eros_fe/store/archive_async.dart';
import 'package:eros_fe/utils/saf_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:saf/saf.dart';

import 'download_gallery_item.dart';

const kCardRadius = 10.0;
final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');

class DownloadArchiverItem extends GetView<DownloadViewController> {
  DownloadArchiverItem({
    super.key,
    required this.index,
    required this.archiverTaskInfo,
  })  : title = archiverTaskInfo.title ?? '',
        progress = archiverTaskInfo.progress ?? 0,
        status = intToDownloadStatus(archiverTaskInfo.status ?? 0),
        coverUrl = archiverTaskInfo.imgUrl,
        galleryUrl = archiverTaskInfo.galleryUrl,
        galleryGid = archiverTaskInfo.gid,
        filePath = (archiverTaskInfo.savedDir == null ||
                (archiverTaskInfo.savedDir?.isContentUri ?? false))
            ? archiverTaskInfo.safUri ?? ''
            : path.join(
                archiverTaskInfo.savedDir ?? '', archiverTaskInfo.fileName),
        timeCreated = archiverTaskInfo.timeCreated != null
            ? DateTime.fromMillisecondsSinceEpoch(
                archiverTaskInfo.timeCreated ?? 0)
            : null,
        resolution = archiverTaskInfo.resolution;

  final String title;
  final int progress;
  final DownloadTaskStatus status;
  final int index;
  final String? coverUrl;
  final String? galleryUrl;
  final String? galleryGid;
  final String filePath;
  final DateTime? timeCreated;
  final String? resolution;

  final DownloadArchiverTaskInfo archiverTaskInfo;

  @override
  Widget build(BuildContext context) {
    logger.t('timeCreated $timeCreated, resolution $resolution');

    final showProgress = status == DownloadTaskStatus.running ||
        status == DownloadTaskStatus.paused;

    return Container(
      padding: const EdgeInsets.only(right: 10),
      margin: const EdgeInsets.fromLTRB(10, 5, 10, 10),
      decoration: BoxDecoration(
        boxShadow: ehTheme.isDarkMode
            ? null
            : [
                BoxShadow(
                  color: CupertinoDynamicColor.resolve(
                          CupertinoColors.systemGrey5, Get.context!)
                      .withOpacity(0.7),
                  blurRadius: 10,
                  spreadRadius: 1,
                  offset: const Offset(2, 2),
                )
              ],
        color: ehTheme.itemBackgroundColor,
        borderRadius: BorderRadius.circular(kCardRadius),
      ),
      height: 100,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(kCardRadius),
        child: Row(
          children: [
            Column(
              children: [
                Expanded(child: _buildCover().paddingOnly(right: 12)),
              ],
            ),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _onTap(context),
                child: Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 标题
                              Text(
                                title,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  height: 1.2,
                                ),
                              ).paddingOnly(bottom: 4),
                            ],
                          ),
                        ),
                      ),
                      AnimatedPadding(
                        curve: Curves.easeIn,
                        padding: EdgeInsets.only(
                          bottom: showProgress ? 0 : 8,
                        ),
                        duration: const Duration(milliseconds: 300),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // 分辨率
                            if (resolution?.isNotEmpty ?? false)
                              Text(
                                resolution ?? '',
                                style: TextStyle(
                                  fontSize: 11,
                                  height: 1.2,
                                  fontWeight: FontWeight.w600,
                                  color: CupertinoDynamicColor.resolve(
                                      CupertinoColors.secondaryLabel, context),
                                ),
                              )
                            else
                              const SizedBox.shrink(),
                            // 创建时间
                            if (timeCreated != null)
                              Text(
                                formatter.format(timeCreated!),
                                style: TextStyle(
                                  fontSize: 10,
                                  height: 1.2,
                                  color: CupertinoDynamicColor.resolve(
                                      CupertinoColors.secondaryLabel, context),
                                ),
                              )
                            else
                              const SizedBox.shrink(),
                          ],
                        ),
                      ),
                      AnimatedCrossFade(
                        firstCurve: Curves.easeIn,
                        firstChild: Row(
                          children: [
                            Expanded(
                              child: LinearProgressIndicator(
                                borderRadius: BorderRadius.circular(4),
                                value: progress / 100.0,
                                backgroundColor: CupertinoDynamicColor.resolve(
                                    CupertinoColors.secondarySystemFill,
                                    context),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    CupertinoDynamicColor.resolve(
                                        CupertinoColors.activeBlue, context)),
                              ).paddingOnly(right: 8.0),
                            ),
                            Container(
                              constraints: const BoxConstraints(minWidth: 30),
                              alignment: Alignment.center,
                              child: Text(
                                '$progress %',
                                style: const TextStyle(
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                        secondChild: const SizedBox.shrink(),
                        crossFadeState: showProgress
                            ? CrossFadeState.showFirst
                            : CrossFadeState.showSecond,
                        duration: const Duration(milliseconds: 300),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            TaskActionButton(index: index, status: status),
          ],
        ),
      ),
    );
  }

  Future<void> _onTap(BuildContext context) async {
    logger.d('<<>>>>>>> archiverTaskInfo: ${archiverTaskInfo.toJson()}');

    logger
        .d('<<>>>>>>> archiverTaskInfo.savedDir: ${archiverTaskInfo.savedDir}');
    logger.d(
        '<<>>>>>>> gid: $galleryGid\npath: \nfilePath: $filePath\nrealArchiverPath: ${filePath.realArchiverPath}');
    if (galleryGid == null) {
      return;
    }
    if (status != DownloadTaskStatus.complete) {
      return;
    }

    final gid = int.parse(galleryGid ?? '0');

    // 进度
    int? lastIndex = 0;
    if (Get.find<WebdavController>().syncReadProgress) {
      lastIndex = await syncReadProgress(context, gid);
    }
    final cache = await Get.find<GalleryCacheController>()
        .listenGalleryCache('$gid', sync: false)
        .first;
    if (cache?.lastIndex != null) {
      lastIndex = cache?.lastIndex;
    }

    late String? archiverPath;
    late String safCacheDirectory;
    if (filePath.realArchiverPath.isContentUri) {
      logger.d('filePath.realArchiverPath ${filePath.realArchiverPath}');
      final result = await safCacheSingle(Uri.parse(filePath.realArchiverPath));
      archiverPath = result.cachePath;
      safCacheDirectory = result.parentPath;
    } else {
      archiverPath = filePath.realArchiverPath;
    }

    if (archiverPath == null) {
      throw Exception('archiverPath is null');
    }

    // 异步读取zip
    final result = await readAsyncArchive(archiverPath);
    final asyncArchive = result.asyncArchive;
    final inputStream = result.asyncInputStream;
    logger.t('${asyncArchive.length}');
    logger.t('${asyncArchive.files.map((e) => e.name).join('\n')} ');

    // 进入阅读
    await NavigatorUtil.goGalleryViewPageArchiver(
        lastIndex ?? 0, asyncArchive, '$gid');

    inputStream.close();
    Saf.clearCacheFor(safCacheDirectory);
  }

  Widget _buildCover() {
    return GestureDetector(
      child: SizedBox(
        width: 74,
        child: coverUrl != null && coverUrl!.isNotEmpty
            ? DownloadItemCoverImage(
                url: coverUrl,
                cardType: true,
              )
            : Container(
                color: CupertinoColors.systemGrey5,
                child: Icon(
                  CupertinoIcons.arrow_down_circle,
                  color: CupertinoDynamicColor.resolve(
                      CupertinoColors.systemBackground, Get.context!),
                ),
              ),
      ),
      onTap: () async {
        logger.t('$galleryUrl ');
        String? url = galleryUrl;
        if (url == null) {
          return;
        }
        if (!url.startsWith('http')) {
          url = '${Api.getBaseUrl()}$url';
        }
        NavigatorUtil.goGalleryPage(url: url);
      },
    );
  }
}

class TaskActionButton extends GetView<DownloadViewController> {
  const TaskActionButton({
    super.key,
    required this.index,
    required this.status,
  });
  final int index;
  final DownloadTaskStatus status;
  DownloadArchiverTaskInfo get _taskInfo => controller.archiverTasks[index];

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case DownloadTaskStatus.running:
        // 下载时，显示暂停按钮
        return CupertinoTheme(
          data:
              const CupertinoThemeData(primaryColor: CupertinoColors.systemRed),
          child: !Platform.isIOS
              ? CupertinoButton(
                  padding: const EdgeInsets.all(0),
                  child: const Icon(
                    FontAwesomeIcons.pause,
                    size: 18,
                  ),
                  onPressed: () {
                    controller.pauseArchiverDownload(taskId: _taskInfo.taskId);
                  },
                )
              : CupertinoButton(
                  padding: const EdgeInsets.all(0),
                  child: const Icon(
                    FontAwesomeIcons.stop,
                    size: 18,
                  ),
                  onPressed: () {
                    controller.cancelArchiverDownload(taskId: _taskInfo.taskId);
                  },
                ),
        );
      case DownloadTaskStatus.complete:
        // 完成时 按下无动作
        return CupertinoTheme(
          data: const CupertinoThemeData(
              primaryColor: CupertinoColors.activeGreen),
          child: CupertinoButton(
            padding: const EdgeInsets.all(0),
            child: const Icon(
              FontAwesomeIcons.check,
              size: 18,
            ),
            onPressed: () {},
          ),
        );
      case DownloadTaskStatus.paused:
        // 暂停时 显示继续按钮。按下恢复任务
        return CupertinoTheme(
          data: const CupertinoThemeData(
              primaryColor: CupertinoColors.activeBlue),
          child: CupertinoButton(
            padding: const EdgeInsets.all(0),
            child: const Icon(
              FontAwesomeIcons.play,
              size: 18,
            ),
            onPressed: () {
              controller.resumeArchiverDownload(index);
            },
          ),
        );
      case DownloadTaskStatus.failed:
        // 失败时 显示重试按钮。按下重试任务
        return CupertinoTheme(
          data:
              const CupertinoThemeData(primaryColor: CupertinoColors.systemRed),
          child: CupertinoButton(
            padding: const EdgeInsets.all(0),
            child: const Icon(
              FontAwesomeIcons.arrowRotateLeft,
              size: 18,
            ),
            onPressed: () {
              controller.retryArchiverDownload(index);
            },
          ),
        );
      case DownloadTaskStatus.canceled:
        // 取消状态 显示重试按钮。按下重试任务
        return CupertinoButton(
          padding: const EdgeInsets.all(0),
          child: const Icon(
            FontAwesomeIcons.arrowRotateLeft,
            size: 18,
          ),
          onPressed: () {
            controller.retryArchiverDownload(index);
          },
        ).paddingSymmetric();
      case DownloadTaskStatus.enqueued:
        // 等待状态
        return Container(
          width: 40,
          height: 40,
          child: const CupertinoActivityIndicator(
            radius: 10,
          ),
        );
      case DownloadTaskStatus.undefined:
        return Container(
          width: 40,
          height: 40,
          child: const CupertinoActivityIndicator(
            radius: 10,
          ),
        );
    }
  }
}
