import 'dart:math';

import 'package:eros_fe/common/service/ehsetting_service.dart';
import 'package:eros_fe/index.dart';
import 'package:eros_fe/pages/tab/view/download_page.dart';
import 'package:eros_fe/pages/tab/view/history_page.dart';
import 'package:eros_fe/pages/tab/view/tabbar/custom_tabbar_page.dart';
import 'package:eros_fe/pages/tab/view/tabbar/favorite_tabbar_page.dart';
import 'package:eros_fe/pages/tab/view/toplist_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../../common/service/layout_service.dart';
import '../../../route/first_observer.dart';
import '../comm.dart';
import '../view/setting_page.dart';

const double kIconSize = 24.0;
final TabPages tabPages = TabPages();

class TabPages {
  final Map<String, EhTabController?> scrollControllerMap = {};

  Map<String, Widget> get tabViews => <String, Widget>{
        EHRoutes.gallery: const CustomTabbarList(),
        EHRoutes.favorite: const FavoriteTabTabBarPage(),
        EHRoutes.toplist: const ToplistTab(),
        // EHRoutes.toplist: const ToplistTabDebug(),
        EHRoutes.history: const HistoryTab(),
        EHRoutes.download: const DownloadTab(),
        EHRoutes.setting: const SettingTab(),
      };

  final Map<String, IconData> iconDatas = <String, IconData>{
    EHRoutes.popular: FontAwesomeIcons.fire,
    EHRoutes.watched: FontAwesomeIcons.solidEye,
    // EHRoutes.gallery: FontAwesomeIcons.jira,
    EHRoutes.gallery: FontAwesomeIcons.layerGroup,
    EHRoutes.favorite: FontAwesomeIcons.solidHeart,
    EHRoutes.toplist: FontAwesomeIcons.listOl,
    EHRoutes.history: FontAwesomeIcons.history,
    EHRoutes.download: FontAwesomeIcons.download,
    EHRoutes.setting: FontAwesomeIcons.cog,
    EHRoutes.customList: FontAwesomeIcons.layerGroup,
    EHRoutes.favoriteTabbar: FontAwesomeIcons.heartBroken,
  };

  Map<String, Widget> get tabIcons => iconDatas
      .map((key, value) => MapEntry(key, Icon(value, size: kIconSize)));

  BuildContext get _context => Get.find<TabHomeController>().tContext;

  Map<String, String> get tabTitles => <String, String>{
        EHRoutes.popular: L10n.of(_context).tab_popular,
        EHRoutes.watched: L10n.of(_context).tab_watched,
        EHRoutes.gallery: L10n.of(_context).tab_gallery,
        EHRoutes.favorite: L10n.of(_context).tab_favorite,
        EHRoutes.toplist: L10n.of(_context).tab_toplist,
        EHRoutes.history: L10n.of(_context).tab_history,
        EHRoutes.download: L10n.of(_context).tab_download,
        EHRoutes.setting: L10n.of(_context).tab_setting,
        EHRoutes.customList: L10n.of(_context).tab_gallery,
        EHRoutes.favoriteTabbar: L10n.of(_context).tab_favorite,
      };
}

// 默认显示在tabbar的view
Map<String, bool> kDefTabMap = <String, bool>{
  // EHRoutes.popular: true,
  // EHRoutes.watched: false,
  EHRoutes.gallery: true,
  // EHRoutes.favoriteTabbar: true,
  EHRoutes.favorite: true,
  EHRoutes.toplist: true,
  EHRoutes.download: true,
  EHRoutes.history: false,
  // EHRoutes.customlist: false,
};

// 启用的项目以及默认显示顺序 ?
List<String> kTabNameList = <String>[
  EHRoutes.gallery,
  // EHRoutes.popular,
  // EHRoutes.customlist,
  // EHRoutes.watched,
  // EHRoutes.favoriteTabbar,
  EHRoutes.favorite,
  EHRoutes.toplist,
  EHRoutes.download,
  EHRoutes.history,
];

/// TabHome布局控制器
class TabHomeController extends GetxController {
  TabHomeController();

  DateTime? lastPressedAt; //上次点击时间

  int currentIndex = 0;
  bool tapAwait = false;

  final EhSettingService _ehSettingService = Get.find();

  bool get isSafeMode => _ehSettingService.isSafeMode.value;

  final CupertinoTabController tabController = CupertinoTabController();

  String get currRoute => _showTabs[currentIndex];

  // 需要显示的tab
  List<String> get _showTabs => isSafeMode
      ? <String>[
          EHRoutes.gallery,
          EHRoutes.setting,
        ]
      : _sortedTabList;

  List<String> get _sortedTabList {
    final List<String> _list = <String>[];
    for (final String key in tabNameList) {
      if (tabMap[key] ?? false) {
        _list.add(key);
      }
    }
    if (_list.isEmpty) {
      _list.add(EHRoutes.gallery);
    }
    // setting 必须保留
    _list.add(EHRoutes.setting);
    return _list;
  }

  // 控制tab项顺序
  RxList<String> tabNameList = kTabNameList.obs;

  // 通过控制该变量控制tab项的开关
  RxMap<String, bool> tabMap = kDefTabMap.obs;

  late TabConfig _tabConfig;

  @override
  void onInit() {
    super.onInit();

    _tabConfig = Global.profile.tabConfig ?? (const TabConfig(tabItemList: []));

    if (_tabConfig.tabMap.isNotEmpty) {
      final List<String> _tabConfigNames =
          _tabConfig.tabItemList.map((e) => e.name).toList();

      final List<String> _addTabs = kTabNameList
          .where((String element) => !_tabConfigNames.contains(element))
          .toList();

      final _subTabs = _tabConfigNames
          .where((element) => !kTabNameList.contains(element))
          .toList();

      // logger.d('sub tab $_subTabs');

      for (final viewName in _subTabs) {
        _tabConfig.tabItemList
            .removeWhere((element) => element.name == viewName);
      }

      // 新增tab页的处理
      // logger.d('add tab $_addTabs');

      for (final viewName in _addTabs) {
        _tabConfig.tabItemList.add(TabItem(name: viewName, enable: false));
      }

      tabMap(_tabConfig.tabMap);
    }

    if (_tabConfig.tabNameList.isNotEmpty) {
      _tabConfig.tabNameList
          .removeWhere((element) => element == EHRoutes.setting);
      tabNameList(_tabConfig.tabNameList);
    }

    // logger.d('${tabNameList}');

    ever(tabMap, (Map<String, bool> map) {
      updateItemList(map, tabNameList);

      Global.profile = Global.profile.copyWith(tabConfig: _tabConfig.oN);
      Global.saveProfile();

      logger.d(
          '${_tabConfig.tabItemList.map((e) => '${e.name}:${e.enable}').toList().join('\n')} ');
    });

    ever(tabNameList, (List<String> nameList) {
      updateItemList(tabMap, nameList);

      Global.profile = Global.profile.copyWith(tabConfig: _tabConfig.oN);
      Global.saveProfile();

      logger.d(
          '${_tabConfig.tabItemList.map((e) => '${e.name}:${e.enable}').toList().join('\n')} ');
    });
  }

  void updateItemList(Map<String, bool> map, List<String> nameList) {
    final tabItemList = <TabItem>[];
    for (final String name in nameList) {
      tabItemList.add(TabItem(name: name, enable: map[name] ?? false));
    }
    _tabConfig = _tabConfig.copyWith(tabItemList: tabItemList);
  }

  List<BottomNavigationBarItem> get listBottomNavigationBarItem => _showTabs
      .map((e) => BottomNavigationBarItem(
            icon: tabPages.tabIcons[e]!,
            label: tabPages.tabTitles[e],
          ))
      .toList();

  late BuildContext tContext;

  /// 需要初始化获取BuildContext 否则修改语言时 tabitem 的文字不会立即生效
  void init({required BuildContext inContext}) {
    // logger.d(' rebuild home');
    tContext = inContext;
  }

  List<Widget> get viewList =>
      _showTabs.map((e) => tabPages.tabViews[e]!).toList();

  List<EhTabController?> get scrollControllerList =>
      _showTabs.map((e) => tabPages.scrollControllerMap[e]).toList();

  Future<void> onTap(int index) async {
    if (index == currentIndex &&
        index != listBottomNavigationBarItem.length - 1) {
      await doubleTapBar(
        duration: const Duration(milliseconds: 800),
        awaitComplete: false,
        onTap: () {
          scrollControllerList[index]?.scrollToTop();
        },
        onDoubleTap: () {
          scrollControllerList[index]?.scrollToTopRefresh();
        },
      );
    } else {
      currentIndex = index;
    }
  }

  void resetIndex() {
    final int last = listBottomNavigationBarItem.length;
    tabController.index = last - 1;
  }

  /// 双击bar的处理
  Future<void> doubleTapBar({
    required VoidCallback onTap,
    required VoidCallback onDoubleTap,
    required Duration duration,
    required bool awaitComplete,
  }) async {
    final Duration _duration = duration;
    if (!tapAwait) {
      tapAwait = true;

      if (awaitComplete) {
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
    } else {
      tapAwait = false;
      onDoubleTap();
    }
  }

  /// 连按两次返回退出
  Future<bool> doubleClickBack() async {
    logger.t('click back');
    if (lastPressedAt == null ||
        DateTime.now().difference(lastPressedAt ?? DateTime.now()) >
            const Duration(seconds: 1)) {
      showToast(L10n.of(tContext).double_click_back);
      //两次点击间隔超过1秒则重新计时
      lastPressedAt = DateTime.now();
      return false;
    }
    return true;
  }

  Future<bool> onWillPop() async {
    if (!isLayoutLarge) {
      return await doubleClickBack();
    }

    logger.t(
        'history first ${FirstNavigatorObserver().history.map((e) => e.settings.name).join(', ')} ');

    logger.t(
        'history second ${SecondNavigatorObserver().history.map((e) => e.settings.name).join(', ')} ');

    logger.t(
        '${FirstNavigatorObserver().history.length} ${SecondNavigatorObserver().history.length} ');

    final history = SecondNavigatorObserver().history;
    final prevSecondRoute = history[max(0, history.length - 2)].settings.name;
    logger.t('prevSecondRoute $prevSecondRoute');

    if (SecondNavigatorObserver().history.length > 1 &&
        prevSecondRoute != EHRoutes.root) {
      Get.back(id: 2);
      return false;
    } else if (FirstNavigatorObserver().history.length > 1) {
      Get.back(id: 1);
      return false;
    } else {
      return await doubleClickBack();
    }
  }

  Future<void> onPopInvoked(bool didPop) async {
    logger.d('onPopInvoked $didPop');
  }
}
