import 'package:collection/collection.dart';
import 'package:eros_fe/common/service/layout_service.dart';
import 'package:eros_fe/common/service/theme_service.dart';
import 'package:eros_fe/component/setting_base.dart';
import 'package:eros_fe/route/second_observer.dart';
import 'package:eros_fe/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingItems extends StatefulWidget {
  const SettingItems({
    required this.text,
    required this.icon,
    required this.route,
    this.topDivider = false,
    this.bottomDivider = true,
  });

  final String text;
  final IconData icon;
  final String route;
  final bool topDivider;
  final bool bottomDivider;

  @override
  _SettingItems createState() => _SettingItems();
}

/// 设置项
class _SettingItems extends State<SettingItems> {
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

    final Widget container = Container(
        color: _color,
        child: SafeArea(
          top: false,
          bottom: false,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (widget.topDivider) _settingItemDivider(),
              Container(
                height: 50,
                padding: const EdgeInsets.fromLTRB(16, 8, 20, 8),
                child: Row(
                  children: <Widget>[
                    Container(
//                    padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
                      child: Icon(
                        widget.icon,
                        size: 26.0,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(left: 16),
                      child: Text(widget.text),
                    ),
                    const Spacer(),
                    const Icon(
                      CupertinoIcons.forward,
                      color: CupertinoColors.systemGrey,
                    ),
                  ],
                ),
              ),
              if (widget.bottomDivider) _settingItemDivider(),
            ],
          ),
        ));

    return GestureDetector(
      child: container,
      // 不可见区域有效
      behavior: HitTestBehavior.opaque,
      onTap: () {
        loggerNoStack.t('set tap ${widget.text} ');
        if (isLayoutLarge) {
          final topRoute =
              SecondNavigatorObserver().history.lastOrNull?.settings.name;
          if (topRoute?.startsWith('/setting') ?? false) {
            Get.offNamed(widget.route, id: 2);
          } else {
            Get.toNamed(widget.route, id: 2);
          }
        } else {
          Get.toNamed(widget.route);
        }
      },
      onTapDown: (_) => _updatePressedColor(),
      onTapUp: (_) {
        Future.delayed(const Duration(milliseconds: 100), () {
          _updateNormalColor();
        });
      },
      onTapCancel: () => _updateNormalColor(),
    );
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

  /// 设置项分隔线
  Widget _settingItemDivider() {
    return Divider(
      height: 0.8,
      indent: 45.0,
      color:
          CupertinoDynamicColor.resolve(CupertinoColors.systemGrey4, context),
    );
  }
}
