import 'package:FEhViewer/fehviewer/route/navigator_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SettingItems extends StatefulWidget {
  final int index;
  final String text;
  final IconData icon;
  final bool isLast;
  final String route;

  SettingItems({
    this.index,
    this.text,
    this.icon,
    this.isLast,
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
        padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _settingItemDivider(),
            Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
                  child: Icon(
                    widget.icon,
                    size: 28.0,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Text(widget.text),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Icon(
                      CupertinoIcons.forward,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ),
              ],
            ),
            widget.isLast ? _settingItemDivider() : new Container(), // 末尾分隔线
          ],
        ));

    return GestureDetector(
      child: container,
      // 不可见区域有效
      behavior: HitTestBehavior.opaque,
      onTap: () {
        debugPrint("set tap ${widget.index}  ${widget.isLast}");
        NavigatorUtil.jump(context, widget.route);
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
