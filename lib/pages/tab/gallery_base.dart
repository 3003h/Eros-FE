import 'package:FEhViewer/models/states/ehconfig_model.dart';
import 'package:FEhViewer/utils/utility.dart';
import 'package:FEhViewer/values/const.dart';
import 'package:FEhViewer/values/theme_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  })  : offColor = offColor ?? onColor,
        offTextColor = offTextColor ?? onTextColor,
        super(key: key);

  final bool value;
  final ValueChanged<bool> onChanged;
  final String text;
  final Color onColor;
  final Color offColor;
  final Color onTextColor;
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

class GalleryCatFilter extends StatefulWidget {
  const GalleryCatFilter({Key key, this.value, this.onChanged})
      : super(key: key);

  final int value;
  final ValueChanged<int> onChanged;

  @override
  _GalleryCatFilterState createState() => _GalleryCatFilterState();
}

class _GalleryCatFilterState extends State<GalleryCatFilter> {
  int _catNum;
  Map<String, bool> _catMap;
  final List<Widget> _catButttonListWidget = <Widget>[];

  Widget _getCatButton({@required String catName}) {
    return GalleryCatButton(
      text: catName,
      onChanged: (bool value) {
        // Global.logger.v('$catName changed to ${!value}');
        setState(() {
          _catMap[catName] = !value;
          widget.onChanged(EHUtils.convCatMapToNum(_catMap));
          // Global.logger.v('$_catMap');
        });
      },
      onColor: ThemeColors.catColor[catName]['color'],
      offColor: CupertinoColors.systemGrey4,
      offTextColor: CupertinoColors.systemGrey,
      value: _catMap[catName],
    );
  }

  @override
  void initState() {
    super.initState();
    _catNum = widget.value;
    _catMap = EHUtils.convNumToCatMap(_catNum);

    for (final String cat in EHConst.cats.keys) {
      _catButttonListWidget.add(_getCatButton(catName: cat));
    }
  }

  @override
  Widget build(BuildContext context) {
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
  }
}

class GalleryBase {
  /// 设置类型筛选
  Future<void> setCats(BuildContext context) async {
    return showCupertinoDialog<void>(
      context: context,
      builder: (BuildContext context) {
        // Global.logger.v('_setCats showCupertinoDialog builder');
        int _catNum =
            Provider.of<EhConfigModel>(context, listen: false).catFilter;

        return CupertinoAlertDialog(
          title: const Text('过滤类型'),
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
