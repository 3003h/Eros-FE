import 'package:fehviewer/common/parser/profile_parser.dart';
import 'package:fehviewer/models/base/eh_models.dart';
import 'package:fehviewer/network/gallery_request.dart';
import 'package:fehviewer/network/request.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class EhMySettingsController extends GetxController {
  // Rx<EhSettings> ehSettings = const EhSettings().obs;

  final _ehSetting = const EhSettings(profilelist: [], xn: [], xl: []).obs;
  EhSettings get ehSetting => _ehSetting.value;
  set ehSetting(EhSettings val) => _ehSetting.value = val;

  void printParam() {
    logger.d('${_ehSetting.value.postParam}');
  }

  Future<void> loadData({bool refresh = false}) async {
    final String url = '${Api.getBaseUrl()}/uconfig.php';
    final uconfig = await getUconfig(url, refresh: refresh);
    if (uconfig != null) {
      ehSetting = uconfig;
    }
  }

  Future<void> reloadData() async {
    await loadData(refresh: true);
  }

  void renameProfile() {}

  void setDefaultProfile() {}

  void deleteProfile() {}

  void crtNewProfile() {}
}
