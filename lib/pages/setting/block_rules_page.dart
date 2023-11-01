import 'package:fehviewer/common/controller/block_controller.dart';
import 'package:fehviewer/common/service/theme_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

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
