import 'package:eros_fe/common/service/dns_service.dart';
import 'package:eros_fe/common/service/theme_service.dart';
import 'package:eros_fe/component/setting_base.dart';
import 'package:eros_fe/generated/l10n.dart';
import 'package:eros_fe/models/base/eh_models.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class CustomHostsPage extends StatelessWidget {
  const CustomHostsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String _title = L10n.of(context).custom_hosts;
    final DnsService dnsConfigController = Get.find();

    void _handleEnableCustomHostDarkChanged(bool value) {
      dnsConfigController.enableCustomHosts = value;
    }

    return Obx(() {
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
        child: Container(
          child: ListView(
            children: <Widget>[
              Obx(() => TextSwitchItem(
                    _title,
                    value: dnsConfigController.enableCustomHosts,
                    onChanged: _handleEnableCustomHostDarkChanged,
                  )),
              const ItemSpace(),
              CustomHostsListView(),
            ],
          ),
        ),
      );
    });
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
    return Obx(() => ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (_, int index) {
            final DnsCache _dnsCache = dnsConfigController.hosts[index];
            return Slidable(
              endActionPane: ActionPane(
                motion: const ScrollMotion(),
                extentRatio: 0.25,
                children: [
                  SlidableAction(
                    onPressed: (_) =>
                        dnsConfigController.removeCustomHostAt(index),
                    backgroundColor: CupertinoDynamicColor.resolve(
                        CupertinoColors.systemRed, context),
                    foregroundColor: Colors.white,
                    icon: Icons.delete,
                    label: L10n.of(context).delete,
                  ),
                ],
              ),
              child: CuttomHostItem(
                index: index,
                host: _dnsCache.host ?? '',
                addr: _dnsCache.addr ?? '',
              ),
            );
          },
          itemCount: dnsConfigController.hosts.length,
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
        subTitle: addr,
        onTap: () {
          showCustomHostEditer(context, index: index);
        },
      ),
    );
  }
}
