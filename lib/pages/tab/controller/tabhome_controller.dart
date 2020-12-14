import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/utils/toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../view/favorite_page.dart';
import '../view/gallery_page.dart';
import '../view/history_page.dart';
import '../view/popular_page.dart';
import '../view/setting_page.dart';

class TabHomeController extends GetxController {
  DateTime lastPressedAt; //上次点击时间

  int currentIndex = 0;
  bool tapAwait = false;

  final List oriTabList = [];
  final List scrollControllerList = [];
  final List pageList = [];
  final List tabList = [];

  final Map<String, ScrollController> _scrollControllerMap = {};
  final CupertinoTabController tabController = CupertinoTabController();

  List<BottomNavigationBarItem> listBottomNavigationBarItem;

  final BuildContext context = Get.context;

  void init() {
    scrollControllerList.clear();
    tabList.clear();
    pageList.clear();
    oriTabList.clear();
    const double _iconSize = 24.0;
    oriTabList.addAll([
      {
        'title': 'tab_popular'.tr,
        'icon': const Icon(FontAwesomeIcons.fire, size: _iconSize),
        'disable': Global.profile.ehConfig.safeMode,
        'page': PopularListTab(
          tabIndex: 'tab_popular'.tr,
          scrollController: _getScrollController('tab_popular'.tr),
        )
      },
      {
        'title': 'tab_gallery'.tr,
        'icon': const Icon(FontAwesomeIcons.list, size: _iconSize),
        'page': GalleryListTab(
          tabIndex: 'tab_gallery'.tr,
          scrollController: _getScrollController('tab_gallery'.tr),
        )
      },
      /*
      {
        'title': 'tab_favorite'.tr,
        'icon': const Icon(FontAwesomeIcons.solidHeart, size: _iconSize),
        'disable': Global.profile.ehConfig.safeMode,
        'page': FavoriteTab(
          tabIndex: 'tab_favorite'.tr,
          scrollController: _getScrollController('tab_favorite'.tr),
        )
      },
      {
        'title': 'tab_history'.tr,
        'icon': const Icon(FontAwesomeIcons.history, size: _iconSize),
        'disable': Global.profile.ehConfig.safeMode,
        'page': HistoryTab(
          tabIndex: 'tab_history'.tr,
          scrollController: _getScrollController('tab_history'.tr),
        )
      },*/
      {
        'title': 'tab_setting'.tr,
        'icon': const Icon(FontAwesomeIcons.cog, size: _iconSize),
        'page': SettingTab(
          tabIndex: 'tab_setting'.tr,
          scrollController: _getScrollController('tab_setting'.tr),
        )
      },
    ]);

    for (final tabObj in oriTabList) {
      if (tabObj['disable'] != null && tabObj['disable']) {
      } else {
        scrollControllerList.add(_getScrollController(tabObj['title']));
        tabList.add(tabObj);
        pageList.add(tabObj['page']);
      }
    }

    listBottomNavigationBarItem = getBottomNavigationBarItem();
  }

  ScrollController _getScrollController(String key) {
    if (_scrollControllerMap[key] == null) {
      _scrollControllerMap[key] = ScrollController();
    }
    return _scrollControllerMap[key];
  }

  // 获取BottomNavigationBarItem
  List<BottomNavigationBarItem> getBottomNavigationBarItem() {
    final List<BottomNavigationBarItem> list = [];
    for (final tabObj in tabList) {
      list.add(BottomNavigationBarItem(
          icon: tabObj['icon'], label: tabObj['title']));
    }

    return list;
  }

  /// 连按两次返回退出
  Future<bool> doubleClickBack() async {
    Global.loggerNoStack.v('click back');
    if (lastPressedAt == null ||
        DateTime.now().difference(lastPressedAt) > const Duration(seconds: 1)) {
      showToast('double_click_back'.tr);
      //两次点击间隔超过1秒则重新计时
      lastPressedAt = DateTime.now();
      return false;
    }
    return true;
  }

  /// 双击bar的处理
  Future<void> doubleTapBar(
      {VoidCallback onTap,
      VoidCallback onDoubleTap,
      Duration duration,
      bool awaitComplete}) async {
    final Duration _duration = duration ?? const Duration(milliseconds: 500);
    if (!tapAwait || tapAwait == null) {
      tapAwait = true;

      if (awaitComplete ?? false) {
        await Future<void>.delayed(_duration);
        if (tapAwait) {
//        Global.loggerNoStack.v('等待结束 执行单击事件');
          tapAwait = false;
          onTap();
        }
      } else {
        onTap();
        await Future<void>.delayed(_duration);
        tapAwait = false;
      }
    } else if (onDoubleTap != null) {
//      Global.loggerNoStack.v('等待时间内第二次点击 执行双击事件');
      tapAwait = false;
      onDoubleTap();
    }
  }

  Future<void> onTap(int index) async {
    if (index == currentIndex &&
        index != listBottomNavigationBarItem.length - 1) {
      await doubleTapBar(
        duration: const Duration(milliseconds: 800),
        awaitComplete: false,
        onTap: () {
          scrollControllerList[index].animateTo(0.0,
              duration: const Duration(milliseconds: 500), curve: Curves.ease);
        },
        onDoubleTap: () {
          scrollControllerList[index].animateTo(-100.0,
              duration: const Duration(milliseconds: 500), curve: Curves.ease);
        },
      );
    } else {
      currentIndex = index;
    }
  }
}
