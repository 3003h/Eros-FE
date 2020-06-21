import 'package:FEhViewer/fehviewer/pages/item/setting_item.dart';
import 'package:FEhViewer/fehviewer/pages/item/user_item.dart';
import 'package:FEhViewer/values/const.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// 定义一个回调接口
typedef OnItemClickListener = void Function(int position);

class SettingTab extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SettingTab();
}

class _SettingTab extends State<SettingTab> {
  String _title = "设置";
  List _settingItemList = EHConst.settingList;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        CupertinoSliverNavigationBar(
          largeTitle: Text(_title),
        ),
        SliverSafeArea(
            top: false,
            minimum: const EdgeInsets.only(
              left: 8,
              top: 8,
              bottom: 8,
              right: 8,
            ),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                switch (index) {
                  case 0:
                    return UserItem();
                  default:
                    {
                      if (index < _settingItemList.length + 1) {
                        return SettingItems(
                          index: index,
                          text: _settingItemList[index - 1]["title"],
                          icon: _settingItemList[index - 1]["icon"],
                          isLast: _settingItemList.length == index,
                          route: _settingItemList[index - 1]["route"],
                        );
                      } else {
                        return null;
                      }
                    }
                }
              }),
            ))
      ],
    );
  }
}
