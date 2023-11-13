import 'dart:convert';
import 'dart:io';

import 'package:fehviewer/common/controller/log_controller.dart';
import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

class LogViewPage extends StatefulWidget {
  const LogViewPage({Key? key, required this.index, required this.title})
      : super(key: key);
  final int index;
  final String title;

  @override
  State<LogViewPage> createState() => _LogViewPageState();
}

class _LogViewPageState extends State<LogViewPage> {
  final LogService logService = Get.find();

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // SchedulerBinding.instance.addPostFrameCallback((_) {
    //   _scrollToBottom();
    // });
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent, //滚动到底部
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }

  Future<String> _getLog() async {
    final logFile = logService.logFiles[widget.index];
    if (!logFile.existsSync()) {
      Get.back();
    }

    final Uint8List _logByte = await compute(_readFileBytes, logFile.path);
    final _log = const Utf8Decoder(allowMalformed: true).convert(_logByte);

    // await 30.seconds.delay();

    // final lines = await readLastNLines(logFile.path, 100);
    // final _log = lines.join('\n');

    return _log;
  }

  @override
  Widget build(BuildContext context) {
    final logFile = logService.logFiles[widget.index];

    Widget scrollView = FutureBuilder<String>(
        future: _getLog(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CupertinoActivityIndicator(
              radius: 14,
            ));
          }

          final _log = snapshot.data ?? '';

          return SingleChildScrollView(
            controller: _scrollController,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                child: Text(
                  _log,
                  softWrap: false,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.1,
                    fontFamilyFallback: EHConst.monoFontFamilyFallback,
                  ),
                ).paddingAll(8),
              ),
            ),
          );
        });

    if (GetPlatform.isMobile) {
      scrollView = CupertinoScrollbar(
        controller: _scrollController,
        child: scrollView,
      );
    }

    return Obx(() {
      return CupertinoPageScaffold(
        backgroundColor: !ehTheme.isDarkMode
            ? CupertinoColors.secondarySystemBackground
            : null,
        navigationBar: CupertinoNavigationBar(
          padding: const EdgeInsetsDirectional.only(start: 0),
          middle: Text(widget.title),
          previousPageTitle: 'Log',
          trailing: CupertinoButton(
            padding: const EdgeInsets.only(right: 12),
            // 清除按钮
            child: const Icon(
              CupertinoIcons.share,
              size: 26,
            ),
            onPressed: () {
              Share.shareXFiles([XFile(logFile.path)]);
            },
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: scrollView,
        ),
      );
    });
  }
}

Uint8List _readFileBytes(String path) {
  return File(path).readAsBytesSync();
}
