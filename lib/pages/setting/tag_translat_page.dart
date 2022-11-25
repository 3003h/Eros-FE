import 'package:fehviewer/common/controller/tag_trans_controller.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/component/setting_base.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/pages/setting/setting_items/selector_Item.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class TagTranslatePage extends StatelessWidget {
  const TagTranslatePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Widget cps = Obx(() {
      return CupertinoPageScaffold(
          backgroundColor: !ehTheme.isDarkMode
              ? CupertinoColors.secondarySystemBackground
              : null,
          navigationBar: const CupertinoNavigationBar(
            middle: Text('标签翻译'),
          ),
          child: SafeArea(
            child: ListViewTagTranslate(),
            bottom: false,
          ));
    });

    return cps;
  }
}

class ListViewTagTranslate extends StatelessWidget {
  ListViewTagTranslate({Key? key}) : super(key: key);

  final EhConfigService _ehConfigService = Get.find();
  final TagTransController transController = Get.find();

  Future<void> _handleTagTranslatChanged(bool newValue) async {
    _ehConfigService.isTagTranslat = newValue;
    if (newValue) {
      try {
        if (await transController.checkUpdate()) {
          showToast('更新开始');
          await transController.updateDB();
          showToast('更新完成');
        } else {
          logger.v('do not need update');
        }
      } catch (e) {
        logger.e('更新翻译异常 $e');
        rethrow;
      }
    }
  }

  void _handleTagTranslatCDNChanged(bool newValue) {
    _ehConfigService.enableTagTranslateCDN = newValue;
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
    final bool _tagTranslat = _ehConfigService.isTagTranslat;

    return Column(
      children: [
        Obx(() => TextSwitchItem(
              '开启标签翻译',
              value: _tagTranslat,
              onChanged: _handleTagTranslatChanged,
              desc: '当前版本:${_ehConfigService.tagTranslatVer.value}',
              suffix: CupertinoButton(
                padding: const EdgeInsets.all(0),
                child: const Icon(CupertinoIcons.refresh),
                onPressed: _forceUpdateTranslate,
              ),
            )),
        Obx(() {
          return AnimatedCrossFade(
            alignment: Alignment.center,
            crossFadeState: _ehConfigService.isTagTranslat
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstCurve: Curves.easeIn,
            secondCurve: Curves.easeOut,
            duration: const Duration(milliseconds: 200),
            firstChild: const SizedBox(),
            secondChild: _buildTagIntroImgLvItem(context),
          );
        }),
        TextSwitchItem(
          '加速下载数据',
          value: _ehConfigService.enableTagTranslateCDN,
          onChanged: _handleTagTranslatCDNChanged,
          desc: '使用CDN进行加速下载',
        ),
        // SelectorSettingItem(
        //   title: '自动更新策略',
        //   onTap: () {},
        //   selector: _tagTranslat ? L10n.of(context).on : L10n.of(context).off,
        //   hideLine: true,
        // ),
        _buildTagTranslateDataUpdateModeItem(
          context,
          hideLine: true,
        ),
      ],
    );
  }
}

/// 标签介绍图片切换
Widget _buildTagIntroImgLvItem(BuildContext context, {bool hideLine = false}) {
  const String _title = '标签介绍图片';
  final EhConfigService ehConfigService = Get.find();

  final Map<TagIntroImgLv, String> descMap = <TagIntroImgLv, String>{
    TagIntroImgLv.disable: '禁用',
    TagIntroImgLv.nonh: '隐藏H图片',
    TagIntroImgLv.r18: '隐藏引起不适的图片',
    TagIntroImgLv.r18g: '全部显示',
  };

  return Obx(() {
    return SelectorItem<TagIntroImgLv>(
      title: _title,
      hideDivider: hideLine,
      actionMap: descMap,
      initVal: ehConfigService.tagIntroImgLv.value,
      onValueChanged: (val) => ehConfigService.tagIntroImgLv.value = val,
    );
  });
}

/// 自动更新策略切换
Widget _buildTagTranslateDataUpdateModeItem(BuildContext context,
    {bool hideLine = false}) {
  const String _title = '自动更新策略';
  final EhConfigService ehConfigService = Get.find();

  final Map<TagTranslateDataUpdateMode, String> modeMap =
      <TagTranslateDataUpdateMode, String>{
    TagTranslateDataUpdateMode.manual: '手动更新',
    TagTranslateDataUpdateMode.everyStartApp: '启动App时更新',
  };

  return Obx(() {
    return SelectorItem<TagTranslateDataUpdateMode>(
      title: _title,
      hideDivider: hideLine,
      actionMap: modeMap,
      initVal: ehConfigService.tagTranslateDataUpdateMode,
      onValueChanged: (val) => ehConfigService.tagTranslateDataUpdateMode = val,
    );
  });
}
