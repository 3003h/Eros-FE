import 'dart:convert';
import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:fehviewer/common/controller/cache_controller.dart';
import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/common/service/dns_service.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/common/service/layout_service.dart';
import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/models/profile.dart';
import 'package:fehviewer/pages/setting/webview/mode.dart';
import 'package:fehviewer/route/routes.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/toast.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;

import '../../component/setting_base.dart';
import 'setting_items/selector_Item.dart';

class AdvancedSettingPage extends StatelessWidget {
  const AdvancedSettingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Widget cps = Obx(() {
      return CupertinoPageScaffold(
          backgroundColor: !ehTheme.isDarkMode
              ? CupertinoColors.secondarySystemBackground
              : null,
          navigationBar: CupertinoNavigationBar(
            // transitionBetweenRoutes: true,
            middle: Text(L10n.of(context).advanced),
          ),
          child: const SafeArea(
            bottom: false,
            child: ListViewAdvancedSetting(),
          ));
    });

    return cps;
  }
}

class ListViewAdvancedSetting extends StatelessWidget {
  const ListViewAdvancedSetting({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final EhConfigService _ehConfigService = Get.find();
    final DnsService _dnsService = Get.find();
    final CacheController _cacheController = Get.find();

    void _handleDoHChanged(bool newValue) {
      // if (!newValue && !_dnsService.enableCustomHosts) {
      //   /// 清除hosts 关闭代理
      //   logger.d(' 关闭代理');
      //   HttpOverrides.global = null;
      // } else if (newValue) {
      //   /// 设置全局本地代理
      //   HttpOverrides.global = Global.httpProxy;
      // }
      _dnsService.enableDoH = newValue;
    }

    void _handleDFChanged(bool newValue) {
      _dnsService.enableDomainFronting = newValue;
      if (!newValue) {
        HttpOverrides.global = null;
      } else {
        HttpOverrides.global = ehHttpOverrides..skipCertificateCheck = true;
        final HttpClient eClient =
            ExtendedNetworkImageProvider.httpClient as HttpClient;
        eClient.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          return true;
        };
      }
    }

    final List<Widget> _list = <Widget>[
      SelectorSettingItem(
        hideDivider: true,
        title: L10n.of(context).image_hide,
        selector: '',
        onTap: () {
          Get.toNamed(
            EHRoutes.imageHide,
            id: isLayoutLarge ? 2 : null,
          );
        },
      ),
      const ItemSpace(),
      // 清除缓存
      _cacheController.obx(
          (String? state) => SelectorSettingItem(
                title: L10n.of(context).clear_cache,
                selector: state ?? '',
                hideDivider: true,
                onTap: () {
                  logger.d(' clear_cache');
                  _cacheController.clearAllCache();
                },
              ),
          onLoading: SelectorSettingItem(
            title: L10n.of(context).clear_cache,
            selector: '',
            hideDivider: true,
            onTap: () {
              logger.d(' clear_cache');
              _cacheController.clearAllCache();
            },
          )),
      const ItemSpace(),
      Obx(() => SelectorSettingItem(
            title: L10n.of(context).proxy,
            selector:
                getProxyTypeModeMap(context)[_ehConfigService.proxyType] ?? '',
            onTap: () {
              Get.toNamed(
                EHRoutes.proxySeting,
                id: isLayoutLarge ? 2 : null,
              );
            },
          )),
      TextSwitchItem(
        L10n.of(context).domain_fronting,
        intValue: _dnsService.enableDomainFronting,
        onChanged: _handleDFChanged,
        desc: 'By pass SNI',
      ),

      Obx(() => SelectorSettingItem(
            title: L10n.of(context).custom_hosts,
            selector: _dnsService.enableCustomHosts
                ? L10n.of(context).on
                : L10n.of(context).off,
            onTap: () {
              if (!_dnsService.enableDomainFronting) {
                return;
              }
              Get.toNamed(
                EHRoutes.customHosts,
                id: isLayoutLarge ? 2 : null,
              );
            },
            titleColor: !_dnsService.enableDomainFronting
                ? CupertinoColors.secondaryLabel
                : null,
            hideDivider: true,
          )),
      // TextSwitchItem(
      //   'DNS-over-HTTPS',
      //   intValue: _dnsConfigController.enableDoH.value,
      //   onChanged: _handleDoHChanged,
      //   desc: '优先级低于自定义hosts',
      // ),
      const ItemSpace(),
      // webDAVMaxConnections
      _buildWebDAVMaxConnectionsItem(context, hideDivider: true),
      const ItemSpace(),
      TextSwitchItem(
        L10n.of(context).vibrate_feedback,
        intValue: _ehConfigService.vibrate.value,
        onChanged: (bool val) => _ehConfigService.vibrate.value = val,
        hideDivider: true,
      ),
      const ItemSpace(),
      TextItem(
        'Export App Data',
        // subTitle: 'Includes settings, quick search',
        onTap: () async {
          final Profile profile = Global.profile.copyWith(user: kDefUser);
          final String jsonStr = jsonEncode(profile.toJson());
          // final String base64Str = base64Encode(utf8.encode(jsonStr));
          final time = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
          final tempFilePath =
              path.join(Global.tempPath, 'fehviewer_profile_$time.json');
          // logger.d('base64Str $base64Str,\njsonStr $jsonStr');
          final tempFile = File(tempFilePath);
          tempFile.writeAsStringSync(jsonStr);

          try {
            await requestManageExternalStoragePermission();

            final _saveToDirPath = await FilePicker.platform.getDirectoryPath();
            logger.d('saveToDirPath $_saveToDirPath');
            if (_saveToDirPath != null) {
              final _dstPath =
                  path.join(_saveToDirPath, path.basename(tempFilePath));
              tempFile.copySync(_dstPath);
            }
          } catch (e) {
            showToast('$e');
            rethrow;
          }
        },
      ),
      TextItem(
        'Import App Data',
        subTitle: 'Need restart app',
        onTap: () async {
          final FilePickerResult? result =
              await FilePicker.platform.pickFiles();
          if (result != null) {
            final PlatformFile platFile = result.files.single;
            final file = File(platFile.path!);
            final String jsonStr = file.readAsStringSync();
            final Map<String, dynamic> jsonMap =
                jsonDecode(jsonStr) as Map<String, dynamic>;
            final Profile profile = Profile.fromJson(jsonMap);
            Global.profile = profile;
            Global.saveProfile();
            Get.reloadAll(force: true);
            showToast('Import success');
          }
        },
        hideDivider: true,
      ),
      const ItemSpace(),
      SelectorSettingItem(
        title: 'Log',
        onTap: () {
          Get.toNamed(
            EHRoutes.logfile,
            id: isLayoutLarge ? 2 : null,
          );
        },
      ),
      TextSwitchItem(
        'Log debugMode',
        intValue: _ehConfigService.debugMode,
        onChanged: (bool val) => _ehConfigService.debugMode = val,
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

Widget _buildWebDAVMaxConnectionsItem(BuildContext context,
    {bool hideDivider = false}) {
  final String _title = 'WebDAV Max Connections';
  final EhConfigService ehConfigService = Get.find();

  // map from EHConst.webDAVConnections
  final Map<int, String> actionMap = Map.fromEntries(
      EHConst.webDAVConnections.map((e) => MapEntry(e, e.toString())));

  return Obx(() {
    return SelectorItem<int>(
      title: _title,
      hideDivider: hideDivider,
      actionMap: actionMap,
      initVal: ehConfigService.webDAVMaxConnections,
      onValueChanged: (val) => ehConfigService.webDAVMaxConnections = val,
    );
  });
}
