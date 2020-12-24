import 'dart:io';

import 'package:fehviewer/common/controller/cache_controller.dart';
import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/common/service/dns_service.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/common/service/locale_service.dart';
import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/pages/setting/custom_hosts_page.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/const/theme_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'setting_base.dart';

class AdvancedSettingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final CupertinoPageScaffold cps = CupertinoPageScaffold(
        backgroundColor: !ehTheme.isDarkMode
            ? CupertinoColors.secondarySystemBackground
            : null,
        navigationBar: CupertinoNavigationBar(
          // transitionBetweenRoutes: true,
          middle: Text(S.of(context).advanced),
        ),
        child: SafeArea(
          child: ListViewAdvancedSetting(),
        ));

    return cps;
  }
}

class ListViewAdvancedSetting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final EhConfigService ehConfigService = Get.find();
    final DnsService dnsConfigController = Get.find();
    void _handlePureDarkChanged(bool newValue) {
      ehConfigService.isPureDarkTheme.value = newValue;
    }

    void _handleDoHChanged(bool newValue) {
      if (!newValue &&
          !(dnsConfigController.enableCustomHosts.value ?? false)) {
        /// 清除hosts 关闭代理
        logger.d(' 关闭代理');
        HttpOverrides.global = null;
      } else if (newValue) {
        /// 设置全局本地代理
        HttpOverrides.global = Global.httpProxy;
      }
      dnsConfigController.enableDoH.value = newValue;
    }

    void _handleEFChanged(bool newValue) {
      dnsConfigController.enableDomainFronting.value = newValue;
    }

    final List<Widget> _list = <Widget>[
      _buildLanguageItem(context),
      Container(height: 38),
      _buildThemeItem(context),
      Obx(() => TextSwitchItem(
            S.of(context).dark_mode_effect,
            intValue: ehConfigService.isPureDarkTheme.value,
            onChanged: _handlePureDarkChanged,
            desc: S.of(context).gray_black,
            descOn: S.of(context).pure_black,
            hideLine: true,
          )),
      Container(height: 38),
      SelectorSettingItem(
        title: S.of(context).clear_cache,
        selector: '',
        hideLine: true,
        onTap: () {
          logger.d(' clear_cache');
          Get.find<CacheController>().clearAllCache();
        },
      ),
      Container(height: 38),
      Obx(() => SelectorSettingItem(
            title: S.of(context).custom_hosts,
            selector: dnsConfigController.enableCustomHosts.value
                ? S.of(context).on
                : S.of(context).off,
            onTap: () {
              Get.to(CustomHostsPage(), transition: Transition.cupertino);
            },
          )),
      if (Global.inDebugMode)
        TextSwitchItem(
          S.of(context).domain_fronting,
          intValue: dnsConfigController.enableDomainFronting.value,
          onChanged: _handleEFChanged,
          desc: 'pass SNI',
        ),
      TextSwitchItem(
        'DNS-over-HTTPS',
        intValue: dnsConfigController.enableDoH.value,
        onChanged: _handleDoHChanged,
        hideLine: true,
        desc: '优先级低于自定义hosts',
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
  Widget _buildLanguageItem(BuildContext context) {
    final LocaleService localeService = Get.find();
    final String _title = S.of(context).language;

    final Map<String, String> localeMap = <String, String>{
      '': S.of(context).follow_system,
      'zh_CN': '简体中文',
      'en_US': 'English',
    };

    List<Widget> _getLocaleList(BuildContext context) {
      return List<Widget>.from(localeMap.keys.map((String element) {
        return CupertinoActionSheetAction(
            onPressed: () {
              Get.back(result: element);
            },
            child: Text(localeMap[element]));
      }).toList());
    }

    Future<String> _showDialog(BuildContext context) {
      return showCupertinoModalPopup<String>(
          context: context,
          builder: (BuildContext context) {
            final CupertinoActionSheet dialog = CupertinoActionSheet(
              cancelButton: CupertinoActionSheetAction(
                  onPressed: () {
                    Get.back();
                  },
                  child: Text(S.of(context).cancel)),
              actions: <Widget>[
                ..._getLocaleList(context),
              ],
            );
            return dialog;
          });
    }

    return Obx(() => SelectorSettingItem(
          title: _title,
          selector: localeMap[localeService.localCode.value ?? ''],
          hideLine: true,
          onTap: () async {
            logger.v('tap LanguageItem');
            final String _result = await _showDialog(context);
            if (_result is String) {
              localeService.localCode.value = _result;
            }
            // logger.v('$_result');
          },
        ));
  }

  /// 主题设置部件
  Widget _buildThemeItem(BuildContext context) {
    final String _title = S.of(context).theme;
    final ThemeService themeService = Get.find();

    final Map<ThemesModeEnum, String> themeMap = <ThemesModeEnum, String>{
      ThemesModeEnum.system: S.of(context).follow_system,
      ThemesModeEnum.ligthMode: S.of(context).light,
      ThemesModeEnum.darkMode: S.of(context).dark,
    };

    List<Widget> _getThemeList(BuildContext context) {
      return List<Widget>.from(themeMap.keys.map((ThemesModeEnum themesMode) {
        return CupertinoActionSheetAction(
            onPressed: () {
              Get.back(result: themesMode);
            },
            child: Text(themeMap[themesMode]));
      }).toList());
    }

    Future<ThemesModeEnum> _showDialog(BuildContext context) {
      return showCupertinoModalPopup<ThemesModeEnum>(
          context: context,
          builder: (BuildContext context) {
            final CupertinoActionSheet dialog = CupertinoActionSheet(
              cancelButton: CupertinoActionSheetAction(
                  onPressed: () {
                    Get.back();
                  },
                  child: Text(S.of(context).cancel)),
              actions: <Widget>[
                ..._getThemeList(context),
              ],
            );
            return dialog;
          });
    }

    return SelectorSettingItem(
      title: _title,
      selector: themeMap[themeService.themeModel],
      onTap: () async {
        logger.v('tap ThemeItem');
        final ThemesModeEnum _result = await _showDialog(context);
        if (_result is ThemesModeEnum) {
          themeService.themeModel = _result;
        }
      },
    );
  }

  /// 清除缓存

}
