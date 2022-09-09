import 'dart:math';

import 'package:enum_to_string/enum_to_string.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/component/setting_base.dart';
import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/pages/image_view/common.dart';
import 'package:fehviewer/pages/image_view/controller/view_controller.dart';
import 'package:fehviewer/pages/setting/setting_items/selector_Item.dart';
import 'package:fehviewer/route/main_observer.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fullscreen/fullscreen.dart';
import 'package:get/get.dart';
import 'package:orientation/orientation.dart';

class ReadSettingPage extends StatelessWidget {
  const ReadSettingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Widget cps = Obx(() {
      return CupertinoPageScaffold(
          backgroundColor: !ehTheme.isDarkMode
              ? CupertinoColors.secondarySystemBackground
              : null,
          navigationBar: CupertinoNavigationBar(
            // transitionBetweenRoutes: true,
            middle: Text(L10n.of(context).read_setting),
          ),
          child: SafeArea(
            bottom: false,
            child: ViewSettingList(),
          ));
    });

    return cps;
  }
}

class ViewSettingList extends StatelessWidget {
  final EhConfigService ehConfigService = Get.find();

  Future<void> onViewFullscreenChanged(bool val) async {
    ehConfigService.viewFullscreen = val;
    final history = MainNavigatorObserver().history;
    final prevMainRoute = history[max(0, history.length - 2)].settings.name;
    logger.d('prevMainRoute $prevMainRoute');

    if (prevMainRoute == EHRoutes.galleryViewExt) {
      if (val) {
        await FullScreen.enterFullScreen(FullScreenMode.EMERSIVE_STICKY);
      } else {
        await FullScreen.exitFullScreen();
        // SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        //   systemNavigationBarColor: Colors.transparent,
        //   systemNavigationBarDividerColor: Colors.transparent,
        //   statusBarColor: Colors.transparent,
        // ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // iPad不显示旋转设置
    final bool _hideOrientationItem = GetPlatform.isIOS && context.isTablet;

    final List<Widget> _list = <Widget>[
      _buildViewModeItem(context),
      if (!_hideOrientationItem) ReadOrientationItem(),
      _buildDoublePageItem(context),
      TextSwitchItem(
        L10n.of(context).show_page_interval,
        intValue: ehConfigService.showPageInterval.value,
        onChanged: (bool val) {
          ehConfigService.showPageInterval.value = val;
          if (Get.isRegistered<ViewExtController>()) {
            Get.find<ViewExtController>().resetPageController();
            Get.find<ViewExtController>().update([idSlidePage]);
          }
        },
      ),
      TextSwitchItem(
        L10n.of(context).tap_to_turn_page_anima,
        intValue: ehConfigService.tapToTurnPageAnimations,
        onChanged: (bool val) {
          ehConfigService.tapToTurnPageAnimations = val;
        },
      ),
      TextSwitchItem(
        L10n.of(context).fullscreen,
        intValue: ehConfigService.viewFullscreen,
        onChanged: onViewFullscreenChanged,
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

/// 阅读方向模式切换
Widget _buildViewModeItem(BuildContext context) {
  final String _title = L10n.of(context).reading_direction;
  final EhConfigService ehConfigService = Get.find();

  final Map<ViewMode, String> modeMap = <ViewMode, String>{
    ViewMode.LeftToRight: L10n.of(context).left_to_right,
    ViewMode.rightToLeft: L10n.of(context).right_to_left,
    ViewMode.topToBottom: L10n.of(context).top_to_bottom,
  };

  List<Widget> _getModeList() {
    return List<Widget>.from(modeMap.keys.map((ViewMode element) {
      return CupertinoActionSheetAction(
          onPressed: () {
            Get.back(result: element);
          },
          child: Text(modeMap[element] ?? ''));
    }).toList());
  }

  Future<ViewMode?> _showDialog(BuildContext context) {
    return showCupertinoModalPopup<ViewMode>(
        context: context,
        builder: (BuildContext context) {
          final CupertinoActionSheet dialog = CupertinoActionSheet(
            cancelButton: CupertinoActionSheetAction(
                onPressed: () {
                  Get.back();
                },
                child: Text(L10n.of(context).cancel)),
            actions: <Widget>[
              ..._getModeList(),
            ],
          );
          return dialog;
        });
  }

  return Obx(() => SelectorSettingItem(
        title: _title,
        selector: modeMap[ehConfigService.viewMode.value] ?? '',
        onTap: () async {
          logger.v('tap ModeItem');
          final ViewMode? _result = await _showDialog(context);
          if (_result != null) {
            // ignore: unnecessary_string_interpolations
            logger.v('${EnumToString.convertToString(_result)}');
            ehConfigService.viewMode.value = _result;
            if (Get.isRegistered<ViewExtController>()) {
              Get.find<ViewExtController>().handOnViewModeChanged(_result);
            }
          }
        },
      ));
}

class ReadOrientationItem extends StatelessWidget {
  final String _title = L10n.of(Get.context!).screen_orientation;
  final EhConfigService ehConfigService = Get.find();

  final Map<ReadOrientation, String> modeMap = <ReadOrientation, String>{
    ReadOrientation.system: L10n.of(Get.context!).orientation_system,
    ReadOrientation.portraitUp: L10n.of(Get.context!).orientation_portraitUp,
    ReadOrientation.landscapeLeft:
        L10n.of(Get.context!).orientation_landscapeLeft,
    ReadOrientation.landscapeRight:
        L10n.of(Get.context!).orientation_landscapeRight,
  };

  List<Widget> get modeList {
    return List<Widget>.from(modeMap.keys.map((ReadOrientation element) {
      return CupertinoActionSheetAction(
          onPressed: () {
            Get.back(result: element);
          },
          child: Text(modeMap[element] ?? ''));
    }).toList());
  }

  Future<ReadOrientation?> _showDialog(BuildContext context) {
    return showCupertinoModalPopup<ReadOrientation>(
        context: context,
        builder: (BuildContext context) {
          final CupertinoActionSheet dialog = CupertinoActionSheet(
            cancelButton: CupertinoActionSheetAction(
                onPressed: () {
                  Get.back();
                },
                child: Text(L10n.of(context).cancel)),
            actions: <Widget>[
              ...modeList,
            ],
          );
          return dialog;
        });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => SelectorSettingItem(
          title: _title,
          selector: modeMap[ehConfigService.orientation.value] ?? '',
          onTap: () async {
            logger.v('tap ModeItem');
            final ReadOrientation? _result = await _showDialog(context);
            if (_result != null) {
              // ignore: unnecessary_string_interpolations
              // logger.v('${EnumToString.convertToString(_result)}');
              ehConfigService.orientation.value = _result;
              if (_result != ReadOrientation.system &&
                  _result != ReadOrientation.auto) {
                OrientationPlugin.setPreferredOrientations(
                    [orientationMap[_result] ?? DeviceOrientation.portraitUp]);
                // OrientationPlugin.forceOrientation(orientationMap[_result]!);
              } else if (_result == ReadOrientation.system) {
                // OrientationPlugin.forceOrientation(
                //     DeviceOrientation.portraitUp);
                OrientationPlugin.setPreferredOrientations(
                    DeviceOrientation.values);
              }
            }
          },
        ));
  }
}

/// 双页设置切换
Widget _buildDoublePageItem(BuildContext context, {bool hideLine = false}) {
  final String _title = L10n.of(context).double_page_model;
  final EhConfigService ehConfigService = Get.find();

  final Map<ViewColumnMode, String> actionMap = <ViewColumnMode, String>{
    ViewColumnMode.single: L10n.of(context).off,
    ViewColumnMode.oddLeft: L10n.of(context).model('A'),
    ViewColumnMode.evenLeft: L10n.of(context).model('B'),
  };

  Widget _getTempPage(String ser) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      height: 100,
      width: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6.0),
        color:
            CupertinoDynamicColor.resolve(CupertinoColors.systemGrey4, context),
      ),
      alignment: Alignment.center,
      child: Text(
        ser,
        style: TextStyle(
            color: CupertinoDynamicColor.resolve(
                CupertinoColors.secondaryLabel, context)),
      ),
    );
  }

  Widget _getDivider() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        width: 2,
        height: 5,
        color: CupertinoDynamicColor.resolve(
            CupertinoColors.secondaryLabel, context),
      ),
    );
  }

  final modeB = [
    _getTempPage('1'),
    _getDivider(),
    _getTempPage('2'),
    _getTempPage('3'),
    _getDivider(),
    _getTempPage('4'),
    _getTempPage('5'),
  ];

  final modeA = [
    _getTempPage('1'),
    _getTempPage('2'),
    _getDivider(),
    _getTempPage('3'),
    _getTempPage('4'),
    _getDivider(),
    _getTempPage('5'),
  ];

  final Map<ViewColumnMode, Widget> actionWidgetMap = <ViewColumnMode, Widget>{
    ViewColumnMode.single: Text(L10n.of(context).off),
    ViewColumnMode.oddLeft: Column(
      children: [
        Text(
          L10n.of(context).model('A'),
          textScaleFactor: 0.8,
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          height: 100,
          child: Obx(() {
            return ListView(
              scrollDirection: Axis.horizontal,
              reverse: ehConfigService.viewMode.value == ViewMode.rightToLeft,
              children: modeA,
            );
          }),
        ),
      ],
    ),
    ViewColumnMode.evenLeft: Column(
      children: [
        Text(
          L10n.of(context).model('B'),
          textScaleFactor: 0.8,
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          height: 100,
          child: Obx(() {
            return ListView(
              scrollDirection: Axis.horizontal,
              reverse: ehConfigService.viewMode.value == ViewMode.rightToLeft,
              children: modeB,
            );
          }),
        ),
      ],
    ),
  };

  return Obx(() {
    return SelectorItem<ViewColumnMode>(
      title: _title,
      hideDivider: hideLine,
      actionMap: actionMap,
      actionWidgetMap: actionWidgetMap,
      initVal: ehConfigService.viewColumnMode,
      onValueChanged: (val) => ehConfigService.viewColumnMode = val,
    );
  });
}
