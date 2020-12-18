import 'dart:io';

import 'package:fehviewer/common/controller/dnsconfig_controller.dart';
import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/models/dnsCache.dart';
import 'package:fehviewer/pages/setting/setting_base.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class CustomHostsPage extends StatelessWidget {
  final String _title = '自定义hosts';

  @override
  Widget build(BuildContext context) {
    final DnsConfigController dnsConfigController = Get.find();

    void _handleEnableCustomHostDarkChanged(bool value) {
      if (!value && !(dnsConfigController.enableDoH.value ?? false)) {
        /// 关闭代理
        HttpOverrides.global = null;
      } else if (value) {
        /// 设置全局本地代理
        HttpOverrides.global = Global.httpProxy;
      }
      dnsConfigController.enableCustomHosts.value = value;
    }

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        padding: const EdgeInsetsDirectional.only(start: 0),
        middle: Text(_title),
        transitionBetweenRoutes: false,
        trailing: _buildListBtns(context),
      ),
      child: SafeArea(
        child: Container(
          child: ListView(
            children: <Widget>[
              Obx(() => TextSwitchItem(
                    _title,
                    intValue: dnsConfigController.enableCustomHosts.value,
                    onChanged: _handleEnableCustomHostDarkChanged,
                    // desc: '已关闭',
                    // descOn: '已开启',
                  )),
              Divider(
                height: 38,
                thickness: 38.5,
                color: CupertinoDynamicColor.resolve(
                    CupertinoColors.systemGrey5, context),
              ),
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
          SettingBase().showCustomHostEditer(context);
        });
  }
}

class CustomHostsListView extends StatelessWidget {
  final DnsConfigController dnsConfigController = Get.find();
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
                    caption: '删除',
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
                  host: _dnsCache.host,
                  addr: _dnsCache.addr,
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
    Key key,
    @required this.host,
    @required this.addr,
    @required this.index,
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
          SettingBase().showCustomHostEditer(context, index: index);
        },
      ),
    );
  }
}
