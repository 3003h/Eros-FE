import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/pages/tab/view/watched_page.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../view/favorite_page.dart';
import '../view/gallery_page.dart';
import '../view/popular_page.dart';
import '../view/setting_page.dart';

class TabHomeController extends GetxController {
  DateTime lastPressedAt; //上次点击时间

  int currentIndex = 0;
  bool tapAwait = false;

  // 需要显示的tab
  List<String> tabs = <String>[
    TabPages.popular,
    TabPages.gallery,
    TabPages.favorite,
    TabPages.setting,
  ];

  final List defTabs = [];
  final List scrollControllerList = [];
  final List pageList = [];
  final List tabList = [];

  final Map<String, ScrollController> _scrollControllerMap = {};
  final CupertinoTabController tabController = CupertinoTabController();

  final EhConfigService _ehConfigService = Get.find();

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
    defTabs.clear();
    const double _iconSize = 24.0;
    defTabs.addAll([
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
        'title': S.of(context).tab_setting,
        'icon': const Icon(FontAwesomeIcons.cog, size: _iconSize),
        'page': SettingTab(
          tabIndex: S.of(context).tab_setting,
          scrollController: _getScrollController(S.of(context).tab_setting),
        )
      },
    ]);

    for (final tabObj in defTabs) {
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

const double kIconSize = 24.0;
final TabPages tabPages = TabPages();

class TabPages {
  static const String popular = 'popular';
  static const String watched = 'watched';
  static const String gallery = 'gallery';
  static const String favorite = 'favorite';
  static const String setting = 'setting';

  final Map<String, ScrollController> scrollControllerMap = {};
  ScrollController _scrollController(String key) {
    if (scrollControllerMap[key] == null) {
      scrollControllerMap[key] = ScrollController();
    }
    return scrollControllerMap[key];
  }

  Map<String, Widget> get tabViews => <String, Widget>{
        popular: PopularListTab(
          tabIndex: popular,
          scrollController: _scrollController(popular),
        ),
        watched: WatchedListTab(
          tabIndex: watched,
          scrollController: _scrollController(watched),
        ),
        gallery: GalleryListTab(
          tabIndex: gallery,
          scrollController: _scrollController(gallery),
        ),
        favorite: FavoriteTab(
          tabIndex: favorite,
          scrollController: _scrollController(favorite),
        ),
        setting: SettingTab(
          tabIndex: setting,
          scrollController: _scrollController(setting),
        ),
      };

  final Map<String, Widget> tabIcons = <String, Widget>{
    popular: const Icon(FontAwesomeIcons.fire, size: kIconSize),
    watched: const Icon(FontAwesomeIcons.eye, size: kIconSize),
    gallery: const Icon(FontAwesomeIcons.list, size: kIconSize),
    favorite: const Icon(FontAwesomeIcons.solidHeart, size: kIconSize),
    setting: const Icon(FontAwesomeIcons.cog, size: kIconSize),
  };

  Map<String, String> get tabTitles => <String, String>{
        popular: S.of(Get.find<TabHomeControllerNew>().tContext).tab_popular,
        watched: S.of(Get.find<TabHomeControllerNew>().tContext).tab_watched,
        gallery: S.of(Get.find<TabHomeControllerNew>().tContext).tab_gallery,
        favorite: S.of(Get.find<TabHomeControllerNew>().tContext).tab_favorite,
        setting: S.of(Get.find<TabHomeControllerNew>().tContext).tab_setting,
      };
}

class TabHomeControllerNew extends GetxController {
  DateTime lastPressedAt; //上次点击时间

  int currentIndex = 0;
  bool tapAwait = false;

  final EhConfigService _ehConfigService = Get.find();
  bool get isSafeMode => _ehConfigService.isSafeMode.value;

  final CupertinoTabController tabController = CupertinoTabController();

  // 需要显示的tab
  List<String> get tabs => isSafeMode
      ? <String>[
          TabPages.gallery,
          TabPages.setting,
        ]
      : <String>[
          TabPages.popular,
          TabPages.watched,
          TabPages.gallery,
          TabPages.favorite,
          TabPages.setting,
        ];

  List<BottomNavigationBarItem> get listBottomNavigationBarItem => tabs
      .map((e) => BottomNavigationBarItem(
          icon: tabPages.tabIcons[e], label: tabPages.tabTitles[e]))
      .toList();

  BuildContext tContext = Get.context;

  /// 需要初始化获取BuildContext 否则修改语言时tabitem的文字不会立即生效
  void init({BuildContext inContext}) {
    logger.d(' rebuild home');
    tContext = inContext;
  }

  List<Widget> get viewList => tabs.map((e) => tabPages.tabViews[e]).toList();
  List<ScrollController> get scrollControllerList =>
      tabs.map((e) => tabPages.scrollControllerMap[e]).toList();

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

  /// 连按两次返回退出
  Future<bool> doubleClickBack() async {
    loggerNoStack.v('click back');
    if (lastPressedAt == null ||
        DateTime.now().difference(lastPressedAt) > const Duration(seconds: 1)) {
      showToast(S.of(tContext).double_click_back);
      //两次点击间隔超过1秒则重新计时
      lastPressedAt = DateTime.now();
      return false;
    }
    return true;
  }
}
