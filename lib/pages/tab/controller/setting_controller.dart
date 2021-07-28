import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/pages/item/setting_item.dart';
import 'package:fehviewer/pages/tab/controller/tabhome_controller.dart';
import 'package:fehviewer/route/routes.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class SettingViewController extends GetxController
    with SingleGetTickerProviderMixin {
  // 控制middle显示
  final RxBool _showMiddle = false.obs;

  bool get showMidle => _showMiddle.value;

  set showMidle(bool val) => _showMiddle.value = val;

  //
  late Animation<double> animation;
  late AnimationController _animationController;

  final ScrollController _scrollController =
      tabPages.scrollControllerMap[EHRoutes.setting]!;

  @override
  void onInit() {
    super.onInit();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    animation = Tween(begin: 0.0, end: 1.0).animate(_animationController);

    // 监听滚动
    _scrollController.addListener(_scrollControllerLister);
  }

  void _scrollControllerLister() {
    if (_scrollController.offset < 50.0 && showMidle) {
      _animationController.reverse();
      showMidle = false;
    } else if (_scrollController.offset >= 50.0 && !showMidle) {
      _animationController.forward();
      showMidle = true;
    }
  }

  @override
  void onClose() {
    _animationController.dispose();
    super.onClose();
  }

  // 菜单文案
  List _itemTitles = [];

  List _icons = [];

  List _routes = [];

  List get itemList {
    final List _slivers = [];
    for (int _index = 0; _index < _itemTitles.length; _index++) {
      _slivers.add(
        SettingItems(
          bottomDivider: _index != _itemTitles.length - 1,
          text: _itemTitles[_index],
          icon: _icons[_index],
          route: _routes[_index],
        ),
      );
    }
    return _slivers;
  }

  void initData(BuildContext context) {
    _itemTitles = <String>[
      L10n.of(context).eh,
      L10n.of(context).download,
      L10n.of(context).search,
      L10n.of(context).advanced,
      L10n.of(context).security,
      L10n.of(context).about,
    ];

    _icons = <IconData>[
      FontAwesomeIcons.cookieBite,
      FontAwesomeIcons.download,
      FontAwesomeIcons.search,
      FontAwesomeIcons.tools,
      FontAwesomeIcons.shieldAlt,
      FontAwesomeIcons.infoCircle,
    ];

    _routes = <String>[
      EHRoutes.ehSetting,
      EHRoutes.downloadSetting,
      EHRoutes.searchSetting,
      EHRoutes.advancedSetting,
      EHRoutes.securitySetting,
      EHRoutes.about,
    ];
  }
}
