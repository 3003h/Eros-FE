import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:dio_firebase_performance/dio_firebase_performance.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/const/const.dart';
import 'package:fehviewer/utils/time.dart';
import 'package:fehviewer/utils/toast.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import 'dio_retry/options.dart';
import 'dio_retry/retry_interceptor.dart';
import 'logger.dart';

const int kDefconnectTimeout = 10000;
const int kDefreceiveTimeout = 10000;

class HttpManager {
  //构造函数
  HttpManager(
    String _baseUrl, {
    bool cache = true,
    bool retry = false,
    int? connectTimeout = kDefconnectTimeout,
  }) {
    _options = BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: connectTimeout ?? kDefconnectTimeout,
        receiveTimeout: kDefreceiveTimeout,
        //设置请求头
        headers: <String, String>{
          'User-Agent': EHConst.CHROME_USER_AGENT,
          'Accept': EHConst.CHROME_ACCEPT,
          'Accept-Language': EHConst.CHROME_ACCEPT_LANGUAGE,
        },
        //默认值是"application/json; charset=utf-8",Headers.formUrlEncodedContentType会自动编码请求体.
        contentType: Headers.formUrlEncodedContentType,
        //共有三种方式json,bytes(响应字节),stream（响应流）,plain
        responseType: ResponseType.json);
    _dio = Dio(_options);

    // Cookie管理拦截器
    _dio.interceptors.add(Global.cookieManager);

    // 缓存拦截器
    if (cache) {
      _dio.interceptors.add(DioCacheManager(
        CacheConfig(
          databasePath: Global.appSupportPath,
          baseUrl: _baseUrl,
        ),
      ).interceptor);
    }

    _dio.interceptors.add(DioFirebasePerformanceInterceptor());

    _dio.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: false,
      maxWidth: 120,
      // logPrint: kDebugMode ? loggerSimple.d : loggerSimpleOnlyFile.d,
      logPrint: loggerSimpleOnlyFile.d,
    ));

    // if (kDebugMode) {
    //   _dio.interceptors.add(LogInterceptor(
    //       responseBody: false,
    //       error: true,
    //       requestHeader: false,
    //       responseHeader: false,
    //       request: true,
    //       requestBody: true));
    // }

    // _dio.interceptors.add(LogInterceptor(
    //     logPrint: (Object log) {
    //       if ('$log'.trim().isEmpty) {
    //         return;
    //       }
    //       if (log is String && log.startsWith('\n')) {
    //         loggerSimple.d(log.substring(1).trim());
    //       } else {
    //         loggerSimple.d('$log'.trim());
    //       }
    //     },
    //     responseBody: false,
    //     error: true,
    //     requestHeader: false,
    //     responseHeader: false,
    //     request: true,
    //     requestBody: true));

    if (retry) {
      _dio.interceptors.add(RetryInterceptor(
          dio: _dio..options.extra.addAll({DIO_CACHE_KEY_FORCE_REFRESH: true}),
          options: RetryOptions(
            retries: 3, // Number of retries before a failure
            retryInterval:
                const Duration(seconds: 1), // Interval between each retry
            retryEvaluator: (error) =>
                error.type != DioErrorType.cancel &&
                error.type !=
                    DioErrorType
                        .response, // Evaluating if a retry is necessary regarding the error. It is a good candidate for updating authentication token in case of a unauthorized error (be careful with concurrency though)
          )));
    }

    (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      final HttpClient httpClient = HttpClient();
      httpClient.badCertificateCallback =
          (X509Certificate cert, String host, int port) {
        return true;
      };
      return httpClient;
    };
  }

  //单例模式
  static final Map<String, HttpManager> _instanceMap = <String, HttpManager>{};

  late Dio _dio;

  Dio get dio => _dio;
  late BaseOptions _options;

  //单例模式，一个baseUrl只创建一次实例
  static HttpManager getInstance(
      {String baseUrl = '', bool cache = true, bool retry = false}) {
    final String _key = '${baseUrl}_$cache';
    if (null == _instanceMap[_key]) {
      _instanceMap[_key] = HttpManager(baseUrl, cache: cache, retry: retry);
    }
    return _instanceMap[_key]!;
  }

  //get请求方法
  Future<String?> get(
    String url, {
    Map<String, dynamic>? params,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    Response<String> response;

    time.showTime('get $url start');
    try {
      response = await _dio.get<String>(url,
          queryParameters: params, options: options, cancelToken: cancelToken);
    } on DioError catch (e, stack) {
      if (CancelToken.isCancel(e)) {
        // print('$e');
      } else {
        logger.e('getHttp exception: $e\n$stack');
      }

      formatError(e);
      rethrow;
    }
    time.showTime('get $url end');

    // print('getHttp statusCode: ${response.statusCode}');
    return response.data;
  }

  Future<Response<dynamic>> getAll(
    String url, {
    Map<String, dynamic>? params,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    late Response<dynamic> response;
    try {
      response = await _dio.get<dynamic>(url,
          queryParameters: params, options: options, cancelToken: cancelToken);
    } on DioError catch (e) {
      logger.e('getHttp exception: $e');
//      formatError(e);
      return response;
//      throw e;
    }
    return response;
  }

  //post请求
  Future<Response<dynamic>> post(
    String url, {
    Map<String, dynamic>? params,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    late Response<dynamic> response;
    try {
      response = await _dio.post<dynamic>(url,
          queryParameters: params, options: options, cancelToken: cancelToken);
    } on DioError catch (e) {
      logger.e('postHttp exception: $e');
      formatError(e);
//      throw e;
    }
    return response;
  }

  //post Form请求
  Future<Response<dynamic>> postForm(
    String url, {
    Object? data,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    late Response<dynamic> response;
    try {
      response = await _dio.post<dynamic>(url,
          options: options, cancelToken: cancelToken, data: data);
//      debugPrint('postHttp response: $response');
    } on DioError catch (e) {
//      print('postHttp exception: $e');
      formatError(e);
      rethrow;
//      throw e;
    }
    return response;
  }

  //下载文件
  Future<Response<dynamic>> downLoadFile(
    String urlPath,
    String savePath, {
    CancelToken? cancelToken,
  }) async {
    late Response<dynamic> response;
    try {
      response = await _dio.download(
        urlPath,
        savePath,
        onReceiveProgress: (int count, int total) {
          logger.v('$count $total');
        },
        options: Options(
          receiveTimeout: 0,
        ),
        cancelToken: cancelToken,
      );
      // print('downLoadFile response: $response');
    } on DioError catch (e) {
      // logger.e('downLoadFile exception: $e');
      if (CancelToken.isCancel(e)) {
        // print('$e');
      }
      formatError(e);
      rethrow;
    }
    return response;
  }

  //取消请求
  void cancleRequests(CancelToken token) {
    token.cancel('cancelled');
  }

  void formatError(DioError e) {
    if (e.type == DioErrorType.connectTimeout) {
      showToast('连接超时');
    } else if (e.type == DioErrorType.sendTimeout) {
      showToast('请求超时');
    } else if (e.type == DioErrorType.receiveTimeout) {
      showToast('响应超时');
    } else if (e.type == DioErrorType.response) {
      showToast('响应异常');
    } else if (e.type == DioErrorType.cancel) {
      // showToast('请求取消');
    } else {
      showToast('网络好像出问题了');
    }
  }
}
