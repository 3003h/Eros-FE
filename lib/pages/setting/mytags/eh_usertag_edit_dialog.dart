import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../index.dart';

const BorderSide _kDefaultRoundedBorderSide = BorderSide(
  color: CupertinoDynamicColor.withBrightness(
    color: Color(0x33000000),
    darkColor: Color(0x33FFFFFF),
  ),
  width: 0.0,
);
const Border _kDefaultRoundedBorder = Border(
  top: _kDefaultRoundedBorderSide,
  bottom: _kDefaultRoundedBorderSide,
  left: _kDefaultRoundedBorderSide,
  right: _kDefaultRoundedBorderSide,
);

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
  bool _defaultColor = true;
  late Color screenPickerColor;
  // Color for the picker in a dialog using onChanged.
  late Color dialogPickerColor;
  // Color for picker using the color select dialog.
  late Color dialogSelectColor;
  TextEditingController colorTextEditingController = TextEditingController();
  TextEditingController tagWeightTextEditingController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _watch = widget.usertag.watch ?? false;
    _hide = widget.usertag.hide ?? false;
    _defaultColor = widget.usertag.defaultColor ?? false;

    screenPickerColor = ColorsUtil.hexStringToColor(widget.usertag.colorCode) ??
        Colors.blue; // Material blue.
    dialogPickerColor = Colors.red; // Material red.
    dialogSelectColor = const Color(0xFFA239CA);

    colorTextEditingController.text = widget.usertag.colorCode ?? '';
    tagWeightTextEditingController.text = widget.usertag.tagWeight ?? '';

    colorTextEditingController.addListener(() {
      final colorHex = colorTextEditingController.text.trim();
      final colorInput = ColorsUtil.hexStringToColor(colorHex);
      if (colorInput != null && colorInput.value != screenPickerColor.value) {
        setState(() {
          screenPickerColor = colorInput;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    colorTextEditingController.dispose();
    tagWeightTextEditingController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorPicker = Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(L10n.of(context).tag_dialog_TagColor),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 4),
              child: Container(
                width: 100,
                child: CupertinoTextField(
                  enabled: !_defaultColor,
                  maxLines: 1,
                  textAlign: TextAlign.right,
                  controller: colorTextEditingController,
                  style: !_defaultColor
                      ? TextStyle(
                          color: ColorsUtil.isLight(screenPickerColor)
                              ? Colors.black
                              : Colors.white,
                        )
                      : null,
                  cursorColor: ColorsUtil.isLight(screenPickerColor)
                      ? Colors.black
                      : Colors.white,
                  decoration: BoxDecoration(
                    color: CupertinoDynamicColor.withBrightness(
                      color: screenPickerColor,
                      darkColor: screenPickerColor,
                    ),
                    border: _kDefaultRoundedBorder,
                    borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                  ),
                ),
              ),
            ),
          ],
        ),
        ColorPicker(
          // Use the screenPickerColor as start color.
          color: screenPickerColor,
          // Update the screenPickerColor using the callback.
          onColorChanged: (Color color) {
            setState(() {
              screenPickerColor = color;
              colorTextEditingController.text = '#${screenPickerColor.hex}';
            });
          },
          pickersEnabled: const <ColorPickerType, bool>{
            ColorPickerType.accent: false,
            ColorPickerType.primary: true,
            ColorPickerType.wheel: true,
          },
          pickerTypeLabels: <ColorPickerType, String>{
            // ColorPickerType.accent: '',
            ColorPickerType.primary: L10n.of(context).color_picker_primary,
            ColorPickerType.wheel: L10n.of(context).color_picker_wheel,
          },
          width: 36,
          height: 36,
          // heading: Text(
          //   'Select color',
          // ),
          subheading: const SizedBox(height: 26),
          // wheelSubheading: Text(
          //   'Select color and its color swatch',
          // ),
        ),
      ],
    );

    return CupertinoAlertDialog(
      title: Text(widget.usertag.title),
      content: Column(
        children: [
          Row(
            children: [
              Text(L10n.of(context).tag_dialog_Watch),
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
              Text(L10n.of(context).tag_dialog_Hide),
              const Spacer(),
              CupertinoSwitch(
                  activeColor: CupertinoColors.destructiveRed,
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(L10n.of(context).tag_dialog_tagWeight),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(left: 20, top: 4),
                child: Container(
                  width: 100,
                  child: CupertinoTextField(
                    maxLines: 1,
                    textAlign: TextAlign.right,
                    controller: tagWeightTextEditingController,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text(L10n.of(context).tag_dialog_Default_color),
              const Spacer(),
              CupertinoSwitch(
                  value: _defaultColor,
                  onChanged: (val) {
                    _defaultColor = val;
                    setState(() {});
                  }),
            ],
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: colorPicker,
            crossFadeState: _defaultColor
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: 300.milliseconds,
            secondCurve: Curves.ease,
            firstCurve: Curves.ease,
            sizeCurve: Curves.ease,
          ),
          // if (!_defaultColor) colorPicker,
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
              hide: _hide.oN,
              watch: _watch.oN,
              colorCode: (_defaultColor ? '' : screenPickerColor.hex).oN,
              tagWeight: tagWeightTextEditingController.text.trim().oN,
            ),
          ),
        ),
      ],
    );
  }
}
