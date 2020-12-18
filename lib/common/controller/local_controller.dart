import 'dart:ui';

import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/models/index.dart';
import 'package:get/get.dart';

import 'base_controller.dart';

class LocaleController extends ProfileController {
  RxString localCode = window.locale.toString().obs;

  Locale get locale {
    final String localeSt = localCode.value;
    if (localeSt == null ||
        localeSt.isEmpty ||
        localeSt == '_' ||
        !localeSt.contains('_')) {
      return window.locale;
    }
    final List<String> t = localeSt.split('_');
    return Locale(t[0], t[1]);
  }

  @override
  void onInit() {
    super.onInit();
    final Profile _profile = Global.profile;

    localCode.value = _profile.locale;
    everProfile<String>(localCode, (String value) {
      Get.updateLocale(locale);
      _profile.locale = value;
    });
  }
}
