import 'package:extended_image/extended_image.dart';
import 'package:fehviewer/common/isolate_download/download_manager.dart';
import 'package:fehviewer/pages/image_view/view/view_local_page.dart';
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
    required this.index,
    required this.filecount,
    this.completeCount = 0,
    this.coverimagePath,
    this.coverUrl,
  }) : super(key: key);
  final String title;
  final int filecount;
  final int completeCount;
  final TaskStatus status;
  final int index;
  final String? coverimagePath;
  final String? coverUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 8, bottom: 8, left: 20, right: 16),
      height: 100,
      child: Row(
        children: [
          GestureDetector(
            child: _CoverImage(path: coverimagePath, url: coverUrl)
                .paddingOnly(right: 8),
            onTap: () async {
              final List<GalleryImageTask> imageTasks =
                  await controller.getImageTasks(index);
              final gTask = controller.galleryTasks[index];

              final List<String> pics = imageTasks
                  .where((element) =>
                      element.filePath != null && element.filePath!.isNotEmpty)
                  .map((e) => path.join(gTask.dirPath ?? '', e.filePath ?? ''))
                  .toList();

              // Get.to(
              //   ViewLocalPage(
              //     pics: pics,
              //   ),
              //   transition: Transition.fade,
              // );
              NavigatorUtil.goGalleryViewPageFile(0, pics);
            },
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    title,
                    softWrap: true,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.2,
                    ),
                  ).paddingSymmetric(vertical: 4),
                ),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: completeCount / filecount,
                            backgroundColor: CupertinoDynamicColor.resolve(
                                CupertinoColors.secondarySystemFill, context),
                            valueColor: AlwaysStoppedAnimation<Color>(
                                CupertinoDynamicColor.resolve(
                                    CupertinoColors.activeBlue, context)),
                          )).paddingOnly(right: 8.0),
                    ),
                    Text(
                      '$completeCount/$filecount',
                      style: const TextStyle(
                        fontSize: 13,
                      ),
                    ),
                    _getIcon(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _getIcon() {
    final GalleryTask _taskInfo = controller.galleryTasks[index];

    final Map<TaskStatus, Widget> statusMap = {
      // 下载时，显示暂停按钮
      TaskStatus.running: CupertinoTheme(
        data: const CupertinoThemeData(primaryColor: CupertinoColors.systemRed),
        child: CupertinoButton(
          padding: const EdgeInsets.all(0),
          child: const Icon(
            FontAwesomeIcons.pause,
            size: 14,
          ),
          onPressed: () {
            controller.pauseGalleryDownload(_taskInfo.gid);
          },
        ),
      ),
      // 完成时 按下无动作
      TaskStatus.complete: CupertinoTheme(
        data:
            const CupertinoThemeData(primaryColor: CupertinoColors.activeBlue),
        child: CupertinoButton(
          padding: const EdgeInsets.all(0),
          child: const Icon(
            FontAwesomeIcons.check,
            size: 14,
          ),
          onPressed: () {},
        ),
      ),
      // 暂停时 显示继续按钮。按下恢复任务
      TaskStatus.paused: CupertinoTheme(
        data:
            const CupertinoThemeData(primaryColor: CupertinoColors.activeGreen),
        child: CupertinoButton(
          padding: const EdgeInsets.all(0),
          child: const Icon(
            FontAwesomeIcons.play,
            size: 14,
          ),
          onPressed: () {
            controller.resumeGalleryDownload(_taskInfo.gid);
          },
        ),
      ),
      // 失败时 显示重试按钮。按下重试任务
      TaskStatus.failed: CupertinoButton(
        padding: const EdgeInsets.all(0),
        child: const Icon(
          FontAwesomeIcons.play,
          size: 14,
        ),
        onPressed: () {
          controller.retryArchiverDownload(index);
        },
      ),
      // 取消状态 显示重试按钮。按下重试任务
      TaskStatus.canceled: CupertinoButton(
        padding: const EdgeInsets.all(0),
        child: const Icon(
          FontAwesomeIcons.redo,
          size: 14,
        ),
        onPressed: () {
          controller.retryArchiverDownload(index);
        },
      ).paddingSymmetric(),
      TaskStatus.enqueued: Container(
        width: 40,
        height: 40,
        child: const CupertinoActivityIndicator(
          radius: 10,
        ),
      ),
      TaskStatus.undefined: Container(
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
      width: 60,
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
