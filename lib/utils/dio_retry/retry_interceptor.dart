import 'package:dio/dio.dart';

import '../logger.dart';
import 'options.dart';

/// An interceptor that will try to send failed request again
class RetryInterceptor extends Interceptor {
  RetryInterceptor({required this.dio, RetryOptions? options})
      : options = options ?? const RetryOptions();

  final Dio dio;
  final RetryOptions options;

  @override
  Future onError(DioError err, ErrorInterceptorHandler handler) async {
    RetryOptions? retryOptions;
    try {
      retryOptions = RetryOptions.fromExtra(err.requestOptions);
    } catch (e) {
      logger.e('retryOptions error');
      return;
    }

    if (retryOptions == null) {
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

      try {
        logger.d(
            '[${err.requestOptions.uri}] An error occured during request, trying a again (remaining tries: ${retryOptions.retries}, error: ${err.error})');
        // We retry with the updated options
        return await dio.request(
          err.requestOptions.path,
          cancelToken: err.requestOptions.cancelToken,
          data: err.requestOptions.data,
          onReceiveProgress: err.requestOptions.onReceiveProgress,
          onSendProgress: err.requestOptions.onSendProgress,
          queryParameters: err.requestOptions.queryParameters,
        );
      } catch (e) {
        return e;
      }
    }

    return handler.next(err);
  }
}
