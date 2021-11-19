import 'package:fehviewer/models/base/eh_models.dart';
import 'package:fehviewer/network/gallery_request.dart';
import 'package:fehviewer/network/request.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:get/get.dart';

class EhMySettingsController extends GetxController {
  // Rx<EhSettings> ehSettings = const EhSettings().obs;

  final _ehSetting = const EhSettings(profilelist: [], xn: [], xl: []).obs;
  EhSettings get ehSetting => _ehSetting.value;
  set ehSetting(EhSettings val) => _ehSetting.value = val;

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(bool val) => _isLoading.value = val;

  void printParam() {
    logger.d('${_ehSetting.value.postParam}');
  }

  Future<EhSettings?> loadData({bool refresh = false}) async {
    final String url = '${Api.getBaseUrl()}/uconfig.php';
    isLoading = true;
    try {
      final uconfig = await getUconfig(url, refresh: refresh);
      isLoading = false;
      if (uconfig != null) {
        ehSetting = uconfig;
        return uconfig;
      }
    } catch (e) {
      rethrow;
    } finally {
      isLoading = false;
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
