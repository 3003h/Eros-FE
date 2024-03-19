import 'package:eros_fe/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class BlockRuleEditDialog extends StatelessWidget {
  const BlockRuleEditDialog({
    Key? key,
    required this.text,
    required this.title,
  }) : super(key: key);
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    TextEditingController blockRuleTextEditingController =
        TextEditingController.fromValue(
      TextEditingValue(
        text: text,
        selection: TextSelection.fromPosition(
          TextPosition(
            affinity: TextAffinity.downstream,
            offset: text.length,
          ),
        ),
      ),
    );
    return CupertinoAlertDialog(
      title: Text(title).paddingSymmetric(vertical: 8),
      content: Column(
        children: [
          // CupertinoSlidingSegmentedControl<BlockType>(
          //   children: const <BlockType, Widget>{
          //     BlockType.title: Text('Title'),
          //     BlockType.uploader: Text('Uploader'),
          //     BlockType.commentator: Text('Commentator'),
          //     BlockType.comment: Text('Comment'),
          //   },
          //   groupValue: BlockType.title,
          //   onValueChanged: (BlockType? value) {},
          // ),
          CupertinoTextField(
            maxLines: null,
            controller: blockRuleTextEditingController,
            // autofocus: text.isEmpty,
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
            Get.back(result: blockRuleTextEditingController.text.trim());
          },
        ),
      ],
    );
  }
}
