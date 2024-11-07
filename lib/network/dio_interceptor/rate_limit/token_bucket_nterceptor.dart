import 'dart:async';

import 'package:dio/dio.dart';
import 'package:eros_fe/index.dart';

class RateLimitConfig {
  // 令牌补充间隔时间

  RateLimitConfig({
    required this.maxTokens,
    required this.refillDuration,
  });
  final int maxTokens; // 令牌桶的最大容量
  final Duration refillDuration;
}

class TokenBucketInterceptor extends Interceptor {
  TokenBucketInterceptor({
    required this.defaultMaxTokens,
    required this.defaultRefillDuration,
    this.globalLimit = true,
    this.hostConfig = const {}, // 可选的特定主机配置
  }) : _globalAvailableTokens = defaultMaxTokens {
    if (globalLimit) {
      _startGlobalRefillTimer();
    }
  }
  final int defaultMaxTokens; // 默认令牌桶最大容量
  final Duration defaultRefillDuration; // 默认令牌补充时间
  final bool globalLimit; // 是否全局限制

  // 特定主机配置
  final Map<String, RateLimitConfig> hostConfig;

  int _globalAvailableTokens;
  Timer? _globalRefillTimer;

  final Map<String, int> _hostAvailableTokens = {};
  final Map<String, Timer> _hostRefillTimers = {};

  // 启动全局限频令牌桶
  void _startGlobalRefillTimer() {
    _globalRefillTimer = Timer.periodic(defaultRefillDuration, (_) {
      if (_globalAvailableTokens < defaultMaxTokens) {
        _globalAvailableTokens++;
      }
    });
  }

  // 启动按主机限频令牌桶
  void _startHostRefillTimer(
      String host, int maxTokens, Duration refillDuration) {
    _hostRefillTimers[host] = Timer.periodic(refillDuration, (_) {
      if (_hostAvailableTokens[host]! < maxTokens) {
        _hostAvailableTokens[host] = _hostAvailableTokens[host]! + 1;
      }
    });
  }

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final host = options.uri.host;

    logger.d('host: $host');

    if (globalLimit) {
      await _acquireTokenGlobally();
    } else {
      await _acquireTokenPerHost(host);
    }

    handler.next(options);
  }

  // 获取全局限频令牌
  Future<void> _acquireTokenGlobally() async {
    while (_globalAvailableTokens <= 0) {
      logger.d('等待令牌补充');
      await Future.delayed(defaultRefillDuration);
    }
    _globalAvailableTokens--;
    logger.d('获取全局令牌成功, 剩余 $_globalAvailableTokens');
  }

  // 获取按主机限频令牌
  Future<void> _acquireTokenPerHost(String host) async {
    final config = hostConfig[host] ??
        RateLimitConfig(
          maxTokens: defaultMaxTokens,
          refillDuration: defaultRefillDuration,
        );

    // 初始化主机的令牌桶及定时器
    if (!_hostAvailableTokens.containsKey(host)) {
      _hostAvailableTokens[host] = config.maxTokens;
      _startHostRefillTimer(host, config.maxTokens, config.refillDuration);
    }

    // 检查令牌
    while (_hostAvailableTokens[host]! <= 0) {
      logger.d('等待 $host 令牌补充');
      await Future.delayed(config.refillDuration);
    }
    _hostAvailableTokens[host] = _hostAvailableTokens[host]! - 1;
    logger.d('获取 $host 令牌成功, 剩余 ${_hostAvailableTokens[host]}');
  }

  // 清理所有定时器
  void dispose() {
    _globalRefillTimer?.cancel();
    for (final timer in _hostRefillTimers.values) {
      timer.cancel();
    }
  }
}
