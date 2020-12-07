import 'dart:io';

import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/utils/toast.dart';
import 'package:FEhViewer/utils/utility.dart';
import 'package:FEhViewer/values/const.dart';
import 'package:cookie_jar/src/persist_cookie_jar.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:flutter/cupertino.dart';

class HttpManager {
  //构造函数
  HttpManager(String _baseUrl, {bool cache = true}) {
    _options = BaseOptions(
        baseUrl: _baseUrl,
        //连接时间为5秒
        connectTimeout: connectTimeout,
        //响应时间为3秒
        receiveTimeout: receiveTimeout,
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

    //设置Cookie管理
    _dio.interceptors.add(Global.cookieManager);

    //添加拦截器
    // _dio.interceptors.add(Global.netCache);
    if (cache) {
      _dio.interceptors.add(DioCacheManager(CacheConfig(
        databasePath: Global.appSupportPath,
        baseUrl: _baseUrl,
      )).interceptor);
    }
  }

  HttpManager.withProxy(String _baseUrl, {bool cache = true}) {
    _options = BaseOptions(
        baseUrl: _baseUrl,
        //连接时间为5秒
        connectTimeout: connectTimeout,
        //响应时间为3秒
        receiveTimeout: receiveTimeout,
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

    (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      client.findProxy = (Uri uri) => 'PROXY localhost:4041';
    };
    //设置Cookie管理
    _dio.interceptors.add(Global.cookieManager);

    // _dio.interceptors.add(Global.netCache);
    if (cache) {
      _dio.interceptors.add(DioCacheManager(CacheConfig(
        databasePath: Global.appSupportPath,
        baseUrl: _baseUrl,
      )).interceptor);
    }
  }

  final int connectTimeout = 8000;
  final int receiveTimeout = 10000;

  //单例模式
  static final Map<String, HttpManager> _instanceMap = <String, HttpManager>{};

  Dio _dio;
  BaseOptions _options;

  //单例模式，一个baseUrl只创建一次实例
  static HttpManager getInstance({String baseUrl = '', bool cache = true}) {
    final String _key = '${baseUrl}_$cache';
    if (null == _instanceMap[_key]) {
      _instanceMap[_key] = HttpManager(baseUrl, cache: cache);
    }
    return _instanceMap[_key];
  }

  //get请求方法
  Future<String> get(String url,
      {Map<String, dynamic> params,
      Options options,
      CancelToken cancelToken}) async {
    //设置Cookie管理
    _dio.interceptors.add(CookieManager(await Api.cookieJar));
    Response<String> response;
    try {
      response = await _dio.get<String>(url,
          queryParameters: params, options: options, cancelToken: cancelToken);
    } on DioError catch (e) {
      Global.logger.v('getHttp exception: $e');
      formatError(e);
      rethrow;
    }
    // print('getHttp statusCode: ${response.statusCode}');
    return response.data;
  }

  Future<Response<dynamic>> getAll(String url,
      {Map<String, dynamic> params,
      Options options,
      CancelToken cancelToken}) async {
    //设置Cookie管理
    // _dio.interceptors.add(CookieManager(await Api.cookieJar));

    Response<dynamic> response;
    try {
      response = await _dio.get<dynamic>(url,
          queryParameters: params, options: options, cancelToken: cancelToken);
    } on DioError catch (e) {
      print('getHttp exception: $e');
//      formatError(e);
      return response;
//      throw e;
    }
    return response;
  }

  //post请求
  Future<Response<dynamic>> post(String url,
      {Map<String, dynamic> params,
      Options options,
      CancelToken cancelToken}) async {
    //设置Cookie管理
    // _dio.interceptors.add(CookieManager(await Api.cookieJar));

    Response<dynamic> response;
    try {
      response = await _dio.post<dynamic>(url,
          queryParameters: params, options: options, cancelToken: cancelToken);
      debugPrint('postHttp response: $response');
    } on DioError catch (e) {
      print('postHttp exception: $e');
      formatError(e);
//      throw e;
    }
    return response;
  }

  //post Form请求
  Future<Response<dynamic>> postForm(String url,
      {Object data, Options options, CancelToken cancelToken}) async {
    //设置Cookie管理
    // _dio.interceptors.add(CookieManager(await Api.cookieJar));

    Response<dynamic> response;
    try {
      response = await _dio.post<dynamic>(url,
          options: options, cancelToken: cancelToken, data: data);
//      debugPrint('postHttp response: $response');
    } on DioError catch (e) {
//      print('postHttp exception: $e');
      formatError(e);
//      throw e;
    }
    return response;
  }

  //下载文件
  Future<Response<dynamic>> downLoadFile(
      String urlPath, String savePath) async {
    //设置Cookie管理
    // _dio.interceptors.add(CookieManager(await Api.cookieJar));

    Response<dynamic> response;
    try {
      response = await _dio.download(urlPath, savePath,
          onReceiveProgress: (int count, int total) {
        print('$count $total');
      });
      print('downLoadFile response: $response');
    } on DioError catch (e) {
      print('downLoadFile exception: $e');
      formatError(e);
    }
    return response;
  }

  //取消请求
  void cancleRequests(CancelToken token) {
    token.cancel('cancelled');
  }

  void formatError(DioError e) {
    if (e.type == DioErrorType.CONNECT_TIMEOUT) {
      showToast('连接超时');
    } else if (e.type == DioErrorType.SEND_TIMEOUT) {
      showToast('请求超时');
    } else if (e.type == DioErrorType.RECEIVE_TIMEOUT) {
      showToast('响应超时');
    } else if (e.type == DioErrorType.RESPONSE) {
      showToast('出现异常');
    } else if (e.type == DioErrorType.CANCEL) {
      showToast('请求取消');
    } else {
      showToast('网络好像出问题了');
    }
  }
}
