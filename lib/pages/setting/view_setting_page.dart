import 'package:enum_to_string/enum_to_string.dart';
import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/pages/setting/setting_base.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/values/const.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class ViewSettingPage extends StatefulWidget {
  @override
  _ViewSettingPageState createState() => _ViewSettingPageState();
}

class _ViewSettingPageState extends State<ViewSettingPage> {
  final String _title = '浏览设置';

  @override
  Widget build(BuildContext context) {
    final CupertinoPageScaffold cps = CupertinoPageScaffold(
        backgroundColor:
            !Get.isDarkMode ? CupertinoColors.secondarySystemBackground : null,
        navigationBar: CupertinoNavigationBar(
          // transitionBetweenRoutes: true,
          middle: Text(_title),
        ),
        child: SafeArea(
          child: ViewSettingList(),
        ));

    return cps;
  }
}

class ViewSettingList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<Widget> _list = <Widget>[
      _buildViewModeItem(context),
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
  const String _title = '阅读方向';
  final EhConfigService ehConfigService = Get.find();

  final Map<ViewMode, String> modeMap = <ViewMode, String>{
    ViewMode.horizontalLeft: '由左到右',
    ViewMode.horizontalRight: '由右到左',
    if (Global.inDebugMode) ViewMode.vertical: '由上到下',
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
            modeMap[ehConfigService.viewMode.value ?? ViewMode.horizontalLeft],
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
