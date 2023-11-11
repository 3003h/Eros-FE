import 'package:fehviewer/common/controller/tag_trans_controller.dart';
import 'package:fehviewer/common/service/ehsetting_service.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/pages/setting/setting_items/selector_Item.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:sliver_tools/sliver_tools.dart';

class TagTranslatePage extends StatelessWidget {
  const TagTranslatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        middle: Text('标签翻译'),
      ),
      child: CustomScrollView(
        slivers: [
          SliverSafeArea(sliver: ListViewTagTranslate()),
        ],
      ),
    );
  }
}

class ListViewTagTranslate extends StatelessWidget {
  const ListViewTagTranslate({super.key});

  EhSettingService get _ehSettingService => Get.find();

  TagTransController get transController => Get.find();

  Future<void> _handleTagTranslatChanged(bool newValue) async {
    _ehSettingService.isTagTranslate = newValue;
    if (newValue) {
      try {
        if (await transController.checkUpdate()) {
          showToast('更新开始');
          await transController.updateDB();
          showToast('更新完成');
        } else {
          logger.t('do not need update');
        }
      } catch (e) {
        logger.e('更新翻译异常 $e');
        rethrow;
      }
    }
  }

  void _handleTagTranslatCDNChanged(bool newValue) {
    _ehSettingService.enableTagTranslateCDN = newValue;
  }

  Future<void> _forceUpdateTranslate() async {
    if (await transController.checkUpdate(force: true)) {
      showToast('手动更新开始');
      await transController.updateDB();
      showToast('更新完成');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiSliver(children: [
      SliverCupertinoListSection.listInsetGrouped(children: [
        // _handleTagTranslatChanged switch
        EhCupertinoListTile(
          title: const Text('启用标签翻译'),
          subtitle: Text('当前版本:${_ehSettingService.tagTranslatVer.value}'),
          trailing: Obx(() {
            return Row(
              children: [
                CupertinoButton(
                  padding: const EdgeInsets.all(0),
                  child: const Icon(CupertinoIcons.refresh),
                  onPressed: _forceUpdateTranslate,
                ),
                CupertinoSwitch(
                  value: _ehSettingService.isTagTranslate,
                  onChanged: _handleTagTranslatChanged,
                ),
              ],
            );
          }),
        ),

        Obx(() {
          return AnimatedCrossFade(
            alignment: Alignment.center,
            crossFadeState: _ehSettingService.isTagTranslate
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstCurve: Curves.easeIn,
            secondCurve: Curves.easeOut,
            duration: const Duration(milliseconds: 200),
            firstChild: const SizedBox(),
            secondChild: _buildTagIntroImgLvItem(context),
          );
        }),

        // enableTagTranslateCDN switch
        EhCupertinoListTile(
          title: const Text('加速下载数据'),
          subtitle: const Text('使用CDN加速下载数据'),
          trailing: Obx(() {
            return CupertinoSwitch(
              value: _ehSettingService.enableTagTranslateCDN,
              onChanged: _handleTagTranslatCDNChanged,
            );
          }),
        ),

        _buildTagTranslateDataUpdateModeItem(context),
      ]),
    ]);
  }
}

/// 标签介绍图片切换
Widget _buildTagIntroImgLvItem(BuildContext context) {
  const String _title = '标签介绍图片';
  final EhSettingService ehSettingService = Get.find();

  final Map<TagIntroImgLv, String> descMap = <TagIntroImgLv, String>{
    TagIntroImgLv.disable: '禁用',
    TagIntroImgLv.nonh: '隐藏H图片',
    TagIntroImgLv.r18: '隐藏引起不适的图片',
    TagIntroImgLv.r18g: '全部显示',
  };

  return Obx(() {
    return SelectorCupertinoListTile<TagIntroImgLv>(
      title: _title,
      actionMap: descMap,
      initVal: ehSettingService.tagIntroImgLv.value,
      onValueChanged: (val) => ehSettingService.tagIntroImgLv.value = val,
    );
  });
}

/// 自动更新策略切换
Widget _buildTagTranslateDataUpdateModeItem(BuildContext context) {
  const String _title = '自动更新策略';
  final EhSettingService ehSettingService = Get.find();

  final Map<TagTranslateDataUpdateMode, String> modeMap =
      <TagTranslateDataUpdateMode, String>{
    TagTranslateDataUpdateMode.manual: '手动更新',
    TagTranslateDataUpdateMode.everyStartApp: '启动App时更新',
  };

  return Obx(() {
    return SelectorCupertinoListTile<TagTranslateDataUpdateMode>(
      title: _title,
      actionMap: modeMap,
      initVal: ehSettingService.tagTranslateDataUpdateMode,
      onValueChanged: (val) =>
          ehSettingService.tagTranslateDataUpdateMode = val,
    );
  });
}
