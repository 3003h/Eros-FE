import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:dio_firebase_performance/dio_firebase_performance.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/common/service/dns_service.dart';
import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/network/dio_interceptor/domain_fronting/domain_fronting.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import 'http_config.dart';

export 'http_config.dart';

class AppDio with DioMixin implements Dio {
  AppDio({BaseOptions? options, DioHttpConfig? dioConfig}) {
    options ??= BaseOptions(
      baseUrl: dioConfig?.baseUrl ?? '',
      contentType: Headers.formUrlEncodedContentType,
      connectTimeout: dioConfig?.connectTimeout,
      sendTimeout: dioConfig?.sendTimeout,
      receiveTimeout: dioConfig?.receiveTimeout,
      headers: <String, String>{
        'User-Agent': EHConst.CHROME_USER_AGENT,
        'Accept': EHConst.CHROME_ACCEPT,
        'Accept-Language': EHConst.CHROME_ACCEPT_LANGUAGE,
      },
    );
    this.options = options;

    logger.v('dioConfig ${dioConfig?.toString()}');

    // DioCacheManager
    final cacheOptions = CacheConfig(
      databasePath: Global.appSupportPath,
      baseUrl: dioConfig?.baseUrl,
      defaultRequestMethod: 'GET',
    );
    interceptors.add(DioCacheManager(cacheOptions).interceptor as Interceptor);

    // Cookie管理
    if (dioConfig?.cookiesPath?.isNotEmpty ?? false) {
      interceptors.add(CookieManager(
          PersistCookieJar(storage: FileStorage(dioConfig!.cookiesPath))));
    }

    // if (kDebugMode) {
    //   interceptors.add(LogInterceptor(
    //       responseBody: false,
    //       error: true,
    //       requestHeader: false,
    //       responseHeader: false,
    //       request: true,
    //       requestBody: true));
    // }

    interceptors.add(DioFirebasePerformanceInterceptor());

    interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: false,
      maxWidth: 120,
      logPrint: kDebugMode ? loggerSimple.d : loggerSimpleOnlyFile.d,
      // logPrint: loggerSimpleOnlyFile.d,
    ));

    if (dioConfig?.interceptors?.isNotEmpty ?? false) {
      interceptors.addAll(interceptors);
    }
    httpClientAdapter = DefaultHttpClientAdapter();
    if (dioConfig?.proxy?.isNotEmpty ?? false) {
      setProxy(dioConfig!.proxy!);
    }

    if (dioConfig?.domainFronting ?? false) {
      final DnsService dnsServices = Get.find();
      final bool enableDoH = dnsServices.enableDoH;

      final coutomHosts = dnsServices.hostMapMerge;

      final domainFronting = DomainFronting(
        hosts: coutomHosts,
        dnsLookup: enableDoH
            ? (String host) async {
                final dc = await dnsServices.getDoHCache(host);
                return dc?.addr ?? host;
              }
            : null,
      );

      // 允许证书错误的地址/ip
      final hostWhiteList = coutomHosts.values.toSet();

      (httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          return hostWhiteList.contains(host);
        };
      };

      // 在其他插件添加完毕后再添加，以确保执行顺序正确
      domainFronting.bind(interceptors);
    }
  }

  void setProxy(String proxy) {
    (httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (client) {
      // config the http client
      client.findProxy = (uri) {
        // proxy all request to localhost:8888
        return 'PROXY $proxy';
      };
      // you can also create a HttpClient to dio
      // return HttpClient();
    };
  }
}
