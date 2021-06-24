import 'package:fehviewer/common/service/log_service.dart';
import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/const/const.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share/share.dart';

class LogViewPage extends StatelessWidget {
  LogViewPage({Key? key, required this.index, required this.title})
      : super(key: key);
  final LogService logService = Get.find();
  final int index;
  final String title;

  @override
  Widget build(BuildContext context) {
    final _log = logService.logFiles[index].readAsStringSync();
    return CupertinoPageScaffold(
      backgroundColor: !ehTheme.isDarkMode
          ? CupertinoColors.secondarySystemBackground
          : null,
      navigationBar: CupertinoNavigationBar(
        padding: const EdgeInsetsDirectional.only(start: 0),
        middle: Text(title),
        trailing: CupertinoButton(
          padding: const EdgeInsets.only(right: 12),
          // 清除按钮
          child: const Icon(
            CupertinoIcons.share,
            size: 26,
          ),
          onPressed: () {
            Share.shareFiles([logService.logFiles[index].path]);
          },
        ),
        // transitionBetweenRoutes: false,
      ),
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Container(
            child: SelectableText(
              _log,
              style: TextStyle(
                fontSize: 12,
                fontFamilyFallback: EHConst.monoFontFamilyFallback,
              ),
            ).paddingAll(8),
          ),
        ),
      ),
    );
  }
}
