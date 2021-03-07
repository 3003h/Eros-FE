import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/network/gallery_request.dart';
import 'package:fehviewer/pages/tab/controller/tabhome_controller.dart';
import 'package:fehviewer/utils/vibrate.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'tabview_controller.dart';

class GalleryViewController extends TabViewController {
  GalleryViewController({int? cats}) : super(cats: cats);

  final TabHomeController _tabHomeController = Get.find();

  bool get enablePopupMenu =>
      _tabHomeController.tabMap.entries
          .toList()
          .indexWhere((MapEntry<String, bool> element) => !element.value) >
      -1;

  final CustomPopupMenuController customPopupMenuController =
      CustomPopupMenuController();
  Widget get popupMenu {
    final List<Widget> _menu = <Widget>[];
    for (final MapEntry<String, bool> elem
        in _tabHomeController.tabMap.entries) {
      if (!elem.value) {
        _menu.add(GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            vibrateUtil.light();
            customPopupMenuController.hideMenu();
            Get.toNamed(elem.key);
          },
          child: Container(
            padding:
                const EdgeInsets.only(left: 14, right: 18, top: 5, bottom: 5),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  tabPages.iconDatas[elem.key],
                  size: 20,
                  // color: CupertinoDynamicColor.resolve(
                  //     CupertinoColors.secondaryLabel, Get.context!),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(left: 10),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      tabPages.tabTitles[elem.key] ?? '',
                      style: TextStyle(
                        color: CupertinoDynamicColor.resolve(
                            CupertinoColors.label, Get.context!),
                        fontWeight: FontWeight.w500,
                        // fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: _menu,
    );
  }

  String get title {
    if (cats != null) {
      return EHConst.cats.entries
              ?.firstWhere((MapEntry<String, int> element) =>
                  element.value == EHConst.sumCats - (cats ?? 0))
              ?.key ??
          S.of(Get.context!)!.tab_gallery;
    } else {
      return S.of(Get.context!)!.tab_gallery;
    }
  }

  @override
  void onInit() {
    fetchNormal = Api.getGallery;
    super.onInit();
  }
}
