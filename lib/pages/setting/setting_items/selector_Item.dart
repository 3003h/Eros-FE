import 'package:fehviewer/generated/l10n.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../component/setting_base.dart';

class SelectorItem<T> extends StatefulWidget {
  const SelectorItem({
    Key? key,
    required this.title,
    this.actionTitle,
    this.hideDivider = false,
    required this.actionMap,
    this.simpleActionMap,
    required this.initVal,
    this.onValueChanged,
  }) : super(key: key);
  final String title;
  final String? actionTitle;
  final bool hideDivider;
  final Map<T, String> actionMap;
  final Map<T, String>? simpleActionMap;
  final T initVal;
  final ValueChanged<T>? onValueChanged;

  @override
  _SelectorItemState<T> createState() => _SelectorItemState<T>();
}

class _SelectorItemState<T> extends State<SelectorItem<T>> {
  String selector = '';

  @override
  void initState() {
    super.initState();
    selector = widget.simpleActionMap?[widget.initVal] ??
        widget.actionMap[widget.initVal] ??
        '';
  }

  List<Widget> _getActionList() {
    return List<Widget>.from(widget.actionMap.keys.map((T element) {
      return CupertinoActionSheetAction(
          onPressed: () {
            Get.back(result: element);
          },
          child: Text(widget.actionMap[element] ?? ''));
    }).toList());
  }

  @override
  Widget build(BuildContext context) {
    Future<T?> _showDialog(BuildContext context) {
      return showCupertinoModalPopup<T>(
          context: context,
          builder: (BuildContext context) {
            final CupertinoActionSheet dialog = CupertinoActionSheet(
              title: Text(widget.actionTitle ?? widget.title),
              cancelButton: CupertinoActionSheetAction(
                  onPressed: () {
                    Get.back();
                  },
                  child: Text(L10n.of(context).cancel)),
              actions: <Widget>[
                ..._getActionList(),
              ],
            );
            return dialog;
          });
    }

    return SelectorSettingItem(
      title: widget.title,
      hideLine: widget.hideDivider,
      selector: selector,
      titleFlex: 0,
      valueFlex: 1,
      onTap: () async {
        // 显示dialog 选择选项
        final T? _result = await _showDialog(context);
        if (_result != null) {
          // 结果回调
          setState(() {
            selector = widget.simpleActionMap?[_result] ??
                widget.actionMap[_result] ??
                '';
          });
          widget.onValueChanged?.call(_result);
        }
      },
    );
  }
}
