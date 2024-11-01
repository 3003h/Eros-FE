import 'dart:math';

import 'package:enum_to_string/enum_to_string.dart';
import 'package:eros_fe/common/service/ehsetting_service.dart';
import 'package:eros_fe/component/setting_base.dart';
import 'package:eros_fe/index.dart';
import 'package:eros_fe/pages/image_view/common.dart';
import 'package:eros_fe/pages/image_view/controller/view_controller.dart';
import 'package:eros_fe/pages/setting/setting_items/selector_Item.dart';
import 'package:eros_fe/utils/orientation_helper.dart';
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
        middle: Text(L10n.of(context).read_setting),
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
    final bool hideOrientationItem = GetPlatform.isIOS && context.isTablet;

    return MultiSliver(children: [
      SliverCupertinoListSection.listInsetGrouped(
        children: [
          _buildViewModeItem(context),
          if (!hideOrientationItem) const ReadOrientationItem(),
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
        ],
      ),

      SliverCupertinoListSection.listInsetGrouped(
        footer: Text(L10n.of(context).experimental_feature),
        children: [
          _buildPageTypeItem(context),
          _buildEnableSlideOutPageItem(context),
        ],
      ),

      // 兼容模式
      // SliverCupertinoListSection.listInsetGrouped(children: [
      //   EhCupertinoListTile(
      //     title: Text(L10n.of(context).read_view_compatible_mode),
      //     trailing: Obx(() {
      //       return CupertinoSwitch(
      //         value: ehSettingService.readViewCompatibleMode,
      //         onChanged: (bool val) {
      //           ehSettingService.readViewCompatibleMode = val;
      //         },
      //       );
      //     }),
      //   ),
      // ]),
    ]);
  }
}

Widget _buildPageTypeItem(
  BuildContext context,
) {
  final Map<PageViewType, String> actionMap = <PageViewType, String>{
    PageViewType.extendedImageGesturePageView: 'ExtendedImage (Default)',
    PageViewType.preloadPageView: 'PreloadPageView',
  };

  final Map<PageViewType, String> simpleActionMap = <PageViewType, String>{
    PageViewType.extendedImageGesturePageView: 'ExtendedImage',
    PageViewType.preloadPageView: 'PreloadPageView',
  };

  final EhSettingService ehSettingService = Get.find();
  // final ViewExtController viewExtController = Get.find();

  return Obx(() {
    return SelectorCupertinoListTile<PageViewType>(
      // key: UniqueKey(),
      title: L10n.of(context).page_view_type,
      actionMap: actionMap,
      simpleActionMap: simpleActionMap,
      initVal: ehSettingService.pageViewType,
      onValueChanged: (val) {
        ehSettingService.pageViewType = val;
        // viewExtController.update([idSlidePage]);
        if (Get.isRegistered<ViewExtController>()) {
          Get.find<ViewExtController>().resetPageController();
          Get.find<ViewExtController>().update([idSlidePage]);
        }
      },
    );
  });
}

Widget _buildEnableSlideOutPageItem(
  BuildContext context,
) {
  // final ViewExtController viewExtController = Get.find();
  final EhSettingService ehSettingService = Get.find();

  return EhCupertinoListTile(
    title: Text(L10n.of(context).slide_out_page),
    trailing: Obx(() {
      return CupertinoSwitch(
        value: ehSettingService.enableSlideOutPage,
        onChanged: (val) {
          ehSettingService.enableSlideOutPage = val;
          if (Get.isRegistered<ViewExtController>()) {
            Get.find<ViewExtController>().resetPageController();
            Get.find<ViewExtController>()
                .update([idSlidePage, idImagePageView]);
          }
        },
      );
    }),
  );
}

/// 阅读方向模式切换
Widget _buildViewModeItem(BuildContext context) {
  final String title = L10n.of(context).reading_direction;
  final EhSettingService ehSettingService = Get.find();

  final Map<ViewMode, String> modeMap = <ViewMode, String>{
    ViewMode.leftToRight: L10n.of(context).left_to_right,
    ViewMode.rightToLeft: L10n.of(context).right_to_left,
    ViewMode.topToBottom: L10n.of(context).top_to_bottom,
  };

  List<Widget> getModeList() {
    return List<Widget>.from(modeMap.keys.map((ViewMode element) {
      return CupertinoActionSheetAction(
          onPressed: () {
            Get.back(result: element);
          },
          child: Text(modeMap[element] ?? ''));
    }).toList());
  }

  Future<ViewMode?> showDialog(BuildContext context) {
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
              ...getModeList(),
            ],
          );
          return dialog;
        });
  }

  return Obx(() => EhCupertinoListTile(
        title: Text(title),
        trailing: const CupertinoListTileChevron(),
        additionalInfo: Text(modeMap[ehSettingService.viewMode.value] ?? ''),
        onTap: () async {
          logger.t('tap ModeItem');
          final ViewMode? result = await showDialog(context);
          if (result != null) {
            // ignore: unnecessary_string_interpolations
            logger.t('${EnumToString.convertToString(result)}');
            ehSettingService.viewMode.value = result;
            if (Get.isRegistered<ViewExtController>()) {
              Get.find<ViewExtController>().handOnViewModeChanged(result);
            }
          }
        },
      ));
}

class ReadOrientationItem extends StatelessWidget {
  const ReadOrientationItem({super.key});

  EhSettingService get ehSettingService => Get.find();

  Map<ReadOrientation, String> getModeMap(BuildContext context) =>
      <ReadOrientation, String>{
        ReadOrientation.system: L10n.of(context).orientation_system,
        ReadOrientation.portraitUp:
            L10n.of(Get.context!).orientation_portraitUp,
        ReadOrientation.landscapeLeft:
            L10n.of(Get.context!).orientation_landscapeLeft,
        ReadOrientation.landscapeRight:
            L10n.of(Get.context!).orientation_landscapeRight,
      };

  List<Widget> getModeList(Map<ReadOrientation, String> modeMap) {
    return List<Widget>.from(modeMap.keys.map((ReadOrientation element) {
      return CupertinoActionSheetAction(
          onPressed: () {
            Get.back(result: element);
          },
          child: Text(modeMap[element] ?? ''));
    }).toList());
  }

  Future<ReadOrientation?> _showDialog(BuildContext context) {
    final modeList = getModeList(getModeMap(context));

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
    final String title = L10n.of(Get.context!).screen_orientation;
    final modeMap = getModeMap(context);
    return Obx(() => EhCupertinoListTile(
          title: Text(title),
          trailing: const CupertinoListTileChevron(),
          additionalInfo:
              Text(modeMap[ehSettingService.orientation.value] ?? ''),
          onTap: () async {
            logger.t('tap ModeItem');
            final ReadOrientation? result = await _showDialog(context);
            if (result != null) {
              ehSettingService.orientation.value = result;
              if (result != ReadOrientation.system &&
                  result != ReadOrientation.auto) {
                OrientationHelper.setPreferredOrientations(
                    [orientationMap[result] ?? DeviceOrientation.portraitUp]);
              } else if (result == ReadOrientation.system) {
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
  final String title = L10n.of(context).double_page_model;
  final EhSettingService ehSettingService = Get.find();

  final Map<ViewColumnMode, String> actionMap = <ViewColumnMode, String>{
    ViewColumnMode.single: L10n.of(context).off,
    ViewColumnMode.oddLeft: L10n.of(context).model('A'),
    ViewColumnMode.evenLeft: L10n.of(context).model('B'),
  };

  Widget getTempPage(String ser) {
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

  Widget getDivider() {
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
    getTempPage('1'),
    getDivider(),
    getTempPage('2'),
    getTempPage('3'),
    getDivider(),
    getTempPage('4'),
    getTempPage('5'),
  ];

  final modeA = [
    getTempPage('1'),
    getTempPage('2'),
    getDivider(),
    getTempPage('3'),
    getTempPage('4'),
    getDivider(),
    getTempPage('5'),
  ];

  final Map<ViewColumnMode, Widget> actionWidgetMap = <ViewColumnMode, Widget>{
    ViewColumnMode.single: Text(L10n.of(context).off),
    ViewColumnMode.oddLeft: Column(
      children: [
        Text(
          L10n.of(context).model('A'),
          textScaler: const TextScaler.linear(0.8),
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
          textScaler: const TextScaler.linear(0.8),
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
      title: title,
      actionMap: actionMap,
      actionWidgetMap: actionWidgetMap,
      initVal: ehSettingService.viewColumnMode,
      onValueChanged: (val) => ehSettingService.viewColumnMode = val,
    );
  });
}
