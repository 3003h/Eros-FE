import 'package:FEhViewer/models/states/dnsconfig_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
            height: 54,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Row(
              children: <Widget>[
                Text(
                  widget.title,
                  style: const TextStyle(
                    height: 1.0,
                  ),
                ),
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
            indent: 20,
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
  String _desc;

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
          height: 54.0,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Row(
            children: <Widget>[
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      widget.title,
                      style: const TextStyle(
                        height: 1.0,
                      ),
                    ),
                    if (_desc != null || widget.desc != null)
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
        Divider(
          indent: 20,
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
    this.height = 54.0,
  }) : super(key: key);

  final String title;
  final String desc;
  final VoidCallback onTap;
  final double height;

  @override
  _TextItemState createState() => _TextItemState();
}

class _TextItemState extends State<TextItem> {
  Color _color;

  @override
  Widget build(BuildContext context) {
    final Widget item = Column(
      children: <Widget>[
        Container(
          color: _color,
          alignment: Alignment.center,
          height: widget.height,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      widget.title,
                      style: const TextStyle(
                        height: 1.0,
                      ),
                    ),
                    Text(
                      widget.desc,
                      style: const TextStyle(
                          fontSize: 12.5, color: CupertinoColors.systemGrey),
                    ),
                  ]),
            ],
          ),
        ),
        Divider(
          indent: 20,
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

class SettingBase {
  Future<void> showCustomHostEditer(BuildContext context, {int index}) async {
    final TextEditingController _hostController = TextEditingController();
    final TextEditingController _addrController = TextEditingController();
    final FocusNode _nodeAddr = FocusNode();
    return showCupertinoDialog<void>(
      context: context,
      builder: (BuildContext context) {
        final DnsConfigModel dnsConfigModel =
            Provider.of<DnsConfigModel>(context, listen: false);
        final bool _isAddNew = index == null;
        if (!_isAddNew) {
          _hostController.text = dnsConfigModel.hosts[index].host;
          _addrController.text = dnsConfigModel.hosts[index].addr;
        }

        return CupertinoAlertDialog(
          content: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                CupertinoTextField(
                  enabled: _isAddNew,
                  clearButtonMode: _isAddNew
                      ? OverlayVisibilityMode.editing
                      : OverlayVisibilityMode.never,
                  controller: _hostController,
                  placeholder: 'Host',
                  autofocus: _isAddNew,
                  onEditingComplete: () {
                    // 点击键盘完成
                    FocusScope.of(context).requestFocus(_nodeAddr);
                  },
                ),
                Container(
                  height: 10,
                ),
                CupertinoTextField(
                  clearButtonMode: OverlayVisibilityMode.editing,
                  controller: _addrController,
                  placeholder: 'Addr',
                  focusNode: _nodeAddr,
                  autofocus: !_isAddNew,
                  onEditingComplete: () {
                    // 点击键盘完成
                    if (dnsConfigModel.addCustomHost(
                        _hostController.text.trim(),
                        _addrController.text.trim()))
                      Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              child: const Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              child: const Text('确定'),
              onPressed: () {
                if (dnsConfigModel.addCustomHost(
                    _hostController.text.trim(), _addrController.text.trim()))
                  Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
