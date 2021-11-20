import 'package:fehviewer/common/service/layout_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../setting_base.dart';
import 'single_input_page.dart';

class SingleInputItem extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final selector = initVal ?? '';

    return SelectorSettingItem(
      title: title,
      hideLine: hideLine,
      selector: (selector.isNotEmpty && suffixText != null)
          ? '$selector $suffixText'
          : selector,
      onTap: () async {
        Get.to(
          () => SingleInputPage(
            title: pageTitle ?? title,
            previousPageTitle: previousPageTitle,
            suffixText: suffixText,
            initValue: selector,
            placeholder: placeholder,
            onValueChanged: (val) {
              onValueChanged?.call(val);
            },
          ),
          id: isLayoutLarge ? 2 : null,
        );
      },
    );
  }
}
