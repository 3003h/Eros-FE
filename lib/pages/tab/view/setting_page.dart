import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/pages/tab/controller/setting_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingTab extends GetView<SettingViewController> {
  const SettingTab({Key key, this.tabIndex, this.scrollController})
      : super(key: key);
  final String tabIndex;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final String _title = S.of(context).tab_setting;
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
