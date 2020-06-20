import 'package:FEhViewer/utils/toast.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

class HttpManager {
  final int connectTimeout = 10000;
  final int receiveTimeout = 5000;

  //单例模式
  static Map _instanceMap = new Map();

  Dio _dio;
  BaseOptions _options;

  //单例模式，一个baseUrl只创建一次实例
  static HttpManager getInstance([baseUrl = ""]) {
    if (null == _instanceMap[baseUrl]) {
      _instanceMap[baseUrl] = new HttpManager(baseUrl);
    }
    return _instanceMap[baseUrl];
  }

  //构造函数
  HttpManager(_baseUrl) {
    _options = new BaseOptions(
        baseUrl: _baseUrl,
        //连接时间为5秒
        connectTimeout: connectTimeout,
        //响应时间为3秒
        receiveTimeout: receiveTimeout,
        //设置请求头
        // headers: {
        //   "resource":"android"
        // },
        //默认值是"application/json; charset=utf-8",Headers.formUrlEncodedContentType会自动编码请求体.
        contentType: Headers.formUrlEncodedContentType,
        //共有三种方式json,bytes(响应字节),stream（响应流）,plain
        responseType: ResponseType.json);
    _dio = new Dio(_options);
    //设置Cookie
//    _dio.interceptors.add(CookieManager(CookieJar()));

    //添加拦截器
    _dio.interceptors
        .add(InterceptorsWrapper(onRequest: (RequestOptions options) {
      return options;
    }, onResponse: (Response response) {
      return response;
    }, onError: (DioError e) {
      return e;
    }));
  }

  //get请求方法
  get(url, {params, options, cancelToken}) async {
    Response response;
    try {
      response = await _dio.get(url,
          queryParameters: params, options: options, cancelToken: cancelToken);
    } on DioError catch (e) {
      print('getHttp exception: $e');
      formatError(e);
//      return response;
    }
    return response.data;
  }

  //post请求
  post(url, {params, options, cancelToken}) async {
    Response response;
    try {
      response = await _dio.post(url,
          queryParameters: params, options: options, cancelToken: cancelToken);
      debugPrint('postHttp response: $response');
    } on DioError catch (e) {
      print('postHttp exception: $e');
      formatError(e);
    }
    return response;
  }

  //post Form请求
  postForm(url, {data, options, cancelToken}) async {
    Response response;
    try {
      response = await _dio.post(url,
          options: options, cancelToken: cancelToken, data: data);
//      debugPrint('postHttp response: $response');
    } on DioError catch (e) {
//      print('postHttp exception: $e');
      formatError(e);
    }
    return response;
  }

  //下载文件
  downLoadFile(urlPath, savePath) async {
    Response response;
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
  cancleRequests(CancelToken token) {
    token.cancel("cancelled");
  }

  void formatError(DioError e) {
    if (e.type == DioErrorType.CONNECT_TIMEOUT) {
      showToast("网络好像出问题了");
    } else if (e.type == DioErrorType.SEND_TIMEOUT) {
      showToast("请求超时");
    } else if (e.type == DioErrorType.RECEIVE_TIMEOUT) {
      showToast("响应超时");
    } else if (e.type == DioErrorType.RESPONSE) {
      showToast("出现异常");
    } else if (e.type == DioErrorType.CANCEL) {
      showToast("请求取消");
    } else {
      showToast("网络好像出问题了");
    }
  }
}
