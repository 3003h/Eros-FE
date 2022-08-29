import 'dart:math';

import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/network/request.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher_string.dart';

const String kGithubUrl =
    'https://api.github.com/repos/honjow/FEhViewer/releases/latest';

class UpdateController extends GetxController {
  final _canUpdate = false.obs;
  bool get canUpdate => _canUpdate.value;
  set canUpdate(bool val) => _canUpdate.value = val;

  String? lastVersion;

  @override
  void onInit() {
    super.onInit();
    checkUpdate();
  }

  Future<void> checkUpdate({bool showDialog = false}) async {
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;

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
    if (kDebugMode ? compare <= 0 : compare < 0) {
      lastVersion = remoteVersion;
      canUpdate = true;

      if (showDialog) {
        showSimpleEhDiglog(
          context: Get.context!,
          title: remoteVersion,
          contentText: body,
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
