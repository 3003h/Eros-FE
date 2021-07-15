import 'package:enum_to_string/enum_to_string.dart';
import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/models/index.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class ProfileService extends GetxService {
  EhConfig get ehConfig => Global.profile.ehConfig;
  set ehConfig(EhConfig val) =>
      Global.profile = Global.profile.copyWith(ehConfig: val);

  DownloadConfig get downloadConfig => Global.profile.downloadConfig;
  set downloadConfig(DownloadConfig val) =>
      Global.profile = Global.profile.copyWith(downloadConfig: val);

  Worker everProfile<T>(RxInterface<T> listener, ValueChanged<T> onChange) {
    return ever<T>(listener, (value) {
      onChange(value);
      Global.saveProfile();
    });
  }

  Worker everFromEunm<T>(
      RxInterface<T> listener, ValueChanged<String> onChange) {
    return ever<T>(listener, (T value) {
      onChange(EnumToString.convertToString(value));
      Global.saveProfile();
    });
  }
}
