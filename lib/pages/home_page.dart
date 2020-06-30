import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/generated/l10n.dart';
import 'package:FEhViewer/utils/toast.dart';
import 'package:FEhViewer/values/const.dart';
import 'gallery_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'popular_page.dart';
import 'setting_page.dart';
import 'favorite_page.dart';

class FEhHome extends StatefulWidget {
  @override
  _FEhHomeState createState() => _FEhHomeState();
}

class _FEhHomeState extends State<FEhHome> {
  DateTime _lastPressedAt; //上次点击时间

  // 底部菜单栏图标数组
  var tabIcon;

  // 页面内容
  var _pages = [];

  // 菜单文案
  var _tabTitles = [];

  void initData(BuildContext context) {
    final _iconSize = 24.0;
    if (tabIcon == null) {
      tabIcon = [
        // Icon(EHCupertinoIcons.fire_solid),
        // Icon(EHCupertinoIcons.gallery_solid),
        // Icon(EHCupertinoIcons.heart_solid),
        // Icon(CupertinoIcons.settings_solid),
        Icon(
          FontAwesomeIcons.fire,
          size: _iconSize,
        ),
        Icon(
          FontAwesomeIcons.list,
          size: _iconSize,
        ),
        Icon(
          FontAwesomeIcons.solidHeart,
          size: _iconSize,
        ),
        Icon(
          FontAwesomeIcons.cog,
          size: _iconSize,
        ),
      ];
    }

    _pages = [
      new PopularListTab(),
      new GalleryListTab(),
      new FavoriteTab(),
      new SettingTab()
    ];

    _tabTitles = [
      S.of(context).tab_popular,
      S.of(context).tab_gallery,
      S.of(context).tab_favorite,
      S.of(context).tab_setting
    ];
  }

  // 获取图标
  Icon getTabIcon(int curIndex) {
    return tabIcon[curIndex];
  }

  // 获取标题文本
  Text getTabTitle(int curIndex) {
    return Text(
      _tabTitles[curIndex],
      style: TextStyle(fontFamilyFallback: [EHConst.FONT_FAMILY]),
//      style: getTabTextStyle(curIndex),
    );
  }

  // 获取BottomNavigationBarItem
  List<BottomNavigationBarItem> getBottomNavigationBarItem() {
    List<BottomNavigationBarItem> list = new List();
    for (int index = 0; index < 4; index++) {
      list.add(new BottomNavigationBarItem(
          icon: getTabIcon(index), title: getTabTitle(index)));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    initData(context);

    CupertinoTabScaffold cupertinoTabScaffold = CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: getBottomNavigationBarItem(),
      ),
      tabBuilder: (context, index) {
        return _pages[index];
        // return CupertinoTabView(
        //   builder: (BuildContext context) {
        //     return _pages[index];
        //   },
        // );
      },
    );

    WillPopScope willPopScope = WillPopScope(
      onWillPop: doubleClickBack,
      child: cupertinoTabScaffold,
    );

    return willPopScope;
  }

  Future<bool> doubleClickBack() async {
    Global.loggerNoStack.v("click back");
    if (_lastPressedAt == null ||
        DateTime.now().difference(_lastPressedAt) > Duration(seconds: 1)) {
      showToast(S.of(context).double_click_back);
      //两次点击间隔超过1秒则重新计时
      _lastPressedAt = DateTime.now();
      return false;
    }
    return true;
  }
}
