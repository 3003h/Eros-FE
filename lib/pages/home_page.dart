import 'gallery_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:FEhViewer/utils/icon.dart';
import 'package:flutter/material.dart';
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
  var tabTitles = ['热门', '画廊', '收藏', '设置'];

  void initData() {
    if (tabIcon == null) {
      tabIcon = [
        Icon(EHCupertinoIcons.fire_solid),
        Icon(EHCupertinoIcons.gallery_solid),
        Icon(EHCupertinoIcons.heart_solid),
        Icon(CupertinoIcons.settings_solid),
      ];
    }

    _pages = [
      new PopularListTab(),
      new GalleryListTab(),
      new FavoriteTab(),
      new SettingTab()
    ];
  }

  // 获取图标
  Icon getTabIcon(int curIndex) {
    return tabIcon[curIndex];
  }

  // 获取标题文本
  Text getTabTitle(int curIndex) {
    return new Text(
      tabTitles[curIndex],
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
    initData();

    CupertinoTabScaffold cupertinoTabScaffold = CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: getBottomNavigationBarItem(),
      ),
      tabBuilder: (context, index) {
        return CupertinoTabView(
          builder: (BuildContext context) {
            return CupertinoPageScaffold(
              child: _pages[index],
            );
          },
        );
      },
    );

    return cupertinoTabScaffold;
  }
}
