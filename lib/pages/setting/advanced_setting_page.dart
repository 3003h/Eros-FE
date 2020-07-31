import 'package:FEhViewer/common/global.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
  Widget _buildLanguageItem() {
    var _title = '语言设置';
    var _lang = '跟随系统设置';
    return SelectorSettingItem(
      title: _title,
      selector: _lang,
      onTap: () {
        Global.logger.v('tap LanguageItem');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView(
        children: <Widget>[
          _buildLanguageItem(),
        ],
      ),
    );
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
            height: 60,
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
