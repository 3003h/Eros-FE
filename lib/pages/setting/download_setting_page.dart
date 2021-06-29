import 'package:fehviewer/common/controller/download_controller.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/pages/setting/setting_base.dart';
// import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DownloadSettingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final CupertinoPageScaffold cps = CupertinoPageScaffold(
        backgroundColor: !ehTheme.isDarkMode
            ? CupertinoColors.secondarySystemBackground
            : null,
        navigationBar: CupertinoNavigationBar(
          transitionBetweenRoutes: true,
          middle: Text(S.of(context).download),
        ),
        child: SafeArea(
          bottom: false,
          child: ListViewDownloadSetting(),
        ));

    return cps;
  }
}

class ListViewDownloadSetting extends StatelessWidget {
  final EhConfigService ehConfigService = Get.find();
  @override
  Widget build(BuildContext context) {
    final List<Widget> _list = <Widget>[
      if (GetPlatform.isAndroid || GetPlatform.isFuchsia)
        Obx(() {
          ehConfigService.downloadLocatino;
          return FutureBuilder<String>(
              future: defDownloadPath,
              builder: (context, snapshot) {
                return SelectorSettingItem(
                  title: S.of(context).download_location,
                  desc: snapshot.data ?? '',
                  onTap: () async {
                    // final FilePickerResult? result =
                    //     await FilePicker.platform.pickFiles();
                    // String? path = await FilesystemPicker.open(
                    //   title: 'Save to folder',
                    //   context: context,
                    //   rootDirectory: Directory(Global.extStorePath),
                    //   fsType: FilesystemType.folder,
                    //   pickText: 'Save file to this folder',
                    //   folderIconColor: Colors.teal,
                    // );
                  },
                );
              });
        }),
      _buildPreloadImageItem(context),
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
  final String _title = S.of(context).preload_image;
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
                child: Text(S.of(context).cancel)),
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
