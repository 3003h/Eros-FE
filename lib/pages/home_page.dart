import 'package:flutter/cupertino.dart';
import 'package:FEhViewer/utils/icon.dart';
import 'popular_page.dart';
import 'setting_page.dart';
import 'favorite_page.dart';

class FEhHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
//      title: 'FEhViewer Demo',
      home: CupertinoHomePage(),
    );
  }
}

class CupertinoHomePage extends StatefulWidget {
//  CupertinoHomePage({Key key, this.title}) : super(key: key);
//
//  final String title;

  @override
  _CupertinoHomePage createState() => _CupertinoHomePage();
}

class _CupertinoHomePage extends State<CupertinoHomePage> {
  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(EHCupertinoIcons.fire_solid),
            title: Text('热门'),
          ),
          BottomNavigationBarItem(
            icon: Icon(EHCupertinoIcons.gallery_solid),
            title: Text('画廊'),
          ),
          BottomNavigationBarItem(
            icon: Icon(EHCupertinoIcons.star_solid),
            title: Text('收藏'),
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.settings_solid),
            title: Text('设置'),
          ),
        ],
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return CupertinoTabView(builder: (context) {
              return CupertinoPageScaffold(
                // ignore: missing_return
                child: PopularListTab(),
              );
            });
          case 1:
            return CupertinoTabView(builder: (context) {
              return CupertinoPageScaffold(
                child: PopularListTab(),
              );
            });
          case 2:
            return CupertinoTabView(builder: (context) {
              return CupertinoPageScaffold(
                child: FavoriteTab(),
              );
            });
          case 3:
            return CupertinoTabView(builder: (context) {
              return CupertinoPageScaffold(
                child: SettingTab(),
              );
            });
        }
      },
    );
  }
}
