import 'package:eros_fe/common/service/ehsetting_service.dart';
import 'package:eros_fe/component/setting_base.dart';
import 'package:eros_fe/index.dart';
import 'package:eros_fe/pages/setting/webview/mode.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:sliver_tools/sliver_tools.dart';

import 'setting_items/selector_Item.dart';

class ProxyPage extends StatelessWidget {
  const ProxyPage({Key? key}) : super(key: key);
  EhSettingService get ehSettingService => Get.find();

  @override
  Widget build(BuildContext context) {
    final String _title = L10n.of(context).proxy;

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        padding: const EdgeInsetsDirectional.only(start: 0),
        middle: Text(_title),
      ),
      child: CustomScrollView(
        slivers: [
          SliverSafeArea(
            sliver: MultiSliver(
              children: <Widget>[
                SliverCupertinoListSection.listInsetGrouped(
                  children: [
                    _buildProxyTypeItem(context),
                  ],
                ),
                SliverCupertinoListSection.listInsetGrouped(
                  children: [
                    CupertinoTextInputListTile(
                      title: L10n.of(context).host,
                      textAlign: TextAlign.right,
                      initValue: ehSettingService.proxyHost,
                      onChanged: (val) => ehSettingService.proxyHost = val,
                    ),
                    CupertinoTextInputListTile(
                      title: L10n.of(context).port,
                      textAlign: TextAlign.right,
                      initValue: ehSettingService.proxyPort.toString(),
                      onChanged: (val) =>
                          ehSettingService.proxyPort = int.parse(val),
                      keyboardType: TextInputType.number,
                    ),
                    CupertinoTextInputListTile(
                      title: L10n.of(context).user_name,
                      textAlign: TextAlign.right,
                      initValue: ehSettingService.proxyUsername,
                      onChanged: (val) => ehSettingService.proxyUsername = val,
                    ),
                    CupertinoTextInputListTile(
                      title: L10n.of(context).passwd,
                      textAlign: TextAlign.right,
                      initValue: ehSettingService.proxyPassword,
                      onChanged: (val) => ehSettingService.proxyPassword = val,
                      obscureText: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildProxyTypeItem(BuildContext context) {
  final String _title = L10n.of(context).proxy_type;
  final EhSettingService ehSettingService = Get.find();

  return Obx(() {
    return SelectorCupertinoListTile<ProxyType>(
      title: _title,
      actionMap: getProxyTypeModeMap(context),
      initVal: ehSettingService.proxyType,
      onValueChanged: (val) => ehSettingService.proxyType = val,
    );
  });
}
