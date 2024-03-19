import 'package:eros_fe/common/controller/tag_trans_controller.dart';
import 'package:eros_fe/common/controller/user_controller.dart';
import 'package:eros_fe/common/service/ehsetting_service.dart';
import 'package:eros_fe/common/service/layout_service.dart';
import 'package:eros_fe/common/service/locale_service.dart';
import 'package:eros_fe/component/setting_base.dart';
import 'package:eros_fe/index.dart';
import 'package:eros_fe/network/api.dart';
import 'package:eros_fe/network/request.dart';
import 'package:eros_fe/pages/login/controller/login_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:open_by_default/open_by_default.dart';
import 'package:sliver_tools/sliver_tools.dart';

class EhSettingPage extends StatelessWidget {
  const EhSettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        middle: Text(L10n.of(context).eh),
      ),
      child: CustomScrollView(slivers: [
        SliverSafeArea(sliver: ListViewEhSetting()),
      ]),
    );
  }
}

class ListViewEhSetting extends StatelessWidget {
  ListViewEhSetting({super.key});

  final EhSettingService _ehSettingService = Get.find();
  final UserController userController = Get.find();
  final TagTransController transController = Get.find();
  final LocaleService localeService = Get.find();
  final LoginController loginController = Get.put(LoginController());

  Future<void> _handleSiteChanged(bool newValue) async {
    _ehSettingService.isSiteEx(newValue);
    Global.forceRefreshUconfig = true;
    if (newValue) {
      getExIgneous();
    }
    Api.selEhProfile();
    loginController.asyncGetUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    final bool _isLogin = userController.isLogin;
    Future<EhHome?> _futureImageLimits = getEhHome(refresh: true);

    return MultiSliver(children: [
      SliverCupertinoListSection.listInsetGrouped(children: [
        if (_isLogin)
          EhCupertinoListTile(
            title: Text(L10n.of(context).galery_site),
            trailing: Obx(() {
              return CupertinoSlidingSegmentedControl<String>(
                groupValue: _ehSettingService.isSiteEx.value
                    ? EHConst.EX_BASE_HOST
                    : EHConst.EH_BASE_HOST,
                children: const {
                  EHConst.EH_BASE_HOST: Text('E-Hentai', textScaleFactor: 0.8),
                  EHConst.EX_BASE_HOST: Text('ExHentai', textScaleFactor: 0.8)
                },
                onValueChanged: (String? val) {
                  if (val != null) {
                    _handleSiteChanged(val == EHConst.EX_BASE_HOST);
                  }
                },
              );
            }),
          ),
        EhCupertinoListTile(
          title: Text(L10n.of(context).link_redirect),
          subtitle: Text(L10n.of(context).link_redirect_summary),
          trailing: Obx(() {
            return CupertinoSwitch(
              value: _ehSettingService.linkRedirect,
              onChanged: (bool val) {
                _ehSettingService.linkRedirect = val;
              },
            );
          }),
        ),
        EhCupertinoListTile(
          title: Text(L10n.of(context).redirect_thumb_link),
          subtitle: Text(L10n.of(context).redirect_thumb_link_summary),
          trailing: Obx(() {
            return CupertinoSwitch(
              value: _ehSettingService.redirectThumbLink,
              onChanged: (bool val) {
                _ehSettingService.redirectThumbLink = val;
              },
            );
          }),
        ),
        if (_isLogin)
          const EhCupertinoListTile(
            title: Text('Cookie'),
            trailing: CupertinoListTileChevron(),
            onTap: showUserCookie,
          ),
        EhCupertinoListTile(
          title: Text(L10n.of(context).auto_select_profile),
          trailing: Obx(() {
            return CupertinoSwitch(
              value: _ehSettingService.autoSelectProfile,
              onChanged: (bool val) =>
                  _ehSettingService.autoSelectProfile = val,
            );
          }),
        ),
        if (_isLogin)
          EhCupertinoListTile(
            title: Text(L10n.of(context).ehentai_settings),
            subtitle: Text(L10n.of(context).setting_on_website),
            trailing: const CupertinoListTileChevron(),
            onTap: () {
              Get.toNamed(
                EHRoutes.mySettings,
                id: isLayoutLarge ? 2 : null,
              );
            },
          ),
        if (_isLogin)
          EhCupertinoListTile(
            title: Text(L10n.of(context).ehentai_my_tags),
            subtitle: Text(L10n.of(context).mytags_on_website),
            trailing: const CupertinoListTileChevron(),
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
                  return EhCupertinoListTile(
                    title: Text(L10n.of(context).image_limits),
                    additionalInfo: Text(ehHome == null
                        ? ''
                        : '${ehHome.currentLimit ?? ''} / ${ehHome.totLimit ?? ''}'),
                    subtitle: Text(
                        '${L10n.of(context).reset_cost}: ${ehHome?.resetCost ?? 0} GP'),
                    trailing: snapshot.connectionState != ConnectionState.done
                        ? CupertinoActivityIndicator(
                            radius: (CupertinoTheme.of(context)
                                        .textTheme
                                        .textStyle
                                        .fontSize ??
                                    14) /
                                2,
                          )
                        : const CupertinoListTileChevron(),
                    onTap: () {
                      setState(() {
                        _futureImageLimits = getEhHome(refresh: true);
                      });
                    },
                  );
                });
          }),
      ]),

      // 云服务
      SliverCupertinoListSection.listInsetGrouped(children: [
        EhCupertinoListTile(
          title: Text('WebDAV'),
          trailing: const CupertinoListTileChevron(),
          onTap: () {
            Get.toNamed(
              EHRoutes.webDavSetting,
              id: isLayoutLarge ? 2 : null,
            );
          },
        ),
        EhCupertinoListTile(
          title: Text('MySQL Sync'),
          trailing: const CupertinoListTileChevron(),
          onTap: () {
            Get.toNamed(
              EHRoutes.mysqlSync,
              id: isLayoutLarge ? 2 : null,
            );
          },
        ),
      ]),

      // 默认打开
      FutureBuilder<bool>(future: () async {
        return GetPlatform.isAndroid &&
            (await deviceInfo.androidInfo).version.sdkInt >= 31;
      }(), builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            (snapshot.data ?? false)) {
          return SliverCupertinoListSection.listInsetGrouped(
            children: [
              EhCupertinoListTile(
                title: Text(L10n.of(context).open_supported_links),
                trailing: const CupertinoListTileChevron(),
                // subtitle: Text(L10n.of(context).open_supported_links_summary),
                onTap: () {
                  OpenByDefault.open();
                },
              ),
            ],
            footer: Text(L10n.of(context).open_supported_links_summary),
          );
        } else {
          return const SizedBox.shrink();
        }
      }),

      SliverCupertinoListSection.listInsetGrouped(children: [
        EhCupertinoListTile(
          title: Text(L10n.of(context).default_favorites),
          subtitle: Text(L10n.of(context).manually_sel_favorites),
          trailing: Obx(() {
            return CupertinoSwitch(
              value: _ehSettingService.isFavLongTap.value,
              onChanged: (bool val) =>
                  _ehSettingService.isFavLongTap.value = val,
            );
          }),
        ),
        EhCupertinoListTile(
          title: Text(L10n.of(context).clipboard_detection),
          subtitle: Text(L10n.of(context).clipboard_detection_desc),
          trailing: Obx(() {
            return CupertinoSwitch(
              value: _ehSettingService.isClipboardLink.value,
              onChanged: (bool val) =>
                  _ehSettingService.isClipboardLink.value = val,
            );
          }),
        ),
      ]),
    ]);
  }
}
