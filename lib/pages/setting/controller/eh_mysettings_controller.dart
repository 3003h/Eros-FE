import 'package:fehviewer/models/base/eh_models.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:get/get.dart';

class EhMySettingsController extends GetxController {
  // Rx<EhSettings> ehSettings = const EhSettings().obs;

  final _ehSetting = EhSettings().obs;
  EhSettings get ehSetting => _ehSetting.value;
  set ehSetting(EhSettings val) => _ehSetting.value = val;

  void print() {
    logger.d('${_ehSetting.value.postParam}');
  }
}
