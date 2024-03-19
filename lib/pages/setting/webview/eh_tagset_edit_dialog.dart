import 'package:eros_fe/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class EhTagSetEditDialog extends StatelessWidget {
  const EhTagSetEditDialog({Key? key, required this.text, required this.title})
      : super(key: key);
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    TextEditingController tagsetNameTextEditingController =
        TextEditingController.fromValue(TextEditingValue(
      text: text,
      selection: TextSelection.fromPosition(
        TextPosition(
          affinity: TextAffinity.downstream,
          offset: text.length,
        ),
      ),
    ));
    return CupertinoAlertDialog(
      title: Text(title).paddingSymmetric(vertical: 8),
      content: Column(
        children: [
          CupertinoTextField(
            maxLines: 1,
            controller: tagsetNameTextEditingController,
            autofocus: true,
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
          onPressed: () {
            Get.back(result: tagsetNameTextEditingController.text.trim());
          },
        ),
      ],
    );
  }
}
