import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/component/setting_base.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import 'setting_items/selector_Item.dart';

class ItemWidthSettingPage extends StatefulWidget {
  const ItemWidthSettingPage({Key? key}) : super(key: key);

  @override
  State<ItemWidthSettingPage> createState() => _ItemWidthSettingPageState();
}

class _ItemWidthSettingPageState extends State<ItemWidthSettingPage> {
  EhConfigService get _ehConfigService => Get.find();
  late ListModeEnum selectedMode;
  late double itemWidth;

  @override
  void initState() {
    super.initState();
    selectedMode = _ehConfigService.listMode.value;
    itemWidth = 200;
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
                    logger.d('listMode $val');
                    setState(() {
                      selectedMode = val;
                    });
                  },
                ),
                Obx(() => TextSwitchItem(
                      L10n.of(context).custom_width,
                      intValue: _ehConfigService.enableQRCodeCheck,
                      onChanged: (bool val) =>
                          _ehConfigService.enableQRCodeCheck = val,
                      hideDivider: false,
                    )),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  constraints: const BoxConstraints(minHeight: kItemHeight),
                  color: CupertinoDynamicColor.resolve(
                      ehTheme.itemBackgroundColor!, context),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        alignment: Alignment.center,
                        child: Text('${itemWidth.toInt()}'),
                      ),
                      Expanded(
                        child: CupertinoSlider(
                          value: itemWidth,
                          min: 100,
                          max: 300,
                          divisions: 200,
                          onChanged: (double val) {
                            setState(() {
                              itemWidth = val;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const ItemSpace(),
              ],
            ),
          ),
        ),
      );
    });
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
    ListModeEnum.waterfall: L10n.of(context).listmode_waterfall,
    ListModeEnum.waterfallLarge: L10n.of(context).listmode_waterfall_large,
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
