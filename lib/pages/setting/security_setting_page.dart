import 'package:fehviewer/common/controller/auto_lock_controller.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/component/setting_base.dart';
import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class SecuritySettingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Widget cps = Obx(() {
      return CupertinoPageScaffold(
          backgroundColor: !ehTheme.isDarkMode
              ? CupertinoColors.secondarySystemBackground
              : null,
          navigationBar: CupertinoNavigationBar(
            transitionBetweenRoutes: true,
            middle: Text(L10n.of(context).security),
          ),
          child: SafeArea(
            child: ListViewSecuritySetting(),
            bottom: false,
          ));
    });

    return cps;
  }
}

class ListViewSecuritySetting extends StatelessWidget {
  EhConfigService get _ehConfigService => Get.find<EhConfigService>();

  @override
  Widget build(BuildContext context) {
    final List<Widget> _list = <Widget>[
      if (GetPlatform.isIOS)
        TextSwitchItem(
          L10n.of(context).security_blurredInRecentTasks,
          intValue: _ehConfigService.blurredInRecentTasks.value,
          onChanged: (val) => _ehConfigService.blurredInRecentTasks.value = val,
        ),
      _buildAutoLockItem(context, hideLine: true),
    ];
    return ListView.builder(
      itemCount: _list.length,
      itemBuilder: (BuildContext context, int index) {
        return _list[index];
      },
    );
  }
}

/// 自动锁定时间设置
Widget _buildAutoLockItem(BuildContext context, {bool hideLine = false}) {
  final String _title = L10n.of(context).autoLock;
  final EhConfigService ehConfigService = Get.find();
  final AutoLockController autoLockController = Get.find();

  String _getTimeText(int seconds) {
    if (seconds < 0) {
      return L10n.of(context).disabled;
    }

    if (seconds == 0) {
      return L10n.of(context).instantly;
    }

    final Duration d = Duration(seconds: seconds);
    final List<String> parts = d.toString().split(RegExp(r'[:.]'));

    final _hours = int.parse(parts[0]);
    final partHours = _hours > 0 ? '$_hours ${L10n.of(context).hours}' : '';

    final _min = int.parse(parts[1]);
    final partMin = _min > 0 ? '$_min ${L10n.of(context).min}' : '';

    final _second = int.parse(parts[2]);
    final partSecond = _second > 0 ? '$_second ${L10n.of(context).second}' : '';

    return '$partHours $partMin $partSecond';
  }

  List<Widget> _getTimeOutList(BuildContext context) {
    return List<Widget>.from(EHConst.autoLockTime.map((int element) {
      return CupertinoActionSheetAction(
          onPressed: () {
            Get.back(result: element);
          },
          child: Text(_getTimeText(element)));
    }).toList());
  }

  Future<int?> _showActionSheet(BuildContext context) {
    return showCupertinoModalPopup<int>(
        context: context,
        builder: (BuildContext context) {
          final CupertinoActionSheet dialog = CupertinoActionSheet(
            cancelButton: CupertinoActionSheetAction(
                onPressed: () {
                  Get.back();
                },
                child: Text(L10n.of(context).cancel)),
            actions: <Widget>[
              ..._getTimeOutList(context),
            ],
          );
          return dialog;
        });
  }

  void _setAutoLockTimeOut(int timeOut) {
    if (timeOut == ehConfigService.autoLockTimeOut.value) {
      return;
    }

    if (timeOut == -1 || ehConfigService.autoLockTimeOut.value == -1) {
      Future.delayed(const Duration(milliseconds: 400))
          .then((_) => autoLockController.checkBiometrics())
          .then((bool value) {
        autoLockController.resetLastLeaveTime();
        if (value) {
          ehConfigService.autoLockTimeOut(timeOut);
        }
      });
    } else {
      ehConfigService.autoLockTimeOut(timeOut);
    }
  }

  return Obx(() => SelectorSettingItem(
        title: _title,
        hideDivider: hideLine,
        selector: _getTimeText(ehConfigService.autoLockTimeOut.value),
        onTap: () async {
          final int? _result = await _showActionSheet(context);
          if (_result != null) {
            _setAutoLockTimeOut(_result);
          }
        },
      ));
}
