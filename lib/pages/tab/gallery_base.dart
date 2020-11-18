import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/models/states/ehconfig_model.dart';
import 'package:FEhViewer/utils/utility.dart';
import 'package:FEhViewer/values/const.dart';
import 'package:FEhViewer/values/theme_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

///
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
    // Global.logger.v('GalleryCatButton build');
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
    // Global.logger.v('_pressBtn ${widget.text}');
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
  const GalleryCatFilter({Key key, this.value, this.onChanged})
      : super(key: key);

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
        Global.logger.v('$catName changed to ${!value}');
        setState(() {
          catMap[catName] = !value;
          onChanged(EHUtils.convCatMapToNum(catMap));
          Global.logger.v('$catMap');
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
    return Selector<EhConfigModel, int>(
        selector: (context, EhConfigModel ehconfig) => ehconfig.catFilter,
        builder: (context, int catFilter, _) {
          return Container(
            child: GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 3.6,
              mainAxisSpacing: 4.0,
              crossAxisSpacing: 4.0,
              // physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(0.0),
              children: <Widget>[..._catButttonListWidget],
            ),
          );
        });
  }
}

class GalleryBase {
  /// 设置类型筛选
  /// 弹出toast 通过Provider 全局 维护cat的值
  Future<void> setCats(BuildContext context) async {
    return showCupertinoDialog<void>(
      context: context,
      builder: (BuildContext context) {
        // Global.logger.v('_setCats showCupertinoDialog builder');
        int _catNum =
            Provider.of<EhConfigModel>(context, listen: false).catFilter;

        return CupertinoAlertDialog(
          title: const Text('普通搜索'),
          content: Container(
            height: 180,
            child: GalleryCatFilter(
              value: _catNum,
              onChanged: (int toNum) {
                _catNum = toNum;
              },
            ),
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              child: const Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              child: const Text('确定'),
              onPressed: () {
                Provider.of<EhConfigModel>(context, listen: false).catFilter =
                    _catNum;
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

/// 列表加载异常时的默认页面
/// 包含一个点击回调 可用于触发重载
class GalleryErrorPage extends StatelessWidget {
  const GalleryErrorPage({Key key, this.onTap}) : super(key: key);
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: CupertinoButton(
        onPressed: onTap,
        child: Icon(
          FontAwesomeIcons.syncAlt,
          size: 50,
          color: CupertinoDynamicColor.resolve(
              CupertinoColors.systemGrey, context),
        ),
      ),
    );
  }
}
