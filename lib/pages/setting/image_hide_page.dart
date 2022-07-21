import 'package:fehviewer/common/controller/image_hide_controller.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/common/service/layout_service.dart';
import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/component/setting_base.dart';
import 'package:fehviewer/route/routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class ImageHidePage extends GetView<ImageHideController> {
  const ImageHidePage({Key? key}) : super(key: key);
  EhConfigService get _ehConfigService => Get.find();

  @override
  Widget build(BuildContext context) {
    const String _title = 'Image Hide';
    return Obx(() {
      return CupertinoPageScaffold(
        backgroundColor: !ehTheme.isDarkMode
            ? CupertinoColors.secondarySystemBackground
            : null,
        navigationBar: const CupertinoNavigationBar(
          padding: EdgeInsetsDirectional.only(end: 12),
          middle: Text(_title),
        ),
        child: SafeArea(
          bottom: false,
          top: false,
          child: Container(
            child: ListView(
              children: [
                Obx(() => TextSwitchItem(
                      'QRCode Check',
                      intValue: _ehConfigService.enableQRCodeCheck,
                      onChanged: (bool val) =>
                          _ehConfigService.enableQRCodeCheck = val,
                      hideDivider: true,
                    )),
                const ItemSpace(),
                Obx(() => TextSwitchItem(
                      'PHash Check',
                      intValue: _ehConfigService.enablePHashCheck,
                      onChanged: (bool val) =>
                          _ehConfigService.enablePHashCheck = val,
                    )),
                SelectorSettingItem(
                  hideDivider: true,
                  title: 'Mange Hided Images',
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
        ),
      );
    });
  }
}
