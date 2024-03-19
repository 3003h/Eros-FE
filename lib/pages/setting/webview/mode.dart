import 'package:eros_fe/index.dart';
import 'package:flutter/widgets.dart';

Map<ProxyType, String> getProxyTypeModeMap(BuildContext context) {
  final Map<ProxyType, String> proxyTypeModeMap = <ProxyType, String>{
    ProxyType.system: L10n.of(context).system_proxy,
    ProxyType.http: 'HTTP',
    ProxyType.socks5: 'SOCKS5',
    ProxyType.socks4: 'SOCKS4',
    ProxyType.direct: L10n.of(context).direct,
  };

  return proxyTypeModeMap;
}
