import 'package:fehviewer/common/parser/profile_parser.dart';
import 'package:fehviewer/models/base/eh_models.dart';
import 'package:fehviewer/network/gallery_request.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:get/get.dart';

class EhMySettingsController extends GetxController {
  // Rx<EhSettings> ehSettings = const EhSettings().obs;

  final _ehSetting = const EhSettings(profilelist: [], xn: [], xl: []).obs;
  EhSettings get ehSetting => _ehSetting.value;
  set ehSetting(EhSettings val) => _ehSetting.value = val;

  void print() {
    logger.d('${_ehSetting.value.postParam}');
  }

  Future<void> loadData() async {
    final String url = '${Api.getBaseUrl()}/uconfig.php';
    final String? response = await Api.getHttpManager(cache: false).get(url);
    final uconfig = parseUconfig(response ?? '');
    ehSetting = uconfig;
  }

  void renameProfile() {}

  void setDefaultProfile() {}

  void deleteProfile() {}

  void crtNewProfile() {}
}
