import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fehviewer/utils/logger.dart';

import 'exception.dart';
import 'http_transformer.dart';

class DioHttpResponse<T> {
  DioHttpResponse._internal({this.ok = false});

  DioHttpResponse.success(this.data) {
    ok = true;
  }

  DioHttpResponse.failure({String? errorMsg, int? errorCode}) {
    error = BadRequestException(message: errorMsg, code: errorCode);
    ok = false;
  }

  DioHttpResponse.failureFormResponse({dynamic data}) {
    error = BadResponseException(data);
    ok = false;
  }

  DioHttpResponse.failureFromError([HttpException? error]) {
    this.error = error ?? UnknownException();
    ok = false;
  }

  late bool ok;
  T? data;
  HttpException? error;
}

FutureOr<DioHttpResponse> handleResponse(Response? response,
    {HttpTransformer? httpTransformer}) async {
  httpTransformer ??= DefaultHttpTransformer.getInstance();

  // 返回值异常
  if (response == null) {
    return DioHttpResponse.failureFromError();
  }

  // token失效
  if (_isTokenTimeout(response.statusCode)) {
    return DioHttpResponse.failureFromError(
        UnauthorisedException(message: '没有权限', code: response.statusCode));
  }
  // 接口调用成功
  if (_isRequestSuccess(response.statusCode)) {
    return await httpTransformer.parse(response);
  } else {
    // 接口调用失败
    logger.d('接口调用失败');
    return DioHttpResponse.failure(
        errorMsg: response.statusMessage, errorCode: response.statusCode);
  }
}

DioHttpResponse<T> handleException<T>(Exception exception, {dynamic data}) {
  var parseException = _parseException(exception, data: data);
  return DioHttpResponse.failureFromError(parseException);
}

/// 鉴权失败
bool _isTokenTimeout(int? code) {
  return code == 401;
}

/// 请求成功
bool _isRequestSuccess(int? statusCode) {
  return statusCode != null && statusCode >= 200 && statusCode <= 302;
}

HttpException _parseException(Exception error, {dynamic data}) {
  if (error is DioError) {
    switch (error.type) {
      case DioErrorType.connectTimeout:
      case DioErrorType.receiveTimeout:
      case DioErrorType.sendTimeout:
        return NetworkException(message: error.error as String?);
      case DioErrorType.cancel:
        return CancelException(error.error as String?);
      case DioErrorType.response:
        try {
          int? errCode = error.response?.statusCode;
          switch (errCode) {
            case 400:
              return BadRequestException(
                  message: '400', code: errCode, data: data);
            case 401:
              return UnauthorisedException(
                  message: '401 Unauthorised', code: errCode);
            case 403:
              return BadRequestException(
                  message: '403 Error', code: errCode, data: data);
            case 404:
              return BadRequestException(
                  message: '404 Not Found', code: errCode, data: data);
            case 405:
              return BadRequestException(message: '405', code: errCode);
            case 500:
              return BadServiceException(message: '500', code: errCode);
            case 502:
              return BadServiceException(message: '502', code: errCode);
            case 503:
              return BadServiceException(message: '503', code: errCode);
            case 505:
              return UnauthorisedException(message: '505', code: errCode);
            default:
              return UnknownException(error.error.message as String?);
          }
        } on Exception catch (_) {
          return UnknownException(error.error.message as String?);
        }

      case DioErrorType.other:
        if (error.error is SocketException) {
          return NetworkException(message: error.message);
        } else {
          return UnknownException(error.message);
        }
      default:
        return UnknownException(error.message);
    }
  } else {
    return UnknownException(error.toString());
  }
}
