import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/pages/setting/setting_items/selector_Item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../common/controller/tag_trans_controller.dart';
import '../../common/controller/user_controller.dart';
import '../../common/service/ehconfig_service.dart';
import '../../common/service/layout_service.dart';
import '../../common/service/locale_service.dart';
import '../../component/setting_base.dart';
import '../../const/locale.dart';
import '../../const/theme_colors.dart';
import '../../fehviewer.dart';
import '../login/controller/login_controller.dart';

class LayoutSettingPage extends StatelessWidget {
  const LayoutSettingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Widget cps = Obx(() {
      return CupertinoPageScaffold(
          backgroundColor: !ehTheme.isDarkMode
              ? CupertinoColors.secondarySystemBackground
              : null,
          navigationBar: CupertinoNavigationBar(
            middle: Text(L10n.of(context).layout),
          ),
          child: SafeArea(
            bottom: false,
            child: ListViewLayoutSetting(),
          ));
    });

    return cps;
  }
}

class ListViewLayoutSetting extends StatelessWidget {
  ListViewLayoutSetting({Key? key}) : super(key: key);

  final EhConfigService _ehConfigService = Get.find();
  final UserController userController = Get.find();
  final TagTransController transController = Get.find();
  final LocaleService localeService = Get.find();
  final LoginController loginController = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    final bool _jpnTitle = _ehConfigService.isJpnTitle.value;
    final bool _tagTranslat = _ehConfigService.isTagTranslat;
    final bool _galleryImgBlur = _ehConfigService.isGalleryImgBlur.value;

    void _handleJpnTitleChanged(bool newValue) {
      _ehConfigService.isJpnTitle(newValue);
    }

    void _handleGalleryListImgBlurChanged(bool newValue) {
      _ehConfigService.isGalleryImgBlur.value = newValue;
    }

    void _handlePureDarkChanged(bool newValue) {
      _ehConfigService.isPureDarkTheme.value = newValue;
    }

    final List<Widget> _list = <Widget>[
      _buildLanguageItem(context, hideLine: true),
      const ItemSpace(),
      _buildThemeItem(context),
      Obx(() => TextSwitchItem(
            L10n.of(context).dark_mode_effect,
            intValue: _ehConfigService.isPureDarkTheme.value,
            onChanged: _handlePureDarkChanged,
            desc: L10n.of(context).gray_black,
            descOn: L10n.of(context).pure_black,
          )),
      if (context.isTablet)
        Obx(() => TextSwitchItem(
              L10n.of(context).tablet_layout,
              intValue: _ehConfigService.tabletLayout,
              onChanged: (bool val) => _ehConfigService.tabletLayout = val,
            )),
      if (!Get.find<EhConfigService>().isSafeMode.value)
        SelectorSettingItem(
          hideDivider: true,
          title: L10n.of(context).tabbar_setting,
          selector: '',
          onTap: () {
            Get.toNamed(
              EHRoutes.pageSetting,
              id: isLayoutLarge ? 2 : null,
            );
          },
        ),
      const ItemSpace(),
      if (localeService.isLanguageCodeZh)
        Obx(() {
          return SelectorSettingItem(
            title: '标签翻译',
            onTap: () {
              Get.toNamed(
                EHRoutes.tagTranslat,
                id: isLayoutLarge ? 2 : null,
              );
            },
            selector: _tagTranslat ? L10n.of(context).on : L10n.of(context).off,
            desc: '当前版本:${_ehConfigService.tagTranslatVer.value}',
          );
        }),
      TextSwitchItem(
        L10n.of(context).show_jpn_title,
        intValue: _jpnTitle,
        onChanged: _handleJpnTitleChanged,
        // desc: '如果该画廊有日文标题则优先显示',
      ),
      if (localeService.isLanguageCodeZh)
        TextSwitchItem(
          '画廊封面模糊',
          intValue: _galleryImgBlur,
          onChanged: _handleGalleryListImgBlurChanged,
          hideDivider: true,
          // desc: '画廊列表封面模糊效果',
        ),
      const ItemSpace(),
      _buildListModeItem(
        context,
      ),
      _buildTagLimitItem(context),
      Obx(() {
        return AnimatedCrossFade(
          alignment: Alignment.center,
          crossFadeState: _ehConfigService.listMode.value == ListModeEnum.list
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstCurve: Curves.easeIn,
          secondCurve: Curves.easeOut,
          duration: const Duration(milliseconds: 200),
          firstChild: const SizedBox(),
          secondChild: TextSwitchItem(
            L10n.of(context).blurring_cover_background,
            intValue: _ehConfigService.blurringOfCoverBackground,
            onChanged: (val) =>
                _ehConfigService.blurringOfCoverBackground = val,
            hideDivider: _ehConfigService.listMode.value != ListModeEnum.list,
          ),
        );
      }),
      Obx(() {
        return AnimatedCrossFade(
          alignment: Alignment.center,
          crossFadeState: _ehConfigService.listMode.value == ListModeEnum.list
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstCurve: Curves.easeIn,
          secondCurve: Curves.easeOut,
          duration: const Duration(milliseconds: 200),
          firstChild: const SizedBox(),
          secondChild: TextSwitchItem(
            L10n.of(context).fixed_height_of_list_items,
            intValue: _ehConfigService.fixedHeightOfListItems,
            onChanged: (val) => _ehConfigService.fixedHeightOfListItems = val,
            hideDivider: true,
          ),
        );
      }),
      const ItemSpace(),
      Obx(() {
        return SelectorSettingItem(
          title: L10n.of(context).avatar,
          hideDivider: !localeService.isLanguageCodeZh,
          onTap: () {
            Get.toNamed(
              EHRoutes.avatarSetting,
              id: isLayoutLarge ? 2 : null,
            );
          },
          selector: _ehConfigService.showCommentAvatar
              ? L10n.of(context).on
              : L10n.of(context).off,
        );
      }),
      if (localeService.isLanguageCodeZh)
        TextSwitchItem(
          '评论机翻按钮',
          intValue: _ehConfigService.commentTrans.value,
          onChanged: (bool newValue) =>
              _ehConfigService.commentTrans.value = newValue,
          desc: '关闭',
          descOn: '用机器翻译将评论翻译为简体中文',
          hideDivider: true,
        ),
    ];

    return ListView.builder(
      itemCount: _list.length,
      itemBuilder: (BuildContext context, int index) {
        return _list[index];
      },
    );
  }

  /// 语言设置部件
  Widget _buildLanguageItem(BuildContext context, {bool hideLine = false}) {
    final LocaleService localeService = Get.find();
    final String _title = L10n.of(context).language;

    final Map<String, String> localeMap = <String, String>{
      '': L10n.of(context).follow_system,
    };

    localeMap.addAll(languageMenu);

    return Obx(() {
      return SelectorItem<String>(
        title: _title,
        hideDivider: hideLine,
        actionMap: localeMap,
        initVal: localeService.localCode.value,
        onValueChanged: (val) => localeService.localCode.value = val,
      );
    });
  }
}

/// 主题设置部件
Widget _buildThemeItem(BuildContext context, {bool hideLine = false}) {
  final String _title = L10n.of(context).theme;
  final ThemeService themeService = Get.find();

  final Map<ThemesModeEnum, String> themeMap = <ThemesModeEnum, String>{
    ThemesModeEnum.system: L10n.of(context).follow_system,
    ThemesModeEnum.ligthMode: L10n.of(context).light,
    ThemesModeEnum.darkMode: L10n.of(context).dark,
  };

  return Obx(() {
    return SelectorItem<ThemesModeEnum>(
      title: _title,
      hideDivider: hideLine,
      actionMap: themeMap,
      initVal: themeService.themeModel,
      onValueChanged: (val) => themeService.themeModel = val,
    );
  });
}

/// 列表模式切换
Widget _buildListModeItem(BuildContext context, {bool hideDivider = false}) {
  final String _title = L10n.of(context).list_mode;
  final EhConfigService ehConfigService = Get.find();

  final Map<ListModeEnum, String> modeMap = <ListModeEnum, String>{
    ListModeEnum.list: L10n.of(context).listmode_medium,
    ListModeEnum.simpleList: L10n.of(context).listmode_small,
    ListModeEnum.waterfall: L10n.of(context).listmode_waterfall,
    ListModeEnum.waterfallLarge: L10n.of(context).listmode_waterfall_large,
    ListModeEnum.grid: L10n.of(context).listmode_grid,
    if (kDebugMode || ehConfigService.debugMode)
      ListModeEnum.debugSimple: 'debugSimple',
  };
  return Obx(() {
    return SelectorItem<ListModeEnum>(
      title: _title,
      hideDivider: hideDivider,
      actionMap: modeMap,
      initVal: ehConfigService.listMode.value,
      onValueChanged: (val) => ehConfigService.listMode.value = val,
    );
  });
}

/// tag上限
Widget _buildTagLimitItem(BuildContext context, {bool hideDivider = false}) {
  final String _title = L10n.of(context).tag_limit;
  final EhConfigService ehConfigService = Get.find();

  Map<int, String> modeMap = {};

  for (final lim in EHConst.tagLimit) {
    modeMap.putIfAbsent(
        lim, () => lim == -1 ? L10n.of(context).no_limit : '$lim');
  }

  return Obx(() {
    return SelectorItem<int>(
      title: _title,
      hideDivider: hideDivider,
      actionMap: modeMap,
      initVal: ehConfigService.listViewTagLimit,
      onValueChanged: (val) => ehConfigService.listViewTagLimit = val,
    );
  });
}
