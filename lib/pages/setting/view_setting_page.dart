import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/models/states/ehconfig_model.dart';
import 'package:FEhViewer/pages/setting/setting_base.dart';
import 'package:FEhViewer/values/const.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

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
  final EhConfigModel ehConfigModel =
      Provider.of<EhConfigModel>(context, listen: false);

  final Map<ViewMode, String> modeMap = <ViewMode, String>{
    ViewMode.horizontalLeft: '由左到右',
    ViewMode.horizontalRight: '由右到左',
    if (Global.inDebugMode) ViewMode.vertical: '由上到下',
  };

  List<Widget> _getModeList(BuildContext context) {
    return List<Widget>.from(modeMap.keys.map((ViewMode element) {
      return CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context, element);
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
                  Navigator.pop(context);
                },
                child: const Text('取消')),
            actions: <Widget>[
              ..._getModeList(context),
            ],
          );
          return dialog;
        });
  }

  return Selector<EhConfigModel, String>(
      selector: (BuildContext context, EhConfigModel ehConfigModel) =>
          modeMap[ehConfigModel.viewMode ?? ViewMode.horizontalLeft],
      builder: (BuildContext context, String viewModeText, _) {
        return SelectorSettingItem(
          title: _title,
          selector: viewModeText,
          onTap: () async {
            Global.logger.v('tap ModeItem');
            final ViewMode _result = await _showDialog(context);
            if (_result != null) {
              // ignore: unnecessary_string_interpolations
              Global.logger.v('${EnumToString.convertToString(_result)}');
              ehConfigModel.viewMode = _result;
            }
          },
        );
      });
}
