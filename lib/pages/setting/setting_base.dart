import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// 选择类型的设置项
class SelectorSettingItem extends StatefulWidget {
  const SelectorSettingItem({
    Key key,
    this.onTap,
    @required this.title,
    @required this.selector,
  }) : super(key: key);

  final String title;
  final String selector;

  // 点击回调
  final VoidCallback onTap;

  @override
  _SelectorSettingItemState createState() => _SelectorSettingItemState();
}

class _SelectorSettingItemState extends State<SelectorSettingItem> {
  Color _color;

  @override
  Widget build(BuildContext context) {
    final Container container = Container(
      color: _color,
      child: Column(
        children: <Widget>[
          Container(
            height: 60,
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: Row(
              children: <Widget>[
                Text(widget.title),
                const Spacer(),
                Text(
                  widget.selector ?? '',
                  style: const TextStyle(
                    color: CupertinoColors.systemGrey2,
                  ),
                ),
                const Icon(
                  CupertinoIcons.forward,
                  color: CupertinoColors.systemGrey,
                ),
              ],
            ),
          ),
          Divider(
            height: 0.5,
            color: CupertinoDynamicColor.resolve(
                CupertinoColors.systemGrey4, context),
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
      _color =
          CupertinoDynamicColor.resolve(CupertinoColors.systemGrey4, context);
    });
  }
}

/// 开关类型
class TextSwitchItem extends StatefulWidget {
  const TextSwitchItem(
    this.title, {
    this.intValue,
    this.onChanged,
    this.desc,
    this.descOn,
    Key key,
  }) : super(key: key);

  final bool intValue;
  final ValueChanged<bool> onChanged;
  final String title;
  final String desc;
  final String descOn;

  @override
  _TextSwitchItemState createState() => _TextSwitchItemState();
}

class _TextSwitchItemState extends State<TextSwitchItem> {
  bool _switchValue;
  String _desc = '';

  void _handOnChanged() {
    widget.onChanged(_switchValue);
  }

  @override
  Widget build(BuildContext context) {
    _switchValue = _switchValue ?? widget.intValue ?? false;
    _desc = _switchValue ? widget.descOn : widget.desc;
    return Column(
      children: <Widget>[
        Container(
          height: 60,
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          child: Row(
            children: <Widget>[
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(widget.title),
                    Text(
                      _desc ?? widget.desc,
                      style: const TextStyle(
                          fontSize: 12.5, color: CupertinoColors.systemGrey),
                    ),
                  ]),
              Expanded(
                child: Container(),
              ),
              CupertinoSwitch(
                onChanged: (bool value) {
                  setState(() {
                    _switchValue = value;
                    _desc = value ? widget.descOn : widget.desc;
                    _handOnChanged();
                  });
                },
                value: _switchValue,
              ),
            ],
          ),
        ),
        Container(
          height: 0.5,
          color: CupertinoDynamicColor.resolve(
              CupertinoColors.systemGrey4, context),
        ),
      ],
    );
  }
}

/// 普通文本类型
class TextItem extends StatefulWidget {
  const TextItem(
    this.title, {
    this.desc,
    this.onTap,
    Key key,
  }) : super(key: key);

  final String title;
  final String desc;
  final VoidCallback onTap;

  @override
  _TextItemState createState() => _TextItemState();
}

class _TextItemState extends State<TextItem> {
  @override
  Widget build(BuildContext context) {
    final Widget item = Column(
      children: <Widget>[
        Container(
          height: 60,
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          child: Row(
            children: <Widget>[
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(widget.title),
                    Text(
                      widget.desc,
                      style: const TextStyle(
                          fontSize: 12.5, color: CupertinoColors.systemGrey),
                    ),
                  ]),
              Expanded(
                child: Container(),
              ),
            ],
          ),
        ),
        Container(
          height: 0.5,
          color: CupertinoDynamicColor.resolve(
              CupertinoColors.systemGrey4, context),
        ),
      ],
    );

    return GestureDetector(
      child: item,
      // 不可见区域有效
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
    );
  }
}
