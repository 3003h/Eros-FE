import 'package:fehviewer/pages/tab/controller/tabhome_controller.dart';
import 'package:fehviewer/pages/tab/view/popular_page.dart';
import 'package:fehviewer/pages/tab/view/setting_page.dart';
import 'package:fehviewer/pages/tab/view/toplist_page.dart';
import 'package:fehviewer/route/routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:fehviewer/generated/l10n.dart';

import 'gallery_page.dart';

class TabHomeSmallPersistent extends GetView<TabHomeController> {
  @override
  Widget build(BuildContext context) {
    controller.init(inContext: context);

    return PersistentTabView(
      context,
      screens: [
        GalleryListTab(),
        ToplistTab(),
        SettingTab(),
      ],
      decoration: NavBarDecoration(
          colorBehindNavBar: Colors.indigo,
          borderRadius: BorderRadius.circular(20.0)),
      items: [
        PersistentBottomNavBarItem(
          icon: Icon(FontAwesomeIcons.list, size: kIconSize),
          title: L10n.of(Get.find<TabHomeController>().tContext).tab_gallery,
          activeColorPrimary: Colors.blue,
          inactiveColorPrimary: Colors.grey,
          inactiveColorSecondary: Colors.purple,
        ),
        PersistentBottomNavBarItem(
          icon: Icon(FontAwesomeIcons.solidThumbsUp, size: kIconSize),
          title: L10n.of(Get.find<TabHomeController>().tContext).tab_toplist,
          activeColorPrimary: Colors.teal,
          inactiveColorPrimary: Colors.grey,
        ),
        PersistentBottomNavBarItem(
          icon: Icon(FontAwesomeIcons.cog, size: kIconSize),
          title: L10n.of(Get.find<TabHomeController>().tContext).tab_setting,
          activeColorPrimary: Colors.indigo,
          inactiveColorPrimary: Colors.grey,
          // inactiveColorSecondary: Colors.purple,
        ),
      ],
      screenTransitionAnimation: ScreenTransitionAnimation(
        animateTabTransition: true,
        curve: Curves.ease,
        duration: Duration(milliseconds: 200),
      ),
      itemAnimationProperties: ItemAnimationProperties(
        duration: Duration(milliseconds: 400),
        curve: Curves.ease,
      ),
    );
  }
}
