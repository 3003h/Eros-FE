import 'dart:async';
import 'dart:io';

import 'package:eros_fe/common/controller/download_controller.dart';
import 'package:eros_fe/common/controller/gallerycache_controller.dart';
import 'package:eros_fe/common/controller/webdav_controller.dart';
import 'package:eros_fe/common/service/theme_service.dart';
import 'package:eros_fe/const/theme_colors.dart';
import 'package:eros_fe/index.dart';
import 'package:eros_fe/network/api.dart';
import 'package:eros_fe/pages/tab/controller/download_view_controller.dart';
import 'package:eros_fe/store/db/entity/gallery_image_task.dart';
import 'package:eros_fe/store/db/entity/gallery_task.dart';
import 'package:eros_fe/widget/image/extended_saf_image_privider.dart';
import 'package:eros_fe/widget/rating_bar.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;

const kCardRadius = 10.0;

/// 同步阅读进度的提示dialog，会自动关闭，也可跳过同步直接阅读
Future<int?> syncReadProgress(
  BuildContext context,
  int gid, {
  Duration duration = const Duration(milliseconds: 500),
}) async {
  bool _cancelSync = false;
  bool _needShowDialog = true;

  Future<int> _sync() async {
    final _cache = await Get.find<GalleryCacheController>()
        .listenGalleryCache('$gid')
        .last;
    _needShowDialog = false;
    return _cache?.lastIndex ?? 0;
  }

  Future<int?> _showSyncDialog() async {
    return await showCupertinoDialog<int?>(
      context: context,
      // barrierDismissible: true,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('${L10n.of(context).sync_read_progress}...'),
          content: GetBuilder<DownloadViewController>(
            initState: (state) async {
              final _index = await _sync();
              if (!_cancelSync) {
                Get.back(result: _index);
              }
            },
            builder: (logic) {
              return const CupertinoActivityIndicator(radius: 16);
            },
          ).paddingOnly(top: 10.0),
          actions: [
            CupertinoDialogAction(
              child: Text(
                L10n.of(context).skip,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.destructiveRed),
              ),
              onPressed: () {
                _cancelSync = true;
                Get.back();
              },
            ),
          ],
        );
      },
    );
  }

  return await _showSyncDialog();
}

/// 画廊下载项
class DownloadGalleryItem extends GetView<DownloadViewController> {
  const DownloadGalleryItem({
    super.key,
    required this.galleryTask,
    required this.taskIndex,
    this.speed,
    this.errInfo,
  });

  final GalleryTask galleryTask;
  final int taskIndex;
  final String? speed;
  final String? errInfo;

  @override
  Widget build(BuildContext context) {
    final DateTime date =
        DateTime.fromMillisecondsSinceEpoch(galleryTask.addTime ?? 0);
    final addTime = galleryTask.addTime != null
        ? DateFormat('yyyy-MM-dd HH:mm').format(date)
        : null;

    final status = TaskStatus(galleryTask.status ?? 0);
    final complete = status == TaskStatus.complete;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        final List<GalleryImageTask> imageTasks =
            await controller.getImageTasks(galleryTask.gid);
        final GalleryTask? gTask = controller.galleryTaskMap[galleryTask.gid];
        if (gTask == null) {
          return;
        }

        late final List<String> pics;
        final dirPath = gTask.realDirPath;

        if (dirPath?.isContentUri ?? false) {
          if (dirPath != null) {
            logger.t('^^^^ before read, dirPath: $dirPath');

            late final String parentPath;
            if (dirPath.contains('/document/primary')) {
              parentPath = dirPath.substring(
                  0, dirPath.lastIndexOf('/document/primary'));
            } else {
              parentPath = dirPath.substring(0, dirPath.lastIndexOf('%2F'));
            }

            logger.t('^^^^ before read, parentPath: $parentPath');

            if (parentPath.isNotEmpty) {
              await showSAFPermissionRequiredDialog(uri: Uri.parse(parentPath));
            }
          }

          pics = imageTasks
              .where((element) =>
                  element.filePath != null && element.filePath!.isNotEmpty)
              .map((e) => '$dirPath%2F${e.filePath}')
              .toList();
        } else {
          pics = imageTasks
              .where((element) =>
                  element.filePath != null && element.filePath!.isNotEmpty)
              .map((e) => path.join(dirPath ?? '', e.filePath ?? ''))
              .toList();
        }

        logger.t('pics: ${pics.map((e) => e).join('\n')}');

        // 读取进度
        int? lastIndex = 0;
        if (Get.find<WebdavController>().syncReadProgress) {
          lastIndex = await syncReadProgress(context, galleryTask.gid);
        }
        final cache = await Get.find<GalleryCacheController>()
            .listenGalleryCache('${galleryTask.gid}', sync: false)
            .first;
        if (cache?.lastIndex != null) {
          lastIndex = cache?.lastIndex;
        }

        // 进入阅读
        NavigatorUtil.goGalleryViewPageFile(
          lastIndex ?? 0,
          pics,
          '${galleryTask.gid}',
        );
      },
      onLongPress: () => controller.onLongPress(taskIndex, task: galleryTask),
      child: _buildCardItem(context, complete, addTime: addTime),
    );
  }

  Widget _buildCardItem(
    BuildContext context,
    bool complete, {
    String? addTime,
  }) {
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
                      .withOpacity(0.9),
                  blurRadius: 10,
                  spreadRadius: 1.0,
                  offset: const Offset(2, 2),
                )
              ],
        color: ehTheme.itemBackgroundColor,
        borderRadius: BorderRadius.circular(kCardRadius),
      ),
      height: 120,
      child: Row(
        children: [
          // 封面
          Column(
            children: [
              Expanded(child: _buildCover(cardType: true)),
            ],
          ),
          // 右侧
          Expanded(
            child: _buildItemInfo(context, complete, addTime: addTime)
                .paddingSymmetric(vertical: 4),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, bool _complete, {String? addTime}) {
    return Column(
      children: [
        Container(
          padding:
              const EdgeInsets.only(top: 4, bottom: 4, left: 20, right: 16),
          height: 120,
          child: Row(
            children: [
              // 封面
              _buildCover(),
              // 右侧
              Expanded(
                child: _buildItemInfo(context, _complete, addTime: addTime),
              ),
            ],
          ),
        ),
        Divider(
          indent: 20,
          height: 0.6,
          color: CupertinoDynamicColor.resolve(
              CupertinoColors.systemGrey4, context),
        ),
      ],
    );
  }

  Widget _buildCover({bool cardType = false}) {
    return GestureDetector(
      child: Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: DownloadItemCoverImage(
          filePath: (galleryTask.coverImage != null &&
                  galleryTask.coverImage!.isNotEmpty)
              ? (galleryTask.realDirPath?.isContentUri ?? false)
                  ? '${galleryTask.realDirPath}%2F${galleryTask.coverImage}'
                  : path.join(
                      galleryTask.realDirPath ?? '', galleryTask.coverImage)
              : null,
          url: galleryTask.coverUrl,
          cardType: cardType,
        ),
      ),
      onTap: () async {
        logger.t('${galleryTask.url} ');
        String? url = galleryTask.url;
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

  Widget _buildItemInfo(
    BuildContext context,
    bool isComplete, {
    String? addTime,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题
        Text(
          galleryTask.title,
          softWrap: true,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 13,
            height: 1.2,
          ),
        ).paddingSymmetric(vertical: 2),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          galleryTask.uploader ?? '',
                          style: TextStyle(
                            fontSize: 12,
                            color: CupertinoDynamicColor.resolve(
                                CupertinoColors.secondaryLabel, context),
                          ),
                        ),
                        const Spacer(),
                        // 任务添加时间
                        Text(
                          addTime ?? '',
                          style: TextStyle(
                            fontSize: 12,
                            color: CupertinoDynamicColor.resolve(
                                CupertinoColors.secondaryLabel, context),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // 进度条
                    if (!isComplete)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (galleryTask.completCount ?? 0) /
                              galleryTask.fileCount,
                          backgroundColor: CupertinoDynamicColor.resolve(
                              CupertinoColors.secondarySystemFill, context),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            CupertinoDynamicColor.resolve(
                                CupertinoColors.activeBlue, context),
                          ),
                        ),
                      )
                    else
                      _buildRating(galleryTask.rating),
                    // 下载速度 下载进度
                    Row(
                      children: [
                        if (!isComplete)
                          _buildDownloadCtl(context)
                        else
                          _buildCategory(galleryTask.category),
                        const Spacer(),
                        Text(
                          isComplete
                              ? '${galleryTask.fileCount}'
                              : '${galleryTask.completCount ?? 0}/${galleryTask.fileCount}',
                          style: TextStyle(
                              fontSize: 13,
                              color: CupertinoDynamicColor.resolve(
                                  CupertinoColors.secondaryLabel, context)),
                        ),
                        // 控制按钮
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
    );
  }

  Widget _buildDownloadCtl(BuildContext context) {
    if (errInfo != null && errInfo!.isNotEmpty) {
      return Text(
        errInfo ?? '',
        style: TextStyle(
            fontSize: 13,
            color: CupertinoDynamicColor.resolve(
                CupertinoColors.systemRed, context)),
      );
    } else {
      return Text(
        speed != null ? '$speed/s' : '',
        style: TextStyle(
            fontSize: 13,
            color: CupertinoDynamicColor.resolve(
                CupertinoColors.secondaryLabel, context)),
      );
    }
  }

  Widget _buildRating(double? rating) {
    if (rating == null) {
      return const SizedBox.shrink();
    }

    return Row(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
          child: StaticRatingBar(
            size: 16.0,
            rate: rating,
            radiusRatio: 1.5,
            colorLight: ThemeColors.colorRatingMap['ir'],
            colorDark: CupertinoDynamicColor.resolve(
                CupertinoColors.systemGrey3, Get.context!),
          ),
        ),
        Text(
          rating.toString(),
          style: TextStyle(
            fontSize: 11,
            color: CupertinoDynamicColor.resolve(
                CupertinoColors.systemGrey, Get.context!),
          ),
        ),
      ],
    );
  }

  Widget _buildCategory(String? category) {
    final Color _colorCategory = CupertinoDynamicColor.resolve(
        ThemeColors.catColor[category ?? 'default'] ??
            CupertinoColors.systemBackground,
        Get.context!);

    return Container(
      decoration: BoxDecoration(
        color: _colorCategory,
        borderRadius: BorderRadius.circular(4.5),
      ),
      padding: const EdgeInsets.fromLTRB(6, 3, 6, 3),
      child: Text(
        category ?? '',
        style: const TextStyle(
          fontSize: 14,
          height: 1,
          color: CupertinoColors.white,
        ),
      ),
    );
  }

  Widget _getIcon() {
    final GalleryTask? _taskInfo = controller.galleryTaskMap[galleryTask.gid];
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
          controller.retryArchiverDownload(galleryTask.gid);
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
          controller.retryArchiverDownload(galleryTask.gid);
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

    return statusMap[TaskStatus(galleryTask.status ?? 0)] ??
        const SizedBox(width: 40);
  }
}

class DownloadItemCoverImage extends StatelessWidget {
  const DownloadItemCoverImage({
    this.url,
    this.filePath,
    this.cardType = false,
    Key? key,
  }) : super(key: key);

  final String? filePath;
  final String? url;
  final bool cardType;

  @override
  Widget build(BuildContext context) {
    logger.t('$filePath  $url');

    Widget image = () {
      if (filePath != null) {
        final loadStateChanged = (ExtendedImageState state) {
          if (state.extendedImageLoadState == LoadState.loading) {
            return Container(
              alignment: Alignment.center,
              color: CupertinoDynamicColor.resolve(
                  CupertinoColors.systemGrey5, context),
              child: const CupertinoActivityIndicator(),
            );
          }
          return null;
        };

        return (filePath?.isContentUri ?? false)
            ? ExtendedImage(
                image: ExtendedSafImageProvider(Uri.parse(filePath!)),
                fit: cardType ? BoxFit.cover : BoxFit.fitWidth,
                loadStateChanged: loadStateChanged,
              )
            : ExtendedImage.file(
                File(filePath!),
                fit: cardType ? BoxFit.cover : BoxFit.fitWidth,
                loadStateChanged: loadStateChanged,
              );
      } else if (url != null) {
        return EhNetworkImage(
          imageUrl: url!,
          fit: cardType ? BoxFit.cover : BoxFit.fitWidth,
        );
      } else {
        return const SizedBox.expand();
      }
    }();

    image = ClipRRect(
      borderRadius: cardType
          ? const BorderRadius.only(
              topLeft: Radius.circular(kCardRadius),
              bottomLeft: Radius.circular(kCardRadius))
          : BorderRadius.circular(6),
      child: image,
    );

    return Container(
      width: 90,
      decoration: BoxDecoration(
        boxShadow: cardType
            ? null
            : [
                //阴影
                BoxShadow(
                  color: CupertinoDynamicColor.resolve(
                      CupertinoColors.systemGrey5, Get.context!),
                  blurRadius: 3,
                )
              ],
      ),
      child: image,
    );
  }
}
