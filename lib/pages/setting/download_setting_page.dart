import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/pages/setting/setting_base.dart';
import 'package:flutter/cupertino.dart';
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
          middle: Text(S.of(context)!.download),
        ),
        child: SafeArea(
          child: ListViewDownloadSetting(),
        ));

    return cps;
  }
}

class ListViewDownloadSetting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<Widget> _list = <Widget>[
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
  final String _title = S.of(context)!.preload_image;
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
                child: Text(S.of(context)!.cancel)),
            actions: <Widget>[
              ..._getModeList(context),
            ],
          );
          return dialog;
        });
  }

  return Obx(() => SelectorSettingItem(
        title: _title,
        selector: ehConfigService.preloadImage?.toString() ?? '',
        onTap: () async {
          final int? _result = await _showActionSheet(context);
          if (_result != null) {
            ehConfigService.preloadImage(_result);
          }
        },
      ));
}
