import 'package:fehviewer/common/controller/block_controller.dart';
import 'package:fehviewer/common/service/theme_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import 'block_rule_edit_dialog.dart';

class BlockRulesPage extends GetView<BlockController> {
  const BlockRulesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final String _title = 'Block Rules';

    return Obx(() {
      return CupertinoPageScaffold(
        backgroundColor: !ehTheme.isDarkMode
            ? CupertinoColors.secondarySystemBackground
            : null,
        navigationBar: CupertinoNavigationBar(
          padding: const EdgeInsetsDirectional.only(end: 8),
          middle: Text(_title),
          trailing: CupertinoButton(
            padding: const EdgeInsets.all(0),
            minSize: 40,
            child: const Icon(
              // FontAwesomeIcons.plus,
              CupertinoIcons.plus_circle,
              size: 28,
            ),
            onPressed: () async {
              final newName = await showCupertinoDialog<String>(
                  context: context,
                  barrierDismissible: true,
                  builder: (context) {
                    return const BlockRuleEditDialog(
                      text: '',
                      title: 'Edit Block Rule',
                    );
                  });
              // if (newName != null && newName.isNotEmpty) {
              //   controller.crtNewTagset(name: newName);
              // }
            },
          ),
        ),
        child: SafeArea(
          bottom: false,
          top: false,
          child: ListView(),
        ),
      );
    });
  }
}
