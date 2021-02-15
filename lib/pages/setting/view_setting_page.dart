import 'package:enum_to_string/enum_to_string.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/pages/setting/setting_base.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class ViewSettingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final CupertinoPageScaffold cps = CupertinoPageScaffold(
        backgroundColor: !ehTheme.isDarkMode
            ? CupertinoColors.secondarySystemBackground
            : null,
        navigationBar: CupertinoNavigationBar(
          // transitionBetweenRoutes: true,
          middle: Text(S.of(context).read_setting),
        ),
        child: SafeArea(
          child: ViewSettingList(),
        ));

    return cps;
  }
}

class ViewSettingList extends StatelessWidget {
  final EhConfigService ehConfigService = Get.find();

  @override
  Widget build(BuildContext context) {
    final List<Widget> _list = <Widget>[
      _buildViewModeItem(context),
      TextSwitchItem(
        S.of(context).show_page_interval,
        intValue: ehConfigService.showPageInterval.value,
        onChanged: (bool val) => ehConfigService.showPageInterval.value = val,
      )
    ];
    return ListView.builder(
      itemCount: _list.length,
      itemBuilder: (BuildContext context, int index) {
        return _list[index];
      },
    );
  }
}

/// 阅读方向模式切换
Widget _buildViewModeItem(BuildContext context) {
  final String _title = S.of(context).reading_direction;
  final EhConfigService ehConfigService = Get.find();

  final Map<ViewMode, String> modeMap = <ViewMode, String>{
    ViewMode.LeftToRight: S.of(context).left_to_right,
    ViewMode.rightToLeft: S.of(context).right_to_left,
    ViewMode.topToBottom: S.of(context).top_to_bottom,
  };

  List<Widget> _getModeList() {
    return List<Widget>.from(modeMap.keys.map((ViewMode element) {
      return CupertinoActionSheetAction(
          onPressed: () {
            Get.back(result: element);
          },
          child: Text(modeMap[element]));
    }).toList());
  }

  Future<ViewMode> _showDialog(BuildContext context) {
    return showCupertinoModalPopup<ViewMode>(
        context: context,
        builder: (BuildContext context) {
          final CupertinoActionSheet dialog = CupertinoActionSheet(
            cancelButton: CupertinoActionSheetAction(
                onPressed: () {
                  Get.back();
                },
                child: Text(S.of(context).cancel)),
            actions: <Widget>[
              ..._getModeList(),
            ],
          );
          return dialog;
        });
  }

  return Obx(() => SelectorSettingItem(
        title: _title,
        selector:
            modeMap[ehConfigService.viewMode.value ?? ViewMode.LeftToRight],
        onTap: () async {
          logger.v('tap ModeItem');
          final ViewMode _result = await _showDialog(context);
          if (_result != null) {
            // ignore: unnecessary_string_interpolations
            logger.v('${EnumToString.convertToString(_result)}');
            ehConfigService.viewMode.value = _result;
          }
        },
      ));
}
