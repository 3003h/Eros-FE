import 'package:eros_fe/common/service/ehsetting_service.dart';
import 'package:eros_fe/component/exception/error.dart';
import 'package:eros_fe/const/const.dart';
import 'package:eros_fe/const/theme_colors.dart';
import 'package:eros_fe/generated/l10n.dart';
import 'package:eros_fe/pages/filter/gallery_filter_view.dart';
import 'package:eros_fe/utils/logger.dart';
import 'package:eros_fe/utils/utility.dart';
import 'package:eros_fe/utils/vibrate.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

/// 筛选画廊类型的按钮
class GalleryCatButton extends StatefulWidget {
  const GalleryCatButton({
    Key? key,
    required this.value,
    required this.onChanged,
    this.onColor,
    Color? offColor,
    this.onTextColor,
    Color? offTextColor,
    required this.text,
    this.onLongPress,
  })  : offColor = offColor ?? onColor,
        offTextColor = offTextColor ?? onTextColor,
        super(key: key);

  /// 设置的值
  final bool value;

  /// 开关回调
  final ValueChanged<bool> onChanged;

  /// 长按回调
  final VoidCallback? onLongPress;

  /// 显示文本
  final String text;

  /// 开启时按钮色
  final Color? onColor;

  /// 关闭时按钮色
  final Color? offColor;

  /// 开启时文本颜色
  final Color? onTextColor;

  /// 关闭时文本颜色
  final Color? offTextColor;

  @override
  _GalleryCatButtonState createState() => _GalleryCatButtonState();
}

class _GalleryCatButtonState extends State<GalleryCatButton> {
  bool _value = false;
  Color? _textColor;
  Color? _color;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
    _textColor = _value ? widget.onTextColor : widget.offTextColor;
    _color = _value ? widget.onColor : widget.offColor;
  }

  @override
  Widget build(BuildContext context) {
    // loggerNoStack.v('GalleryCatButton build [${widget.text}] [$_value]');
    return Container(
      child: GestureDetector(
        onLongPress: _onLongPress,
        child: CupertinoButton(
          padding: const EdgeInsets.all(2.0),
          onPressed: _onPressed,
          pressedOpacity: 1.0,
          child: Text(
            widget.text,
            style: TextStyle(color: _textColor),
          ),
          color: _color,
        ),
      ),
    );
  }

  void _onLongPress() {
    vibrateUtil.medium();
    widget.onLongPress?.call();
  }

  void _onPressed() {
    // logger.t('_pressBtn ${widget.text}');
    vibrateUtil.light();
    _value = !_value;
    _textColor = _value ? widget.onTextColor : widget.offTextColor;
    _color = _value ? widget.onColor : widget.offColor;
    setState(() {
      widget.onChanged(!_value);
    });
  }
}

/// 画廊类型筛选器
/// 内含十个开关按钮 控制筛选的类型
/// 最终控制搜索的cat字段
class GalleryCatFilter extends StatefulWidget {
  const GalleryCatFilter({
    Key? key,
    required this.catNum,
    required this.onCatNumChanged,
    this.margin,
    this.padding,
    this.crossAxisCount,
    this.maxCrossAxisExtent,
  })  : assert(!(crossAxisCount == null && maxCrossAxisExtent == null)),
        super(key: key);

  final EdgeInsetsGeometry? margin;

  final EdgeInsetsGeometry? padding;

  /// cat值
  final int catNum;

  /// 值变化的回调
  final ValueChanged<int> onCatNumChanged;

  final int? crossAxisCount;

  final double? maxCrossAxisExtent;

  @override
  _GalleryCatFilterState createState() => _GalleryCatFilterState();
}

class _GalleryCatFilterState extends State<GalleryCatFilter> {
  int _catNum = 0;

  Map<String, bool> get _catMap => EHUtils.convNumToCatMap(_catNum);

  List<Widget> get _catButttonListWidget => EHConst.cats.keys
      .map((String catName) => GalleryCatButton(
            key: UniqueKey(),
            text: catName,
            onColor: ThemeColors.catColor[catName],
            onTextColor: CupertinoColors.systemGrey6,
            offColor: CupertinoColors.systemGrey4,
            offTextColor: CupertinoColors.systemGrey,
            value: _catMap[catName] ?? true,
            onChanged: (bool value) {
              logger.t('$catName changed to ${!value}');
              setState(() {
                final tempMap = _catMap;
                tempMap[catName] = !value;
                _catNum = EHUtils.convCatMapToNum(tempMap);
                widget.onCatNumChanged(_catNum);
              });
            },
            onLongPress: () {
              final tempMap = _catMap;
              final bool _selState = tempMap[catName] ?? true;
              logger.t('onLongPress [$catName] [$_selState]');

              tempMap.forEach((key, value) {
                if (key != catName) {
                  tempMap[key] = !_selState;
                }
              });

              setState(() {
                _catNum = EHUtils.convCatMapToNum(tempMap);
                widget.onCatNumChanged(_catNum);
              });
            },
          ))
      .toList();

  @override
  void initState() {
    super.initState();
    _catNum = widget.catNum;
  }

  @override
  Widget build(BuildContext context) {
    // logger.t('build GalleryCatFilter $_catNum');

    late Widget _gridView;

    if (widget.crossAxisCount == null && widget.maxCrossAxisExtent == null) {
      throw EhError(
          error: 'crossAxisCount and maxCrossAxisExtent cannot be both null');
    }

    if (widget.crossAxisCount != null) {
      _gridView = GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: widget.crossAxisCount!,
        childAspectRatio: 3.6,
        mainAxisSpacing: 4.0,
        crossAxisSpacing: 4.0,
        padding: const EdgeInsets.all(0.0),
        children: _catButttonListWidget,
      );
    } else {
      _gridView = GridView.extent(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        maxCrossAxisExtent: widget.maxCrossAxisExtent!,
        childAspectRatio: 3.6,
        mainAxisSpacing: 4.0,
        crossAxisSpacing: 4.0,
        padding: const EdgeInsets.all(0.0),
        children: _catButttonListWidget,
      );
    }

    return Container(
      margin: widget.margin,
      padding: widget.padding,
      child: _gridView,
    );
  }
}

class AdvanceSearchSwitchItem extends StatelessWidget {
  const AdvanceSearchSwitchItem({
    Key? key,
    required this.value,
    required this.onChanged,
    required this.title,
    this.expand = true,
  }) : super(key: key);

  final String title;
  final bool? value;
  final ValueChanged<bool> onChanged;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              title,
              // maxLines: 2,
              textAlign: TextAlign.start,
            ),
          ),
          // if (expand) const Spacer(),
          Container(
            alignment: Alignment.centerRight,
            child: Transform.scale(
              scale: 0.8,
              child:
                  CupertinoSwitch(value: value ?? false, onChanged: onChanged),
            ),
          ),
        ],
      ),
    );
  }
}

/// 设置类型筛选
/// 弹出toast 全局维护cat的值
Future<void> showFilterSetting() async {
  final EhSettingService _ehSettingService = Get.find();
  return showCupertinoDialog<void>(
    context: Get.overlayContext!,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return CupertinoAlertDialog(
        title: Text(L10n.of(context).search),
        content: GalleryFilterView(
          catNum: _ehSettingService.catFilter.value,
          catNumChanged: (int toNum) {
            _ehSettingService.catFilter.value = toNum;
          },
        ),
        actions: [],
      );
    },
  );
}
