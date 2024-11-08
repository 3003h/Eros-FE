import 'dart:async';

import 'package:dio/dio.dart';
import 'package:eros_fe/index.dart';

class RateLimitConfig {
  RateLimitConfig({
    required this.maxTokens,
    required this.refillDuration,
    this.isExactMatch = false,
  });

  final int maxTokens; // 令牌桶的最大容量
  final Duration refillDuration; // 令牌补充间隔时间
  final bool isExactMatch; // 是否为全匹配
}

class TokenBucketInterceptor extends Interceptor {
  factory TokenBucketInterceptor({
    required int defaultMaxTokens,
    required Duration defaultRefillDuration,
    bool globalLimit = true,
    Map<String, RateLimitConfig> hostConfig = const {},
  }) {
    return _instance ??= TokenBucketInterceptor._internal(
      defaultMaxTokens: defaultMaxTokens,
      defaultRefillDuration: defaultRefillDuration,
      globalLimit: globalLimit,
      hostConfig: hostConfig,
    );
  }

  TokenBucketInterceptor._internal({
    required this.defaultMaxTokens,
    required this.defaultRefillDuration,
    this.globalLimit = true,
    this.hostConfig = const {},
  }) : _globalAvailableTokens = defaultMaxTokens {
    if (globalLimit) {
      _startGlobalRefillTimer();
    }
  }

  static TokenBucketInterceptor? _instance;

  final int defaultMaxTokens;
  final Duration defaultRefillDuration;
  final bool globalLimit;
  final Map<String, RateLimitConfig> hostConfig;

  int _globalAvailableTokens;
  Timer? _globalRefillTimer;

  final Map<String, int> _hostAvailableTokens = {};
  final Map<String, Timer> _hostRefillTimers = {};
  final Map<String, int> _groupAvailableTokens = {};

  void _startGlobalRefillTimer() {
    _globalRefillTimer = Timer.periodic(defaultRefillDuration, (_) {
      if (_globalAvailableTokens < defaultMaxTokens) {
        _globalAvailableTokens++;
      }
    });
  }

  void _startHostRefillTimer(
      String host, int maxTokens, Duration refillDuration) {
    _hostRefillTimers[host] = Timer.periodic(refillDuration, (_) {
      if (_hostAvailableTokens[host]! < maxTokens) {
        _hostAvailableTokens[host] = _hostAvailableTokens[host]! + 1;
      }
    });
  }

  void _startGroupRefillTimer(
      String group, int maxTokens, Duration refillDuration) {
    _hostRefillTimers[group] = Timer.periodic(refillDuration, (_) {
      if (_groupAvailableTokens[group]! < maxTokens) {
        _groupAvailableTokens[group] = _groupAvailableTokens[group]! + 1;
      }
    });
  }

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final host = options.uri.host;

    if (globalLimit) {
      await _acquireTokenGlobally();
    } else {
      await _acquireTokenPerHost(host);
    }

    handler.next(options);
  }

  Future<void> _acquireTokenGlobally() async {
    while (_globalAvailableTokens <= 0) {
      logger.w('等待全局令牌补充');
      await Future.delayed(defaultRefillDuration);
    }
    _globalAvailableTokens--;
    logger.t('获取全局令牌, 剩余 $_globalAvailableTokens');
  }

  Future<void> _acquireTokenPerHost(String host) async {
    final config = _getHostConfig(host);

    if (config.isExactMatch) {
      if (!_hostAvailableTokens.containsKey(host)) {
        _hostAvailableTokens[host] = config.maxTokens;
        _startHostRefillTimer(host, config.maxTokens, config.refillDuration);
      }

      while (_hostAvailableTokens[host]! <= 0) {
        logger.w('等待令牌补充 $host');
        await Future.delayed(config.refillDuration);
      }
      _hostAvailableTokens[host] = _hostAvailableTokens[host]! - 1;
      logger.d('获取令牌 $host, 剩余 ${_hostAvailableTokens[host]}');
    } else {
      final group = hostConfig.keys.firstWhere(
          (pattern) => RegExp(pattern).hasMatch(host),
          orElse: () => host);
      if (!_groupAvailableTokens.containsKey(group)) {
        _groupAvailableTokens[group] = config.maxTokens;
        _startGroupRefillTimer(group, config.maxTokens, config.refillDuration);
      }

      while (_groupAvailableTokens[group]! <= 0) {
        logger.w('等待令牌补充 $group');
        await Future.delayed(config.refillDuration);
      }
      _groupAvailableTokens[group] = _groupAvailableTokens[group]! - 1;
      logger.t('获取令牌 $group, 剩余 ${_groupAvailableTokens[group]}');
    }
  }

  RateLimitConfig _getHostConfig(String host) {
    logger.t('获取 $host 的限频配置');
    for (final entry in hostConfig.entries) {
      final pattern = entry.key;
      final config = entry.value;
      if (config.isExactMatch && pattern == host) {
        return config;
      } else if (!config.isExactMatch && RegExp(pattern).hasMatch(host)) {
        return config;
      }
    }
    return RateLimitConfig(
      maxTokens: defaultMaxTokens,
      refillDuration: defaultRefillDuration,
    );
  }

  void dispose() {
    _globalRefillTimer?.cancel();
    for (final timer in _hostRefillTimers.values) {
      timer.cancel();
    }
  }
}
