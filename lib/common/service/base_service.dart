import 'package:enum_to_string/enum_to_string.dart';
import 'package:eros_fe/common/global.dart';
import 'package:eros_fe/extension.dart';
import 'package:eros_fe/models/index.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class ProfileService extends GetxService {
  EhConfig get ehConfig => Global.profile.ehConfig;
  set ehConfig(EhConfig val) =>
      Global.profile = Global.profile.copyWith(ehConfig: val);

  DownloadConfig get downloadConfig => Global.profile.downloadConfig;
  set downloadConfig(DownloadConfig val) =>
      Global.profile = Global.profile.copyWith(downloadConfig: val);

  DnsConfig get dnsConfig => Global.profile.dnsConfig;
  set dnsConfig(DnsConfig val) =>
      Global.profile = Global.profile.copyWith(dnsConfig: val);

  LayoutConfig get layoutConfig =>
      Global.profile.layoutConfig ?? const LayoutConfig();
  set layoutConfig(LayoutConfig val) =>
      Global.profile = Global.profile.copyWith(layoutConfig: val.oN);

  BlockConfig get blockConfig =>
      Global.profile.blockConfig ?? const BlockConfig();
  set blockConfig(BlockConfig val) =>
      Global.profile = Global.profile.copyWith(blockConfig: val.oN);

  Worker everProfile<T>(RxInterface<T> listener, ValueChanged<T> onChange) {
    return ever<T>(listener, (value) {
      onChange(value);
      Global.saveProfile();
    });
  }

  Worker everFromEnum<T>(
      RxInterface<T> listener, ValueChanged<String> onChange) {
    return ever<T>(listener, (T value) {
      onChange(EnumToString.convertToString(value));
      Global.saveProfile();
    });
  }
}
