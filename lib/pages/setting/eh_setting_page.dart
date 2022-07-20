import 'package:fehviewer/common/controller/tag_trans_controller.dart';
import 'package:fehviewer/common/controller/user_controller.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/common/service/layout_service.dart';
import 'package:fehviewer/common/service/locale_service.dart';
import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/network/api.dart';
import 'package:fehviewer/network/request.dart';
import 'package:fehviewer/pages/login/controller/login_controller.dart';
import 'package:fehviewer/pages/setting/setting_items/selector_Item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:open_by_default/open_by_default.dart';

import '../../component/setting_base.dart';

class EhSettingPage extends StatelessWidget {
  const EhSettingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Widget cps = Obx(() {
      return CupertinoPageScaffold(
          backgroundColor: !ehTheme.isDarkMode
              ? CupertinoColors.secondarySystemBackground
              : null,
          navigationBar: CupertinoNavigationBar(
            middle: Text(L10n.of(context).eh),
          ),
          child: SafeArea(
            child: ListViewEhSetting(),
            bottom: false,
          ));
    });

    return cps;
  }
}

class ListViewEhSetting extends StatelessWidget {
  ListViewEhSetting({Key? key}) : super(key: key);

  final EhConfigService _ehConfigService = Get.find();
  final UserController userController = Get.find();
  final TagTransController transController = Get.find();
  final LocaleService localeService = Get.find();
  final LoginController loginController = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    final bool _siteEx = _ehConfigService.isSiteEx.value;
    final bool _jpnTitle = _ehConfigService.isJpnTitle.value;
    final bool _tagTranslat = _ehConfigService.isTagTranslat;
    final bool _galleryImgBlur = _ehConfigService.isGalleryImgBlur.value;
    final bool _favLongTap = _ehConfigService.isFavLongTap.value;
    final bool _isLogin = userController.isLogin;
    final bool _isClipboar = _ehConfigService.isClipboardLink.value;

    final bool _autoSelectProfile = _ehConfigService.autoSelectProfile;

    Future<void> _handleSiteChanged(bool newValue) async {
      _ehConfigService.isSiteEx(newValue);
      Global.forceRefreshUconfig = true;
      if (newValue) {
        getExIgneous();
      }
      Api.selEhProfile();
      loginController.asyncGetUserInfo();
    }

    void _handleJpnTitleChanged(bool newValue) {
      _ehConfigService.isJpnTitle(newValue);
    }

    // Future<void> _handleTagTranslatChanged(bool newValue) async {
    //   _ehConfigService.isTagTranslat = newValue;
    //   if (newValue) {
    //     try {
    //       if (await transController.checkUpdate()) {
    //         showToast('更新开始');
    //         await transController.updateDB();
    //         showToast('更新完成');
    //       } else {
    //         logger.v('do not need update');
    //       }
    //     } catch (e) {
    //       logger.e('更新翻译异常 $e');
    //       rethrow;
    //     }
    //   }
    // }

    void _handleTagTranslatCDNChanged(bool newValue) {
      _ehConfigService.enableTagTranslateCDN = newValue;
    }

    void _handleGalleryListImgBlurChanged(bool newValue) {
      _ehConfigService.isGalleryImgBlur.value = newValue;
    }

    void _handleFavLongTapChanged(bool newValue) {
      _ehConfigService.isFavLongTap.value = newValue;
    }

    void _handleClipboarLinkTapChange(bool val) {
      _ehConfigService.isClipboardLink.value = val;
    }

    // Future<void> _forceUpdateTranslate() async {
    //   if (await transController.checkUpdate(force: true)) {
    //     showToast('手动更新开始');
    //     await transController.updateDB();
    //     showToast('更新完成');
    //   }
    // }

    final List<Widget> _list = <Widget>[
      if (_isLogin)
        GestureDetector(
          onLongPress: Api.selEhProfile,
          child: TextSwitchItem(
            L10n.of(context).galery_site,
            intValue: _siteEx,
            onChanged: _handleSiteChanged,
            desc: L10n.of(context).current_site('E-Hentai'),
            descOn: L10n.of(context).current_site('ExHentai'),
          ),
        ),
      TextSwitchItem(
        L10n.of(context).link_redirect,
        intValue: _ehConfigService.linkRedirect,
        onChanged: (val) => _ehConfigService.linkRedirect = val,
        desc: L10n.of(context).link_redirect_summary,
      ),
      if (_isLogin)
        const SelectorSettingItem(
          title: 'Cookie',
          selector: '',
          onTap: showUserCookie,
        ),
      TextSwitchItem(
        L10n.of(context).auto_select_profile,
        intValue: _autoSelectProfile,
        hideDivider: !_isLogin,
        onChanged: (val) => _ehConfigService.autoSelectProfile = val,
      ),
      if (_isLogin)
        SelectorSettingItem(
          title: L10n.of(context).ehentai_settings,
          selector: L10n.of(context).setting_on_website,
          onTap: () {
            Get.toNamed(
              EHRoutes.mySettings,
              id: isLayoutLarge ? 2 : null,
            );
          },
          onLongPress: () async {
            await Api.selEhProfile();
            showToast('set EhProfile succs');
          },
        ),
      if (_isLogin)
        SelectorSettingItem(
          hideDivider: true,
          title: L10n.of(context).ehentai_my_tags,
          selector: L10n.of(context).mytags_on_website,
          onTap: () {
            // if (GetPlatform.isAndroid || GetPlatform.isIOS) {
            //   Get.to(() => InWebMyTags());
            // } else {
            //   showToast('Not support');
            // }
            Get.toNamed(
              EHRoutes.myTags,
              id: isLayoutLarge ? 2 : null,
            );
          },
        ),
      const ItemSpace(),
      SelectorSettingItem(
        title: 'WebDAV',
        onTap: () {
          Get.toNamed(
            EHRoutes.webDavSetting,
            id: isLayoutLarge ? 2 : null,
          );
        },
        hideDivider: true,
      ),
      if (GetPlatform.isAndroid)
        FutureBuilder<bool>(future: () async {
          final _androidInfo = await deviceInfo.androidInfo;
          return _androidInfo.version.sdkInt >= 31;
        }(), builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              (snapshot.data ?? false)) {
            return Column(
              children: [
                const ItemSpace(),
                SelectorSettingItem(
                  title: L10n.of(context).open_supported_links,
                  desc: L10n.of(context).open_supported_links_summary,
                  onTap: OpenByDefault.open,
                  hideDivider: true,
                ),
              ],
            );
          } else {
            return const SizedBox.shrink();
          }
        }),
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
      Obx(() {
        return _buildListModeItem(
          context,
          hideLine: _ehConfigService.listMode.value != ListModeEnum.list,
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
      TextSwitchItem(
        L10n.of(context).default_favorites,
        intValue: _favLongTap,
        onChanged: _handleFavLongTapChanged,
        desc: L10n.of(context).manually_sel_favorites,
        descOn: L10n.of(context).last_favorites,
      ),
      Obx(() {
        return SelectorSettingItem(
          title: L10n.of(context).avatar,
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
      TextSwitchItem(
        L10n.of(context).clipboard_detection,
        intValue: _isClipboar,
        onChanged: _handleClipboarLinkTapChange,
        desc: L10n.of(context).clipboard_detection_desc,
        hideDivider: !localeService.isLanguageCodeZh,
      ),
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
}

/// 列表模式切换
Widget _buildListModeItem(BuildContext context, {bool hideLine = false}) {
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
      hideDivider: hideLine,
      actionMap: modeMap,
      initVal: ehConfigService.listMode.value,
      onValueChanged: (val) => ehConfigService.listMode.value = val,
    );
  });
}
