import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/route/navigator_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SettingItems extends StatefulWidget {
  final String text;
  final IconData icon;
  final String route;

  SettingItems({
    this.text,
    this.icon,
    this.route,
  });

  @override
  _SettingItems createState() => _SettingItems();
}

/// 设置项
class _SettingItems extends State<SettingItems> {
  Color _color;

  @override
  void initState() {
    super.initState();
    _color = CupertinoColors.systemBackground;
  }

  @override
  Widget build(BuildContext context) {
    // return Text(text);

    Widget container = Container(
        color: _color,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _settingItemDivider(),
            Container(
              height: 50,
              padding: const EdgeInsets.fromLTRB(8, 8, 20, 8),
              child: Row(
                children: <Widget>[
                  Container(
//                    padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
                    child: Icon(
                      widget.icon,
                      size: 26.0,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text(widget.text),
                  ),
                  Spacer(),
                  Icon(
                    CupertinoIcons.forward,
                    color: CupertinoColors.systemGrey,
                  ),
                ],
              ),
            ),
          ],
        ));

    return GestureDetector(
      child: container,
      // 不可见区域有效
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Global.loggerNoStack.v("set tap ${widget.text} ");
        NavigatorUtil.jump(context, widget.route, rootNavigator: true);
      },
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
      _color = CupertinoColors.systemBackground;
    });
  }

  void _updatePressedColor() {
    setState(() {
      _color = CupertinoColors.systemGrey4;
    });
  }

  /// 设置项分隔线
  Widget _settingItemDivider() {
    return Divider(
      height: 0.5,
      indent: 45.0,
      color: CupertinoColors.systemGrey4,
    );
  }
}
