import 'package:fehviewer/common/service/layout_service.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import 'single_input_page.dart';

class SingleInputItem extends StatelessWidget {
  const SingleInputItem({
    Key? key,
    required this.title,
    this.pageTitle,
    this.initValue,
    this.onChanged,
    this.hideLine = false,
    this.previousPageTitle,
    this.suffixText,
    this.placeholder,
    this.selector,
    this.maxLines,
  }) : super(key: key);

  final String title;
  final String? pageTitle;
  final String? previousPageTitle;
  final String? initValue;
  final ValueChanged<String>? onChanged;
  final bool hideLine;
  final String? suffixText;
  final String? placeholder;
  final String? selector;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final _initValue = initValue ?? '';

    return EhCupertinoListTile(
      title: Text(title),
      trailing: const CupertinoListTileChevron(),
      additionalInfo: Text(selector ??
          ((_initValue.isNotEmpty && suffixText != null)
              ? '$_initValue $suffixText'
              : _initValue)),
      onTap: () async {
        Get.to(
          () => SingleInputPage(
            title: pageTitle ?? title,
            previousPageTitle: previousPageTitle,
            suffixText: suffixText,
            maxLines: maxLines,
            initValue: _initValue,
            placeholder: placeholder,
            onValueChanged: (val) {
              onChanged?.call(val);
            },
          ),
          id: isLayoutLarge ? 2 : null,
        );
      },
    );
  }
}
