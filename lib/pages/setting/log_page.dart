import 'dart:io';

import 'package:fehviewer/common/service/log_service.dart';
import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/pages/setting/setting_base.dart';
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
  }
}

class CustomHostsListView extends StatelessWidget {
  final LogService logService = Get.find();
  final ScrollController _controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    logService.loadFiles();
    return Obx(() => Container(
          child: ListView.builder(
            controller: _controller,
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (_, int index) {
              final File _file = logService.logFiles[index];
              return Slidable(
                actionPane: const SlidableDrawerActionPane(),
                actionExtentRatio: 0.25,
                secondaryActions: <Widget>[
                  IconSlideAction(
                    caption: S.of(context).delete,
                    color: CupertinoDynamicColor.resolve(
                        CupertinoColors.systemRed, context),
                    icon: Icons.delete,
                    onTap: () {
                      logService.removeLogAt(index);
                      // showToast('delete');
                    },
                  ),
                ],
                child: LogFileItem(
                  index: index,
                  fileName: path.basename(_file.path),
                ),
              );
            },
            itemCount: logService.logFiles.length,
          ),
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
    return Container(
      child: SelectorSettingItem(
        title: fileName,
        onTap: () {
          // showCustomHostEditer(context, index: index);
          // logger.v('');
          Get.to(() => LogViewPage(
                title: fileName,
                index: index,
              ));
        },
      ),
    );
  }
}
