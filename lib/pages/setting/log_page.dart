import 'dart:io';

import 'package:fehviewer/common/service/layout_service.dart';
import 'package:fehviewer/common/controller/log_controller.dart';
import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/component/setting_base.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:path/path.dart' as path;

import 'log_view_page.dart';

class LogPage extends StatelessWidget {
  LogPage({Key? key}) : super(key: key);
  final LogService logService = Get.find();

  @override
  Widget build(BuildContext context) {
    logService.loadFiles();

    final String _title = 'Log';
    return Obx(() {
      return CupertinoPageScaffold(
        backgroundColor: !ehTheme.isDarkMode
            ? CupertinoColors.secondarySystemBackground
            : null,
        navigationBar: CupertinoNavigationBar(
          padding: const EdgeInsetsDirectional.only(start: 0),
          middle: Text(_title),
          trailing: CupertinoButton(
            // 清除按钮
            child: const Icon(
              LineIcons.alternateTrash,
              size: 26,
            ),
            onPressed: logService.removeAll,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Container(
            child: CustomHostsListView(),
          ),
        ),
      );
    });
  }
}

class CustomHostsListView extends StatelessWidget {
  CustomHostsListView({Key? key}) : super(key: key);

  final LogService logService = Get.find();
  final ScrollController _controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    logService.loadFiles();
    return Obx(() => ListView.builder(
          controller: _controller,
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (_, int index) {
            final File _file = logService.logFiles[index];
            return Slidable(
              endActionPane: ActionPane(
                motion: const ScrollMotion(),
                extentRatio: 0.25,
                children: [
                  SlidableAction(
                    onPressed: (_) => logService.removeLogAt(index),
                    backgroundColor: CupertinoDynamicColor.resolve(
                        CupertinoColors.systemRed, context),
                    foregroundColor: Colors.white,
                    icon: Icons.delete,
                    label: L10n.of(context).delete,
                  ),
                ],
              ),
              child: LogFileItem(
                index: index,
                fileName: path.basename(_file.path),
              ),
            );
          },
          itemCount: logService.logFiles.length,
        ));
  }
}

class LogFileItem extends StatelessWidget {
  const LogFileItem({
    Key? key,
    required this.fileName,
    required this.index,
  }) : super(key: key);
  final String fileName;
  final int index;

  @override
  Widget build(BuildContext context) {
    return SelectorSettingItem(
      title: fileName,
      onTap: () {
        Get.to(
          () => LogViewPage(
            title: fileName,
            index: index,
          ),
          id: isLayoutLarge ? 2 : null,
          transition: isLayoutLarge ? Transition.rightToLeft : null,
        );
      },
    );
  }
}
