import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:eros_fe/common/global.dart';
import 'package:eros_fe/common/service/dns_service.dart';
import 'package:eros_fe/common/service/ehsetting_service.dart';
import 'package:eros_fe/const/const.dart';
import 'package:eros_fe/network/app_dio/proxy.dart';
import 'package:eros_fe/network/dio_interceptor/domain_fronting/domain_fronting.dart';
import 'package:eros_fe/network/dio_interceptor/eh_cookie_interceptor/eh_cookie_interceptor.dart';
import 'package:eros_fe/network/dio_interceptor/rate_limit/rate_limit_interceptor.dart';
import 'package:eros_fe/network/dio_interceptor/rate_limit/token_bucket_interceptor.dart';
import 'package:eros_fe/utils/logger.dart';
import 'package:firebase_performance_dio/firebase_performance_dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:native_dio_adapter/native_dio_adapter.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../api.dart';
import 'http_config.dart';

export 'http_config.dart';

typedef AppHttpAdapter = HttpProxyAdapter;

typedef SavePathBuild = String Function(Headers);

class DioSavePath {
  const DioSavePath({required this.pathBuilder});
  final SavePathBuild pathBuilder;

  String path(Headers h) => pathBuilder(h);
}

extension SavePathExt on String {
  DioSavePath get toDioSavePath => DioSavePath(pathBuilder: (_) => this);
}

class AppDio with DioMixin implements Dio {
  AppDio({BaseOptions? options, DioHttpConfig? dioConfig}) {
    options ??= BaseOptions(
      baseUrl: dioConfig?.baseUrl ?? '',
      contentType: dioConfig?.contentType ?? Headers.formUrlEncodedContentType,
      connectTimeout: dioConfig?.connectTimeout != null
          ? Duration(seconds: dioConfig!.connectTimeout)
          : null,
      sendTimeout: dioConfig?.sendTimeout != null
          ? Duration(seconds: dioConfig!.sendTimeout)
          : null,
      receiveTimeout: dioConfig?.receiveTimeout != null
          ? Duration(seconds: dioConfig!.receiveTimeout)
          : null,
      headers: <String, String>{
        'User-Agent': EHConst.CHROME_USER_AGENT,
        'Accept': EHConst.CHROME_ACCEPT,
        'Accept-Language': EHConst.CHROME_ACCEPT_LANGUAGE,
      },
    );
    this.options = options;

    logger.t('dioConfig ${dioConfig?.toString()}');

    httpClientAdapter = Get.find<EhSettingService>().nativeHttpClientAdapter
        ? NativeAdapter()
        : AppHttpAdapter(
            proxy: dioConfig?.proxy ?? '',
            skipCertificate: dioConfig?.domainFronting,
          );
    // httpClientAdapter = AppHttpAdapter(
    //   proxy: dioConfig?.proxy ?? '',
    //   skipCertificate: dioConfig?.domainFronting,
    // );

    interceptors.add(DioCacheInterceptor(options: Api.cacheOption));

    if (Global.enableFirebase) {
      interceptors.add(DioFirebasePerformanceInterceptor());
    }

    // Cookie管理
    if (dioConfig?.cookiesPath?.isNotEmpty ?? false) {
      interceptors.add(CookieManager(
          PersistCookieJar(storage: FileStorage(dioConfig!.cookiesPath))));
    }

    interceptors.add(EhCookieInterceptor());

    // 限频 普通
    interceptors.add(RateLimitInterceptor(
      rateLimitInterval: const Duration(milliseconds: 200),
      globalLimit: false,
    ));

    // 缩略图请求的限频配置
    final thumbRateLimitConfig = RateLimitConfig(
      maxTokens: 20,
      refillDuration: const Duration(milliseconds: 400),
    );

    // 限频 桶令牌
    interceptors.add(
      TokenBucketInterceptor(
        defaultMaxTokens: 10, // 默认令牌桶最大容量
        defaultRefillDuration: const Duration(milliseconds: 500), // 默认令牌补充间隔时间
        globalLimit: false, // 是否全局限制
        hostConfig: {
          // 缩略图 详情页
          r'^(?!-)[a-zA-Z0-9-]{1,63}(?<!-).hath.network$': thumbRateLimitConfig,
          // 缩略图
          'ehgt.org': thumbRateLimitConfig,
          // 缩略图 (封面?)
          's.exhentai.org': thumbRateLimitConfig,
          'e-hentai.org': RateLimitConfig(
            maxTokens: 5,
            refillDuration: const Duration(milliseconds: 800),
          ),
          'exhentai.org': RateLimitConfig(
            maxTokens: 5,
            refillDuration: const Duration(milliseconds: 800),
          ),
        },
      ),
    );

    // 限频 滑动窗口
    // interceptors.add(
    //   SlidingWindowInterceptor(
    //     defaultMaxRequests: 3, // 默认时间窗口内最大请求数
    //     defaultWindowDuration: const Duration(seconds: 2), // 默认时间窗口时长
    //     globalLimit: true, // false表示按主机限流
    //     hostConfig: {
    //       'ehgt.org': SlidingWindowConfig(
    //         maxRequests: 4,
    //         windowDuration: const Duration(milliseconds: 800),
    //       ),
    //       'e-hentai.org': SlidingWindowConfig(
    //         maxRequests: 3,
    //         windowDuration: const Duration(seconds: 1),
    //       ),
    //       'exhentai.org': SlidingWindowConfig(
    //         maxRequests: 3,
    //         windowDuration: const Duration(seconds: 1),
    //       ),
    //     },
    //   ),
    // );

    // if (kDebugMode) {
    //   interceptors.add(LogInterceptor(
    //       responseBody: false,
    //       error: true,
    //       requestHeader: false,
    //       responseHeader: false,
    //       request: true,
    //       requestBody: true));
    // }

    interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: false,
      maxWidth: 120,
      // logPrint: kDebugMode ? loggerSimple.d : loggerSimpleOnlyFile.d,
      logPrint: loggerSimpleOnlyFile.d,
    ));

    // RetryInterceptor
    // interceptors.add(RetryInterceptor(
    //   dio: this,
    //   logPrint: logger.t, // specify log function (optional)
    //   retries: 3, // retry count (optional)
    //   retryDelays: const [
    //     // set delays between retries (optional)
    //     Duration(seconds: 1), // wait 1 sec before first retry
    //     Duration(seconds: 2), // wait 2 sec before second retry
    //     Duration(seconds: 3), // wait 3 sec before third retry
    //   ],
    // ));

    if (dioConfig?.interceptors?.isNotEmpty ?? false) {
      interceptors.addAll(interceptors);
    }

    if (dioConfig?.domainFronting ?? false) {
      final DnsService dnsServices = Get.find();
      final bool enableDoH = dnsServices.enableDoH;

      final customHosts = dnsServices.hostMapMerge;

      final domainFronting = DomainFronting(
        hosts: customHosts,
        dnsLookup: dnsServices.getHost,
      );

      // 允许证书错误的地址/ip
      final hostWhiteList = customHosts.values.flattened.toSet();

      // (httpClientAdapter as HttpProxyAdapter)
      //     .addOnHttpClientCreate((client) {
      //   client.badCertificateCallback =
      //       (X509Certificate cert, String host, int port) {
      //     // return hostWhiteList.contains(host);
      //     return true;
      //   };
      // });

      // 在其他插件添加完毕后再添加，以确保执行顺序正确
      domainFronting.bind(interceptors);
    }
  }

  /// DioMixin 没有实现下载
  /// 从 [DioForNative] 复制过来的

  /// {@macro dio.Dio.download}
  @override
  Future<Response> download(
    String urlPath,
    dynamic savePath, {
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    bool deleteOnError = true,
    String lengthHeader = Headers.contentLengthHeader,
    Object? data,
    Options? options,
  }) async {
    options ??= DioMixin.checkOptions('GET', options);
    // Manually set the `responseType` to [ResponseType.stream]
    // to retrieve the response stream.
    // Do not modify previous options.
    options = options.copyWith(responseType: ResponseType.stream);
    final Response<ResponseBody> response;
    try {
      response = await request<ResponseBody>(
        urlPath,
        data: data,
        options: options,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.badResponse) {
        final response = e.response!;
        if (response.requestOptions.receiveDataWhenStatusError == true) {
          final ResponseType implyResponseType;
          final contentType = response.headers.value(Headers.contentTypeHeader);
          if (contentType != null && contentType.startsWith('text/')) {
            implyResponseType = ResponseType.plain;
          } else {
            implyResponseType = ResponseType.json;
          }
          final res = await transformer.transformResponse(
            response.requestOptions.copyWith(responseType: implyResponseType),
            response.data as ResponseBody,
          );
          response.data = res;
        } else {
          response.data = null;
        }
      }
      rethrow;
    }
    final File file;
    if (savePath is FutureOr<String> Function(Headers)) {
      // Add real Uri and redirect information to headers.
      response.headers
        ..add('redirects', response.redirects.length.toString())
        ..add('uri', response.realUri.toString());
      file = File(await savePath(response.headers));
    } else if (savePath is String) {
      file = File(savePath);
    } else if (savePath is DioSavePath) {
      // Add for fe
      response.headers
        ..add('redirects', response.redirects.length.toString())
        ..add('uri', response.realUri.toString());
      file = File(savePath.path(response.headers));
    } else {
      throw ArgumentError.value(
        savePath.runtimeType,
        'savePath',
        'The type must be `String` or `FutureOr<String> Function(Headers)`.',
      );
    }

    // If the file already exists, the method fails.
    file.createSync(recursive: true);

    // Shouldn't call file.writeAsBytesSync(list, flush: flush),
    // because it can write all bytes by once. Consider that the file is
    // a very big size (up to 1 Gigabytes), it will be expensive in memory.
    RandomAccessFile raf = file.openSync(mode: FileMode.write);

    // Create a Completer to notify the success/error state.
    final completer = Completer<Response>();
    int received = 0;

    // Stream<Uint8List>
    final stream = response.data!.stream;
    bool compressed = false;
    int total = 0;
    final contentEncoding = response.headers.value(
      Headers.contentEncodingHeader,
    );
    if (contentEncoding != null) {
      compressed = ['gzip', 'deflate', 'compress'].contains(contentEncoding);
    }
    if (lengthHeader == Headers.contentLengthHeader && compressed) {
      total = -1;
    } else {
      total = int.parse(response.headers.value(lengthHeader) ?? '-1');
    }

    Future<void>? asyncWrite;
    bool closed = false;
    Future<void> closeAndDelete() async {
      if (!closed) {
        closed = true;
        await asyncWrite;
        await raf.close().catchError((_) => raf);
        if (deleteOnError && file.existsSync()) {
          await file.delete().catchError((_) => file);
        }
      }
    }

    late StreamSubscription subscription;
    subscription = stream.listen(
      (data) {
        subscription.pause();
        // Write file asynchronously
        asyncWrite = raf.writeFrom(data).then((result) {
          // Notify progress
          received += data.length;
          onReceiveProgress?.call(received, total);
          raf = result;
          if (cancelToken == null || !cancelToken.isCancelled) {
            subscription.resume();
          }
        }).catchError((Object e) async {
          try {
            await subscription.cancel().catchError((_) {});
            closed = true;
            await raf.close().catchError((_) => raf);
            if (deleteOnError && file.existsSync()) {
              await file.delete().catchError((_) => file);
            }
          } finally {
            completer.completeError(
              DioMixin.assureDioException(e, response.requestOptions),
            );
          }
        });
      },
      onDone: () async {
        try {
          await asyncWrite;
          closed = true;
          await raf.close().catchError((_) => raf);
          completer.complete(response);
        } catch (e) {
          completer.completeError(
            DioMixin.assureDioException(e, response.requestOptions),
          );
        }
      },
      onError: (e) async {
        try {
          await closeAndDelete();
        } finally {
          completer.completeError(
            DioMixin.assureDioException(e, response.requestOptions),
          );
        }
      },
      cancelOnError: true,
    );
    cancelToken?.whenCancel.then((_) async {
      await subscription.cancel();
      await closeAndDelete();
    });
    return DioMixin.listenCancelForAsyncTask(cancelToken, completer.future);
  }
}
