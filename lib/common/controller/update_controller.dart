import 'dart:math';

import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/network/request.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher_string.dart';

const String kGithubUrl =
    'https://api.github.com/repos/3003h/FEhViewer/releases/latest';

class UpdateController extends GetxController {
  final _canUpdate = false.obs;
  bool get canUpdate => _canUpdate.value;

  final _isChecking = false.obs;
  bool get isChecking => _isChecking.value;
  set isChecking(bool val) => _isChecking.value = val;

  set canUpdate(bool val) => _canUpdate.value = val;

  final _isLastVersion = true.obs;
  bool get isLastVersion => _isLastVersion.value;
  set isLastVersion(bool val) => _isLastVersion.value = val;

  String? lastVersion;

  @override
  void onInit() {
    super.onInit();
    checkUpdate();
  }

  Future<void> checkUpdate({bool showDialog = false}) async {
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;

    isChecking = true;
    final _response = await getGithubApi(kGithubUrl);
    final tagName = (_response['tag_name'] as String?)?.trim() ?? '';
    final body = (_response['body'] as String?)?.trim() ?? '';
    final htmUrl = (_response['html_url'] as String?)?.trim() ?? '';
    logger.d('tagName $tagName');
    logger.d('body\n$body');

    final regExpTagName = RegExp(r'^([vV])?(\d+\.\d+\.\d+)\+(\d+)');
    final match = regExpTagName.firstMatch(tagName);
    final remoteVersion = match?.group(2) ?? '';
    logger.d('remoteVersion $remoteVersion  , currentVersion $currentVersion');
    final compare = versionStringCompare(
        preVersion: currentVersion, lastVersion: remoteVersion);
    lastVersion = remoteVersion;

    isChecking = false;

    if (compare >= 0) {
      isLastVersion = true;
    }

    if (showDialog) {
      showSimpleEhDiglog(
        context: Get.context!,
        title: remoteVersion,
        // contentText: body,
        content: IntrinsicHeight(
          child: Container(
            height: 300,
            child: SingleChildScrollView(
              child: MarkdownBody(
                data: body,
                selectable: true,
                styleSheetTheme: MarkdownStyleSheetBaseTheme.cupertino,
                styleSheet: MarkdownStyleSheet(
                  a: const TextStyle(
                    color: CupertinoColors.activeBlue,
                    fontSize: 14,
                  ),
                  p: const TextStyle(
                    fontSize: 14,
                  ),
                  em: const TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 14,
                  ),
                  listBullet: const TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.systemGrey,
                  ),
                  code: CupertinoTheme.of(Get.context!)
                      .textTheme
                      .textStyle
                      .copyWith(
                          backgroundColor: Colors.transparent,
                          color: CupertinoColors.systemPink,
                          fontSize: CupertinoTheme.of(Get.context!)
                                  .textTheme
                                  .textStyle
                                  .fontSize! *
                              0.8,
                          fontFamilyFallback: EHConst.monoFontFamilyFallback),
                ),
              ),
            ),
          ),
        ),
        onOk: () {
          launchUrlString(
            htmUrl,
            mode: LaunchMode.externalApplication,
          );
        },
      );
    }
  }
}

int versionStringCompare({String preVersion = '', String lastVersion = ''}) {
  final sources = preVersion.split('.');
  final dests = lastVersion.split('.');
  final maxL = max(sources.length, dests.length);
  var result = 0;
  for (int i = 0; i < maxL; i++) {
    int preNum = sources.length > i ? int.tryParse(sources[i]) ?? 0 : 0;
    int lastNum = dests.length > i ? int.tryParse(dests[i]) ?? 0 : 0;
    if (preNum < lastNum) {
      result = -1;
      break;
    } else if (preNum > lastNum) {
      result = 1;
      break;
    }
  }
  return result;
}
