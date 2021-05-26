import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/pages/item/user_item.dart';
import 'package:fehviewer/pages/tab/controller/setting_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingTab extends GetView<SettingViewController> {
  const SettingTab({
    Key? key,
    this.tabIndex,
    this.scrollController,
  }) : super(key: key);
  final String? tabIndex;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    // logger.d(' SettingTab BuildContext');
    controller.initData(context);
    final String _title = S.of(context).tab_setting;
    return CupertinoPageScaffold(
      backgroundColor: !ehTheme.isDarkMode
          ? CupertinoColors.secondarySystemBackground
          : null,
      child: CustomScrollView(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: <Widget>[
          CupertinoSliverNavigationBar(
            heroTag: 'setting',
            middle: FadeTransition(
              opacity: controller.animation,
              child: Text(
                _title,
              ),
            ),
            largeTitle: Row(
              children: [
                Text(
                  _title,
                ),
                const Spacer(),
                if (Get.find<EhConfigService>().isSafeMode.value)
                  Container()
                else
                  UserWidget().paddingOnly(right: 20),
              ],
            ),
          ),
          SliverSafeArea(
            top: false,
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final List _itemList = controller.itemList;
                  if (index < _itemList.length) {
                    return _itemList[index];
                  } else {
                    return null;
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
