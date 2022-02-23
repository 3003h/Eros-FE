import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/component/setting_base.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserTagItem extends StatefulWidget {
  const UserTagItem({
    Key? key,
    required this.title,
    this.desc,
    this.onTap,
    this.hideLine = false,
    this.tagColor,
    this.borderColor,
    this.inerTextColor,
  }) : super(key: key);

  final String title;
  final String? desc;
  final VoidCallback? onTap;
  final Color? tagColor;
  final Color? borderColor;
  final Color? inerTextColor;

  final bool hideLine;

  @override
  _UserTagItemState createState() => _UserTagItemState();
}

class _UserTagItemState extends State<UserTagItem> {
  Color? _color;
  Color? _pBackgroundColor;

  @override
  void initState() {
    super.initState();
    _color = CupertinoDynamicColor.resolve(
        ehTheme.itemBackgroundColor!, Get.context!);
    _pBackgroundColor = _color;
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
      color: _color,
      child: Column(
        children: <Widget>[
          Container(
            constraints: const BoxConstraints(minHeight: kItemHeight),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: widget.tagColor ?? Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      width: 0.5,
                      color: Colors.black45,
                    ),
                  ),
                  // width: 30,
                  // height: 24,
                  child: Text(
                    'T',
                    style: TextStyle(
                      color: widget.inerTextColor,
                      height: 1.25,
                      // fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          widget.title,
                          style: const TextStyle(
                            height: 1.0,
                            fontSize: 15,
                          ),
                        ),
                        if (widget.desc != null)
                          Text(
                            widget.desc ?? '',
                            style: const TextStyle(
                                fontSize: 12.5,
                                color: CupertinoColors.systemGrey),
                          ).paddingOnly(top: 2.0),
                      ]),
                ),
              ],
            ),
          ),
          if (!widget.hideLine)
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

  void _updateNormalColor() {
    setState(() {
      _color = CupertinoDynamicColor.resolve(
          ehTheme.itemBackgroundColor!, Get.context!);
    });
  }

  void _updatePressedColor() {
    setState(() {
      _color =
          CupertinoDynamicColor.resolve(CupertinoColors.systemGrey4, context);
    });
  }
}
