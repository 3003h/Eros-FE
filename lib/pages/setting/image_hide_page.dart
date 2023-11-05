import 'package:fehviewer/common/controller/image_hide_controller.dart';
import 'package:fehviewer/common/service/ehsetting_service.dart';
import 'package:fehviewer/common/service/layout_service.dart';
import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/component/setting_base.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class ImageHidePage extends GetView<ImageHideController> {
  const ImageHidePage({Key? key}) : super(key: key);
  EhSettingService get _ehSettingService => Get.find();

  @override
  Widget build(BuildContext context) {
    final String _title = L10n.of(context).image_block;
    return Obx(() {
      return CupertinoPageScaffold(
        backgroundColor: !ehTheme.isDarkMode
            ? CupertinoColors.secondarySystemBackground
            : null,
        navigationBar: CupertinoNavigationBar(
          padding: const EdgeInsetsDirectional.only(end: 12),
          middle: Text(_title),
        ),
        child: Container(
          child: ListView(
            children: [
              Obx(() => TextSwitchItem(
                    L10n.of(context).QR_code_block,
                    value: _ehSettingService.enableQRCodeCheck,
                    onChanged: (bool val) =>
                        _ehSettingService.enableQRCodeCheck = val,
                    hideDivider: true,
                  )),
              const ItemSpace(),
              Obx(() => TextSwitchItem(
                    L10n.of(context).phash_check,
                    value: _ehSettingService.enablePHashCheck,
                    onChanged: (bool val) =>
                        _ehSettingService.enablePHashCheck = val,
                  )),
              SelectorSettingItem(
                hideDivider: true,
                title: L10n.of(context).phash_block_list,
                selector: '',
                onTap: () {
                  Get.toNamed(
                    EHRoutes.mangaHidedImage,
                    id: isLayoutLarge ? 2 : null,
                  );
                },
              ),
            ],
          ),
        ),
      );
    });
  }
}
