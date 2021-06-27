import 'package:fehviewer/common/service/log_service.dart';
import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/utility.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:share/share.dart';
import 'dart:convert';

class LogViewPage extends StatelessWidget {
  LogViewPage({Key? key, required this.index, required this.title})
      : super(key: key);
  final LogService logService = Get.find();
  final int index;
  final String title;

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    // final _log = logService.logFiles[index].readAsStringSync();
    final _logByte = logService.logFiles[index].readAsBytesSync();
    final _log = const Utf8Decoder(allowMalformed: true).convert(_logByte);

    SchedulerBinding.instance?.addPostFrameCallback((_) {
      //build完成后的回调
      logger.v('to end');
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent, //滚动到底部
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });

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
        child: CupertinoScrollbar(
          controller: _scrollController,
          child: SingleChildScrollView(
            controller: _scrollController,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                child: Text(
                  _log,
                  softWrap: false,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.1,
                    fontFamilyFallback: EHConst.monoFontFamilyFallback,
                  ),
                ).paddingAll(8),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
