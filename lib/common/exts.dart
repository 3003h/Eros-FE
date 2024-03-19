import 'package:eros_fe/common/service/dns_service.dart';
import 'package:eros_fe/common/service/ehsetting_service.dart';
import 'package:eros_fe/models/index.dart';
import 'package:eros_fe/utils/logger.dart';
import 'package:get/get.dart';

import '../const/const.dart';

extension EhString on String {
  String toRealUrl() {
    final DnsService dnsService = Get.find();
    final bool enableDoH = dnsService.enableDoH;
    final bool enableCustomHosts = dnsService.enableCustomHosts;
    final List<DnsCache> _dohDnsCacheList = dnsService.dohCache;
    final String host = Uri.parse(this).host;
    if (host.isEmpty) {
      return this;
    }
    String realHost = host;
    if (!enableDoH && !enableCustomHosts) {
      logger.d(' none');
      return this;
    } else if (enableDoH && enableCustomHosts) {
      // 同时开启doh和自定义host的情况
      logger.d(' both');
      return this;
    } else if (enableDoH) {
      // logger.d(' enableDoH');
      Get.find<DnsService>().getDoHCache(host);
      final int _dohDnsCacheIndex = dnsService.dohCache
          .indexWhere((DnsCache element) => element.host == host);
      final DnsCache? dohDnsCache =
          _dohDnsCacheIndex > -1 ? _dohDnsCacheList[_dohDnsCacheIndex] : null;
      realHost = dohDnsCache?.addr ?? host;
      final String realUrl = replaceFirst(host, realHost);
      logger.d('realUrl: $realUrl');
      return realUrl;
    }
    return this;
  }

  String get handleUrl {
    return _handleThumbUrlToEh;
  }

  String get _handleThumbUrlToEh {
    final EhSettingService _ehSettingService = Get.find();

    // if (startsWith(RegExp(EHConst.REG_URL_PREFIX_THUMB_EX)) &&
    //     _ehSettingService.redirectThumbLink) {
    //   return replaceFirst(
    //     RegExp(EHConst.REG_URL_PREFIX_THUMB_EX),
    //     EHConst.URL_PREFIX_THUMB_EH,
    //   );
    // }

    if (RegExp(EHConst.REG_URL_THUMB).hasMatch(this) &&
        contains(EHConst.EX_BASE_HOST) &&
        _ehSettingService.redirectThumbLink) {
      return replaceFirstMapped(
        RegExp(EHConst.REG_URL_THUMB),
        (Match m) => '${EHConst.URL_PREFIX_THUMB_EH}/${m.group(2)}',
      );
    }

    return this;
  }

  String get gid {
    final RegExp urlRex = RegExp(r'/g/(\d+)/(\w+)/$');
    final RegExpMatch? urlRult = urlRex.firstMatch(this);

    final String gid = urlRult?.group(1) ?? '';
    final String token = urlRult?.group(2) ?? '';
    return gid;
  }
}
