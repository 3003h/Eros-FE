import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/common/service/locale_service.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/toast.dart';
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

  final EhConfigService _ehConfigService = Get.find();
  final LocaleService _localeService = Get.find();

  Locale get locale => _localeService.locale;

  List<BottomNavigationBarItem> get listBottomNavigationBarItem {
    final List<BottomNavigationBarItem> list = [];
    for (final tabObj in tabList) {
      list.add(BottomNavigationBarItem(
          icon: tabObj['icon'], label: tabObj['title']));
    }

    return list;
  }

  final BuildContext context = Get.context;

  void init({BuildContext inContext}) {
    final BuildContext context = inContext ?? Get.context;
    // logger.i(' init tab home');
    scrollControllerList.clear();
    tabList.clear();
    pageList.clear();
    oriTabList.clear();
    const double _iconSize = 24.0;
    oriTabList.addAll([
      {
        'title': S.of(context).tab_popular,
        'icon': const Icon(FontAwesomeIcons.fire, size: _iconSize),
        'disable': _ehConfigService.isSafeMode.value,
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
        'disable': _ehConfigService.isSafeMode.value,
        'page': FavoriteTab(
          tabIndex: S.of(context).tab_favorite,
          scrollController: _getScrollController(S.of(context).tab_favorite),
        )
      },
      {
        'title': S.of(context).tab_history,
        'icon': const Icon(FontAwesomeIcons.history, size: _iconSize),
        'disable': _ehConfigService.isSafeMode.value,
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

    for (final tabObj in oriTabList) {
      if (tabObj['disable'] != null && tabObj['disable']) {
      } else {
        scrollControllerList.add(_getScrollController(tabObj['title']));
        tabList.add(tabObj);
        pageList.add(tabObj['page']);
      }
    }
  }

  ScrollController _getScrollController(String key) {
    if (_scrollControllerMap[key] == null) {
      _scrollControllerMap[key] = ScrollController();
    }
    return _scrollControllerMap[key];
  }

  /// 连按两次返回退出
  Future<bool> doubleClickBack() async {
    loggerNoStack.v('click back');
    if (lastPressedAt == null ||
        DateTime.now().difference(lastPressedAt) > const Duration(seconds: 1)) {
      showToast(S.of(context).double_click_back);
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
//        loggerNoStack.v('等待结束 执行单击事件');
          tapAwait = false;
          onTap();
        }
      } else {
        onTap();
        await Future<void>.delayed(_duration);
        tapAwait = false;
      }
    } else if (onDoubleTap != null) {
//      loggerNoStack.v('等待时间内第二次点击 执行双击事件');
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
