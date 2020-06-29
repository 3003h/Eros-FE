import 'package:FEhViewer/generated/l10n.dart';
import 'gallery_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'popular_page.dart';
import 'setting_page.dart';
import 'favorite_page.dart';

class FEhHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: CupertinoHomePage(),
    );
  }
}

class CupertinoHomePage extends StatefulWidget {
  @override
  _CupertinoHomePage createState() => _CupertinoHomePage();
}

class _CupertinoHomePage extends State<CupertinoHomePage> {
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
      style: TextStyle(fontFamilyFallback: ['JyuuGothic']),
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

    return cupertinoTabScaffold;
  }
}
