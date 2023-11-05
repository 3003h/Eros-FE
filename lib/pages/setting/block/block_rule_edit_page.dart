import 'package:fehviewer/common/controller/block_controller.dart';
import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class BlockRuleEditPage extends GetView<BlockController> {
  const BlockRuleEditPage({super.key});

  @override
  Widget build(BuildContext context) {
    final String _title = L10n.of(context).blockers;

    return Obx(() {
      return CupertinoPageScaffold(
        backgroundColor: !ehTheme.isDarkMode
            ? CupertinoColors.secondarySystemBackground
            : null,
        navigationBar: CupertinoNavigationBar(
          padding: const EdgeInsetsDirectional.only(start: 0),
          middle: Text(_title),
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
