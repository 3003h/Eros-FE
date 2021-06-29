import 'package:fehviewer/common/isolate/download.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/pages/tab/controller/download_view_controller.dart';
import 'package:fehviewer/store/floor/entity/gallery_task.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get/get_utils/src/platform/platform_io.dart';

class DownloadGalleryItem extends GetView<DownloadViewController> {
  const DownloadGalleryItem({
    Key? key,
    required this.title,
    required this.status,
    required this.index,
    required this.filecount,
    this.completeCount = 0,
  }) : super(key: key);
  final String title;
  final int filecount;
  final int completeCount;
  final TaskStatus status;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 8, bottom: 8, left: 20, right: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.2,
                  ),
                ).paddingSymmetric(vertical: 4),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: completeCount / filecount,
                        backgroundColor: CupertinoDynamicColor.resolve(
                            CupertinoColors.secondarySystemFill, context),
                        valueColor: AlwaysStoppedAnimation<Color>(
                            CupertinoDynamicColor.resolve(
                                CupertinoColors.activeBlue, context)),
                      ).paddingOnly(right: 8.0),
                    ),
                    Text('$completeCount/$filecount',
                        style: const TextStyle(
                          fontSize: 13,
                        )),
                  ],
                ),
              ],
            ),
          ),
          _getIcon(),
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
            // controller.pauseArchiverDownload(taskId: _taskInfo.taskId);
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
            controller.resumeArchiverDownload(index);
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
