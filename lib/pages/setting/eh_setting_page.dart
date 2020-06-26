import 'package:FEhViewer/common/global.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EhSettingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _EhSettingPage();
}

class _EhSettingPage extends State<EhSettingPage> {
  String _title = "EH设置";

  @override
  Widget build(BuildContext context) {
    CupertinoPageScaffold cps = CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(_title),
        ),
        child: SafeArea(
          child: ListViewEhSetting(),
        ));

    return cps;
  }
}

class ListViewEhSetting extends StatefulWidget {
  ListViewEhSetting({Key key}) : super(key: key);

  @override
  _ListViewEhSetting createState() => _ListViewEhSetting();
}

class _ListViewEhSetting extends State<ListViewEhSetting> {
  bool _jpnTitle = Global.profile.ehConfig.jpnTitle;
  bool _tagTranslat = Global.profile.ehConfig.tagTranslat;

  void _handleJpnTitleChanged(bool newValue) {
    setState(() {
      _jpnTitle = newValue;
      Global.profile.ehConfig.jpnTitle = _jpnTitle;
      Global.saveProfile();
    });
  }

  void _handleTagTranslatChanged(bool newValue) {
    setState(() {
      _tagTranslat = newValue;
      Global.profile.ehConfig.tagTranslat = _tagTranslat;
      Global.saveProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      //列表项构造器
      itemBuilder: (BuildContext context, int index) {
        switch (index) {
          case (0):
            return TextSwitchItem('显示标签中文翻译',
                oriValue: _tagTranslat,
                onChanged: _handleTagTranslatChanged,
                desc: '显示翻译后的标签（需要下载数据文件）');
          case (1):
            return TextSwitchItem('显示日文标题',
                oriValue: _jpnTitle,
                onChanged: _handleJpnTitleChanged,
                desc: '如果该画廊有日文标题则优先显示');
          case (2):
            return TextSwitchItem(
              '收藏夹排序方式',
              onChanged: _handleJpnTitleChanged,
              desc: '按更新时间排序',
              descOn: '按收藏时间排序',
            );
          default:
            return null;
        }
      },
    );
  }
}

class TextSwitchItem extends StatefulWidget {
  final bool oriValue;
  final ValueChanged<bool> onChanged;
  final String title;
  final String desc;
  final String descOn;
  TextSwitchItem(
    this.title, {
    this.oriValue,
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
    widget.onChanged(!widget.oriValue);
  }

  @override
  Widget build(BuildContext context) {
    _switchValue = _switchValue ?? widget.oriValue ?? false;
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
