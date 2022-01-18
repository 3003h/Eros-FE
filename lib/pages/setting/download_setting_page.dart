import 'package:fehviewer/common/controller/download_controller.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/component/setting_base.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DownloadSettingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Widget cps = Obx(() {
      return CupertinoPageScaffold(
          backgroundColor: !ehTheme.isDarkMode
              ? CupertinoColors.secondarySystemBackground
              : null,
          navigationBar: CupertinoNavigationBar(
            transitionBetweenRoutes: true,
            middle: Text(L10n.of(context).download),
          ),
          child: SafeArea(
            bottom: false,
            child: ListViewDownloadSetting(),
          ));
    });

    return cps;
  }
}

class ListViewDownloadSetting extends StatelessWidget {
  final EhConfigService ehConfigService = Get.find();
  final DownloadController downloadController = Get.find();

  void _handleAllowMediaScanChanged(bool newValue) {
    ehConfigService.allowMediaScan = newValue;
    downloadController.allowMediaScan(newValue);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _list = <Widget>[
      // 下载路径
      if (GetPlatform.isAndroid || GetPlatform.isFuchsia)
        Obx(() {
          ehConfigService.downloadLocatino;
          return FutureBuilder<String>(
              future: defDownloadPath,
              builder: (context, snapshot) {
                late String path;
                if (snapshot.connectionState == ConnectionState.done) {
                  if (ehConfigService.downloadLocatino.isEmpty) {
                    path = snapshot.data ?? '';
                  } else {
                    path = ehConfigService.downloadLocatino;
                  }
                } else {
                  path = '';
                }

                return SelectorSettingItem(
                  title: L10n.of(context).download_location,
                  desc: path,
                  suffix: CupertinoButton(
                    padding: const EdgeInsets.all(0),
                    minSize: 36,
                    child: const Icon(CupertinoIcons.refresh),
                    onPressed: () async => ehConfigService.downloadLocatino =
                        await defDownloadPath,
                  ),
                  onTap: () async {
                    final String? result =
                        await FilePicker.platform.getDirectoryPath();
                    logger.d('set $result');

                    if (result != null) {
                      if (result.startsWith('/storage/emulated/0/')) {
                        final _uri =
                            result.replaceFirst('/storage/emulated/0/', '');
                        final _uriEncode = Uri.encodeComponent(':$_uri');
                        logger.d('_uriEncode $_uriEncode');
                        final _fullUri =
                            'content://com.android.externalstorage.documents/tree/'
                            'primary$_uriEncode/document/primary$_uriEncode';
                        logger.d('_fullUri  $_fullUri');
                      }

                      ehConfigService.downloadLocatino = result;
                    }
                  },
                );
              });
        }),
      if (GetPlatform.isAndroid || GetPlatform.isFuchsia)
        TextSwitchItem(
          L10n.of(context).allow_media_scan,
          intValue: ehConfigService.allowMediaScan,
          onChanged: _handleAllowMediaScanChanged,
        ),
      _buildPreloadImageItem(context),
      _buildMultiDownloadItem(context),
      // 下载原图
      TextSwitchItem(
        L10n.of(context).download_ori_image,
        desc: L10n.of(context).download_ori_image_summary,
        intValue: ehConfigService.downloadOrigImage,
        onChanged: (val) => ehConfigService.downloadOrigImage = val,
        hideLine: true,
      ),
    ];
    return ListView.builder(
      itemCount: _list.length,
      itemBuilder: (BuildContext context, int index) {
        return _list[index];
      },
    );
  }
}

/// 预载图片数量
Widget _buildPreloadImageItem(BuildContext context) {
  final String _title = L10n.of(context).preload_image;
  final EhConfigService ehConfigService = Get.find();

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

  return Obx(() => SelectorSettingItem(
        title: _title,
        selector: ehConfigService.preloadImage.toString(),
        onTap: () async {
          final int? _result = await _showActionSheet(context);
          if (_result != null) {
            ehConfigService.preloadImage(_result);
          }
        },
      ));
}

/// 同时下载图片数量
Widget _buildMultiDownloadItem(BuildContext context, {bool hideLine = false}) {
  final String _title = L10n.of(context).multi_download;
  final EhConfigService ehConfigService = Get.find();

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

  return Obx(() => SelectorSettingItem(
        title: _title,
        hideLine: hideLine,
        selector: ehConfigService.multiDownload.toString(),
        onTap: () async {
          final int? _result = await _showActionSheet(context);
          if (_result != null) {
            if (ehConfigService.multiDownload != _result) {
              ehConfigService.multiDownload = _result;
              Get.find<DownloadController>().resetConcurrency();
            }
          }
        },
      ));
}
