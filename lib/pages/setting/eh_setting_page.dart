import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/models/states/ehconfig_model.dart';
import 'package:FEhViewer/pages/setting/settting_text_switch_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  bool _galleryImgBlur = Global.profile.ehConfig.galleryImgBlur;

  void _handleJpnTitleChanged(bool newValue) {
    setState(() {
      _jpnTitle = newValue;
      Provider.of<EhConfigModel>(context, listen: false).jpnTitle = _jpnTitle;
    });
  }

  void _handleTagTranslatChanged(bool newValue) {
    setState(() {
      _tagTranslat = newValue;
      Provider.of<EhConfigModel>(context, listen: false).tagTranslat =
          _tagTranslat;
    });
  }

  void _handleGalleryListImgBlurChanged(bool newValue) {
    setState(() {
      _galleryImgBlur = newValue;
      Provider.of<EhConfigModel>(context, listen: false).galleryImgBlur =
          _galleryImgBlur;
    });
  }

  @override
  Widget build(BuildContext context) {
    List _items = [
      TextSwitchItem('显示标签中文翻译',
          intValue: _tagTranslat,
          onChanged: _handleTagTranslatChanged,
          desc: '显示翻译后的标签（需要下载数据文件）'),
      TextSwitchItem('显示日文标题',
          intValue: _jpnTitle,
          onChanged: _handleJpnTitleChanged,
          desc: '如果该画廊有日文标题则优先显示'),
      TextSwitchItem('画廊封面模糊',
          intValue: _galleryImgBlur,
          onChanged: _handleGalleryListImgBlurChanged,
          desc: '画廊列表封面模糊效果'),
      TextSwitchItem(
        '收藏夹排序方式',
        onChanged: _handleJpnTitleChanged,
        desc: '按更新时间排序',
        descOn: '按收藏时间排序',
      )
    ];

    return ListView.builder(
      //列表项构造器
      itemBuilder: (BuildContext context, int index) {
        if (index < _items.length) {
          return _items[index];
        } else {
          return null;
        }
      },
    );
  }
}
