import 'package:fehviewer/common/controller/auto_lock_controller.dart';
import 'package:fehviewer/common/service/ehsetting_service.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class SecuritySettingPage extends StatelessWidget {
  const SecuritySettingPage({super.key});

  EhSettingService get _ehSettingService => Get.find<EhSettingService>();

  @override
  Widget build(BuildContext context) {
    final _widgetList = _buildList(context);
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        transitionBetweenRoutes: true,
        middle: Text(L10n.of(context).security),
      ),
      child: CustomScrollView(
        slivers: [
          SliverSafeArea(
            sliver: SliverCupertinoListSection.insetGrouped(
              hasLeading: false,
              additionalDividerMargin: 6,
              itemBuilder: (context, index) {
                return _widgetList[index];
              },
              itemCount: _widgetList.length,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildList(BuildContext context) {
    return <Widget>[
      if (GetPlatform.isMobile)
        EhCupertinoListTile(
          title: Text(L10n.of(context).security_blurredInRecentTasks),
          trailing: Obx(() {
            return CupertinoSwitch(
              value: _ehSettingService.blurredInRecentTasks,
              onChanged: (bool value) {
                _ehSettingService.blurredInRecentTasks = value;
              },
            );
          }),
        ),
      _buildAutoLockItem(context),
    ];
  }
}

/// 自动锁定时间设置
Widget _buildAutoLockItem(BuildContext context) {
  final String _title = L10n.of(context).autoLock;
  final EhSettingService ehSettingService = Get.find();
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
    if (timeOut == ehSettingService.autoLockTimeOut.value) {
      return;
    }

    if (timeOut == -1 || ehSettingService.autoLockTimeOut.value == -1) {
      Future.delayed(const Duration(milliseconds: 400))
          .then((_) => autoLockController.checkBiometrics())
          .then((bool value) {
        autoLockController.resetLastLeaveTime();
        if (value) {
          ehSettingService.autoLockTimeOut(timeOut);
        }
      });
    } else {
      ehSettingService.autoLockTimeOut(timeOut);
    }
  }

  return Obx(() => EhCupertinoListTile(
        title: Text(_title),
        trailing: const CupertinoListTileChevron(),
        additionalInfo:
            Text(_getTimeText(ehSettingService.autoLockTimeOut.value)),
        onTap: () async {
          final int? _result = await _showActionSheet(context);
          if (_result != null) {
            _setAutoLockTimeOut(_result);
          }
        },
      ));
}
