import 'package:fehviewer/common/controller/block_controller.dart';
import 'package:fehviewer/common/service/theme_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class BlockersPage extends GetView<BlockController> {
  const BlockersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final String _title = 'Blockers';

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
          child: Container(),
        ),
      );
    });
  }
}
