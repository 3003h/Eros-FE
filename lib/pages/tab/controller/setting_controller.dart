import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/pages/item/setting_item.dart';
import 'package:fehviewer/route/routes.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class SettingViewController extends GetxController {
  // 菜单文案
  var _itemTitles = [];

  var _icons = [];

  var _routes = [];

  List getItemList() {
    List _slivers = [];
    for (int _index = 0; _index < _itemTitles.length + 1; _index++) {
      if (_index == 0) {
        // _slivers.add(Get.find<EhConfigService>().isSafeMode.value ?? false
        //     ? Container()
        //     : UserItem());
        _slivers.add(const SizedBox());
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

  void initData(BuildContext context) {
    _itemTitles = <String>[
      S.of(context).eh,
      S.of(context).download,
      S.of(context).advanced,
      // '安全设置',
      S.of(context).about,
    ];

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
