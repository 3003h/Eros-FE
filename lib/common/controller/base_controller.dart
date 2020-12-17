import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/models/index.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController {
  EhConfig ehConfig;
  DownloadConfig downloadConfig;

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
