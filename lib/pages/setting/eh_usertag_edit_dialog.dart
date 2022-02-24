import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../fehviewer.dart';

class EhUserTagEditDialog extends StatefulWidget {
  const EhUserTagEditDialog({Key? key, required this.usertag})
      : super(key: key);
  final EhUsertag usertag;

  @override
  _EhUserTagEditDialogState createState() => _EhUserTagEditDialogState();
}

class _EhUserTagEditDialogState extends State<EhUserTagEditDialog> {
  bool _watch = false;
  bool _hide = false;
  late Color screenPickerColor;
  // Color for the picker in a dialog using onChanged.
  late Color dialogPickerColor;
  // Color for picker using the color select dialog.
  late Color dialogSelectColor;

  @override
  void initState() {
    super.initState();
    _watch = widget.usertag.watch ?? false;
    _hide = widget.usertag.hide ?? false;

    screenPickerColor = ColorsUtil.hexStringToColor(widget.usertag.colorCode) ??
        Colors.blue; // Material blue.
    dialogPickerColor = Colors.red; // Material red.
    dialogSelectColor = const Color(0xFFA239CA);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text(widget.usertag.title),
      content: Column(
        children: [
          Row(
            children: [
              Text('Watch'),
              const Spacer(),
              CupertinoSwitch(
                  value: _watch,
                  onChanged: (val) {
                    if (_hide && val) {
                      _hide = false;
                    }
                    _watch = val;
                    setState(() {});
                  }),
            ],
          ),
          Row(
            children: [
              Text('Hide'),
              const Spacer(),
              CupertinoSwitch(
                  value: _hide,
                  onChanged: (val) {
                    if (_watch && val) {
                      _watch = false;
                    }
                    _hide = val;
                    setState(() {});
                  }),
            ],
          ),
          Text(screenPickerColor.hex),
          ColorPicker(
            // Use the screenPickerColor as start color.
            color: screenPickerColor,
            // Update the screenPickerColor using the callback.
            onColorChanged: (Color color) {
              setState(() {
                screenPickerColor = color;
              });
            },
            pickersEnabled: const <ColorPickerType, bool>{
              ColorPickerType.accent: false,
              ColorPickerType.primary: false,
              ColorPickerType.wheel: true,
            },
            // width: 44,
            // height: 44,
            // borderRadius: 22,
            heading: Text(
              'Select color',
            ),
            subheading: Text(
              'Select color shade',
            ),
            wheelSubheading: Text(
              'Select color and its color swatch',
            ),
            // showColorValue: true,
            // colorCodeHasColor: true,
          ),
        ],
      ),
      actions: [
        CupertinoDialogAction(
          child: Text(L10n.of(context).cancel),
          onPressed: Get.back,
        ),
        CupertinoDialogAction(
          child: Text(L10n.of(context).done),
          onPressed: () => Get.back(
            result: widget.usertag.copyWith(
              hide: _hide,
              watch: _watch,
            ),
          ),
        ),
      ],
    );
  }
}
