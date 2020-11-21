import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/generated/l10n.dart';
import 'package:FEhViewer/pages/tab/history_page.dart';
import 'package:FEhViewer/utils/toast.dart';
import 'package:FEhViewer/values/theme_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'favorite_page.dart';
import 'gallery_page.dart';
import 'popular_page.dart';
import 'setting_page.dart';

class FEhHomeNew extends StatefulWidget {
  @override
  _FEhHomeNewState createState() => _FEhHomeNewState();
}

class _FEhHomeNewState extends State<FEhHomeNew> {
  DateTime _lastPressedAt; //上次点击时间
  // tab控制器 可设置默认tab
  final CupertinoTabController _controller = CupertinoTabController();
  int _currentIndex = 0;
  bool _tapAwait = true;

  final Map<String, ScrollController> _scrollControllerMap = {};

  ScrollController _getScrollController(String key) {
    if (_scrollControllerMap[key] == null) {
      _scrollControllerMap[key] = ScrollController();
    }
    return _scrollControllerMap[key];
  }

  final List _pageList = [];
  final List _tabList = [];
  final List _scrollControllerList = [];
  final List _oriTabList = [];

  void initData() {
    _scrollControllerList.clear();
    _tabList.clear();
    _pageList.clear();
    _oriTabList.clear();

    const double _iconSize = 24.0;
    _oriTabList.addAll([
      {
        'title': S.of(context).tab_popular,
        'icon': const Icon(FontAwesomeIcons.fire, size: _iconSize),
        'disable': Global.profile.ehConfig.safeMode,
        'page': PopularListTab(
          tabIndex: S.of(context).tab_popular,
          scrollController: _getScrollController(S.of(context).tab_popular),
        )
      },
      {
        'title': S.of(context).tab_gallery,
        'icon': const Icon(FontAwesomeIcons.list, size: _iconSize),
        'page': GalleryListTab(
          tabIndex: S.of(context).tab_gallery,
          scrollController: _getScrollController(S.of(context).tab_gallery),
        )
      },
      {
        'title': S.of(context).tab_favorite,
        'icon': const Icon(FontAwesomeIcons.solidHeart, size: _iconSize),
        'disable': Global.profile.ehConfig.safeMode,
        'page': FavoriteTab(
          tabIndex: S.of(context).tab_favorite,
          scrollController: _getScrollController(S.of(context).tab_favorite),
        )
      },
      {
        'title': S.of(context).tab_history,
        'icon': const Icon(FontAwesomeIcons.history, size: _iconSize),
        'disable': Global.profile.ehConfig.safeMode,
        'page': HistoryTab(
          tabIndex: S.of(context).tab_history,
          scrollController: _getScrollController(S.of(context).tab_history),
        )
      },
      {
        'title': S.of(context).tab_setting,
        'icon': const Icon(FontAwesomeIcons.cog, size: _iconSize),
        'page': SettingTab(
          tabIndex: S.of(context).tab_setting,
          scrollController: _getScrollController(S.of(context).tab_setting),
        )
      },
    ]);

    for (final tabObj in _oriTabList) {
      if (tabObj['disable'] != null && tabObj['disable']) {
      } else {
        _scrollControllerList.add(_getScrollController(tabObj['title']));
        _tabList.add(tabObj);
        _pageList.add(tabObj['page']);
      }
    }
  }

  // 获取BottomNavigationBarItem
  List<BottomNavigationBarItem> getBottomNavigationBarItem() {
    final List<BottomNavigationBarItem> list = [];
    for (final tabObj in _tabList) {
      list.add(BottomNavigationBarItem(
          icon: tabObj['icon'], label: tabObj['title']));
    }

    return list;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    initData();
    _tapAwait = false;
  }

  @override
  Widget build(BuildContext context) {
    final List<BottomNavigationBarItem> _listBottomNavigationBarItem =
        getBottomNavigationBarItem();
    final CupertinoTabScaffold cupertinoTabScaffold = CupertinoTabScaffold(
      controller: _controller,
      tabBar: CupertinoTabBar(
        backgroundColor: ThemeColors.navigationBarBackground,
        items: _listBottomNavigationBarItem,
        onTap: (int index) async {
          if (index == _currentIndex &&
              index != _listBottomNavigationBarItem.length - 1) {
            await _doubleTapBar(
              duration: const Duration(milliseconds: 800),
              awaitComplete: false,
              onTap: () {
                _scrollControllerList[index].animateTo(0.0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.ease);
              },
              onDoubleTap: () {
                _scrollControllerList[index].animateTo(-100.0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.ease);
              },
            );
          } else {
            _currentIndex = index;
          }
        },
      ),
      tabBuilder: (BuildContext context, int index) {
//        return _pages[index];
        return CupertinoTabView(
          builder: (BuildContext context) {
            return _pageList[index];
          },
        );
      },
    );

    final WillPopScope willPopScope = WillPopScope(
      onWillPop: doubleClickBack,
      child: cupertinoTabScaffold,
    );

    return willPopScope;
  }

  Future<void> _doubleTapBar(
      {VoidCallback onTap,
      VoidCallback onDoubleTap,
      Duration duration,
      bool awaitComplete}) async {
    final Duration _duration = duration ?? const Duration(milliseconds: 500);
    if (!_tapAwait || _tapAwait == null) {
      _tapAwait = true;

      if (awaitComplete ?? false) {
        await Future<void>.delayed(_duration);
        if (_tapAwait) {
//        Global.loggerNoStack.v('等待结束 执行单击事件');
          _tapAwait = false;
          onTap();
        }
      } else {
        onTap();
        await Future<void>.delayed(_duration);
        _tapAwait = false;
      }
    } else if (onDoubleTap != null) {
//      Global.loggerNoStack.v('等待时间内第二次点击 执行双击事件');
      _tapAwait = false;
      onDoubleTap();
    }
  }

  Future<bool> doubleClickBack() async {
    Global.loggerNoStack.v('click back');
    if (_lastPressedAt == null ||
        DateTime.now().difference(_lastPressedAt) >
            const Duration(seconds: 1)) {
      showToast(S.of(context).double_click_back);
      //两次点击间隔超过1秒则重新计时
      _lastPressedAt = DateTime.now();
      return false;
    }
    return true;
  }
}
