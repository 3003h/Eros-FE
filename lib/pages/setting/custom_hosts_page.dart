import 'dart:io';

import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/common/service/dns_service.dart';
import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/models/base/eh_models.dart';
import 'package:fehviewer/pages/setting/setting_base.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class CustomHostsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final String _title = S.of(context).custom_hosts;
    final DnsService dnsConfigController = Get.find();

    void _handleEnableCustomHostDarkChanged(bool value) {
      if (!value && !(dnsConfigController.enableDoH.value)) {
        /// 关闭代理
        HttpOverrides.global = null;
      } else if (value) {
        /// 设置全局本地代理
        HttpOverrides.global = Global.httpProxy;
      }
      dnsConfigController.enableCustomHosts.value = value;
    }

    return CupertinoPageScaffold(
      backgroundColor: !ehTheme.isDarkMode
          ? CupertinoColors.secondarySystemBackground
          : null,
      navigationBar: CupertinoNavigationBar(
        padding: const EdgeInsetsDirectional.only(start: 0),
        middle: Text(_title),
        // transitionBetweenRoutes: false,
        trailing: _buildListBtns(context),
      ),
      child: SafeArea(
        bottom: false,
        child: Container(
          child: ListView(
            children: <Widget>[
              Obx(() => TextSwitchItem(
                    _title,
                    intValue: dnsConfigController.enableCustomHosts.value,
                    onChanged: _handleEnableCustomHostDarkChanged,
                  )),
              Container(height: 38),
              CustomHostsListView(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListBtns(BuildContext context) {
    return CupertinoButton(
        minSize: 40,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          FontAwesomeIcons.plusCircle,
          size: 20,
        ),
        onPressed: () {
          showCustomHostEditer(context);
        });
  }
}

class CustomHostsListView extends StatelessWidget {
  final DnsService dnsConfigController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (_, int index) {
              final DnsCache _dnsCache = dnsConfigController.hosts[index];
              return Slidable(
                actionPane: const SlidableDrawerActionPane(),
                actionExtentRatio: 0.25,
                secondaryActions: <Widget>[
                  IconSlideAction(
                    caption: S.of(context).delete,
                    color: CupertinoDynamicColor.resolve(
                        CupertinoColors.systemRed, context),
                    icon: Icons.delete,
                    onTap: () {
                      dnsConfigController.removeCustomHostAt(index);
                      // showToast('delete');
                    },
                  ),
                ],
                child: CuttomHostItem(
                  index: index,
                  host: _dnsCache.host ?? '',
                  addr: _dnsCache.addr ?? '',
                ),
              );
            },
            itemCount: dnsConfigController.hosts.length,
          ),
        ));
  }
}

class CuttomHostItem extends StatelessWidget {
  const CuttomHostItem({
    Key? key,
    required this.host,
    required this.addr,
    required this.index,
  }) : super(key: key);
  final String host;
  final String addr;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextItem(
        host,
        desc: addr,
        onTap: () {
          showCustomHostEditer(context, index: index);
        },
      ),
    );
  }
}
