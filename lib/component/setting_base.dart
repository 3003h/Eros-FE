import 'dart:io';

import 'package:eros_fe/common/service/dns_service.dart';
import 'package:eros_fe/common/service/theme_service.dart';
// import 'package:extended_text/extended_text.dart';
import 'package:eros_fe/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

const double kItemHeight = 50.0;
const double kCupertinoItemHeight = 36.0;

const double kDividerHeight = 1.0;

const double kSummaryFontSize = 12.0;

Color getPressedColor(BuildContext context) {
  return CupertinoDynamicColor.resolve(CupertinoColors.systemGrey5, context);
}

class BarsItem extends StatelessWidget {
  const BarsItem({
    Key? key,
    required this.title,
    this.maxLines = 1,
    this.titleSize,
    this.descSize,
    this.desc,
    this.hideDivider = false,
  }) : super(key: key);

  final String title;
  final String? desc;
  final int? maxLines;
  final double? titleSize;
  final double? descSize;
  final bool hideDivider;

  @override
  Widget build(BuildContext context) {
    const _kDescStyle = TextStyle(
        fontSize: kSummaryFontSize,
        height: 1.1,
        color: CupertinoColors.systemGrey);

    return Column(
      children: [
        Container(
          color: CupertinoDynamicColor.resolve(
              ehTheme.itemBackgroundColor!, context),
          constraints: const BoxConstraints(
            minHeight: kItemHeight,
          ),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        maxLines: maxLines,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          height: 1.2,
                        ).copyWith(fontSize: titleSize),
                      ),
                      if (desc != null && desc!.isNotEmpty)
                        Text(
                          desc ?? '',
                          maxLines: null,
                          style: _kDescStyle,
                        ).paddingOnly(top: 6.0)
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  CupertinoIcons.bars,
                  color: CupertinoColors.systemGrey,
                ),
              ],
            ),
          ),
        ),
        Divider(
          indent: 20,
          height: kDividerHeight,
          color: hideDivider
              ? Colors.transparent
              : CupertinoDynamicColor.resolve(
                  CupertinoColors.systemGrey4, context),
        ),
      ],
    );
  }
}

/// 选择类型的设置项
class SelectorSettingItem extends StatefulWidget {
  const SelectorSettingItem({
    Key? key,
    this.onTap,
    required this.title,
    this.titleColor,
    this.desc,
    this.selector,
    this.hideDivider = false,
    this.onLongPress,
    this.titleFlex = 1,
    this.valueFlex = 0,
    this.maxLines = 1,
    this.suffix,
  }) : super(key: key);

  final String title;
  final String? selector;
  final String? desc;
  final bool hideDivider;
  final Color? titleColor;
  final int titleFlex;
  final int valueFlex;
  final int maxLines;
  final Widget? suffix;

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
        fontSize: kSummaryFontSize,
        height: 1.1,
        color: CupertinoColors.systemGrey);

    Widget titleWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.title,
          // maxLines: widget.maxLines,
          // overflow: TextOverflow.ellipsis,
          softWrap: true,
          style: TextStyle(
            height: 1.2,
            color: widget.titleColor,
          ),
        ),
        if (widget.desc != null && widget.desc!.isNotEmpty)
          Text(
            widget.desc ?? '',
            maxLines: null,
            style: _kDescStyle,
          ).paddingOnly(top: 2.0),
      ],
    );

    Widget selectedWidget = Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(left: 8),
      child: Text(
        widget.selector ?? '',
        textAlign: TextAlign.center,
        // overflow: TextOverflow.ellipsis,
        // softWrap: true,
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
            constraints: const BoxConstraints(
              minHeight: kItemHeight,
            ),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
            child: SafeArea(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(flex: widget.titleFlex, child: titleWidget),
                        if (widget.suffix != null) widget.suffix!,
                        Expanded(flex: widget.valueFlex, child: selectedWidget),
                      ],
                    ),
                  ),
                  const Icon(
                    CupertinoIcons.forward,
                    color: CupertinoColors.systemGrey,
                  ),
                ],
              ),
            ),
          ),
          if (!widget.hideDivider)
            Divider(
              indent: 20,
              height: kDividerHeight,
              color: CupertinoDynamicColor.resolve(
                  CupertinoColors.systemGrey4, context),
            )
          else
            Container(
              height: kDividerHeight,
              color: Colors.transparent,
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
      _color = getPressedColor(context);
    });
  }
}

/// 类型
class SlidingSegmentedItem<T> extends StatefulWidget {
  const SlidingSegmentedItem(
    this.title, {
    required this.intValue,
    required this.slidingChildren,
    this.onValueChanged,
    this.desc,
    Key? key,
    this.hideDivider = false,
    this.icon,
    this.iconIndent = 0.0,
    this.onTap,
  }) : super(key: key);

  final T? intValue;
  final ValueChanged<T?>? onValueChanged;
  final Map<T, Widget> slidingChildren;
  final String title;
  final String? desc;
  final bool hideDivider;
  final Widget? icon;
  final double iconIndent;
  // 点击回调
  final VoidCallback? onTap;

  @override
  _SlidingSegmentedItemState<T> createState() =>
      _SlidingSegmentedItemState<T>();
}

class _SlidingSegmentedItemState<T> extends State<SlidingSegmentedItem<T>> {
  String? _desc;

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
    T _value = widget.intValue ?? widget.slidingChildren.keys.first;

    final Color color =
        CupertinoDynamicColor.resolve(ehTheme.itemBackgroundColor!, context);
    if (_pBackgroundColor.value != color.value) {
      _color = color;
      _pBackgroundColor = color;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onTapDown: widget.onTap != null ? (_) => _updatePressedColor() : null,
      onTapUp: (_) {
        Future.delayed(const Duration(milliseconds: 80), () {
          _updateNormalColor();
        });
      },
      child: Container(
        color: _color,
        child: Column(
          children: <Widget>[
            Container(
              constraints: const BoxConstraints(
                minHeight: kItemHeight,
              ),
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: SafeArea(
                child: Row(
                  children: <Widget>[
                    if (widget.icon != null) widget.icon!,
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              widget.title,
                              style: const TextStyle(
                                height: 1.15,
                              ),
                            ),
                            if (_desc != null || widget.desc != null)
                              Text(
                                _desc ?? widget.desc ?? '',
                                style: const TextStyle(
                                    fontSize: kSummaryFontSize,
                                    color: CupertinoColors.systemGrey),
                              ).paddingOnly(top: 2.0),
                          ]),
                    ),
                    CupertinoSlidingSegmentedControl<T>(
                      groupValue: _value,
                      children: widget.slidingChildren,
                      onValueChanged: (T? val) {
                        widget.onValueChanged?.call(val);
                      },
                    ),
                    if (widget.onTap != null)
                      const Icon(
                        CupertinoIcons.forward,
                        color: CupertinoColors.systemGrey,
                      ),
                  ],
                ),
              ),
            ),
            if (!widget.hideDivider)
              Divider(
                indent: 20 + widget.iconIndent,
                height: kDividerHeight,
                color: CupertinoDynamicColor.resolve(
                    CupertinoColors.systemGrey4, context),
              ),
          ],
        ),
      ),
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
      _color = getPressedColor(context);
    });
  }
}

/// 开关类型
class TextSwitchItem extends StatefulWidget {
  const TextSwitchItem(
    this.title, {
    required this.value,
    this.onChanged,
    this.desc,
    this.descOn,
    Key? key,
    this.hideDivider = false,
    this.icon,
    this.iconIndent = 0.0,
    this.suffix,
    this.onTap,
  }) : super(key: key);

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String title;
  final String? desc;
  final String? descOn;
  final bool hideDivider;
  final Widget? icon;
  final double iconIndent;
  final Widget? suffix;
  // 点击回调
  final VoidCallback? onTap;

  @override
  _TextSwitchItemState createState() => _TextSwitchItemState();
}

class _TextSwitchItemState extends State<TextSwitchItem> {
  late bool _switchValue;
  String? _desc;

  late Color _color;
  late Color _pBackgroundColor;

  @override
  void initState() {
    super.initState();
    _switchValue = widget.value;

    _color = CupertinoDynamicColor.resolve(
        ehTheme.itemBackgroundColor!, Get.context!);
    _pBackgroundColor = _color;
  }

  @override
  Widget build(BuildContext context) {
    _desc = _switchValue ? widget.descOn : widget.desc;

    final Color color =
        CupertinoDynamicColor.resolve(ehTheme.itemBackgroundColor!, context);
    if (_pBackgroundColor.value != color.value) {
      _color = color;
      _pBackgroundColor = color;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onTapDown: widget.onTap != null ? (_) => _updatePressedColor() : null,
      onTapUp: (_) {
        Future.delayed(const Duration(milliseconds: 80), () {
          _updateNormalColor();
        });
      },
      child: Container(
        color: _color,
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Container(
                constraints: const BoxConstraints(
                  minHeight: kItemHeight,
                ),
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: <Widget>[
                    if (widget.icon != null) widget.icon!,
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              widget.title,
                              style: const TextStyle(
                                height: 1.15,
                              ),
                            ),
                            if (_desc != null || widget.desc != null)
                              Text(
                                _desc ?? widget.desc ?? '',
                                style: const TextStyle(
                                    fontSize: kSummaryFontSize,
                                    color: CupertinoColors.systemGrey),
                              ).paddingOnly(top: 2.0),
                          ]),
                    ),
                    if (widget.suffix != null) widget.suffix!,
                    CupertinoSwitch(
                      onChanged: widget.onChanged != null
                          ? (bool value) {
                              setState(() {
                                _switchValue = value;
                                widget.onChanged?.call(value);
                              });
                            }
                          : null,
                      value: _switchValue,
                    ),
                    if (widget.onTap != null)
                      const Icon(
                        CupertinoIcons.forward,
                        color: CupertinoColors.systemGrey,
                      ),
                  ],
                ),
              ),
              if (!widget.hideDivider)
                Divider(
                  indent: 20 + widget.iconIndent,
                  height: kDividerHeight,
                  color: CupertinoDynamicColor.resolve(
                      CupertinoColors.systemGrey4, context),
                ),
            ],
          ),
        ),
      ),
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
      _color = getPressedColor(context);
    });
  }
}

/// 普通文本类型
class TextItem extends StatefulWidget {
  const TextItem(
    this.title, {
    this.subTitle,
    this.onTap,
    Key? key,
    this.hideDivider = false,
    this.cupertinoFormRow = false,
    this.textColor,
  }) : super(key: key);

  final String title;
  final String? subTitle;
  final VoidCallback? onTap;

  final bool hideDivider;
  final bool cupertinoFormRow;
  final Color? textColor;

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
            child: SafeArea(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      widget.title,
                      style: TextStyle(
                        height: 1.0,
                        color: widget.textColor,
                      ),
                    ),
                    if (widget.subTitle != null)
                      Text(
                        widget.subTitle ?? '',
                        style: const TextStyle(
                            fontSize: kSummaryFontSize,
                            color: CupertinoColors.systemGrey),
                      ).paddingOnly(top: 2.0),
                  ]),
            ),
          ),
          if (!(widget.hideDivider || widget.cupertinoFormRow))
            Divider(
              indent: 20,
              height: kDividerHeight,
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
      _color = getPressedColor(context);
    });
  }
}

/// 文本输入框类型
class TextInputItem extends StatefulWidget {
  const TextInputItem({
    this.title,
    Key? key,
    this.hideDivider = false,
    this.maxLines = 1,
    this.onChanged,
    this.initValue,
    this.suffixText,
    this.placeholder,
    this.icon,
    this.textAlign = TextAlign.right,
    this.textFieldPadding = const EdgeInsets.all(6.0),
    this.textController,
    this.obscureText,
    this.keyboardType,
  }) : super(key: key);

  final String? title;
  final String? initValue;
  final bool hideDivider;
  final ValueChanged<String>? onChanged;
  final String? suffixText;
  final String? placeholder;
  final int? maxLines;
  final Widget? icon;
  final TextAlign textAlign;
  final EdgeInsetsGeometry textFieldPadding;
  final TextEditingController? textController;
  final bool? obscureText;
  final TextInputType? keyboardType;

  @override
  State<TextInputItem> createState() => _TextInputItemState();
}

class _TextInputItemState extends State<TextInputItem> {
  late TextEditingController textController;

  @override
  void initState() {
    super.initState();
    if (widget.textController != null) {
      textController = widget.textController!;
      textController.text = widget.initValue ?? '';
    } else {
      textController = TextEditingController(text: widget.initValue);
    }
    // textController.addListener(() {
    //   widget.onChanged?.call(textController.text);
    // });
  }

  @override
  Widget build(BuildContext context) {
    Widget item = Obx(() {
      return Container(
        color: CupertinoDynamicColor.resolve(
            ehTheme.itemBackgroundColor!, Get.context!),
        child: SafeArea(
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
                        height: 1.2,
                      ),
                    ),
                    Expanded(
                      child: CupertinoTextField(
                        decoration: null,
                        padding: widget.textFieldPadding,
                        controller: textController,
                        obscureText: widget.obscureText ?? false,
                        keyboardType: widget.keyboardType,
                        textAlign: widget.textAlign,
                        maxLines: widget.maxLines,
                        suffix: widget.suffixText != null
                            ? Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Text(widget.suffixText!),
                              )
                            : null,
                        placeholderStyle: const TextStyle(
                          fontWeight: FontWeight.w400,
                          color: CupertinoColors.placeholderText,
                          height: 1.25,
                        ),
                        placeholder: widget.placeholder,
                        style: const TextStyle(height: 1.2),
                        onChanged: widget.onChanged?.call,
                      ),
                    ),
                  ],
                ),
              ),
              if (!widget.hideDivider)
                Divider(
                  indent: 20,
                  height: kDividerHeight,
                  color: CupertinoDynamicColor.resolve(
                      CupertinoColors.systemGrey4, context),
                ),
            ],
          ),
        ),
      );
    });

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
  final List<String> _c = Global.profile.user.cookie.split(';');

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

class ItemSpace extends StatelessWidget {
  const ItemSpace({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 38);
  }
}

class GroupItem extends StatelessWidget {
  const GroupItem({Key? key, this.title, this.child, this.desc, this.descTop})
      : super(key: key);
  final String? title;
  final Widget? child;
  final String? desc;
  final String? descTop;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        SafeArea(
          child: Container(
            padding: EdgeInsets.only(
              left: 20,
              bottom: 4,
              top: title != null ? 20 : 0,
            ),
            width: double.infinity,
            child: Text(
              title ?? '',
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.start,
            ),
          ),
        ),
        if (descTop != null)
          SafeArea(
            child: Container(
              padding: const EdgeInsets.only(
                left: 20,
                top: 4,
                bottom: 10,
                right: 20,
              ),
              width: double.infinity,
              child: Text(
                descTop!,
                style: TextStyle(
                  fontSize: kSummaryFontSize,
                  color: CupertinoDynamicColor.resolve(
                      CupertinoColors.secondaryLabel, context),
                ),
                textAlign: TextAlign.start,
              ),
            ),
          ),
        child ?? const SizedBox.shrink(),
        if (desc != null)
          SafeArea(
            child: Container(
              padding: const EdgeInsets.only(
                left: 20,
                top: 4,
                bottom: 10,
                right: 20,
              ),
              width: double.infinity,
              child: Text(
                desc!,
                style: TextStyle(
                  fontSize: kSummaryFontSize,
                  color: CupertinoDynamicColor.resolve(
                      CupertinoColors.secondaryLabel, context),
                ),
                textAlign: TextAlign.start,
              ),
            ),
          ),
      ],
    );
  }
}

/// 文本输入框类型
class CupertinoTextInputListTile extends StatefulWidget {
  const CupertinoTextInputListTile({
    this.title,
    Key? key,
    this.maxLines = 1,
    this.onChanged,
    this.initValue,
    this.placeholder,
    this.leading,
    this.trailing,
    this.textAlign = TextAlign.right,
    this.textFieldPadding = const EdgeInsets.all(6.0),
    this.textController,
    this.obscureText,
    this.keyboardType,
  }) : super(key: key);

  final String? title;
  final String? initValue;
  final ValueChanged<String>? onChanged;
  final String? placeholder;
  final int? maxLines;
  final Widget? leading;
  final Widget? trailing;
  final TextAlign textAlign;
  final EdgeInsetsGeometry textFieldPadding;
  final TextEditingController? textController;
  final bool? obscureText;
  final TextInputType? keyboardType;

  @override
  State<CupertinoTextInputListTile> createState() =>
      _CupertinoTextInputListTileState();
}

class _CupertinoTextInputListTileState
    extends State<CupertinoTextInputListTile> {
  late TextEditingController textController;

  @override
  void initState() {
    super.initState();
    if (widget.textController != null) {
      textController = widget.textController!;
      textController.text = widget.initValue ?? '';
    } else {
      textController = TextEditingController(text: widget.initValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    return EhCupertinoListTile(
      title: Text(widget.title ?? ''),
      leading: widget.leading,
      trailing: widget.trailing,
      additionalInfo: Expanded(
        child: CupertinoTextField(
          decoration: null,
          padding: widget.textFieldPadding,
          controller: textController,
          obscureText: widget.obscureText ?? false,
          keyboardType: widget.keyboardType,
          textAlign: widget.textAlign,
          maxLines: widget.maxLines,
          placeholderStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            color: CupertinoColors.placeholderText,
            height: 1.25,
          ),
          placeholder: widget.placeholder,
          style: const TextStyle(height: 1.2),
          onChanged: widget.onChanged?.call,
        ),
      ),
    );
  }
}
