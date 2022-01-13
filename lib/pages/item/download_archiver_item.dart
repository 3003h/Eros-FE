import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/network/api.dart';
import 'package:fehviewer/pages/tab/controller/download_view_controller.dart';
import 'package:fehviewer/route/navigator_util.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get/get_utils/src/platform/platform_io.dart';

import 'download_gallery_item.dart';

const kCardRadius = 10.0;

class DownloadArchiverItem extends GetView<DownloadViewController> {
  const DownloadArchiverItem({
    Key? key,
    required this.title,
    this.progress = 0,
    required this.status,
    required this.index,
    this.coverUrl,
    this.galleryUrl,
  }) : super(key: key);
  final String title;
  final int progress;
  final DownloadTaskStatus status;
  final int index;
  final String? coverUrl;
  final String? galleryUrl;

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
      height: 80,
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
              child: Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.2,
                        ),
                      ).paddingSymmetric(vertical: 4),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: progress / 100.0,
                            backgroundColor: CupertinoDynamicColor.resolve(
                                CupertinoColors.secondarySystemFill, context),
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
            _getIcon(),
          ],
        ),
      ),
    );
  }

  Widget _buildCover() {
    return GestureDetector(
      child: Container(
        width: 64,
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
        child: !GeneralPlatform.isIOS
            ? CupertinoButton(
                padding: const EdgeInsets.all(0),
                child: const Icon(
                  FontAwesomeIcons.pause,
                  size: 14,
                ),
                onPressed: () {
                  controller.pauseArchiverDownload(taskId: _taskInfo.taskId);
                },
              )
            : CupertinoButton(
                padding: const EdgeInsets.all(0),
                child: const Icon(
                  FontAwesomeIcons.stop,
                  size: 14,
                ),
                onPressed: () {
                  controller.cancelArchiverDownload(taskId: _taskInfo.taskId);
                },
              ),
      ),
      // 完成时 按下无动作
      DownloadTaskStatus.complete: CupertinoTheme(
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
      DownloadTaskStatus.paused: CupertinoTheme(
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
      DownloadTaskStatus.failed: CupertinoButton(
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
      DownloadTaskStatus.canceled: CupertinoButton(
        padding: const EdgeInsets.all(0),
        child: const Icon(
          FontAwesomeIcons.redo,
          size: 14,
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
