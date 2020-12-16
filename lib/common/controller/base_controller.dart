import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/models/index.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController {
  EhConfig ehConfig;
  DownloadConfig downloadConfig;

  Worker everSaveProfile<T>(RxInterface<T> listener, ValueChanged<T> onChange,
      {bool isEnum = false}) {
    return ever<T>(listener, (T value) {
      onChange(isEnum ? EnumToString.convertToString(value) : value);
      Global.saveProfile();
    });
  }
}
