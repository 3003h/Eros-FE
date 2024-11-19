import 'package:eros_fe/common/service/ehsetting_service.dart';
import 'package:eros_fe/index.dart';
import 'package:eros_fe/pages/item/user_item.dart';
import 'package:eros_fe/pages/tab/controller/setting_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class SettingTab extends GetView<SettingViewController> {
  const SettingTab({super.key});

  @override
  Widget build(BuildContext context) {
    controller.initData(context);
    final String _title = L10n.of(context).tab_setting;

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      child: CustomScrollView(
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
                if (Get.find<EhSettingService>().isSafeMode.value)
                  Container()
                else
                  UserWidget().paddingOnly(right: 20),
              ],
            ),
          ),
          SliverSafeArea(
            top: false,
            sliver: SliverCupertinoListSection.insetGrouped(
              itemCount: controller.itemCount,
              itemBuilder: (context, index) {
                return controller.cupertinoListTileBuilder(index);
              },
            ),
          ),
        ],
      ),
    );
  }
}
