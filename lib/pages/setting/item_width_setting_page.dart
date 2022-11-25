import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/component/setting_base.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

import '../item/gallery_item_grid.dart';
import '../item/item_base.dart';
import 'setting_items/selector_Item.dart';

final _maybeAspectRatios = <double>[
  4 / 3,
  4 / 3,
  3 / 4,
  3 / 4,
  1,
  2 / 3,
  3 / 2,
  16 / 9,
  9 / 16
];
final _aspectRatioList = _genAspectRatios(100);
List<double> _genAspectRatios([int? count]) {
  final List<double> _aspectRatios = <double>[];
  for (int i = 0; i < count!; i++) {
    _aspectRatios.add(randomList(_maybeAspectRatios));
  }
  return _aspectRatios;
}

class ItemWidthSettingPage extends StatefulWidget {
  const ItemWidthSettingPage({Key? key}) : super(key: key);

  @override
  State<ItemWidthSettingPage> createState() => _ItemWidthSettingPageState();
}

class _ItemWidthSettingPageState extends State<ItemWidthSettingPage> {
  EhConfigService get _ehConfigService => Get.find();
  late ListModeEnum selectedMode;
  late double customWidth;
  late bool enableCustomWidth;

  @override
  void initState() {
    super.initState();
    selectedMode = _ehConfigService.listMode.value;
    if (![
      ListModeEnum.grid,
      ListModeEnum.waterfall,
      ListModeEnum.waterfallLarge
    ].contains(selectedMode)) {
      selectedMode = ListModeEnum.waterfallLarge;
    }

    _onModeChange(selectedMode);
  }

  Map<ListModeEnum, double> defaultWidthMap() => {
        ListModeEnum.grid: EHConst.gridMaxCrossAxisExtent,
        ListModeEnum.waterfall: Get.context!.isPhone
            ? EHConst.waterfallFlowMaxCrossAxisExtent
            : EHConst.waterfallFlowMaxCrossAxisExtentTablet,
        ListModeEnum.waterfallLarge:
            EHConst.waterfallFlowLargeMaxCrossAxisExtent,
      };

  void _onModeChange(ListModeEnum mode) {
    selectedMode = mode;
    enableCustomWidth =
        _ehConfigService.getItemConfig(selectedMode)?.enableCustomWidth ??
            false;
    customWidth =
        _ehConfigService.getItemConfig(selectedMode)?.customWidth?.toDouble() ??
            defaultWidthMap()[mode] ??
            200.0;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return CupertinoPageScaffold(
        backgroundColor: !ehTheme.isDarkMode
            ? CupertinoColors.secondarySystemBackground
            : null,
        navigationBar: CupertinoNavigationBar(
          middle: Text(L10n.of(context).custom_width),
        ),
        child: SafeArea(
          bottom: false,
          top: true,
          child: Container(
            child: Column(
              children: [
                _buildListModeItem(
                  context,
                  initMode: selectedMode,
                  onValueChanged: (val) {
                    // logger.d('切换要修改的列表模式 listMode $val');
                    setState(() {
                      _onModeChange(val);
                    });
                  },
                ),

                // 开关
                StatefulBuilder(builder: (context, setState) {
                  return TextSwitchItem(
                    L10n.of(context).custom_width,
                    key: ValueKey(selectedMode),
                    value: enableCustomWidth,
                    onChanged: (bool val) {
                      _ehConfigService.setItemConfig(
                          selectedMode,
                          (ItemConfig itemConfig) =>
                              itemConfig.copyWith(enableCustomWidth: val));
                      setState(() {
                        enableCustomWidth = val;
                      });
                    },
                    hideDivider: false,
                  );
                }),

                Expanded(
                  child: StatefulBuilder(builder: (context, setState) {
                    return Column(
                      children: [
                        // 滑动条
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          constraints:
                              const BoxConstraints(minHeight: kItemHeight),
                          color: CupertinoDynamicColor.resolve(
                              ehTheme.itemBackgroundColor!, context),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                alignment: Alignment.center,
                                child: Text('${customWidth.toInt()}'),
                              ),
                              Expanded(
                                child: CupertinoSlider(
                                  value: customWidth,
                                  min: 100,
                                  max: 350,
                                  divisions: 250,
                                  onChanged: (double val) {
                                    setState(() {
                                      customWidth = val;
                                    });
                                  },
                                  onChangeEnd: (double val) {
                                    logger.d('onChangeEnd $val');
                                    _ehConfigService.setItemConfig(
                                        selectedMode,
                                        (ItemConfig itemConfig) =>
                                            itemConfig.copyWith(
                                                customWidth: val.toInt()));
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ExampleView(
                            selectedMode: selectedMode,
                            customWidth: customWidth,
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class ExampleView extends StatelessWidget {
  const ExampleView({
    Key? key,
    required this.selectedMode,
    required this.customWidth,
  }) : super(key: key);
  final ListModeEnum selectedMode;
  final double customWidth;

  @override
  Widget build(BuildContext context) {
    const kItemCount = 100;

    switch (selectedMode) {
      case ListModeEnum.grid:
        return GridView.builder(
          padding: const EdgeInsets.all(EHConst.gridCrossAxisSpacing),
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: customWidth,
            childAspectRatio: EHConst.gridChildAspectRatio,
            mainAxisSpacing: 4.0,
            crossAxisSpacing: 4.0,
          ),
          itemBuilder: (context, index) {
            return const _GridItem();
          },
          itemCount: kItemCount,
        );
      case ListModeEnum.waterfall:
        return WaterfallFlowView(customWidth: customWidth);
      case ListModeEnum.waterfallLarge:
        return WaterfallFlowView(
          customWidth: customWidth,
          large: true,
        );

      default:
        return Container();
    }
  }
}

class WaterfallFlowView extends StatelessWidget {
  const WaterfallFlowView({
    Key? key,
    this.large = false,
    required this.customWidth,
  }) : super(key: key);
  final bool large;
  final double customWidth;

  @override
  Widget build(BuildContext context) {
    return WaterfallFlow.builder(
      padding: EdgeInsets.all(large
          ? EHConst.waterfallFlowLargeCrossAxisSpacing
          : EHConst.waterfallFlowCrossAxisSpacing),
      gridDelegate: SliverWaterfallFlowDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: customWidth,
        crossAxisSpacing: large
            ? EHConst.waterfallFlowLargeCrossAxisSpacing
            : EHConst.waterfallFlowCrossAxisSpacing,
        mainAxisSpacing: large
            ? EHConst.waterfallFlowLargeMainAxisSpacing
            : EHConst.waterfallFlowMainAxisSpacing,
      ),
      itemBuilder: (context, index) {
        final aspectRatio = _aspectRatioList[index];
        return _WaterfallFlowItem(
          aspectRatio: aspectRatio,
          large: large,
        );
      },
      itemCount: _aspectRatioList.length,
    );
  }
}

class _WaterfallFlowItem extends StatelessWidget {
  const _WaterfallFlowItem({
    Key? key,
    required this.aspectRatio,
    required this.large,
  }) : super(key: key);
  final double aspectRatio;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
            aspectRatio: aspectRatio,
            child: Container(
              color: CupertinoDynamicColor.resolve(
                  CupertinoColors.systemGrey4, context),
            ),
          ),
          if (large)
            Container(
              height: 80,
              color: CupertinoDynamicColor.resolve(
                  ehTheme.itemBackgroundColor!, context),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Column(
                children: const [
                  PlaceHolderLine(),
                  PlaceHolderLine(),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _GridItem extends StatelessWidget {
  const _GridItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6.0),
      child: Container(
        decoration: BoxDecoration(
          color: ehTheme.itemBackgroundColor,
        ),
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 1 / kCoverRatio,
              child: Container(
                color: CupertinoDynamicColor.resolve(
                    CupertinoColors.systemGrey4, context),
              ),
            ),
            Expanded(
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Column(
                  children: const [
                    PlaceHolderLine(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 列表模式切换
Widget _buildListModeItem(
  BuildContext context, {
  bool hideDivider = false,
  required ListModeEnum initMode,
  ValueChanged<ListModeEnum>? onValueChanged,
}) {
  final String _title = L10n.of(context).list_mode;

  final Map<ListModeEnum, String> modeMap = <ListModeEnum, String>{
    ListModeEnum.waterfallLarge: L10n.of(context).listmode_waterfall_large,
    ListModeEnum.waterfall: L10n.of(context).listmode_waterfall,
    ListModeEnum.grid: L10n.of(context).listmode_grid,
  };
  return SelectorItem<ListModeEnum>(
    title: _title,
    hideDivider: hideDivider,
    actionMap: modeMap,
    initVal: initMode,
    onValueChanged: onValueChanged,
  );
}
