import 'package:enum_to_string/enum_to_string.dart';
import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/pages/image_view/controller/view_contorller.dart';
import 'package:fehviewer/pages/setting/setting_base.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
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

  @override
  Widget build(BuildContext context) {
    // iPad不显示旋转设置
    final bool _hideOrientationItem = GetPlatform.isIOS && context.isTablet;

    final List<Widget> _list = <Widget>[
      _buildViewModeItem(context),
      if (!_hideOrientationItem) ReadOrientationItem(),
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
        hideLine: true,
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
