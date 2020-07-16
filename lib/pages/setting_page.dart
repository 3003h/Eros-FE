import 'package:FEhViewer/generated/l10n.dart';
import 'package:FEhViewer/pages/item/setting_item.dart';
import 'package:FEhViewer/pages/item/user_item.dart';
import 'package:FEhViewer/route/routes.dart';
import 'package:FEhViewer/utils/icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SettingTab extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SettingTab();
}

class _SettingTab extends State<SettingTab> {
  // 菜单文案
  var _itemTitles = [];

  var _icons = [];

  var _routes = [];

  void initData(BuildContext context) {
    _itemTitles = ['EH设置', '关于'];

    _icons = [
      CupertinoIcons.book_solid,
      EHCupertinoIcons.info_solid,
    ];

    _routes = [
      EHRoutes.ehSetting,
      '',
    ];
  }

  List _getItemList() {
    List _slivers = [];
    for (int _index = 0; _index < _itemTitles.length + 1; _index++) {
      if (_index == 0) {
        _slivers.add(UserItem());
      } else {
        _slivers.add(SettingItems(
          text: _itemTitles[_index - 1],
          icon: _icons[_index - 1],
          route: _routes[_index - 1],
        ));
      }
    }
//    Global.logger.v('${_slivers.length}');
    return _slivers;
  }

  @override
  Widget build(BuildContext context) {
    initData(context);

    var ln = S.of(context);
    var _title = ln.tab_setting;
    return CustomScrollView(
      slivers: <Widget>[
        CupertinoSliverNavigationBar(
          largeTitle: Text(
            _title,
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
