import 'dart:async';

import 'package:dio/dio.dart';

typedef RetryEvaluator = FutureOr<bool> Function(DioError error);

class RetryOptions {
  const RetryOptions(
      {this.retries = 3,
      RetryEvaluator? retryEvaluator,
      this.retryInterval = const Duration(seconds: 1)})
      : _retryEvaluator = retryEvaluator;

  factory RetryOptions.fromExtra(RequestOptions? request) {
    return request?.extra[extraKey];
  }

  factory RetryOptions.noRetry() {
    return const RetryOptions(
      retries: 0,
    );
  }

  /// The number of retry in case of an error
  final int retries;

  /// The interval before a retry.
  final Duration retryInterval;

  /// Evaluating if a retry is necessary.regarding the error.
  ///
  /// It can be a good candidate for additional operations too, like
  /// updating authentication token in case of a unauthorized error (be careful
  /// with concurrency though).
  ///
  /// Defaults to [defaultRetryEvaluator].
  RetryEvaluator get retryEvaluator => _retryEvaluator ?? defaultRetryEvaluator;

  final RetryEvaluator? _retryEvaluator;

  static const String extraKey = 'cache_retry_request';

  /// Returns [true] only if the response hasn't been cancelled or got
  /// a bas status code.
  static FutureOr<bool> defaultRetryEvaluator(DioError error) {
    return error.type != DioErrorType.cancel &&
        error.type != DioErrorType.response;
  }

  RetryOptions copyWith({
    int? retries,
    Duration? retryInterval,
  }) =>
      RetryOptions(
        retries: retries ?? this.retries,
        retryInterval: retryInterval ?? this.retryInterval,
      );

  Map<String, dynamic> toExtra() {
    return {
      extraKey: this,
    };
  }

  Options toOptions() {
    return Options(extra: toExtra());
  }

  Options mergeIn(Options options) {
    return options
      ..extra?.addAll(
          <String, dynamic>{}..addAll(options.extra ?? {})..addAll(toExtra()));
  }
}
