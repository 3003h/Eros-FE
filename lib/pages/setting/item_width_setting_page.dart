import 'package:fehviewer/common/service/ehsetting_service.dart';
import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/component/setting_base.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/pages/item/gallery_item_grid.dart';
import 'package:fehviewer/pages/item/item_base.dart';
import 'package:fehviewer/pages/setting/setting_items/selector_Item.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

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
  const ItemWidthSettingPage({super.key});

  @override
  State<ItemWidthSettingPage> createState() => _ItemWidthSettingPageState();
}

class _ItemWidthSettingPageState extends State<ItemWidthSettingPage> {
  EhSettingService get _ehSettingService => Get.find();
  late ListModeEnum selectedMode;
  late double _customWidth;
  late bool enableCustomWidth;

  @override
  void initState() {
    super.initState();
    selectedMode = _ehSettingService.listMode.value;
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
        _ehSettingService.getItemConfig(selectedMode)?.enableCustomWidth ??
            false;
    _customWidth = _ehSettingService
            .getItemConfig(selectedMode)
            ?.customWidth
            ?.toDouble() ??
        defaultWidthMap()[mode] ??
        200.0;
    logger.d('_customWidth of $mode is $_customWidth');
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        backgroundColor: CupertinoColors.systemGroupedBackground,
        navigationBar: CupertinoNavigationBar(
          middle: Text(L10n.of(context).custom_width),
        ),
        child: CustomScrollView(
          slivers: [
            SliverSafeArea(
              left: false,
              right: false,
              sliver: MultiSliver(
                children: [
                  SliverCupertinoListSection.listInsetGrouped(children: [
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
                  ]),
                  SliverCupertinoListSection.listInsetGrouped(children: [
                    CupertinoListTile(
                      title: Text(L10n.of(context).custom_width),
                      trailing: CupertinoSwitch(
                        value: enableCustomWidth,
                        onChanged: (bool val) {
                          _ehSettingService.setItemConfig(
                            selectedMode,
                            (ItemConfig itemConfig) {
                              return itemConfig.copyWith(
                                enableCustomWidth: val,
                                customWidth: _customWidth.toInt(),
                              );
                            },
                          );
                          setState(() {
                            enableCustomWidth = val;
                          });
                        },
                      ),
                    ),

                    // 滑动条
                    _WidthSlide(
                      key: ValueKey(selectedMode),
                      enable: enableCustomWidth,
                      customWidth: _customWidth.toInt(),
                      onChanged: (int val) {
                        _customWidth = val.toDouble();
                        _ehSettingService.setItemConfig(
                            selectedMode,
                            (ItemConfig itemConfig) =>
                                itemConfig.copyWith(customWidth: val));
                        setState(() {});
                      },
                    ),
                  ]),
                  ExampleView(
                    selectedMode: selectedMode,
                    customWidth: _customWidth,
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}

class _WidthSlide extends StatefulWidget {
  const _WidthSlide({
    super.key,
    required this.enable,
    required this.customWidth,
    this.onChanged,
  });

  final bool enable;
  final int customWidth;
  final ValueChanged<int>? onChanged;

  @override
  State<_WidthSlide> createState() => _WidthSlideState();
}

class _WidthSlideState extends State<_WidthSlide> {
  late double _customWidth;

  late TextEditingController textEditingController;

  static const kMaxRating = 400.0;
  static const kMinRating = 100.0;

  @override
  void initState() {
    super.initState();
    _customWidth = widget.customWidth.toDouble();

    textEditingController = TextEditingController.fromValue(
      TextEditingValue(
        text: widget.customWidth.toString(),
        selection: TextSelection.fromPosition(
          TextPosition(
            affinity: TextAffinity.downstream,
            offset: widget.customWidth.toString().length,
          ),
        ),
      ),
    );
  }

  void _onEditComplete() {
    _customWidth = _customWidth.clamp(kMinRating, kMaxRating);
    textEditingController.text = _customWidth.toInt().toString();
    setState(() {});
    widget.onChanged?.call(_customWidth.toInt());

    // close keyboard
    FocusScope.of(context).requestFocus(FocusNode());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      constraints: const BoxConstraints(minHeight: kItemHeight),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: CupertinoSlider(
                value: _customWidth,
                min: kMinRating,
                max: kMaxRating,
                activeColor: widget.enable ? null : CupertinoColors.systemGrey,
                onChanged: widget.enable
                    ? (double val) {
                        _customWidth = val;
                        textEditingController.text =
                            _customWidth.toInt().toString();
                        widget.onChanged?.call(_customWidth.toInt());
                        setState(() {});
                      }
                    : null,
                onChangeEnd: (double val) {
                  _customWidth = val;
                  textEditingController.text = _customWidth.toInt().toString();
                },
              ),
            ),
            Container(
              width: 50,
              alignment: Alignment.center,
              child: CupertinoTextField(
                textAlign: TextAlign.center,
                enabled: widget.enable,
                style: TextStyle(
                  color: widget.enable ? null : CupertinoColors.systemGrey,
                ),
                controller: textEditingController,
                keyboardType: TextInputType.number,
                onChanged: (String val) {
                  final int _val = int.parse(val);
                  _customWidth = _val.clamp(kMinRating, kMaxRating).toDouble();
                  setState(() {});
                },
                onEditingComplete: () {
                  _onEditComplete();
                },
              ),
            ),
          ],
        ),
      ),
    );
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
        return SliverPadding(
          padding: const EdgeInsets.all(EHConst.gridCrossAxisSpacing),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return const _GridItem();
              },
              childCount: kItemCount,
            ),
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: customWidth,
              childAspectRatio: EHConst.gridChildAspectRatio,
              mainAxisSpacing: 4.0,
              crossAxisSpacing: 4.0,
            ),
          ),
        );
      case ListModeEnum.waterfall:
        return WaterfallFlowViewSliver(customWidth: customWidth);
      case ListModeEnum.waterfallLarge:
        return WaterfallFlowViewSliver(
          customWidth: customWidth,
          large: true,
        );

      default:
        return const SliverToBoxAdapter(
          child: SizedBox.shrink(),
        );
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

class WaterfallFlowViewSliver extends StatelessWidget {
  const WaterfallFlowViewSliver({
    super.key,
    this.large = false,
    required this.customWidth,
  });

  final bool large;
  final double customWidth;

  @override
  Widget build(BuildContext context) {
    return SliverSafeArea(
      minimum: EdgeInsets.all(large
          ? EHConst.waterfallFlowLargeCrossAxisSpacing
          : EHConst.waterfallFlowCrossAxisSpacing),
      sliver: SliverWaterfallFlow(
        gridDelegate: SliverWaterfallFlowDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: customWidth,
          crossAxisSpacing: large
              ? EHConst.waterfallFlowLargeCrossAxisSpacing
              : EHConst.waterfallFlowCrossAxisSpacing,
          mainAxisSpacing: large
              ? EHConst.waterfallFlowLargeMainAxisSpacing
              : EHConst.waterfallFlowMainAxisSpacing,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final aspectRatio = _aspectRatioList[index];
            return _WaterfallFlowItem(
              aspectRatio: aspectRatio,
              large: large,
            );
          },
          childCount: _aspectRatioList.length,
        ),
      ),
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
              child: const Column(
                children: [
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
                child: const Column(
                  children: [
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
  required ListModeEnum initMode,
  ValueChanged<ListModeEnum>? onValueChanged,
}) {
  final String _title = L10n.of(context).list_mode;

  final Map<ListModeEnum, String> modeMap = <ListModeEnum, String>{
    ListModeEnum.waterfallLarge: L10n.of(context).listmode_waterfall_large,
    ListModeEnum.waterfall: L10n.of(context).listmode_waterfall,
    ListModeEnum.grid: L10n.of(context).listmode_grid,
  };
  return SelectorCupertinoListTile<ListModeEnum>(
    title: _title,
    actionMap: modeMap,
    initVal: initMode,
    onValueChanged: onValueChanged,
  );
}
