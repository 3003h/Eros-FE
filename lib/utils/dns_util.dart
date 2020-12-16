import 'dart:io';

import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/models/index.dart';
import 'package:FEhViewer/utils/logger.dart';
import 'package:FEhViewer/utils/utility.dart';
import 'package:dns_client/dns_client.dart';

class DnsUtil {
  static Future<String> doh(String host,
      {DohResolve dhoResolve = DohResolve.cloudflare}) async {
    logger.d(' DnsUtil.doh $host');
    final DnsOverHttps dns = dhoResolve == DohResolve.cloudflare
        ? DnsOverHttps.cloudflare()
        : DnsOverHttps.google();
    final List<InternetAddress> response = await dns.lookup(host.trim());
    logger.d('$response');
    return (response..shuffle()).first.address;
  }

  static Future<void> dohToProfile(String url) async {
    if (!Global.profile.dnsConfig.enableDoH ?? false) {
      return;
    }
    // 解析host
    final String _host = Uri.parse(url).host;
    final String _addr = await doh(_host);
    logger.v('$_host  $_addr');
    final List<DnsCache> dnsCacheList = Global.profile.dnsConfig.dohCache;
    dnsCacheList.add(DnsCache()
      ..host = _host
      ..addrs = <String>[_addr]);

    for (DnsCache cache in dnsCacheList) {
      // Global.hosts[cache.host] = cache.addrs.first;
    }
  }

  static Future<void> updateDoHCache(String host) async {
    if (host == 'cloudflare-dns.com') {
      return;
    }
    logger.d(' updateDoHCache $host');
    const int updateInterval = 300;
    final List<DnsCache> dnsCacheList =
        Global.profile.dnsConfig.dohCache ?? <DnsCache>[];

    final int index =
        dnsCacheList.indexWhere((DnsCache element) => element.host == host);
    final DnsCache dnsCache = index >= 0 ? dnsCacheList[index] : null;
    final int nowTime = DateTime.now().millisecondsSinceEpoch;
    if (dnsCache != null) {
      if (dnsCache.lastResolve != null &&
          -dnsCache.lastResolve > updateInterval) {
        // get new and cache
        final String _addr = await doh(host);
        dnsCache
          ..lastResolve = nowTime
          ..addr = _addr;
      }
    } else {
      // get new
      logger.d(' get new doh $host');
      final String _addr = await doh(host);
      logger.d(' get new doh $host  addr=$_addr');
      Global.profile.dnsConfig.dohCache.add(DnsCache()
        ..host = host
        ..lastResolve = nowTime
        ..addr = _addr);
    }
    Global.saveProfile();
  }
}
