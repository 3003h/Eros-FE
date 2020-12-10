import 'dart:io';

import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/models/dnsCache.dart';
import 'package:FEhViewer/models/states/dnsconfig_model.dart';
import 'package:FEhViewer/pages/setting/setting_base.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class CustomHostsPage extends StatelessWidget {
  final String _title = '自定义hosts';

  @override
  Widget build(BuildContext context) {
    final DnsConfigModel dnsConfigModel =
        Provider.of<DnsConfigModel>(context, listen: false);

    void _handleEnableCustomHostDarkChanged(bool value) {
      if (!value && !Global.profile.dnsConfig.enableDoH) {
        /// 关闭代理
        HttpOverrides.global = null;
      } else {
        /// 设置全局本地代理
        HttpOverrides.global = Global.httpProxy;
      }
      dnsConfigModel.enableCustomHosts = value;
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
              TextSwitchItem(
                _title,
                intValue: dnsConfigModel.enableCustomHosts,
                onChanged: _handleEnableCustomHostDarkChanged,
                // desc: '已关闭',
                // descOn: '已开启',
              ),
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
  @override
  Widget build(BuildContext context) {
    return Consumer<DnsConfigModel>(
        builder: (context, DnsConfigModel dnsConfigModel, _) {
      final hosts = dnsConfigModel.hosts;
      return Container(
        child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (_, int index) {
            final DnsCache _dnsCache = hosts[index];
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
                    dnsConfigModel.removeCustomHostAt(index);
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
          itemCount: hosts.length,
        ),
      );
    });
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
