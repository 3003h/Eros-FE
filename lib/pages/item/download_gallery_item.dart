import 'package:extended_image/extended_image.dart';
import 'package:fehviewer/common/controller/gallerycache_controller.dart';
import 'package:fehviewer/common/isolate_download/download_manager.dart';
import 'package:fehviewer/models/gallery_cache.dart';
import 'package:fehviewer/network/gallery_request.dart';
import 'package:fehviewer/pages/tab/controller/download_view_controller.dart';
import 'package:fehviewer/route/navigator_util.dart';
import 'package:fehviewer/store/floor/entity/gallery_image_task.dart';
import 'package:fehviewer/store/floor/entity/gallery_task.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;

class DownloadGalleryItem extends GetView<DownloadViewController> {
  const DownloadGalleryItem({
    Key? key,
    required this.title,
    required this.status,
    required this.gid,
    required this.url,
    required this.filecount,
    this.completeCount = 0,
    this.coverimagePath,
    this.coverUrl,
    this.speed,
    this.addTime,
  }) : super(key: key);
  final String title;
  final int filecount;
  final int completeCount;
  final TaskStatus status;
  final int gid;
  final String? coverimagePath;
  final String? coverUrl;
  final String? speed;
  final String? url;
  final String? addTime;

  @override
  Widget build(BuildContext context) {
    final _complete = status == TaskStatus.complete;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        final List<GalleryImageTask> imageTasks =
            await controller.getImageTasks(gid);
        final GalleryTask? gTask = controller.galleryTaskMap[gid];
        if (gTask == null) {
          return;
        }

        final List<String> pics = imageTasks
            .where((element) =>
                element.filePath != null && element.filePath!.isNotEmpty)
            .map((e) => path.join(gTask.realDirPath ?? '', e.filePath ?? ''))
            .toList();

        final GalleryCache? _galleryCache =
            Get.find<GalleryCacheController>().getGalleryCache('$gid');
        final lastIndex = _galleryCache?.lastIndex ?? 0;

        NavigatorUtil.goGalleryViewPageFile(lastIndex, pics, '$gid');
      },
      child: Container(
        padding: const EdgeInsets.only(top: 4, bottom: 4, left: 20, right: 16),
        height: 110,
        // constraints: const BoxConstraints(minHeight: 120),
        child: Row(
          children: [
            // 封面
            GestureDetector(
              child: _CoverImage(path: coverimagePath, url: coverUrl)
                  .paddingOnly(right: 8),
              onTap: () async {
                NavigatorUtil.goGalleryPage(url: '${Api.getBaseUrl()}$url');
              },
            ),
            // 右侧
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    softWrap: true,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.2,
                    ),
                  ).paddingSymmetric(vertical: 4),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                addTime ?? '',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: CupertinoDynamicColor.resolve(
                                      CupertinoColors.secondaryLabel, context),
                                ),
                              ),
                              const Spacer(),
                              // 进度条行
                              if (!_complete)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: completeCount / filecount,
                                    backgroundColor:
                                        CupertinoDynamicColor.resolve(
                                            CupertinoColors.secondarySystemFill,
                                            context),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      CupertinoDynamicColor.resolve(
                                          CupertinoColors.activeBlue, context),
                                    ),
                                  ),
                                ),
                              // 速度和进度行
                              Row(
                                children: [
                                  Text(
                                    speed != null ? '$speed/s' : '',
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: CupertinoDynamicColor.resolve(
                                            CupertinoColors.secondaryLabel,
                                            context)),
                                  ),
                                  const Spacer(),
                                  Text(
                                    _complete
                                        ? '$filecount'
                                        : '$completeCount/$filecount',
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: CupertinoDynamicColor.resolve(
                                            CupertinoColors.secondaryLabel,
                                            context)),
                                  ),
                                  _getIcon(),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getIcon() {
    final GalleryTask? _taskInfo = controller.galleryTaskMap[gid];
    const minSize = 30.0;
    const iconSize = 18.0;
    const buttonPadding = EdgeInsets.only(left: 8.0);

    final Map<TaskStatus, Widget> statusMap = {
      // 下载时，显示暂停按钮
      TaskStatus.running: CupertinoTheme(
        data: const CupertinoThemeData(primaryColor: CupertinoColors.systemRed),
        child: CupertinoButton(
          padding: buttonPadding,
          minSize: minSize,
          child: const Icon(
            FontAwesomeIcons.pause,
            size: iconSize,
          ),
          onPressed: () {
            controller.pauseGalleryDownload(_taskInfo?.gid);
          },
        ),
      ),
      // 完成时 按下无动作
      TaskStatus.complete: CupertinoTheme(
        data:
            const CupertinoThemeData(primaryColor: CupertinoColors.activeBlue),
        child: CupertinoButton(
          padding: buttonPadding,
          minSize: minSize,
          child: const Icon(
            FontAwesomeIcons.check,
            size: iconSize,
          ),
          onPressed: () {},
        ),
      ),
      // 暂停时 显示继续按钮。按下恢复任务
      TaskStatus.paused: CupertinoTheme(
        data:
            const CupertinoThemeData(primaryColor: CupertinoColors.activeGreen),
        child: CupertinoButton(
          padding: buttonPadding,
          minSize: minSize,
          child: const Icon(
            FontAwesomeIcons.play,
            size: iconSize,
          ),
          onPressed: () {
            controller.resumeGalleryDownload(_taskInfo?.gid);
          },
        ),
      ),
      // 失败时 显示重试按钮。按下重试任务
      TaskStatus.failed: CupertinoButton(
        padding: buttonPadding,
        minSize: minSize,
        child: const Icon(
          FontAwesomeIcons.play,
          size: iconSize,
        ),
        onPressed: () {
          controller.retryArchiverDownload(gid);
        },
      ),
      // 取消状态 显示重试按钮。按下重试任务
      TaskStatus.canceled: CupertinoButton(
        padding: buttonPadding,
        minSize: minSize,
        child: const Icon(
          FontAwesomeIcons.redo,
          size: iconSize,
        ),
        onPressed: () {
          controller.retryArchiverDownload(gid);
        },
      ).paddingSymmetric(),
      TaskStatus.enqueued: Container(
        width: minSize,
        height: minSize,
        child: const CupertinoActivityIndicator(
          radius: 12,
        ),
      ),
      TaskStatus.undefined: Container(
        width: minSize,
        height: minSize,
        child: const CupertinoActivityIndicator(
          radius: 12,
        ),
      ),
    };

    return statusMap[status] ?? const SizedBox(width: 40);
  }
}

class _CoverImage extends StatelessWidget {
  const _CoverImage({
    this.url,
    this.path,
    Key? key,
  }) : super(key: key);

  final String? path;
  final String? url;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      decoration: BoxDecoration(
        boxShadow: [
          //阴影
          BoxShadow(
            color: CupertinoDynamicColor.resolve(
                CupertinoColors.systemGrey5, Get.context!),
            blurRadius: 3,
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: () {
          if (path != null) {
            return ExtendedImage.file(
              File(path!),
              fit: BoxFit.fitWidth,
            );
          } else if (url != null) {
            return ExtendedImage.network(
              url!,
              fit: BoxFit.fitWidth,
            );
          } else {
            return const SizedBox.expand();
          }
        }(),
      ),
    );
  }
}
