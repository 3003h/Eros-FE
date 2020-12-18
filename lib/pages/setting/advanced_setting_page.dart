import 'dart:io';

import 'package:fehviewer/common/controller/dnsconfig_controller.dart';
import 'package:fehviewer/common/controller/ehconfig_controller.dart';
import 'package:fehviewer/common/controller/local_controller.dart';
import 'package:fehviewer/common/controller/theme_controller.dart';
import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/pages/setting/custom_hosts_page.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/values/theme_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'setting_base.dart';

class AdvancedSettingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AdvancedSettingPageState();
  }
}

class AdvancedSettingPageState extends State<AdvancedSettingPage> {
  final String _title = '高级设置';

  @override
  Widget build(BuildContext context) {
    final CupertinoPageScaffold cps = CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          transitionBetweenRoutes: true,
          middle: Text(_title),
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
    final EhConfigController ehConfigController = Get.find();
    final DnsConfigController dnsConfigController = Get.find();
    void _handlePureDarkChanged(bool newValue) {
      ehConfigController.isPureDarkTheme.value = newValue;
    }

    void _handleDoHChanged(bool newValue) {
      if (!newValue && !(dnsConfigController.enableCustomHosts ?? false)) {
        /// 清除hosts 关闭代理
        logger.d(' 关闭代理');
        HttpOverrides.global = null;
      } else if (newValue) {
        /// 设置全局本地代理
        HttpOverrides.global = Global.httpProxy;
      }
      dnsConfigController.enableDoH.value = newValue;
    }

    return Container(
      child: ListView(
        children: <Widget>[
          _buildLanguageItem(context),
          Divider(
            height: 38,
            thickness: 38.5,
            color: CupertinoDynamicColor.resolve(
                CupertinoColors.systemGrey5, context),
          ),
          _buildThemeItem(context),
          Obx(() => TextSwitchItem(
                '深色模式效果',
                intValue: ehConfigController.isPureDarkTheme.value,
                onChanged: _handlePureDarkChanged,
                desc: '灰黑背景',
                descOn: '纯黑背景',
              )),
          Divider(
            height: 38,
            thickness: 38.5,
            color: CupertinoDynamicColor.resolve(
                CupertinoColors.systemGrey5, context),
          ),
          Obx(() => SelectorSettingItem(
                title: '自定义hosts (实验性功能)',
                selector:
                    dnsConfigController.enableCustomHosts.value ? '已开启' : '已关闭',
                onTap: () {
                  Get.to(CustomHostsPage());
                },
              )),
          TextSwitchItem(
            'DNS-over-HTTPS',
            intValue: dnsConfigController.enableDoH.value,
            onChanged: _handleDoHChanged,
            desc: '优先级低于自定义hosts',
          ),
        ],
      ),
    );
  }

  /// 语言设置部件
  Widget _buildLanguageItem(BuildContext context) {
    final LocaleController localeController = Get.find();
    const String _title = '语言设置';

    final Map<String, String> localeMap = <String, String>{
      '': '系统语言(默认)',
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
              title: const Text('语言选择'),
              cancelButton: CupertinoActionSheetAction(
                  onPressed: () {
                    Get.back();
                  },
                  child: const Text('取消')),
              actions: <Widget>[
                ..._getLocaleList(context),
              ],
            );
            return dialog;
          });
    }

    return Obx(() => SelectorSettingItem(
          title: _title,
          selector: localeMap[localeController.localCode.value ?? ''],
          onTap: () async {
            logger.v('tap LanguageItem');
            final String _result = await _showDialog(context);
            if (_result is String) {
              localeController.localCode.value = _result;
            }
            logger.v('$_result');
          },
        ));
  }

  /// 主题设置部件
  Widget _buildThemeItem(BuildContext context) {
    const String _title = '主题设置';
    final ThemeController themeController = Get.find();

    final Map<ThemesModeEnum, String> themeMap = <ThemesModeEnum, String>{
      ThemesModeEnum.system: '跟随系统(默认)',
      ThemesModeEnum.ligthMode: '浅色模式',
      ThemesModeEnum.darkMode: '深色模式',
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
              title: const Text('主题选择'),
              cancelButton: CupertinoActionSheetAction(
                  onPressed: () {
                    Get.back();
                  },
                  child: const Text('取消')),
              actions: <Widget>[
                ..._getThemeList(context),
              ],
            );
            return dialog;
          });
    }

    return SelectorSettingItem(
      title: _title,
      selector: themeMap[themeController.themeModel],
      onTap: () async {
        logger.v('tap ThemeItem');
        final ThemesModeEnum _result = await _showDialog(context);
        if (_result is ThemesModeEnum) {
          themeController.themeModel = _result;
        }
      },
    );
  }
}
