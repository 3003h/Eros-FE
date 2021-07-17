import 'dart:async';

import 'package:dio/dio.dart';

typedef DomainFrontingDomainLookup = FutureOr<String?> Function(
    String hostname);

class DomainFronting {
  DomainFronting({
    Map<String, String>? hosts,
    DomainFrontingDomainLookup? dnsLookup,
    this.noIpSkip = true,
    this.manual = false,
    this.lookupCache = true,
  }) {
    _dnsLookup = dnsLookup;
    // 复制字典防止缓存污染外部数据
    this.hosts = {...hosts ?? {}};
  }

  /// [hosts]: 设置固定域名解析
  ///
  late Map<String, String> hosts;
  bool enable = true;

  /// [dnsLookup]: 设置后如果hosts中没有找到，将通过改方法解析ip
  ///
  late DomainFrontingDomainLookup? _dnsLookup;

  /// [lookupCache] 是否缓存[dnsLookup]返回的结果
  bool lookupCache;

  /// [noIpSkip]: 如果没有找到ip跳过DomainFronting功能，否则将抛出异常
  /// 设置为false所有请求默认启用，建议将[noIpSkip] 设置为 true
  ///
  bool noIpSkip;

  /// [manual] 手动模式，需要在请求的options传入[DomainFronting.auto] 或 [DomainFronting.ip] 才启用
  bool manual;

  // 用于手动模式
  static Options auto([Options? options]) {
    if (options == null) {
      return Options(extra: {'domainFronting': 'dns'});
    }
    final extra = {...options.extra ?? {}, 'domainFronting': 'dns'};
    return options.copyWith(extra: extra);
  }

  // 用于手动模式
  static Options ip(String ip, [Options? options]) {
    if (options == null) {
      return Options(extra: {'domainFronting': ip});
    }
    final extra = {...options.extra ?? {}, 'domainFronting': ip};
    return options.copyWith(extra: extra);
  }

  Future<String?> lookup(String hostname) async {
    print('hostname: ${hostname}');
    if (hosts.containsKey(hostname)) {
      return Future.value(hosts[hostname]);
    }
    if (_dnsLookup == null) return null;
    final ip = await _dnsLookup!(hostname);
    if (lookupCache && ip != null) hosts[hostname] = ip;
    return ip;
  }

  void bind(Interceptors interceptors) {
    interceptors.add(DomainFrontingInterceptorRequest(this));
    interceptors.insert(0, DomainFrontingInterceptorResponse(this));
  }
}

class DomainFrontingInterceptorResponse extends Interceptor {
  DomainFrontingInterceptorResponse(this.df);
  final DomainFronting df;

  @override
  void onResponse(
    Response e,
    ResponseInterceptorHandler handler,
  ) {
    if ((!df.enable) ||
        (!e.requestOptions.extra.containsKey('domainFrontingRawOptions'))) {
      handler.next(e);
      return;
    }
    final rawOptions = e.requestOptions.extra['domainFrontingRawOptions'];
    e.requestOptions = rawOptions;
    handler.next(e);
  }
}

class DomainFrontingInterceptorRequest extends Interceptor {
  DomainFrontingInterceptorRequest(this.df);
  final DomainFronting df;

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    if ((!df.enable) || options.uri.scheme.toLowerCase() != 'https') {
      handler.next(options);
      return;
    }
    if (df.manual && (!options.extra.containsKey('domainFronting'))) {
      handler.next(options);
      return;
    }

    final String domainFronting = options.extra['domainFronting'] ?? 'dns';
    final host = options.uri.host;
    String? ip;
    if (domainFronting != 'dns') {
      ip = domainFronting;
    } else {
      try {
        ip = await df.lookup(host);
      } catch (error, stackTrace) {
        final err = DioError(requestOptions: options, error: error);
        err.stackTrace = stackTrace;
        handler.reject(err, true);
        return;
      }
      if (ip == null) {
        if (df.noIpSkip) {
          handler.next(options);
          return;
        }
        final err = DioError(
            requestOptions: options,
            error: '[DomainFronting] Unable to get IP address');
        err.stackTrace = StackTrace.current;
        handler.reject(err, true);
        return;
      }
    }
    final newUri = options.uri.replace(host: ip);
    final headers = {...options.headers, 'host': host};
    final extra = {...options.extra, 'domainFrontingRawOptions': options};

    print('options.uri ${options.uri}');
    print('newUri $newUri');
    handler.next(options.copyWith(
        path: newUri.toString(), headers: headers, extra: extra));
  }
}
