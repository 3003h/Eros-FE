import 'dart:io';

import 'package:dns_client/dns_client.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/utility.dart';

class DnsUtil {
  static Future<String> doh(String host,
      {DohResolve dhoResolve = DohResolve.cloudflare}) async {
    logger.d(' DnsUtil.doh $host');
    final DnsOverHttps dns = dhoResolve == DohResolve.cloudflare
        ? DnsOverHttps.cloudflare()
        : DnsOverHttps.google();
    final List<InternetAddress> response = await dns.lookup(host.trim());
    logger.d('$response');
    if (response.isNotEmpty) {
      return (response..shuffle()).first.address;
    } else {
      return host;
    }
  }
}
