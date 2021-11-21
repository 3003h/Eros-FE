import 'dart:io';

import 'package:extended_text/extended_text.dart';
import 'package:fehviewer/common/controller/user_controller.dart';
import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/common/service/dns_service.dart';
import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

const double kItemHeight = 50.0;
const double kCupertinoItemHeight = 36.0;

/// 选择类型的设置项
class SelectorSettingItem extends StatefulWidget {
  const SelectorSettingItem({
    Key? key,
    this.onTap,
    required this.title,
    this.titleColor,
    this.desc,
    this.selector,
    this.hideLine = false,
    this.onLongPress,
    this.titleFlex = 1,
    this.valueFlex = 0,
  }) : super(key: key);

  final String title;
  final String? selector;
  final String? desc;
  final bool hideLine;
  final Color? titleColor;
  final int titleFlex;
  final int valueFlex;

  // 点击回调
  final VoidCallback? onTap;

  final VoidCallback? onLongPress;

  @override
  _SelectorSettingItemState createState() => _SelectorSettingItemState();
}

class _SelectorSettingItemState extends State<SelectorSettingItem> {
  late Color _color;
  late Color _pBackgroundColor;

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
    if (_pBackgroundColor.value != color.value) {
      _color = color;
      _pBackgroundColor = color;
    }

    const _kDescStyle = TextStyle(
        fontSize: 12.5, height: 1.1, color: CupertinoColors.systemGrey);

    Widget titleWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.title,
          maxLines: 1,
          style: TextStyle(
            height: 1.0,
            color: widget.titleColor,
          ),
        ),
        if (widget.desc != null && widget.desc!.isNotEmpty)
          ExtendedText(
            widget.desc ?? '',
            maxLines: 4,
            softWrap: true,
            // overflow: TextOverflow.ellipsis,
            overflowWidget: const TextOverflowWidget(
              position: TextOverflowPosition.start,
              child: Text(
                '\u2026 ',
                style: _kDescStyle,
              ),
            ),
            // joinZeroWidthSpace: true,
            style: _kDescStyle,
          ).paddingOnly(top: 2.0),
      ],
    );

    Widget selectedWidget = Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(left: 8),
      child: Text(
        widget.selector ?? '',
        textAlign: TextAlign.right,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: CupertinoColors.systemGrey2,
        ),
      ),
    );

    final Container container = Container(
      color: _color,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            // height: kItemHeight,
            constraints: const BoxConstraints(
              minHeight: kItemHeight,
            ),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
            child: Row(
              children: <Widget>[
                Expanded(flex: widget.titleFlex, child: titleWidget),
                Expanded(flex: widget.valueFlex, child: selectedWidget),
                const Icon(
                  CupertinoIcons.forward,
                  color: CupertinoColors.systemGrey,
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
            )
          else
            Container(
              height: 0,
              color: CupertinoDynamicColor.resolve(
                  CupertinoColors.systemGrey4, context),
            ),
        ],
      ),
    );

    return GestureDetector(
      child: container,
      // 不可见区域有效
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      onTapDown: (_) => _updatePressedColor(),
      onTapUp: (_) {
        Future.delayed(const Duration(milliseconds: 80), () {
          _updateNormalColor();
        });
      },
      onTapCancel: () => _updateNormalColor(),
    );
  }

  void _updateNormalColor() {
    setState(() {
      _color =
          CupertinoDynamicColor.resolve(ehTheme.itemBackgroundColor!, context);
    });
  }

  void _updatePressedColor() {
    setState(() {
      _color =
          CupertinoDynamicColor.resolve(CupertinoColors.systemGrey4, context);
    });
  }
}

/// 开关类型
class TextSwitchItem extends StatefulWidget {
  const TextSwitchItem(
    this.title, {
    required this.intValue,
    this.onChanged,
    this.desc,
    this.descOn,
    Key? key,
    this.hideLine = false,
    this.icon,
    this.iconIndent = 0.0,
    this.suffix,
  }) : super(key: key);

  final bool? intValue;
  final ValueChanged<bool>? onChanged;
  final String title;
  final String? desc;
  final String? descOn;
  final bool hideLine;
  final Widget? icon;
  final double iconIndent;
  final Widget? suffix;

  @override
  _TextSwitchItemState createState() => _TextSwitchItemState();
}

class _TextSwitchItemState extends State<TextSwitchItem> {
  bool? _switchValue;
  String? _desc;

  void _handOnChanged() {
    if (_switchValue != null && widget.onChanged != null) {
      widget.onChanged!(_switchValue!);
    }
  }

  @override
  Widget build(BuildContext context) {
    _switchValue = _switchValue ?? widget.intValue ?? false;
    _desc = (_switchValue ?? false) ? widget.descOn : widget.desc;
    return Container(
      color:
          CupertinoDynamicColor.resolve(ehTheme.itemBackgroundColor!, context),
      child: Column(
        children: <Widget>[
          Container(
            height: kItemHeight,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: <Widget>[
                if (widget.icon != null) widget.icon!,
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        widget.title,
                        style: const TextStyle(
                          height: 1.0,
                        ),
                      ),
                      if (_desc != null || widget.desc != null)
                        Text(
                          _desc ?? widget.desc ?? '',
                          style: const TextStyle(
                              fontSize: 12.5,
                              color: CupertinoColors.systemGrey),
                        ).paddingOnly(top: 2.0),
                    ]),
                const Spacer(),
                if (widget.suffix != null) widget.suffix!,
                if (widget.onChanged != null)
                  CupertinoSwitch(
                    onChanged: (bool value) {
                      setState(() {
                        _switchValue = value;
                        _desc = value ? widget.descOn : widget.desc;
                        _handOnChanged();
                      });
                    },
                    value: _switchValue ?? false,
                  ),
              ],
            ),
          ),
          if (!widget.hideLine)
            Divider(
              indent: 20 + widget.iconIndent,
              height: 0.6,
              color: CupertinoDynamicColor.resolve(
                  CupertinoColors.systemGrey4, context),
            ),
        ],
      ),
    );
  }
}

/// 普通文本类型
class TextItem extends StatefulWidget {
  const TextItem(
    this.title, {
    this.desc,
    this.onTap,
    Key? key,
    // this.height = kItemHeight,
    this.hideLine = false,
    this.cupertinoFormRow = false,
  }) : super(key: key);

  final String title;
  final String? desc;
  final VoidCallback? onTap;
  // final double height;
  final bool hideLine;
  final bool cupertinoFormRow;

  @override
  _TextItemState createState() => _TextItemState();
}

class _TextItemState extends State<TextItem> {
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
            constraints: BoxConstraints(
                minHeight: widget.cupertinoFormRow
                    ? kCupertinoItemHeight
                    : kItemHeight),
            alignment: Alignment.centerLeft,
            padding: widget.cupertinoFormRow
                ? const EdgeInsets.all(0)
                : const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    widget.title,
                    style: const TextStyle(
                      height: 1.0,
                    ),
                  ),
                  if (widget.desc != null)
                    Text(
                      widget.desc ?? '',
                      style: const TextStyle(
                          fontSize: 12.5, color: CupertinoColors.systemGrey),
                    ).paddingOnly(top: 2.0),
                ]),
          ),
          if (!(widget.hideLine || widget.cupertinoFormRow))
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

    if (widget.cupertinoFormRow) {
      item = CupertinoFormRow(child: item);
    }

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

/// 文本输入框类型
class TextInputItem extends StatefulWidget {
  const TextInputItem({
    this.title,
    Key? key,
    this.hideLine = false,
    this.maxLines = 1,
    this.onChanged,
    this.initValue,
    this.suffixText,
    this.placeholder,
    this.icon,
    this.textAlign = TextAlign.right,
  }) : super(key: key);

  final String? title;
  final String? initValue;
  final bool hideLine;
  final ValueChanged<String>? onChanged;
  final String? suffixText;
  final String? placeholder;
  final int? maxLines;
  final Widget? icon;
  final TextAlign textAlign;

  @override
  State<TextInputItem> createState() => _TextInputItemState();
}

class _TextInputItemState extends State<TextInputItem> {
  late TextEditingController textController;

  @override
  void initState() {
    super.initState();
    textController = TextEditingController(text: widget.initValue);
    textController.addListener(() {
      widget.onChanged?.call(textController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget item = Container(
      color: CupertinoDynamicColor.resolve(
          ehTheme.itemBackgroundColor!, Get.context!),
      child: Column(
        children: <Widget>[
          Container(
            constraints: const BoxConstraints(minHeight: kItemHeight),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                if (widget.icon != null) widget.icon!,
                Text(
                  widget.title ?? '',
                  style: const TextStyle(
                    height: 1.0,
                  ),
                ),
                Expanded(
                  child: CupertinoTextField(
                    decoration: null,
                    controller: textController,
                    textAlign: widget.textAlign,
                    maxLines: widget.maxLines,
                    suffix: widget.suffixText != null
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(widget.suffixText!),
                          )
                        : null,
                    placeholderStyle: const TextStyle(
                      fontWeight: FontWeight.w400,
                      color: CupertinoColors.placeholderText,
                      height: 1.25,
                    ),
                    placeholder: widget.placeholder,
                    style: const TextStyle(height: 1.25),
                    onChanged: widget.onChanged?.call,
                  ),
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

    return item;
  }
}

Future<void> showCustomHostEditer(BuildContext context, {int? index}) async {
  final TextEditingController _hostController = TextEditingController();
  final TextEditingController _addrController = TextEditingController();
  final DnsService dnsConfigController = Get.find();
  final FocusNode _nodeAddr = FocusNode();
  return showCupertinoDialog<void>(
    context: context,
    builder: (BuildContext context) {
      final bool _isAddNew = index == null;
      if (!_isAddNew) {
        _hostController.text = dnsConfigController.hosts[index].host ?? '';
        _addrController.text = dnsConfigController.hosts[index].addr ?? '';
      }

      return CupertinoAlertDialog(
        content: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CupertinoTextField(
                decoration: BoxDecoration(
                  color: ehTheme.textFieldBackgroundColor,
                  borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                ),
                enabled: _isAddNew,
                clearButtonMode: _isAddNew
                    ? OverlayVisibilityMode.editing
                    : OverlayVisibilityMode.never,
                controller: _hostController,
                placeholder: 'Host',
                autofocus: _isAddNew,
                onEditingComplete: () {
                  // 点击键盘完成
                  FocusScope.of(context).requestFocus(_nodeAddr);
                },
              ),
              Container(
                height: 10,
              ),
              CupertinoTextField(
                decoration: BoxDecoration(
                  color: ehTheme.textFieldBackgroundColor,
                  borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                ),
                clearButtonMode: OverlayVisibilityMode.editing,
                controller: _addrController,
                placeholder: 'Addr',
                focusNode: _nodeAddr,
                autofocus: !_isAddNew,
                onEditingComplete: () {
                  // 点击键盘完成
                  if (dnsConfigController.addCustomHost(
                      _hostController.text.trim(), _addrController.text.trim()))
                    Get.back();
                },
              ),
            ],
          ),
        ),
        actions: <Widget>[
          CupertinoDialogAction(
            child: Text(L10n.of(context).cancel),
            onPressed: () {
              Get.back();
            },
          ),
          CupertinoDialogAction(
            child: Text(L10n.of(context).ok),
            onPressed: () {
              if (dnsConfigController.addCustomHost(
                  _hostController.text.trim(), _addrController.text.trim()))
                Get.back();
            },
          ),
        ],
      );
    },
  );
}

Future<void> showUserCookie() async {
  final List<String> _c = Global.profile.user.cookie?.split(';') ?? [];

  final List<Cookie> _cookies =
      _c.map((e) => Cookie.fromSetCookieValue(e)).toList();

  final String _cookieString =
      _cookies.map((e) => '${e.name}=${e.value}').join('\n');
  logger.d('$_cookieString ');

  return showCupertinoDialog<void>(
    context: Get.context!,
    builder: (BuildContext context) {
      return CupertinoAlertDialog(
        title: const Text('Cookie'),
        content: Container(
          child: Column(
            children: [
              Text(
                L10n.of(context).KEEP_IT_SAFE,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ).paddingOnly(bottom: 4),
              CupertinoFormSection.insetGrouped(
                margin: const EdgeInsetsDirectional.fromSTEB(0, 0.0, 0, 5.0),
                backgroundColor: Colors.transparent,
                children: _cookies
                    .map((e) => CupertinoTextFormFieldRow(
                          prefix: Text(
                            e.name,
                            style: const TextStyle(fontSize: 14),
                          ),
                          style: const TextStyle(fontSize: 14),
                          initialValue: e.value,
                          readOnly: true,
                          maxLines: 2,
                          minLines: 1,
                          textAlign: TextAlign.right,
                        ))
                    .toList(),
              ),
            ],
          ).paddingSymmetric(vertical: 8),
        ),
        actions: <Widget>[
          CupertinoDialogAction(
            child: Text(L10n.of(context).cancel),
            onPressed: () {
              Get.back();
            },
          ),
          CupertinoDialogAction(
            child: Text(L10n.of(context).copy),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: _cookieString));
              Get.back();
              showToast(L10n.of(context).copied_to_clipboard);
            },
          ),
        ],
      );
    },
  );
}
