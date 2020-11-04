import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/generated/l10n.dart';
import 'package:FEhViewer/pages/item/setting_item.dart';
import 'package:FEhViewer/pages/item/user_item.dart';
import 'package:FEhViewer/route/routes.dart';
import 'package:FEhViewer/values/theme_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SettingTab extends StatefulWidget {
  final tabIndex;
  final scrollController;

  const SettingTab({Key key, this.tabIndex, this.scrollController})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _SettingTabState();
}

class _SettingTabState extends State<SettingTab> {
  // 菜单文案
  var _itemTitles = [];

  var _icons = [];

  var _routes = [];

  void initData(BuildContext context) {
    _itemTitles = ['EH设置', '高级设置', /*'安全设置',*/ '关于'];

    _icons = [
      FontAwesomeIcons.cookieBite,
      FontAwesomeIcons.tools,
      // FontAwesomeIcons.shieldAlt,
      FontAwesomeIcons.infoCircle,
    ];

    _routes = [
      EHRoutes.ehSetting,
      EHRoutes.advancedSetting,
      // '',
      EHRoutes.about,
    ];
  }

  List _getItemList() {
    List _slivers = [];
    for (int _index = 0; _index < _itemTitles.length + 1; _index++) {
      if (_index == 0) {
        _slivers
            .add(Global.profile.ehConfig.safeMode ? Container() : UserItem());
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
    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: <Widget>[
          CupertinoSliverNavigationBar(
            backgroundColor: ThemeColors.navigationBarBackground,
            heroTag: 'setting',
            largeTitle: Text(
              _title,
            ),
            transitionBetweenRoutes: true,
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
      ),
    );
  }
}
