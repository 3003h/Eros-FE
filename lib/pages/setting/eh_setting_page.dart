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

    void _handleFavLongTapChanged(bool newValue) {
      _ehConfigService.isFavLongTap.value = newValue;
    }

    void _handleClipboarLinkTapChange(bool val) {
      _ehConfigService.isClipboardLink.value = val;
    }

    Future<EhHome?> _futureImageLimits = getEhHome(refresh: true);

    final List<Widget> _list = <Widget>[
      // if (_isLogin)
      //   Obx(() {
      //     return GestureDetector(
      //       onLongPress: Api.selEhProfile,
      //       child: TextSwitchItem(
      //         L10n.of(context).galery_site,
      //         intValue: _ehConfigService.isSiteEx.value,
      //         onChanged: _handleSiteChanged,
      //         desc: L10n.of(context).current_site('E-Hentai'),
      //         descOn: L10n.of(context).current_site('ExHentai'),
      //       ),
      //     );
      //   }),
      if (_isLogin)
        Obx(() {
          return SlidingSegmentedItem<String>(
            L10n.of(context).galery_site,
            intValue: _ehConfigService.isSiteEx.value
                ? EHConst.EX_BASE_HOST
                : EHConst.EH_BASE_HOST,
            onValueChanged: (val) {
              logger.d('val  $val');
              _handleSiteChanged(EHConst.EX_BASE_HOST == val);
            },
            slidingChildren: const {
              EHConst.EH_BASE_HOST: Text('E-Hentai', textScaleFactor: 0.8),
              EHConst.EX_BASE_HOST: Text('ExHentai', textScaleFactor: 0.8)
            },
          );
        }),
      TextSwitchItem(
        L10n.of(context).link_redirect,
        intValue: _ehConfigService.linkRedirect,
        onChanged: (val) => _ehConfigService.linkRedirect = val,
        desc: L10n.of(context).link_redirect_summary,
      ),
      TextSwitchItem(
        L10n.of(context).redirect_thumb_link,
        intValue: _ehConfigService.redirectThumbLink,
        onChanged: (val) => _ehConfigService.redirectThumbLink = val,
        desc: L10n.of(context).redirect_thumb_link_summary,
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
          title: L10n.of(context).ehentai_my_tags,
          selector: L10n.of(context).mytags_on_website,
          onTap: () {
            Get.toNamed(
              EHRoutes.myTags,
              id: isLayoutLarge ? 2 : null,
            );
          },
        ),
      if (_isLogin)
        StatefulBuilder(builder: (context, setState) {
          return FutureBuilder<EhHome?>(
              future: _futureImageLimits,
              initialData: hiveHelper.getEhHome(),
              builder: (context, snapshot) {
                EhHome? ehHome = snapshot.data;
                if (snapshot.connectionState == ConnectionState.done) {
                  if (ehHome != null) {
                    hiveHelper.setEhHome(ehHome);
                  }
                }
                return SelectorSettingItem(
                  hideDivider: true,
                  title: L10n.of(context).image_limits,
                  selector: ehHome == null
                      ? ''
                      : '${ehHome.currentLimit ?? ''} / ${ehHome.totLimit ?? ''}',
                  desc:
                      '${L10n.of(context).reset_cost}: ${ehHome?.resetCost ?? 0} GP',
                  suffix: snapshot.connectionState != ConnectionState.done
                      ? const CupertinoActivityIndicator()
                      : const SizedBox(),
                  onTap: () {
                    setState(() {
                      _futureImageLimits = getEhHome(refresh: true);
                    });
                  },
                );
              });
        }),
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
      TextSwitchItem(
        L10n.of(context).default_favorites,
        intValue: _favLongTap,
        onChanged: _handleFavLongTapChanged,
        desc: L10n.of(context).manually_sel_favorites,
        descOn: L10n.of(context).last_favorites,
      ),

      TextSwitchItem(
        L10n.of(context).clipboard_detection,
        intValue: _isClipboar,
        onChanged: _handleClipboarLinkTapChange,
        desc: L10n.of(context).clipboard_detection_desc,
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
