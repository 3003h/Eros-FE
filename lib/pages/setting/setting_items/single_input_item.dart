import 'package:fehviewer/common/service/layout_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../setting_base.dart';
import 'single_input_page.dart';

class SingleInputItem extends StatefulWidget {
  const SingleInputItem({
    Key? key,
    required this.title,
    this.pageTitle,
    this.initVal,
    this.onValueChanged,
    this.hideLine = false,
    this.previousPageTitle,
    this.suffixText,
    this.placeholder,
  }) : super(key: key);

  final String title;
  final String? pageTitle;
  final String? previousPageTitle;
  final String? initVal;
  final ValueChanged<String>? onValueChanged;
  final bool hideLine;
  final String? suffixText;
  final String? placeholder;

  @override
  _SingleInputItemState createState() => _SingleInputItemState();
}

class _SingleInputItemState extends State<SingleInputItem> {
  String selector = '';

  @override
  void initState() {
    super.initState();
    selector = widget.initVal ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return SelectorSettingItem(
      title: widget.title,
      hideLine: widget.hideLine,
      selector: (selector.isNotEmpty && widget.suffixText != null)
          ? '$selector ${widget.suffixText}'
          : selector,
      onTap: () async {
        Get.to(
          () => SingleInputPage(
            title: widget.pageTitle ?? widget.title,
            previousPageTitle: widget.previousPageTitle,
            suffixText: widget.suffixText,
            initValue: selector,
            placeholder: widget.placeholder,
            onValueChanged: (val) {
              setState(() {
                selector = val;
                widget.onValueChanged?.call(val);
              });
            },
          ),
          id: isLayoutLarge ? 2 : null,
        );
      },
    );
  }
}
