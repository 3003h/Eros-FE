import 'package:dio/dio.dart';

// dio 配置项
class DioHttpConfig {
  DioHttpConfig({
    this.baseUrl,
    this.proxy,
    this.cookiesPath,
    this.interceptors,
    this.domainFronting,
    this.connectTimeout = Duration.millisecondsPerMinute,
    this.sendTimeout = Duration.millisecondsPerMinute,
    this.receiveTimeout = Duration.millisecondsPerMinute,
  });

  final String? baseUrl;
  final String? proxy;
  final String? cookiesPath;
  final List<Interceptor>? interceptors;
  final int connectTimeout;
  final int sendTimeout;
  final int receiveTimeout;
  final bool? domainFronting;

// static DioConfig of() => Get.find<DioConfig>();
}
