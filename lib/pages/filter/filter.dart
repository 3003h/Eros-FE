import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/const/theme_colors.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/pages/filter/gallery_filter_view.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/utility.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 筛选画廊类型的按钮
class GalleryCatButton extends StatefulWidget {
  const GalleryCatButton({
    Key key,
    @required this.value,
    @required this.onChanged,
    @required this.onColor,
    Color offColor,
    this.onTextColor,
    Color offTextColor,
    @required this.text,
    this.onLongPress,
  })  : offColor = offColor ?? onColor,
        offTextColor = offTextColor ?? onTextColor,
        super(key: key);

  /// 设置的值
  final bool value;

  /// 开关回调
  final ValueChanged<bool> onChanged;

  /// 长按回调
  final VoidCallback onLongPress;

  /// 显示文本
  final String text;

  /// 开启时按钮色
  final Color onColor;

  /// 关闭时按钮色
  final Color offColor;

  /// 开启时文本颜色
  final Color onTextColor;

  /// 关闭时文本颜色
  final Color offTextColor;

  @override
  _GalleryCatButtonState createState() => _GalleryCatButtonState();
}

class _GalleryCatButtonState extends State<GalleryCatButton> {
  bool _value;
  Color _textColor;
  Color _color;

  @override
  Widget build(BuildContext context) {
    // logger.v('GalleryCatButton build');
    return Container(
      child: GestureDetector(
        onLongPress: () => widget.onLongPress(),
        child: CupertinoButton(
          padding: const EdgeInsets.all(0.0),
          onPressed: _pressBtn,
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

  void _pressBtn() {
    // logger.v('_pressBtn ${widget.text}');
    _value = !_value;
    _textColor = _value ? widget.onTextColor : widget.offTextColor;
    _color = _value ? widget.onColor : widget.offColor;
    setState(() {
      widget.onChanged(!_value);
    });
  }

  @override
  void initState() {
    super.initState();
    _value = widget.value;
    _textColor = _value ? widget.onTextColor : widget.offTextColor;
    _color = _value ? widget.onColor : widget.offColor;
  }
}

/// 画廊类型筛选器
/// 内含十个开关按钮 控制筛选的类型
/// 最终控制搜索的cat字段
class GalleryCatFilter extends StatefulWidget {
  const GalleryCatFilter(
      {Key key, this.value, this.onChanged, this.margin, this.padding})
      : super(key: key);

  final EdgeInsetsGeometry margin;

  final EdgeInsetsGeometry padding;

  /// cat值
  final int value;

  /// 值变化的回调
  final ValueChanged<int> onChanged;

  @override
  _GalleryCatFilterState createState() => _GalleryCatFilterState();
}

class _GalleryCatFilterState extends State<GalleryCatFilter> {
  int _catNum;
  Map<String, bool> _catMap;
  final List<Widget> _catButttonListWidget = <Widget>[];

  Widget _getCatButton(
      {@required String catName,
      Map<String, bool> catMap,
      ValueChanged<int> onChanged}) {
    return GalleryCatButton(
      text: catName,
      onChanged: (bool value) {
        logger.v('$catName changed to ${!value}');
        setState(() {
          catMap[catName] = !value;
          onChanged(EHUtils.convCatMapToNum(catMap));
          // logger.v('$catMap');
        });
      },
      onColor: ThemeColors.catColor[catName],
      onTextColor: CupertinoColors.systemGrey6,
      offColor: CupertinoColors.systemGrey4,
      offTextColor: CupertinoColors.systemGrey,
      value: catMap[catName],
    );
  }

  @override
  void initState() {
    super.initState();
    _catNum = widget.value;
    _catMap = EHUtils.convNumToCatMap(_catNum);

    for (final String cat in EHConst.cats.keys) {
      _catButttonListWidget.add(
        _getCatButton(
          catName: cat,
          catMap: _catMap,
          onChanged: widget.onChanged,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin,
      padding: widget.padding,
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        childAspectRatio: 3.6,
        mainAxisSpacing: 4.0,
        crossAxisSpacing: 4.0,
        padding: const EdgeInsets.all(0.0),
        children: <Widget>[..._catButttonListWidget],
      ),
    );
  }
}

class AdvanceSearchSwitchItem extends StatelessWidget {
  const AdvanceSearchSwitchItem(
      {Key key, this.value, this.onChanged, this.title, this.expand = true})
      : super(key: key);

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: <Widget>[
          Text(title),
          if (expand) const Spacer(),
          Transform.scale(
            scale: 0.8,
            child: CupertinoSwitch(value: value, onChanged: onChanged),
          ),
        ],
      ),
    );
  }
}

/// 设置类型筛选
/// 弹出toast 全局维护cat的值
Future<void> showFilterSetting() async {
  final EhConfigService ehConfigService = Get.find();
  return showCupertinoModalPopup<void>(
    context: Get.overlayContext,
    builder: (BuildContext context) {
      return CupertinoAlertDialog(
        title: Text(S.of(context).search),
        content: GalleryFilterView(
          catNum: ehConfigService.catFilter.value,
          catNumChanged: (int toNum) {
            ehConfigService.catFilter.value = toNum;
          },
        ),
        // actions: <Widget>[
        //   CupertinoDialogAction(
        //     child: Text(S.of(context).ok),
        //     onPressed: () {
        //       Get.back();
        //     },
        //   ),
        // ],
        actions: [],
      );
    },
  );
}
