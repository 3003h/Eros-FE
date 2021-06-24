import 'package:fehviewer/common/service/dns_service.dart';
import 'package:fehviewer/models/index.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:get/get.dart';

extension EhString on String {
  String toRealUrl() {
    final DnsService dnsConfigController = Get.find();
    final bool enableDoH = dnsConfigController.enableDoH.value;
    final bool enableCustomHosts = dnsConfigController.enableCustomHosts.value;
    final List<DnsCache> _dohDnsCacheList = dnsConfigController.dohCache;
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
      Get.find<DnsService>().updateDoHCache(host);
      final int _dohDnsCacheIndex = dnsConfigController.dohCache
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

  String get gid {
    final RegExp urlRex = RegExp(r'/g/(\d+)/(\w+)/$');
    final RegExpMatch? urlRult = urlRex.firstMatch(this);

    final String gid = urlRult?.group(1) ?? '';
    final String token = urlRult?.group(2) ?? '';
    return gid;
  }
}
