import 'package:enum_to_string/enum_to_string.dart';
import 'package:fehviewer/common/controller/ehconfig_controller.dart';
import 'package:fehviewer/common/global.dart';
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
        navigationBar: CupertinoNavigationBar(
          transitionBetweenRoutes: true,
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
  final EhConfigController ehConfigController = Get.find();

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
                child: const Text('取消')),
            actions: <Widget>[
              ..._getModeList(),
            ],
          );
          return dialog;
        });
  }

  return Obx(() => SelectorSettingItem(
        title: _title,
        selector: modeMap[
            ehConfigController.viewMode.value ?? ViewMode.horizontalLeft],
        onTap: () async {
          logger.v('tap ModeItem');
          final ViewMode _result = await _showDialog(context);
          if (_result != null) {
            // ignore: unnecessary_string_interpolations
            logger.v('${EnumToString.convertToString(_result)}');
            ehConfigController.viewMode.value = _result;
          }
        },
      ));
}
