import 'package:dio/dio.dart';
import 'package:eros_fe/common/service/dns_service.dart';
import 'package:eros_fe/extension.dart';
import 'package:eros_fe/utils/logger.dart';
import 'package:get/get.dart';

final EHInterceptor ehInterceptor = EHInterceptor();

class EHInterceptor extends Interceptor {
  @override
  Future<dynamic> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    logger.d(
        '${options.baseUrl}  \n${options.path} \n${options.headers['Host'] ?? options.headers['host']} ');
    final DnsService dnsConfigController = Get.find();
    _paraOptions(options);
    return options;
  }

  Future<void> _paraOptions(RequestOptions options) async {
    // logger.d('_handBefore url = $url');
    final String host = Uri.parse(options.baseUrl).host;
    if (host.isNotEmpty) {
      if (!host.isIPv4) {
        await _updateDoHCache(host);
      }

      final String newUrl = options.baseUrl.toRealUrl();
      logger.d('newUrl $newUrl');
      options.baseUrl = newUrl;
      options.headers['Host'] = host;
    }

    final String path = options.path;
    final String hostInPath = Uri.parse(path).host;
    if (hostInPath.isNotEmpty) {
      if (!hostInPath.isIPv4) {
        await _updateDoHCache(hostInPath);
      }

      final String newPath = path.toRealUrl();
      logger.d('newPath $newPath');
      options.path = options.path.replaceFirst(path, newPath);
      options.headers['Host'] = host;
    }

    logger.d(
        '${options.baseUrl}  \n${options.path} \n${options.headers['Host'] ?? options.headers['host']} ');
  }

  Future<void> _updateDoHCache(String host) async {
    final DnsService dnsConfigController = Get.find();
    final bool enableDoH = dnsConfigController.enableDoH;
    // 更新doh
    if (enableDoH) {
      await dnsConfigController.getDoHCache(host);
    }
  }
}
