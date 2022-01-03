import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/component/setting_base.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/pages/filter/filter.dart';
import 'package:fehviewer/pages/filter/gallery_filter_view.dart';
import 'package:fehviewer/pages/tab/controller/custom_sublist_controller.dart';
import 'package:fehviewer/pages/tab/controller/custom_tabbar_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class CustomProfileSettingView extends GetView<CustomTabbarController> {
  const CustomProfileSettingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    CustomProfile customProfile;

    String? profileUuid = Get.arguments as String?;
    if (profileUuid != null) {
      customProfile = controller.profileMap[profileUuid] ??
          CustomProfile(name: '', uuid: generateUuidv4());
    } else {
      customProfile = CustomProfile(name: '', uuid: generateUuidv4());
    }

    final int oriIndex = controller.profiles
        .indexWhere((element) => element.uuid == profileUuid);

    final _style = TextStyle(
      // height: 1,
      color: CupertinoDynamicColor.resolve(CupertinoColors.activeBlue, context),
    );

    return CupertinoPageScaffold(
      backgroundColor: !ehTheme.isDarkMode
          ? CupertinoColors.secondarySystemBackground
          : null,
      navigationBar: CupertinoNavigationBar(
        trailing: GestureDetector(
          onTap: () {
            if (oriIndex >= 0) {
              controller.profiles[oriIndex] = customProfile;
            } else {
              controller.profiles.add(customProfile);
            }
            Get.lazyPut(() => CustomSubListController(),
                tag: customProfile.uuid);
            Get.back();
          },
          child: Text(
            '保存',
            style: _style,
          ),
        ),
      ),
      child: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              TextInputItem(
                title: '分组名称',
                textFieldPadding: const EdgeInsets.fromLTRB(20, 6, 6, 6),
                initValue: customProfile.name,
                maxLines: null,
                textAlign: TextAlign.left,
                onChanged: (value) {
                  customProfile = customProfile.copyWith(
                      name: value.replaceAll('\n', '').trim());
                },
              ),
              Container(
                color: CupertinoDynamicColor.resolve(
                    ehTheme.itemBackgroundColor!, Get.context!),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GalleryCatFilter(
                  catNum: customProfile.cats ?? 0,
                  maxCrossAxisExtent: 150,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  onCatNumChanged: (int value) {
                    logger.d('onCatNumChanged $value');
                    customProfile = customProfile.copyWith(cats: value);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
