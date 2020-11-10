import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
