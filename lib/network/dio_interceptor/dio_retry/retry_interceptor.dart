import 'package:dio/dio.dart';

import '../../../utils/logger.dart';
import 'options.dart';

/// An interceptor that will try to send failed request again
class RetryInterceptor extends Interceptor {
  RetryInterceptor({required this.dio, RetryOptions? options})
      : options = options ?? const RetryOptions();

  final Dio dio;
  final RetryOptions options;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final RetryOptions retryOptions = RetryOptions.fromExtra(options);
    if (retryOptions.retries < 0) {
      options.extra.addAll(this.options.toExtra());
    }
    handler.next(options);
  }

  @override
  Future<void> onError(DioError err, ErrorInterceptorHandler handler) async {
    late RetryOptions retryOptions;

    // logger.d('RetryInterceptor onError');
    // logger.d('err.requestOptions.extra: ${err.requestOptions.extra}');

    try {
      retryOptions = RetryOptions.fromExtra(err.requestOptions);
    } catch (e, stack) {
      logger.e('retryOptions error \n$e\n$stack');
      handler.next(err);
      return;
    }

    if (retryOptions.retries == 0) {
      logger.d('retries 0 => handler.next(err)');
      handler.next(err);
      return;
    }

    final bool shouldRetry =
        retryOptions.retries > 0 && await options.retryEvaluator(err);
    if (shouldRetry) {
      if (retryOptions.retryInterval.inMilliseconds > 0) {
        await Future.delayed(retryOptions.retryInterval);
      }

      // Update options to decrease retry count before new try
      retryOptions = retryOptions.copyWith(retries: retryOptions.retries - 1);
      err.requestOptions.extra = err.requestOptions.extra
        ..addAll(retryOptions.toExtra());

      logger.d('err.requestOptions.extra: ${err.requestOptions.extra}');

      final Options _options = Options(
        method: err.requestOptions.method,
        sendTimeout: err.requestOptions.sendTimeout,
        receiveTimeout: err.requestOptions.sendTimeout,
        extra: err.requestOptions.extra,
        headers: err.requestOptions.headers,
        responseType: err.requestOptions.responseType,
        contentType: err.requestOptions.contentType,
        validateStatus: err.requestOptions.validateStatus,
        receiveDataWhenStatusError:
            err.requestOptions.receiveDataWhenStatusError,
        followRedirects: err.requestOptions.followRedirects,
        maxRedirects: err.requestOptions.sendTimeout,
        requestEncoder: err.requestOptions.requestEncoder,
        responseDecoder: err.requestOptions.responseDecoder,
        listFormat: err.requestOptions.listFormat,
      );

      try {
        logger5.d(
            '[${err.requestOptions.uri}] An error occured during request, trying a again (remaining tries: ${retryOptions.retries}, error: ${err.error})');
        // We retry with the updated options

        await dio.request(
          err.requestOptions.path,
          cancelToken: err.requestOptions.cancelToken,
          data: err.requestOptions.data,
          onReceiveProgress: err.requestOptions.onReceiveProgress,
          onSendProgress: err.requestOptions.onSendProgress,
          queryParameters: err.requestOptions.queryParameters,
          options: _options,
        );
      } on DioError catch (e) {
        // return e;
        handler.next(e);
      }
    }

    return handler.next(err);
  }
}
