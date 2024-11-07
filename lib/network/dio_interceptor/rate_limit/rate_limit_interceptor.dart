import 'dart:async';
import 'dart:collection';

import 'package:dio/dio.dart';

class RateLimitInterceptor extends Interceptor {
  // 使用 factory 构造函数创建单例
  factory RateLimitInterceptor({
    required Duration rateLimitInterval,
    bool globalLimit = true,
  }) {
    return _instance ??= RateLimitInterceptor._internal(
      rateLimitInterval: rateLimitInterval,
      globalLimit: globalLimit,
    );
  }

  // 私有的命名构造函数
  RateLimitInterceptor._internal({
    required this.rateLimitInterval,
    this.globalLimit = true,
  });

  static RateLimitInterceptor? _instance;

  final Duration rateLimitInterval; // 请求间隔时间
  final bool globalLimit; // 是否为全局限频
  DateTime _lastGlobalRequestTime =
      DateTime.fromMillisecondsSinceEpoch(0); // 全局最后请求时间
  final Map<String, DateTime> _hostLastRequestTime = {}; // 每个host的最后请求时间
  final Queue<Future<void> Function()> _requestQueue = Queue();
  bool _isProcessingQueue = false;

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final now = DateTime.now();
    String host = options.uri.host;

    if (globalLimit) {
      // 全局限频
      final timeSinceLastRequest = now.difference(_lastGlobalRequestTime);
      if (timeSinceLastRequest < rateLimitInterval) {
        _enqueueRequest(() => _processRequest(options, handler));
      } else {
        _lastGlobalRequestTime = DateTime.now();
        handler.next(options);
      }
    } else {
      // 按主机限频
      final lastRequestTime =
          _hostLastRequestTime[host] ?? DateTime.fromMillisecondsSinceEpoch(0);
      final timeSinceLastHostRequest = now.difference(lastRequestTime);

      if (timeSinceLastHostRequest < rateLimitInterval) {
        _enqueueRequest(() => _processRequest(options, handler), host: host);
      } else {
        _hostLastRequestTime[host] = DateTime.now();
        handler.next(options);
      }
    }
  }

  // 将请求添加到队列
  void _enqueueRequest(Future<void> Function() requestFunction,
      {String? host}) {
    _requestQueue.add(() async {
      if (host != null) {
        _hostLastRequestTime[host] = DateTime.now();
      } else {
        _lastGlobalRequestTime = DateTime.now();
      }
      await requestFunction();
    });
    _processQueue();
  }

  // 处理队列中的请求
  void _processQueue() {
    if (_isProcessingQueue) {
      return;
    }
    _isProcessingQueue = true;

    Timer.periodic(rateLimitInterval, (timer) {
      if (_requestQueue.isNotEmpty) {
        final request = _requestQueue.removeFirst();
        request(); // 处理队列中的第一个请求
      } else {
        timer.cancel();
        _isProcessingQueue = false;
      }
    });
  }

  // 处理单个请求
  Future<void> _processRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    await Future.delayed(rateLimitInterval);
    handler.next(options);
  }
}
