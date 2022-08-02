import 'package:fehviewer/common/controller/gallerycache_controller.dart';
import 'package:fehviewer/common/controller/webdav_controller.dart';
import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/network/api.dart';
import 'package:fehviewer/pages/tab/controller/download_view_controller.dart';
import 'package:fehviewer/store/archive_async.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get/get_utils/src/platform/platform_io.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;

import 'download_gallery_item.dart';

const kCardRadius = 10.0;
final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');

class DownloadArchiverItem extends GetView<DownloadViewController> {
  DownloadArchiverItem({
    Key? key,
    required this.index,
    required this.archiverTaskInfo,
  })  : title = archiverTaskInfo.title ?? '',
        progress = archiverTaskInfo.progress ?? 0,
        status = DownloadTaskStatus(archiverTaskInfo.status ?? 0),
        coverUrl = archiverTaskInfo.imgUrl,
        galleryUrl = archiverTaskInfo.galleryUrl,
        galleryGid = archiverTaskInfo.gid,
        filePath = path.join(
            archiverTaskInfo.savedDir ?? '', archiverTaskInfo.fileName),
        timeCreated = archiverTaskInfo.timeCreated != null
            ? DateTime.fromMillisecondsSinceEpoch(
                archiverTaskInfo.timeCreated ?? 0)
            : null,
        resolution = archiverTaskInfo.resolution,
        super(key: key);

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
      height: 84,
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
                onTap: () async {
                  logger.d(
                      'gid: $galleryGid\npath:\n$filePath\n${filePath.realArchiverPath}');
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

                  // 异步读取zip
                  final tuple =
                      await readAsyncArchive(filePath.realArchiverPath);
                  final asyncArchive = tuple.item1;
                  final inputStream = tuple.item2;
                  logger.v('${asyncArchive.length}');
                  logger.v(
                      '${asyncArchive.files.map((e) => e.name).join('\n')} ');

                  // 进入阅读
                  await NavigatorUtil.goGalleryViewPageArchiver(
                      lastIndex ?? 0, asyncArchive, '$gid');

                  inputStream.close();
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              maxLines: 3,
                              style: const TextStyle(
                                fontSize: 13,
                                height: 1.2,
                              ),
                            ).paddingOnly(bottom: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (resolution?.isNotEmpty ?? false)
                                  Text(
                                    resolution ?? '',
                                    style: TextStyle(
                                      fontSize: 11,
                                      height: 1.2,
                                      fontWeight: FontWeight.w600,
                                      color: CupertinoDynamicColor.resolve(
                                          CupertinoColors.secondaryLabel,
                                          context),
                                    ),
                                  )
                                else
                                  const SizedBox.shrink(),
                                if (timeCreated != null &&
                                    status != DownloadTaskStatus.running &&
                                    status != DownloadTaskStatus.paused)
                                  Text(
                                    formatter.format(timeCreated!),
                                    style: TextStyle(
                                      fontSize: 10,
                                      height: 1.2,
                                      color: CupertinoDynamicColor.resolve(
                                          CupertinoColors.secondaryLabel,
                                          context),
                                    ),
                                  )
                                else
                                  const SizedBox.shrink(),
                              ],
                            ),
                          ],
                        ).paddingSymmetric(vertical: 4),
                      ),
                      // 进度条
                      if (status == DownloadTaskStatus.running ||
                          status == DownloadTaskStatus.paused)
                        Row(
                          children: [
                            Expanded(
                              child: LinearProgressIndicator(
                                value: progress / 100.0,
                                backgroundColor: CupertinoDynamicColor.resolve(
                                    CupertinoColors.secondarySystemFill,
                                    context),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    CupertinoDynamicColor.resolve(
                                        CupertinoColors.activeBlue, context)),
                              ).paddingOnly(right: 8.0),
                            ),
                            Text(
                              '$progress %',
                              style: const TextStyle(
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
            _getIcon(),
          ],
        ),
      ),
    );
  }

  Widget _buildCover() {
    return GestureDetector(
      child: Container(
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
        logger.v('$galleryUrl ');
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

  Widget _getIcon() {
    final _taskInfo = controller.archiverTasks[index];

    final Map<DownloadTaskStatus, Widget> statusMap = {
      // 下载时，显示暂停按钮
      DownloadTaskStatus.running: CupertinoTheme(
        data: const CupertinoThemeData(primaryColor: CupertinoColors.systemRed),
        child: !GeneralPlatform.isIOS || kDebugMode
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
      ),
      // 完成时 按下无动作
      DownloadTaskStatus.complete: CupertinoTheme(
        data:
            const CupertinoThemeData(primaryColor: CupertinoColors.activeGreen),
        child: CupertinoButton(
          padding: const EdgeInsets.all(0),
          child: const Icon(
            FontAwesomeIcons.check,
            size: 18,
          ),
          onPressed: () {},
        ),
      ),
      // 暂停时 显示继续按钮。按下恢复任务
      DownloadTaskStatus.paused: CupertinoTheme(
        data:
            const CupertinoThemeData(primaryColor: CupertinoColors.activeBlue),
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
      ),
      // 失败时 显示重试按钮。按下重试任务
      DownloadTaskStatus.failed: CupertinoTheme(
        data: const CupertinoThemeData(primaryColor: CupertinoColors.systemRed),
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
      ),
      // 取消状态 显示重试按钮。按下重试任务
      DownloadTaskStatus.canceled: CupertinoButton(
        padding: const EdgeInsets.all(0),
        child: const Icon(
          FontAwesomeIcons.arrowRotateLeft,
          size: 18,
        ),
        onPressed: () {
          controller.retryArchiverDownload(index);
        },
      ).paddingSymmetric(),
      DownloadTaskStatus.enqueued: Container(
        width: 40,
        height: 40,
        child: const CupertinoActivityIndicator(
          radius: 10,
        ),
      ),
      DownloadTaskStatus.undefined: Container(
        width: 40,
        height: 40,
        child: const CupertinoActivityIndicator(
          radius: 10,
        ),
      ),
    };

    return statusMap[status] ?? const SizedBox(width: 40);
  }
}
