import 'package:flutter/cupertino.dart';

class TextSwitchItem extends StatefulWidget {
  final bool intValue;
  final ValueChanged<bool> onChanged;
  final String title;
  final String desc;
  final String descOn;
  TextSwitchItem(
    this.title, {
    this.intValue,
    this.onChanged,
    this.desc,
    this.descOn,
    Key key,
  }) : super(key: key);

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
          margin: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          child: Row(
            children: <Widget>[
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(widget.title),
                    Text(
                      _desc ?? widget.desc,
                      style: TextStyle(
                          fontSize: 13, color: CupertinoColors.systemGrey),
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
          color: CupertinoColors.systemGrey4,
        )
      ],
    );
  }
}
