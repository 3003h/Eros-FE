import 'package:dio/dio.dart';
import 'package:fehviewer/utils/optional.dart';

// dio 配置项
class DioHttpConfig {
  const DioHttpConfig({
    this.baseUrl,
    this.proxy,
    this.cookiesPath,
    this.interceptors,
    this.domainFronting,
    this.connectTimeout = Duration.millisecondsPerMinute,
    this.sendTimeout = Duration.millisecondsPerMinute,
    this.receiveTimeout = Duration.millisecondsPerMinute,
    this.maxConnectionsPerHost,
    this.contentType = Headers.formUrlEncodedContentType,
  });

  final String? baseUrl;
  final String? proxy;
  final String? cookiesPath;
  final List<Interceptor>? interceptors;
  final int connectTimeout;
  final int sendTimeout;
  final int receiveTimeout;
  final bool? domainFronting;
  final int? maxConnectionsPerHost;
  final String? contentType;

  DioHttpConfig copyWith({
    String? baseUrl,
    String? proxy,
    String? cookiesPath,
    List<Interceptor>? interceptors,
    int? connectTimeout,
    int? sendTimeout,
    int? receiveTimeout,
    bool? domainFronting,
    int? maxConnectionsPerHost,
    String? contentType,
  }) {
    return DioHttpConfig(
      baseUrl: baseUrl ?? this.baseUrl,
      proxy: proxy ?? this.proxy,
      cookiesPath: cookiesPath ?? this.cookiesPath,
      interceptors: interceptors ?? this.interceptors,
      connectTimeout: connectTimeout ?? this.connectTimeout,
      sendTimeout: sendTimeout ?? this.sendTimeout,
      receiveTimeout: receiveTimeout ?? this.receiveTimeout,
      domainFronting: domainFronting ?? this.domainFronting,
      maxConnectionsPerHost:
          maxConnectionsPerHost ?? this.maxConnectionsPerHost,
      contentType: contentType ?? this.contentType,
    );
  }

  @override
  String toString() {
    return 'DioHttpConfig{baseUrl: $baseUrl, proxy: $proxy, cookiesPath: $cookiesPath, interceptors: $interceptors, connectTimeout: $connectTimeout, sendTimeout: $sendTimeout, receiveTimeout: $receiveTimeout, domainFronting: $domainFronting, maxConnectionsPerHost: $maxConnectionsPerHost, contentType: $contentType}';
  }
}
