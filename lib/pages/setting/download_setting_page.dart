import 'package:eros_fe/common/controller/download_controller.dart';
import 'package:eros_fe/common/service/ehsetting_service.dart';
import 'package:eros_fe/index.dart';
import 'package:eros_fe/pages/setting/setting_items/selector_Item.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:shared_storage/shared_storage.dart' as ss;
import 'package:sliver_tools/sliver_tools.dart';

class DownloadSettingPage extends StatelessWidget {
  const DownloadSettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        middle: Text(L10n.of(context).download),
      ),
      child: CustomScrollView(slivers: [
        SliverSafeArea(sliver: DownloadSetting()),
      ]),
    );
  }
}

class DownloadSetting extends StatelessWidget {
  DownloadSetting({super.key});

  final EhSettingService ehSettingService = Get.find();
  final DownloadController downloadController = Get.find();

  void _handleAllowMediaScanChanged(bool newValue) {
    ehSettingService.allowMediaScan = newValue;
    downloadController.allowMediaScan(newValue);
  }

  @override
  Widget build(BuildContext context) {
    return MultiSliver(children: [
      SliverCupertinoListSection.listInsetGrouped(children: [
        // 下载路径
        if (!GetPlatform.isIOS)
          Obx(() {
            ehSettingService.downloadLocatino;
            return FutureBuilder<String>(
                future: defDownloadPath,
                builder: (context, snapshot) {
                  late String path;
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (ehSettingService.downloadLocatino.isEmpty) {
                      path = snapshot.data ?? '';
                    } else {
                      path = ehSettingService.downloadLocatino;
                    }
                  } else {
                    path = '';
                  }

                  return EhCupertinoListTile(
                    padding: const EdgeInsetsDirectional.only(
                        start: 20.0, end: 14.0, top: 6.0, bottom: 6.0),
                    title: Text(L10n.of(context).download_location),
                    subtitle: Text(path, maxLines: 10),
                    trailing: CupertinoButton(
                      padding: const EdgeInsets.all(0),
                      minSize: 14,
                      child: const Icon(CupertinoIcons.refresh),
                      onPressed: () async => ehSettingService.downloadLocatino =
                          await defDownloadPath,
                    ),
                    onTap: () async {
                      if (GetPlatform.isAndroid) {
                        // android 使用 SAF
                        final uri = await ss.openDocumentTree();
                        logger.d('uri $uri');
                        if (uri != null) {
                          ehSettingService.downloadLocatino = uri.toString();
                        }
                      } else {
                        final String? result =
                            await FilePicker.platform.getDirectoryPath();
                        logger.d('set $result');

                        if (result != null) {
                          ehSettingService.downloadLocatino = result;
                        }
                      }
                    },
                  );
                });
          }),

        // allow_media_scan
        if (GetPlatform.isAndroid || GetPlatform.isFuchsia)
          EhCupertinoListTile(
            title: Text(L10n.of(context).allow_media_scan),
            trailing: Obx(() {
              return CupertinoSwitch(
                value: ehSettingService.allowMediaScan,
                onChanged: _handleAllowMediaScanChanged,
              );
            }),
          ),

        _buildPreloadImageItem(context),
        _buildMultiDownloadItem(context),
        _buildDownloadOrigImageItem(context),

        //
      ]),

      // 数据处理
      SliverCupertinoListSection.listInsetGrouped(children: [
        // 恢复下载任务数据
        EhCupertinoListTile(
          title: Text(L10n.of(context).restore_tasks_data),
          trailing: const CupertinoListTileChevron(),
          onTap: () async {
            final downloadController = Get.find<DownloadController>();
            await downloadController.restoreGalleryTasks(init: true);
          },
        ),
        // 重建下载任务数据
        EhCupertinoListTile(
          title: Text(L10n.of(context).rebuild_tasks_data),
          trailing: const CupertinoListTileChevron(),
          onTap: () async {
            await Get.find<DownloadController>().rebuildGalleryTasks();
          },
        ),
      ]),
    ]);
  }
}

/// 下载原图
Widget _buildDownloadOrigImageItem(BuildContext context) {
  final String title = L10n.of(context).download_ori_image;
  final EhSettingService ehSettingService = Get.find();

  final Map<DownloadOrigImageType, String> modeMap =
      <DownloadOrigImageType, String>{
    DownloadOrigImageType.no: L10n.of(context).no,
    DownloadOrigImageType.askMe: L10n.of(context).ask_me,
    DownloadOrigImageType.always: L10n.of(context).always,
  };
  return Obx(() {
    return SelectorCupertinoListTile<DownloadOrigImageType>(
      title: title,
      actionMap: modeMap,
      initVal: ehSettingService.downloadOrigType,
      onValueChanged: (val) => ehSettingService.downloadOrigType = val,
    );
  });
}

/// 预载图片数量
Widget _buildPreloadImageItem(BuildContext context) {
  final String title = L10n.of(context).preload_image;
  final EhSettingService ehSettingService = Get.find();

  List<Widget> _getModeList(BuildContext context) {
    return List<Widget>.from(EHConst.preloadImage.map((int element) {
      return CupertinoActionSheetAction(
          onPressed: () {
            Get.back(result: element);
          },
          child: Text('$element'));
    }).toList());
  }

  Future<int?> _showActionSheet(BuildContext context) {
    return showCupertinoModalPopup<int>(
        context: context,
        builder: (BuildContext context) {
          final CupertinoActionSheet dialog = CupertinoActionSheet(
            cancelButton: CupertinoActionSheetAction(
                onPressed: () {
                  Get.back();
                },
                child: Text(L10n.of(context).cancel)),
            actions: <Widget>[
              ..._getModeList(context),
            ],
          );
          return dialog;
        });
  }

  return Obx(() => EhCupertinoListTile(
        title: Text(title),
        trailing: const CupertinoListTileChevron(),
        additionalInfo: Text(ehSettingService.preloadImage.toString()),
        onTap: () async {
          final int? result = await _showActionSheet(context);
          if (result != null) {
            ehSettingService.preloadImage(result);
          }
        },
      ));
}

/// 同时下载图片数量
Widget _buildMultiDownloadItem(BuildContext context) {
  final String title = L10n.of(context).multi_download;
  final EhSettingService ehSettingService = Get.find();

  List<Widget> _getModeList(BuildContext context) {
    return List<Widget>.from(EHConst.multiDownload.map((int element) {
      return CupertinoActionSheetAction(
          onPressed: () {
            Get.back(result: element);
          },
          child: Text('$element'));
    }).toList());
  }

  Future<int?> _showActionSheet(BuildContext context) {
    return showCupertinoModalPopup<int>(
        context: context,
        builder: (BuildContext context) {
          final CupertinoActionSheet dialog = CupertinoActionSheet(
            cancelButton: CupertinoActionSheetAction(
                onPressed: () {
                  Get.back();
                },
                child: Text(L10n.of(context).cancel)),
            actions: <Widget>[
              ..._getModeList(context),
            ],
          );
          return dialog;
        });
  }

  return Obx(() => EhCupertinoListTile(
        title: Text(title),
        trailing: const CupertinoListTileChevron(),
        additionalInfo: Text(ehSettingService.multiDownload.toString()),
        onTap: () async {
          final int? result = await _showActionSheet(context);
          if (result != null) {
            if (ehSettingService.multiDownload != result) {
              ehSettingService.multiDownload = result;
              Get.find<DownloadController>().resetConcurrency();
            }
          }
        },
      ));
}
