import 'dart:async';

import 'package:dio/dio.dart';
import 'package:eros_fe/index.dart';

class SlidingWindowConfig {
  // 窗口时间长度

  SlidingWindowConfig({
    required this.maxRequests,
    required this.windowDuration,
  });
  final int maxRequests; // 窗口内最大请求数
  final Duration windowDuration;
}

class SlidingWindowInterceptor extends Interceptor {
  // 使用 factory 构造函数创建单例
  factory SlidingWindowInterceptor({
    required int defaultMaxRequests,
    required Duration defaultWindowDuration,
    bool globalLimit = true,
    Map<String, SlidingWindowConfig> hostConfig = const {},
  }) {
    // 如果 _instance 已存在，直接返回现有实例
    return _instance ??= SlidingWindowInterceptor._internal(
      defaultMaxRequests: defaultMaxRequests,
      defaultWindowDuration: defaultWindowDuration,
      globalLimit: globalLimit,
      hostConfig: hostConfig,
    );
  }

  // 私有的命名构造函数
  SlidingWindowInterceptor._internal({
    required this.defaultMaxRequests,
    required this.defaultWindowDuration,
    this.globalLimit = true,
    this.hostConfig = const {},
  }) : _globalWindowStart = DateTime.now();

  static SlidingWindowInterceptor? _instance;

  final int defaultMaxRequests; // 默认每个窗口的最大请求数
  final Duration defaultWindowDuration; // 默认时间窗口大小
  final bool globalLimit; // 是否为全局限制
  final Map<String, SlidingWindowConfig> hostConfig; // 主机的单独配置

  // 全局限流使用的计数器和时间窗口
  int _globalRequestCount = 0;
  DateTime _globalWindowStart;

  // 每个主机的请求计数器和窗口开始时间
  final Map<String, int> _hostRequestCounts = {};
  final Map<String, DateTime> _hostWindowStarts = {};

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final host = options.uri.host;

    if (globalLimit) {
      await _handleGlobalRateLimit(handler);
    } else {
      await _handleHostRateLimit(host, handler);
    }

    handler.next(options);
  }

  Future<void> _handleGlobalRateLimit(RequestInterceptorHandler handler) async {
    final now = DateTime.now();

    // 检查是否在当前时间窗口内
    if (now.difference(_globalWindowStart) >= defaultWindowDuration) {
      // 重置计数器和窗口开始时间
      _globalWindowStart = now;
      _globalRequestCount = 0;
      logger.d('重置全局请求计数');
    }

    // 判断请求数量是否超限
    if (_globalRequestCount < defaultMaxRequests) {
      _globalRequestCount++; // 增加全局请求计数
      logger.d('全局请求计数: $_globalRequestCount');
    } else {
      // 请求超出限制，延迟至下一个窗口
      logger.d('请求超出限制，延迟至下一个全局窗口');
      await Future.delayed(
          defaultWindowDuration - now.difference(_globalWindowStart));
    }
  }

  Future<void> _handleHostRateLimit(
      String host, RequestInterceptorHandler handler) async {
    final now = DateTime.now();
    final config = hostConfig[host] ??
        SlidingWindowConfig(
          maxRequests: defaultMaxRequests,
          windowDuration: defaultWindowDuration,
        );

    // 初始化主机的请求计数和窗口时间
    if (!_hostRequestCounts.containsKey(host)) {
      _hostRequestCounts[host] = 0;
      _hostWindowStarts[host] = now;
      logger.d('初始化 $host 请求计数');
    }

    // 检查是否在当前时间窗口内
    if (now.difference(_hostWindowStarts[host]!) >= config.windowDuration) {
      // 重置该主机的计数器和窗口开始时间
      _hostWindowStarts[host] = now;
      _hostRequestCounts[host] = 0;
    }

    // 判断请求数量是否超限
    if (_hostRequestCounts[host]! < config.maxRequests) {
      _hostRequestCounts[host] = _hostRequestCounts[host]! + 1; // 增加该主机的请求计数
      logger.d('host: $host, 请求计数: ${_hostRequestCounts[host]}');
    } else {
      logger.d('请求超出限制，延迟至下一个 $host 窗口');
      // 请求超出限制，延迟至下一个窗口
      await Future.delayed(
          config.windowDuration - now.difference(_hostWindowStarts[host]!));
    }
  }
}
