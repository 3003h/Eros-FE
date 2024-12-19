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
    final bool isLogin = userController.isLogin;
    Future<EhHome?> futureImageLimits = getEhHome(refresh: true);

    return MultiSliver(children: [
      SliverCupertinoListSection.listInsetGrouped(children: [
        if (isLogin)
          EhCupertinoListTile(
            title: Text(L10n.of(context).galery_site),
            trailing: Obx(() {
              return CupertinoSlidingSegmentedControl<String>(
                groupValue: _ehSettingService.isSiteEx.value
                    ? EHConst.EX_BASE_HOST
                    : EHConst.EH_BASE_HOST,
                children: const {
                  EHConst.EH_BASE_HOST: Text(
                    'E-Hentai',
                    textScaler: TextScaler.linear(0.9),
                  ),
                  EHConst.EX_BASE_HOST: Text(
                    'ExHentai',
                    textScaler: TextScaler.linear(0.9),
                  ),
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
        if (isLogin)
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
        if (isLogin)
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
        if (isLogin)
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
        if (isLogin)
          StatefulBuilder(builder: (context, setState) {
            return FutureBuilder<EhHome?>(
                future: futureImageLimits,
                initialData: hiveHelper.getEhHome(),
                builder: (context, snapshot) {
                  EhHome? ehHome = snapshot.data;
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (ehHome != null) {
                      hiveHelper.setEhHome(ehHome);
                    }
                  }
                  final currentLimit = ehHome?.currentLimit ?? 0;
                  final totLimit = ehHome?.totLimit ?? 0;
                  String additionalInfoText = '';
                  if (totLimit > 0) {
                    additionalInfoText =
                        '$currentLimit / $totLimit'.numberFormat;
                  }
                  String subtitleText = '';
                  // if (ehHome?.highResolutionLimited ?? false) {
                  //   subtitleText =
                  //       L10n.of(context).high_resolution_images_limited;
                  // }
                  if (ehHome?.resetCost != null) {
                    if (subtitleText.isNotEmpty) {
                      subtitleText += '\n';
                    }
                    subtitleText +=
                        '${L10n.of(context).reset_cost}: ${ehHome?.resetCost ?? 0} GP'
                            .numberFormat;
                  }

                  return EhCupertinoListTile(
                    title: Text(L10n.of(context).image_limits),
                    additionalInfo: Text(additionalInfoText),
                    subtitle: subtitleText.isNotEmpty
                        ? Text(
                            subtitleText,
                            maxLines: 5,
                          )
                        : null,
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
                        futureImageLimits = getEhHome(refresh: true);
                      });
                    },
                  );
                });
          }),
      ]),

      // 云服务
      SliverCupertinoListSection.listInsetGrouped(children: [
        EhCupertinoListTile(
          title: const Text('WebDAV'),
          trailing: const CupertinoListTileChevron(),
          onTap: () {
            Get.toNamed(
              EHRoutes.webDavSetting,
              id: isLayoutLarge ? 2 : null,
            );
          },
        ),
        EhCupertinoListTile(
          title: const Text('MySQL Sync'),
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
            footer: Text(L10n.of(context).open_supported_links_summary),
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
          );
        } else {
          return const SizedBox.shrink();
        }
      }),

      SliverCupertinoListSection.listInsetGrouped(children: [
        EhCupertinoListTile(
          title: Text(L10n.of(context).one_step_favorite),
          subtitle: Text(
            L10n.of(context).one_step_favorite_desc,
            maxLines: 4,
          ),
          trailing: Obx(() {
            return Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: CupertinoSwitch(
                value: _ehSettingService.isFavLongTap.value,
                onChanged: (bool val) =>
                    _ehSettingService.isFavLongTap.value = val,
              ),
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
