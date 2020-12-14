import 'package:FEhViewer/pages/tab/controller/setting_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingTab extends StatelessWidget {
  SettingTab({Key key, this.tabIndex, this.scrollController}) : super(key: key);
  final tabIndex;
  final scrollController;

  // ignore: avoid_field_initializers_in_const_classes
  final controller = Get.put(SettingController());

  @override
  Widget build(BuildContext context) {
    final String _title = 'tab_setting'.tr;
    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: <Widget>[
          CupertinoSliverNavigationBar(
            heroTag: 'setting',
            largeTitle: Text(
              _title,
            ),
            transitionBetweenRoutes: true,
          ),
          SliverSafeArea(
              top: false,
              minimum: const EdgeInsets.all(8),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  List _itemList = controller.getItemList();
                  if (index < _itemList.length) {
                    return _itemList[index];
                  } else {
                    return null;
                  }
                }),
              ))
        ],
      ),
    );
  }
}
