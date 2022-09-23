import 'package:dio/adapter.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:get/get.dart';
import 'package:system_network_proxy/system_network_proxy.dart';
import 'package:system_proxy/system_proxy.dart';

class HttpProxyAdapter extends DefaultHttpClientAdapter {}

Future<String> getProxy({
  ProxyType proxyType = ProxyType.system,
  String? proxyHost,
  int? proxyPort,
  String? proxyUsername,
  String? proxyPassword,
}) async {
  String proxy = '';
  if (proxyUsername != null && proxyPassword != null) {
    proxy = '$proxyUsername:$proxyPassword@$proxyHost:$proxyPort';
  }
  switch (proxyType) {
    case ProxyType.system:
      if (GetPlatform.isMobile) {
        Map<String, String>? systemProxy = await SystemProxy.getProxySettings();
        if (systemProxy != null) {
          proxy = 'PROXY ${systemProxy['host']}:${systemProxy['port']}';
        } else {
          proxy = 'DIRECT';
        }
      }

      if (GetPlatform.isDesktop) {
        final proxyEnable = await SystemNetworkProxy.getProxyEnable();
        final proxyServer = await SystemNetworkProxy.getProxyServer();
        logger.d('proxyEnable: $proxyEnable proxyServer: $proxyServer');
        if (proxyEnable && proxyServer.isNotEmpty) {
          proxy = 'PROXY $proxyServer';
        } else {
          proxy = 'DIRECT';
        }
      }
      break;
    case ProxyType.http:
      proxy = 'PROXY $proxy';
      break;
    case ProxyType.socks5:
      proxy = 'SOCKS5 $proxy';
      break;
    case ProxyType.socks4:
      proxy = 'SOCKS4 $proxy';
      break;
    case ProxyType.direct:
      proxy = 'DIRECT';
      break;
  }

  return proxy;
}
