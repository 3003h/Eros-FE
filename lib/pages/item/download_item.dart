import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class DownloadArchiverItem extends StatelessWidget {
  const DownloadArchiverItem({
    Key key,
    @required this.title,
    this.progress = 0,
    @required this.status,
    @required this.onStatusChange,
  }) : super(key: key);
  final String title;
  final int progress;
  final DownloadTaskStatus status;
  final ValueChanged<DownloadTaskStatus> onStatusChange;

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
                  title ?? '',
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.2,
                  ),
                ).paddingSymmetric(vertical: 4),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: (progress ?? 0.0) / 100.0,
                        backgroundColor: CupertinoDynamicColor.resolve(
                            CupertinoColors.secondarySystemFill, context),
                        valueColor:
                            AlwaysStoppedAnimation<CupertinoDynamicColor>(
                                CupertinoDynamicColor.resolve(
                                    CupertinoColors.activeBlue, context)),
                      ).paddingOnly(right: 8.0),
                    ),
                    Text('${progress ?? 0} %',
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
    // logger.d('$status');

    final Map<DownloadTaskStatus, Widget> statusMap = {
      // 下载时，显示暂停按钮
      DownloadTaskStatus.running: CupertinoTheme(
        data: const CupertinoThemeData(primaryColor: CupertinoColors.systemRed),
        child: CupertinoButton(
          padding: const EdgeInsets.all(0),
          child: const Icon(
            FontAwesomeIcons.pause,
            size: 14,
          ),
          onPressed: () {
            onStatusChange(DownloadTaskStatus.paused);
          },
        ),
      ),
      // 完成时 显示打钩按钮 按下无动作
      DownloadTaskStatus.complete: CupertinoTheme(
        data:
            const CupertinoThemeData(primaryColor: CupertinoColors.activeGreen),
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
      DownloadTaskStatus.paused: CupertinoButton(
        padding: const EdgeInsets.all(0),
        child: const Icon(
          FontAwesomeIcons.play,
          size: 14,
        ),
        onPressed: () {
          onStatusChange(DownloadTaskStatus.running);
        },
      ),
      // 失败时 显示重试按钮。按下重试任务
      DownloadTaskStatus.failed: CupertinoButton(
        padding: const EdgeInsets.all(0),
        child: const Icon(
          FontAwesomeIcons.play,
          size: 14,
        ),
        onPressed: () {
          onStatusChange(DownloadTaskStatus.running);
        },
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
