import 'dart:math';

import 'package:enum_to_string/enum_to_string.dart';
import 'package:fehviewer/common/service/ehsetting_service.dart';
import 'package:fehviewer/component/setting_base.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/pages/image_view/common.dart';
import 'package:fehviewer/pages/image_view/controller/view_controller.dart';
import 'package:fehviewer/pages/setting/setting_items/selector_Item.dart';
import 'package:fehviewer/utils/orientation_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sliver_tools/sliver_tools.dart';

class ReadSettingPage extends StatelessWidget {
  const ReadSettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        middle: Text(L10n.of(context).eh),
      ),
      child: CustomScrollView(slivers: [
        SliverSafeArea(sliver: ReadSettingList()),
      ]),
    );
  }
}

class ReadSettingList extends StatelessWidget {
  ReadSettingList({super.key});

  final EhSettingService ehSettingService = Get.find();

  Future<void> onViewFullscreenChanged(bool val) async {
    ehSettingService.viewFullscreen = val;
    final history = MainNavigatorObserver().history;
    final prevMainRoute = history[max(0, history.length - 2)].settings.name;
    logger.d('prevMainRoute $prevMainRoute');

    if (prevMainRoute == EHRoutes.galleryViewExt) {
      if (val) {
        await SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.immersiveSticky,
        );
      } else {
        await SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.edgeToEdge,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // iPad不显示旋转设置
    final bool _hideOrientationItem = GetPlatform.isIOS && context.isTablet;

    return MultiSliver(children: [
      SliverCupertinoListSection.listInsetGrouped(children: [
        _buildViewModeItem(context),
        if (!_hideOrientationItem) ReadOrientationItem(),
        _buildDoublePageItem(context),
        EhCupertinoListTile(
          title: Text(L10n.of(context).show_page_interval),
          trailing: Obx(() {
            return CupertinoSwitch(
              value: ehSettingService.showPageInterval.value,
              onChanged: (bool val) {
                ehSettingService.showPageInterval.value = val;
                if (Get.isRegistered<ViewExtController>()) {
                  Get.find<ViewExtController>().resetPageController();
                  Get.find<ViewExtController>().update([idSlidePage]);
                }
              },
            );
          }),
        ),
        // turn_page_anima
        EhCupertinoListTile(
          title: Text(L10n.of(context).turn_page_anima),
          trailing: Obx(() {
            return CupertinoSwitch(
              value: ehSettingService.turnPageAnimations,
              onChanged: (bool val) {
                ehSettingService.turnPageAnimations = val;
              },
            );
          }),
        ),
        // volume_key_turn_page
        if (GetPlatform.isAndroid)
          EhCupertinoListTile(
            title: Text(L10n.of(context).volume_key_turn_page),
            trailing: Obx(() {
              return CupertinoSwitch(
                value: ehSettingService.volumnTurnPage,
                onChanged: (bool val) {
                  ehSettingService.volumnTurnPage = val;
                },
              );
            }),
          ),
        // fullscreen
        EhCupertinoListTile(
          title: Text(L10n.of(context).fullscreen),
          trailing: Obx(() {
            return CupertinoSwitch(
              value: ehSettingService.viewFullscreen,
              onChanged: onViewFullscreenChanged,
            );
          }),
        ),
      ]),

      // 兼容模式
      SliverCupertinoListSection.listInsetGrouped(children: [
        EhCupertinoListTile(
          title: Text(L10n.of(context).read_view_compatible_mode),
          trailing: Obx(() {
            return CupertinoSwitch(
              value: ehSettingService.readViewCompatibleMode,
              onChanged: (bool val) {
                ehSettingService.readViewCompatibleMode = val;
              },
            );
          }),
        ),
      ]),
    ]);
  }
}

/// 阅读方向模式切换
Widget _buildViewModeItem(BuildContext context) {
  final String _title = L10n.of(context).reading_direction;
  final EhSettingService ehSettingService = Get.find();

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

  return Obx(() => EhCupertinoListTile(
        title: Text(_title),
        trailing: const CupertinoListTileChevron(),
        additionalInfo: Text(modeMap[ehSettingService.viewMode.value] ?? ''),
        onTap: () async {
          logger.t('tap ModeItem');
          final ViewMode? _result = await _showDialog(context);
          if (_result != null) {
            // ignore: unnecessary_string_interpolations
            logger.t('${EnumToString.convertToString(_result)}');
            ehSettingService.viewMode.value = _result;
            if (Get.isRegistered<ViewExtController>()) {
              Get.find<ViewExtController>().handOnViewModeChanged(_result);
            }
          }
        },
      ));
}

class ReadOrientationItem extends StatelessWidget {
  final String _title = L10n.of(Get.context!).screen_orientation;
  final EhSettingService ehSettingService = Get.find();

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
    return Obx(() => EhCupertinoListTile(
          title: Text(_title),
          trailing: const CupertinoListTileChevron(),
          additionalInfo:
              Text(modeMap[ehSettingService.orientation.value] ?? ''),
          onTap: () async {
            logger.t('tap ModeItem');
            final ReadOrientation? _result = await _showDialog(context);
            if (_result != null) {
              ehSettingService.orientation.value = _result;
              if (_result != ReadOrientation.system &&
                  _result != ReadOrientation.auto) {
                OrientationHelper.setPreferredOrientations(
                    [orientationMap[_result] ?? DeviceOrientation.portraitUp]);
              } else if (_result == ReadOrientation.system) {
                OrientationHelper.setPreferredOrientations(
                    DeviceOrientation.values);
              }
            }
          },
        ));
  }
}

/// 双页设置切换
Widget _buildDoublePageItem(BuildContext context) {
  final String _title = L10n.of(context).double_page_model;
  final EhSettingService ehSettingService = Get.find();

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
        color: getPressedColor(context),
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
              reverse: ehSettingService.viewMode.value == ViewMode.rightToLeft,
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
              reverse: ehSettingService.viewMode.value == ViewMode.rightToLeft,
              children: modeB,
            );
          }),
        ),
      ],
    ),
  };

  return Obx(() {
    return SelectorCupertinoListTile<ViewColumnMode>(
      title: _title,
      actionMap: actionMap,
      actionWidgetMap: actionWidgetMap,
      initVal: ehSettingService.viewColumnMode,
      onValueChanged: (val) => ehSettingService.viewColumnMode = val,
    );
  });
}
