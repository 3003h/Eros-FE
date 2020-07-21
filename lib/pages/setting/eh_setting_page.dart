import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/models/states/ehconfig_model.dart';
import 'package:FEhViewer/models/states/user_model.dart';
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

class ListViewEhSetting extends StatelessWidget {
  final bool _siteEx = Global.profile.ehConfig.siteEx;
  final bool _jpnTitle = Global.profile.ehConfig.jpnTitle;
  final bool _tagTranslat = Global.profile.ehConfig.tagTranslat;
  final bool _galleryImgBlur = Global.profile.ehConfig.galleryImgBlur;

  @override
  Widget build(BuildContext context) {
    void _handleSiteChanged(bool newValue) {
      Provider.of<EhConfigModel>(context, listen: false).siteEx = newValue;
    }

    void _handleJpnTitleChanged(bool newValue) {
      Provider.of<EhConfigModel>(context, listen: false).jpnTitle = newValue;
    }

    void _handleTagTranslatChanged(bool newValue) {
      Provider.of<EhConfigModel>(context, listen: false).tagTranslat = newValue;
    }

    void _handleGalleryListImgBlurChanged(bool newValue) {
      Provider.of<EhConfigModel>(context, listen: false).galleryImgBlur =
          newValue;
    }

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

    if (Provider.of<UserModel>(context, listen: false).isLogin) {
      _items.insert(
          0,
          TextSwitchItem(
            '站点切换',
            intValue: _siteEx,
            onChanged: _handleSiteChanged,
            desc: 'E-Hentai',
            descOn: 'ExHentai',
          ));
    }

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
