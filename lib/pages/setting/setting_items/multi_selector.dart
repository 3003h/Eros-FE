import 'package:eros_fe/common/service/theme_service.dart';
import 'package:eros_fe/utils/vibrate.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';

import '../../../component/setting_base.dart';

class MultiSelectorPage extends StatelessWidget {
  const MultiSelectorPage({Key? key, this.title}) : super(key: key);
  final String? title;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(title ?? ''),
        // previousPageTitle: previousPageTitle,
      ),
      child: Container(),
    );
  }
}

class MultiSelectorGroup extends StatefulWidget {
  const MultiSelectorGroup({
    Key? key,
    required this.selectorMap,
    this.initValue,
    this.onValueChanged,
  }) : super(key: key);
  final Map<String, SingleSelectItemBean> selectorMap;
  final List<bool>? initValue;
  final ValueChanged<Map<String, SingleSelectItemBean>>? onValueChanged;

  @override
  State<MultiSelectorGroup> createState() => _MultiSelectorGroupState();
}

class _MultiSelectorGroupState extends State<MultiSelectorGroup> {
  Map<String, SingleSelectItemBean> valueMap = {};

  List<MapEntry<String, SingleSelectItemBean>> get selectorTitleList =>
      valueMap.entries.toList();

  @override
  void initState() {
    super.initState();
    valueMap = widget.selectorMap;
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 220,
          childAspectRatio: 4.5,
        ),
        itemCount: selectorTitleList.length,
        itemBuilder: (context, index) {
          final select = selectorTitleList[index];
          final _title = select.value.title;
          final _enable = select.value.enable ?? false;
          return SingleSelectItem(
            title: _title,
            enable: _enable,
            onChanged: (val) {
              vibrateUtil.light();
              setState(() {
                valueMap[select.key] =
                    SingleSelectItemBean(title: _title, enable: val);
                widget.onValueChanged?.call(valueMap);
              });
            },
            expand: true,
            // showLine: index < selectorTitleList.length - 1,
            onTap: () {
              vibrateUtil.light();
              setState(() {
                valueMap[select.key] =
                    SingleSelectItemBean(title: _title, enable: !_enable);
                widget.onValueChanged?.call(valueMap);
              });
            },
          );
        });
    //
    // return ListView.builder(
    //   physics: const NeverScrollableScrollPhysics(),
    //   shrinkWrap: true,
    //   itemBuilder: (context, index) {
    //     final select = selectorTitleList[index];
    //     final _title = select.value.title;
    //     final _enable = select.value.enable ?? false;
    //     return SingleSelectItem(
    //       title: _title,
    //       enable: _enable,
    //       showLine: index < selectorTitleList.length - 1,
    //       onTap: () {
    //         setState(() {
    //           valueMap[select.key] =
    //               SingleSelectItemBean(title: _title, enable: !_enable);
    //           widget.onValueChanged?.call(valueMap);
    //         });
    //       },
    //     );
    //   },
    //   itemCount: selectorTitleList.length,
    // );
  }
}

class SingleSelectItemBean {
  const SingleSelectItemBean({this.title, this.enable});
  final String? title;
  final bool? enable;

  @override
  String toString() {
    return 'SingleSelectItemBean{title: $title, enable: $enable}';
  }
}

class SingleSelectItem extends StatefulWidget {
  const SingleSelectItem({
    Key? key,
    this.title,
    this.onTap,
    this.enable = false,
    this.showLine = true,
    this.expand = false,
    this.onChanged,
  }) : super(key: key);
  final String? title;
  final bool enable;
  final VoidCallback? onTap;
  final bool showLine;
  final bool expand;
  final ValueChanged<bool>? onChanged;

  @override
  State<SingleSelectItem> createState() => _SingleSelectItemState();
}

class _SingleSelectItemState extends State<SingleSelectItem> {
  Color? _color;
  Color? _pBackgroundColor;

  @override
  void initState() {
    super.initState();
    _color =
        CupertinoDynamicColor.resolve(ehTheme.itemBackgroundColor!, context);
    _pBackgroundColor = _color;
  }

  void _updateNormalColor() {
    setState(() {
      _color = CupertinoDynamicColor.resolve(
          ehTheme.itemBackgroundColor!, Get.context!);
    });
  }

  void _updatePressedColor() {
    setState(() {
      _color = getPressedColor(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color color =
        CupertinoDynamicColor.resolve(ehTheme.itemBackgroundColor!, context);
    if (_pBackgroundColor?.value != color.value) {
      _color = color;
      _pBackgroundColor = color;
    }

    Widget item = Container(
      constraints: !widget.expand
          ? const BoxConstraints(
              minHeight: kItemHeight,
            )
          : null,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 20, right: 26),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: [
                Text(
                  widget.title ?? '',
                  style: const TextStyle(
                    height: 1.0,
                  ),
                ),
                const Spacer(),
                Card(
                  color: Colors.transparent,
                  shadowColor: Colors.transparent,
                  child: Theme(
                    data: ThemeData(
                      // 去掉水波纹效果
                      splashColor: Colors.transparent,
                      // 去掉点击效果
                      highlightColor: Colors.transparent,
                    ),
                    child: GFCheckbox(
                      size: 24.0,
                      activeBgColor: GFColors.DANGER,
                      inactiveBgColor: Colors.transparent,
                      activeBorderColor: GFColors.DANGER,
                      inactiveBorderColor: CupertinoDynamicColor.resolve(
                          CupertinoColors.label, context),
                      type: GFCheckboxType.circle,
                      onChanged: widget.onChanged?.call,
                      value: widget.enable,
                      inactiveIcon: null,
                    ),
                  ),
                ),
              ],
            ),
          ]),
    );

    item = Container(
      color: _color,
      child: Column(
        children: <Widget>[
          if (widget.expand)
            Expanded(
              child: item,
            )
          else
            item,
          if (widget.showLine)
            Divider(
              indent: 20,
              height: 0.6,
              color: CupertinoDynamicColor.resolve(
                  CupertinoColors.systemGrey4, context),
            ),
        ],
      ),
    );

    item = GestureDetector(
      child: item,
      behavior: HitTestBehavior.translucent,
      onTap: widget.onTap,
      onTapDown: (_) => _updatePressedColor(),
      onTapUp: (_) {
        Future.delayed(const Duration(milliseconds: 100), () {
          _updateNormalColor();
        });
      },
      onTapCancel: () => _updateNormalColor(),
    );

    return item;
  }
}
