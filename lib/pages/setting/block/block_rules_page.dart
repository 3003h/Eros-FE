import 'package:fehviewer/common/controller/block_controller.dart';
import 'package:fehviewer/common/service/layout_service.dart';
import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class BlockRulesPage extends GetView<BlockController> {
  const BlockRulesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final String _title = L10n.of(context).block_rules;

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
              final result = await Get.toNamed<dynamic>(
                EHRoutes.blockRuleEdit,
                id: isLayoutLarge ? 2 : null,
              );
              if (result != null && result is BlockRule) {
                controller.addBlockRule(result);
              }
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
