import 'dart:io';

import 'package:fehviewer/common/controller/cache_controller.dart';
import 'package:fehviewer/common/service/ehsetting_service.dart';
import 'package:fehviewer/common/service/layout_service.dart';
import 'package:fehviewer/common/service/locale_service.dart';
import 'package:fehviewer/const/locale.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/pages/setting/setting_items/selector_Item.dart';
import 'package:fehviewer/pages/setting/webview/mode.dart';
import 'package:fehviewer/utils/import_export.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:sliver_tools/sliver_tools.dart';

class AdvancedSettingPage extends StatelessWidget {
  const AdvancedSettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        middle: Text(L10n.of(context).advanced),
      ),
      child: const CustomScrollView(
        slivers: [
          SliverSafeArea(sliver: ListViewAdvancedSetting()),
        ],
      ),
    );
  }
}

class ListViewAdvancedSetting extends StatelessWidget {
  const ListViewAdvancedSetting({super.key});

  @override
  Widget build(BuildContext context) {
    final EhSettingService _ehSettingService = Get.find();
    final CacheController _cacheController = Get.find();

    return MultiSliver(
      children: [
        CupertinoListSection.insetGrouped(
          children: [_buildLanguageItem(context)],
        ),

        SliverCupertinoListSection.listInsetGrouped(
          children: [
            EhCupertinoListTile(
              title: Text(L10n.of(context).image_block),
              trailing: const CupertinoListTileChevron(),
              onTap: () {
                Get.toNamed(
                  EHRoutes.imageHide,
                  id: isLayoutLarge ? 2 : null,
                );
              },
            ),
            EhCupertinoListTile(
              title: Text(L10n.of(context).blockers),
              trailing: const CupertinoListTileChevron(),
              onTap: () {
                Get.toNamed(
                  EHRoutes.blockers,
                  id: isLayoutLarge ? 2 : null,
                );
              },
            ),
          ],
        ),

        SliverCupertinoListSection.listInsetGrouped(
          children: [
            // 清除缓存
            _cacheController.obx(
                (String? state) => EhCupertinoListTile(
                      title: Text(L10n.of(context).clear_cache),
                      trailing: const CupertinoListTileChevron(),
                      additionalInfo: Text(state ?? ''),
                      onTap: () {
                        logger.d(' clear_cache');
                        _cacheController.clearAllCache();
                      },
                    ),
                onLoading: EhCupertinoListTile(
                  title: Text(L10n.of(context).clear_cache),
                  trailing: const CupertinoActivityIndicator(),
                  onTap: () {
                    logger.d(' clear_cache');
                    _cacheController.clearAllCache();
                  },
                )),
          ],
        ),

        SliverCupertinoListSection.listInsetGrouped(
          children: [
            Obx(() {
              return EhCupertinoListTile(
                title: Text(L10n.of(context).proxy),
                additionalInfo: Text(
                    getProxyTypeModeMap(context)[_ehSettingService.proxyType] ??
                        ''),
                trailing: const CupertinoListTileChevron(),
                onTap: () {
                  Get.toNamed(
                    EHRoutes.proxySetting,
                    id: isLayoutLarge ? 2 : null,
                  );
                },
              );
            }),
          ],
        ),

        // webDAVMaxConnections
        SliverCupertinoListSection.listInsetGrouped(
          children: [_buildWebDAVMaxConnectionsItem(context)],
        ),

        SliverCupertinoListSection.listInsetGrouped(
          children: [
            EhCupertinoListTile(
              title: Text(L10n.of(context).vibrate_feedback),
              trailing: Obx(() {
                return CupertinoSwitch(
                  value: _ehSettingService.vibrate.value,
                  onChanged: (bool val) =>
                      _ehSettingService.vibrate.value = val,
                );
              }),
            ),
          ],
        ),

        SliverCupertinoListSection.listInsetGrouped(
          children: [
            EhCupertinoListTile(
              title: Text(L10n.of(context).export_app_data),
              subtitle: Text(L10n.of(context).export_app_data_summary),
              trailing: const CupertinoListTileChevron(),
              onTap: () async {
                // exportAppDataToFile(base64: !kDebugMode);
                exportAppDataToFile();
              },
            ),
            EhCupertinoListTile(
              title: Text(L10n.of(context).import_app_data),
              subtitle: Text(L10n.of(context).import_app_data_summary),
              trailing: const CupertinoListTileChevron(),
              onTap: () async {
                importAppDataFromFile();
              },
            ),
          ],
        ),

        SliverCupertinoListSection.listInsetGrouped(
          children: [
            if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS)
              EhCupertinoListTile(
                title: Text(L10n.of(context).native_http_client_adapter),
                trailing: Obx(() {
                  return CupertinoSwitch(
                    value: _ehSettingService.nativeHttpClientAdapter,
                    onChanged: (bool val) =>
                        _ehSettingService.nativeHttpClientAdapter = val,
                  );
                }),
              ),
            EhCupertinoListTile(
              title: Text('Log'),
              trailing: const CupertinoListTileChevron(),
              onTap: () {
                Get.toNamed(
                  EHRoutes.logfile,
                  id: isLayoutLarge ? 2 : null,
                );
              },
            ),
            EhCupertinoListTile(
              title: Text('Log debugMode'),
              trailing: Obx(() {
                return CupertinoSwitch(
                  value: _ehSettingService.debugMode,
                  onChanged: (bool val) => _ehSettingService.debugMode = val,
                );
              }),
            ),
          ],
        ),
      ],
    );
  }
}

Widget _buildWebDAVMaxConnectionsItem(BuildContext context) {
  final String _title = L10n.of(context).webdav_max_connections;
  final EhSettingService ehSettingService = Get.find();

  // map from EHConst.webDAVConnections
  final Map<int, String> actionMap = Map.fromEntries(
      EHConst.webDAVConnections.map((e) => MapEntry(e, e.toString())));

  return Obx(() {
    return SelectorCupertinoListTile<int>(
      title: _title,
      actionMap: actionMap,
      initVal: ehSettingService.webDAVMaxConnections,
      onValueChanged: (val) => ehSettingService.webDAVMaxConnections = val,
    );
  });
}

/// 语言设置部件
Widget _buildLanguageItem(BuildContext context) {
  final LocaleService localeService = Get.find();
  final String _title = L10n.of(context).language;

  final Map<String, String> localeMap = <String, String>{
    '': L10n.of(context).follow_system,
  };

  localeMap.addAll(languageMenu);

  return Obx(() {
    return SelectorCupertinoListTile<String>(
      title: _title,
      actionMap: localeMap,
      initVal: localeService.localCode.value,
      onValueChanged: (val) => localeService.localCode.value = val,
    );
  });
}
