import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/models/states/locale_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdvancedSettingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AdvancedSettingPageState();
  }
}

class AdvancedSettingPageState extends State<AdvancedSettingPage> {
  String _title = "高级设置";
  @override
  Widget build(BuildContext context) {
    CupertinoPageScaffold cps = CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          transitionBetweenRoutes: true,
          middle: Text(_title),
        ),
        child: SafeArea(
          child: ListViewAdvancedSetting(),
        ));

    return cps;
  }
}

class ListViewAdvancedSetting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView(
        children: <Widget>[
          _buildLanguageItem(context),
        ],
      ),
    );
  }

  /// 语言设置部件
  Widget _buildLanguageItem(context) {
    var _title = '语言设置';
    var localeModel = Provider.of<LocaleModel>(context, listen: false);

    var localeMap = {
      '': '系统语言(默认)',
      'zh_CN': '简体中文',
      'en_US': 'English',
    };

    List<Widget> _getLocaleList(context) {
      return List<Widget>.from(localeMap.keys.map((element) {
        return CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context, element);
            },
            child: Text(localeMap[element]));
      }).toList());
    }

    Future<String> _showDialog(BuildContext context) {
      return showCupertinoModalPopup<String>(
          context: context,
          builder: (context) {
            var dialog = CupertinoActionSheet(
              title: Text("语言选择"),
              cancelButton: CupertinoActionSheetAction(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("取消")),
              actions: <Widget>[
                ..._getLocaleList(context),
              ],
            );
            return dialog;
          });
    }

    return Selector<LocaleModel, String>(
        selector: (context, localeModel) => localeMap[localeModel.locale ?? ''],
        builder: (context, locale, _) {
          return SelectorSettingItem(
            title: _title,
            selector: locale,
            onTap: () async {
              Global.logger.v('tap LanguageItem');
              var _result = await _showDialog(context);
              if (_result is String) {
                localeModel.locale = _result;
              }
              Global.logger.v('$_result');
            },
          );
        });
  }
}

/// 选择类型的设置项
class SelectorSettingItem extends StatefulWidget {
  SelectorSettingItem({
    Key key,
    this.onTap,
    @required this.title,
    @required this.selector,
  }) : super(key: key);

  final title;
  final selector;

  // 点击回调
  final VoidCallback onTap;

  @override
  _SelectorSettingItemState createState() => _SelectorSettingItemState();
}

class _SelectorSettingItemState extends State<SelectorSettingItem> {
  var _color;

  @override
  Widget build(BuildContext context) {
    Container container = Container(
      color: _color,
      child: Column(
        children: [
          Container(
            height: 50,
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: Row(
              children: <Widget>[
                Text(widget.title),
                Spacer(),
                Text(
                  widget.selector,
                  style: TextStyle(
                    color: CupertinoColors.systemGrey2,
                  ),
                ),
                Icon(
                  CupertinoIcons.forward,
                  color: CupertinoColors.systemGrey,
                ),
              ],
            ),
          ),
          Divider(
            height: 0.5,
            color: CupertinoColors.systemGrey4,
          ),
        ],
      ),
    );

    return GestureDetector(
      child: container,
      // 不可见区域有效
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onTapDown: (_) => _updatePressedColor(),
      onTapUp: (_) {
        Future.delayed(const Duration(milliseconds: 100), () {
          _updateNormalColor();
        });
      },
      onTapCancel: () => _updateNormalColor(),
    );
  }

  void _updateNormalColor() {
    setState(() {
      _color = null;
    });
  }

  void _updatePressedColor() {
    setState(() {
      _color = CupertinoColors.systemGrey4;
    });
  }
}
