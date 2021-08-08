import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/models/base/eh_models.dart';
import 'package:fehviewer/pages/tab/view/download_page.dart';
import 'package:fehviewer/pages/tab/view/history_page.dart';
import 'package:fehviewer/pages/tab/view/toplist_page.dart';
import 'package:fehviewer/pages/tab/view/watched_page.dart';
import 'package:fehviewer/route/routes.dart';
import 'package:fehviewer/store/get_store.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

import '../view/favorite_page.dart';
import '../view/gallery_page.dart';
import '../view/popular_page.dart';
import '../view/setting_page.dart';

const double kIconSize = 24.0;
final TabPages tabPages = TabPages();

class TabPages {
  final Map<String, ScrollController> scrollControllerMap = {};

  ScrollController? _scrollController(String key) {
    if (scrollControllerMap[key] == null) {
      scrollControllerMap[key] = ScrollController();
    }
    return scrollControllerMap[key];
  }

  Map<String, Widget> get tabViews => <String, Widget>{
        EHRoutes.popular: PopularListTab(
          tabTag: EHRoutes.popular,
          scrollController: _scrollController(EHRoutes.popular),
        ),
        EHRoutes.watched: WatchedListTab(
          tabIndex: EHRoutes.watched,
          scrollController: _scrollController(EHRoutes.watched),
        ),
        EHRoutes.gallery: GalleryListTab(
          tabTag: EHRoutes.gallery,
          scrollController: _scrollController(EHRoutes.gallery),
        ),
        EHRoutes.favorite: FavoriteTab(
          tabTag: EHRoutes.favorite,
          scrollController: _scrollController(EHRoutes.favorite),
        ),
        EHRoutes.toplist: ToplistTab(
          tabTag: EHRoutes.toplist,
          scrollController: _scrollController(EHRoutes.toplist),
        ),
        EHRoutes.history: HistoryTab(
          tabTag: EHRoutes.history,
          scrollController: _scrollController(EHRoutes.history),
        ),
        EHRoutes.download: DownloadTab(
          tabIndex: EHRoutes.download,
          scrollController: _scrollController(EHRoutes.download),
        ),
        EHRoutes.setting: SettingTab(
          tabIndex: EHRoutes.setting,
          scrollController: _scrollController(EHRoutes.setting),
        ),
      };

  final Map<String, IconData> iconDatas = <String, IconData>{
    EHRoutes.popular: FontAwesomeIcons.fire,
    EHRoutes.watched: FontAwesomeIcons.solidEye,
    EHRoutes.gallery: FontAwesomeIcons.jira,
    EHRoutes.favorite: FontAwesomeIcons.solidHeart,
    EHRoutes.toplist: FontAwesomeIcons.listOl,
    EHRoutes.history: FontAwesomeIcons.history,
    EHRoutes.download: FontAwesomeIcons.download,
    EHRoutes.setting: FontAwesomeIcons.cog,
  };

  Map<String, Widget> get tabIcons => iconDatas
      .map((key, value) => MapEntry(key, Icon(value, size: kIconSize)));

  Map<String, String> get tabTitles => <String, String>{
        EHRoutes.popular:
            L10n.of(Get.find<TabHomeController>().tContext).tab_popular,
        EHRoutes.watched:
            L10n.of(Get.find<TabHomeController>().tContext).tab_watched,
        EHRoutes.gallery:
            L10n.of(Get.find<TabHomeController>().tContext).tab_gallery,
        EHRoutes.favorite:
            L10n.of(Get.find<TabHomeController>().tContext).tab_favorite,
        EHRoutes.toplist:
            L10n.of(Get.find<TabHomeController>().tContext).tab_toplist,
        EHRoutes.history:
            L10n.of(Get.find<TabHomeController>().tContext).tab_history,
        EHRoutes.download:
            L10n.of(Get.find<TabHomeController>().tContext).tab_download,
        EHRoutes.setting:
            L10n.of(Get.find<TabHomeController>().tContext).tab_setting,
      };
}

// 默认显示在tabbar的view
const Map<String, bool> kDefTabMap = <String, bool>{
  EHRoutes.popular: true,
  EHRoutes.watched: false,
  EHRoutes.gallery: true,
  EHRoutes.favorite: true,
  EHRoutes.toplist: false,
  EHRoutes.download: true,
  EHRoutes.history: false,
};

// 默认显示顺序 ?
const List<String> kTabNameList = <String>[
  EHRoutes.gallery,
  EHRoutes.popular,
  EHRoutes.watched,
  EHRoutes.favorite,
  EHRoutes.toplist,
  EHRoutes.download,
  EHRoutes.history,
];

class TabHomeController extends GetxController {
  DateTime? lastPressedAt; //上次点击时间

  int currentIndex = 0;
  bool tapAwait = false;

  final EhConfigService _ehConfigService = Get.find();
  final GStore gStore = Get.find();

  bool get isSafeMode => _ehConfigService.isSafeMode.value;

  final CupertinoTabController tabController = CupertinoTabController();
  final PersistentTabController persistentTabController =
      PersistentTabController();

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
    // setting 必须显示
    _list.add(EHRoutes.setting);
    return _list;
  }

  // 控制tab项顺序
  RxList<String> tabNameList = kTabNameList.obs;
  // RxList<String> tabNameList =
  //     kDefTabMap.entries.map((e) => e.key).toList().obs;

  // 通过控制该变量控制tab项的开关
  RxMap<String, bool> tabMap = kDefTabMap.obs;

  late TabConfig _tabConfig;

  @override
  void onInit() {
    super.onInit();

    _tabConfig = gStore.tabConfig ?? (TabConfig(tabItemList: []));

    // logger.i('get tab config ${_tabConfig.tabItemList.length}');

    if (_tabConfig.tabMap.isNotEmpty) {
      if (_tabConfig.tabItemList.length < kTabNameList.length) {
        final List<String> _tabConfigNames =
            _tabConfig.tabItemList.map((e) => e.name).toList();
        final List<String> _newTabs = kTabNameList
            .where((String element) => !_tabConfigNames.contains(element))
            .toList();

        // 新增tab页的处理
        logger.d('add tab $_newTabs');

        for (final viewName in _newTabs) {
          _tabConfig.tabItemList.add(TabItem(name: viewName, enable: false));
        }
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
      _tabConfig.setItemList(map, tabNameList);
      gStore.tabConfig = _tabConfig;
      logger.d(
          '${_tabConfig.tabItemList.map((e) => '${e.name}:${e.enable}').toList().join('\n')} ');
    });

    ever(tabNameList, (List<String> nameList) {
      _tabConfig.setItemList(tabMap, nameList);
      gStore.tabConfig = _tabConfig;
      logger.d(
          '${_tabConfig.tabItemList.map((e) => '${e.name}:${e.enable}').toList().join('\n')} ');
    });
  }

  List<BottomNavigationBarItem> get listBottomNavigationBarItem => _showTabs
      .map((e) => BottomNavigationBarItem(
            icon: (tabPages.tabIcons[e])!,
            label: tabPages.tabTitles[e],
          ))
      .toList();

  BuildContext tContext = Get.context!;

  /// 需要初始化获取BuildContext 否则修改语言时tabitem的文字不会立即生效
  void init({required BuildContext inContext}) {
    // logger.d(' rebuild home');
    tContext = inContext;
  }

  List<Widget> get viewList =>
      _showTabs.map((e) => tabPages.tabViews[e]!).toList();

  List<ScrollController?> get scrollControllerList =>
      _showTabs.map((e) => tabPages.scrollControllerMap[e]).toList();

  Future<void> onTap(int index) async {
    if (index == currentIndex &&
        index != listBottomNavigationBarItem.length - 1) {
      await doubleTapBar(
        duration: const Duration(milliseconds: 800),
        awaitComplete: false,
        onTap: () {
          scrollControllerList[index]?.animateTo(0.0,
              duration: const Duration(milliseconds: 500), curve: Curves.ease);
        },
        onDoubleTap: () {
          scrollControllerList[index]?.animateTo(-100.0,
              duration: const Duration(milliseconds: 500), curve: Curves.ease);
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
//      loggerNoStack.v('等待时间内第二次点击 执行双击事件');
      tapAwait = false;
      onDoubleTap();
    }
  }

  /// 连按两次返回退出
  Future<bool> doubleClickBack() async {
    logger.v('click back');
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
}
