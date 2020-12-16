import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/pages/item/setting_item.dart';
import 'package:FEhViewer/pages/item/user_item.dart';
import 'package:FEhViewer/route/routes.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class SettingController extends GetxController {
  // 菜单文案
  var _itemTitles = [];

  var _icons = [];

  var _routes = [];

  List getItemList() {
    List _slivers = [];
    for (int _index = 0; _index < _itemTitles.length + 1; _index++) {
      if (_index == 0) {
        _slivers.add(Global.profile.ehConfig.safeMode ?? false
            ? Container()
            : UserItem());
      } else {
        _slivers.add(SettingItems(
          text: _itemTitles[_index - 1],
          icon: _icons[_index - 1],
          route: _routes[_index - 1],
        ));
      }
    }
//    logger.v('${_slivers.length}');
    return _slivers;
  }

  void initData(BuildContext context) {}

  @override
  void onInit() {
    super.onInit();

    _itemTitles = <String>['EH设置', '下载设置', '高级设置', /*'安全设置',*/ '关于'];

    _icons = <IconData>[
      FontAwesomeIcons.cookieBite,
      FontAwesomeIcons.download,
      FontAwesomeIcons.tools,
      // FontAwesomeIcons.shieldAlt,
      FontAwesomeIcons.infoCircle,
    ];

    _routes = <String>[
      EHRoutes.ehSetting,
      EHRoutes.downloadSetting,
      EHRoutes.advancedSetting,
      // '',
      EHRoutes.about,
    ];
  }
}
