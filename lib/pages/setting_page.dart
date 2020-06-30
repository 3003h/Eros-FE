import 'package:FEhViewer/generated/l10n.dart';
import 'package:FEhViewer/pages/item/setting_item.dart';
import 'package:FEhViewer/pages/item/user_item.dart';
import 'package:FEhViewer/values/const.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SettingTab extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SettingTab();
}

class _SettingTab extends State<SettingTab> {
  List _settingItemList = EHConst.settingList;

  List _getItemList() {
    List _slivers = [];
    for (int _index = 0; _index < _settingItemList.length + 1; _index++) {
      if (_index == 0) {
        _slivers.add(UserItem());
      } else {
        _slivers.add(SettingItems(
          index: _index,
          text: _settingItemList[_index - 1]["title"],
          icon: _settingItemList[_index - 1]["icon"],
          isLast: _settingItemList.length == _index,
          route: _settingItemList[_index - 1]["route"],
        ));
      }
    }
    return _slivers;
  }

  @override
  Widget build(BuildContext context) {
    var ln = S.of(context);
    var _title = ln.tab_setting;
    return CustomScrollView(
      slivers: <Widget>[
        CupertinoSliverNavigationBar(
          largeTitle: Text(
            _title,
            style: TextStyle(fontFamilyFallback: [EHConst.FONT_FAMILY]),
          ),
          transitionBetweenRoutes: false,
        ),
        SliverSafeArea(
            top: false,
            minimum: const EdgeInsets.all(8),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                List _itemList = _getItemList();
                if (index < _itemList.length) {
                  return _itemList[index];
                } else {
                  return null;
                }
              }),
            ))
      ],
    );
  }
}
