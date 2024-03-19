import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:eros_fe/common/global.dart';
import 'package:eros_fe/common/service/dns_service.dart';
import 'package:eros_fe/common/service/ehsetting_service.dart';
import 'package:eros_fe/const/const.dart';
import 'package:eros_fe/network/app_dio/proxy.dart';
import 'package:eros_fe/network/dio_interceptor/domain_fronting/domain_fronting.dart';
import 'package:eros_fe/network/dio_interceptor/eh_cookie_interceptor/eh_cookie_interceptor.dart';
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
    interceptors.add(RetryInterceptor(
      dio: this,
      logPrint: logger.t, // specify log function (optional)
      retries: 3, // retry count (optional)
      retryDelays: const [
        // set delays between retries (optional)
        Duration(seconds: 1), // wait 1 sec before first retry
        Duration(seconds: 2), // wait 2 sec before second retry
        Duration(seconds: 3), // wait 3 sec before third retry
      ],
    ));

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
    // We set the `responseType` to [ResponseType.STREAM] to retrieve the
    // response stream.
    options ??= DioMixin.checkOptions('GET', options);

    // Receive data with stream.
    options.responseType = ResponseType.stream;
    Response<ResponseBody> response;
    try {
      response = await request<ResponseBody>(
        urlPath,
        data: data,
        options: options,
        queryParameters: queryParameters,
        cancelToken: cancelToken ?? CancelToken(),
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.badResponse) {
        if (e.response!.requestOptions.receiveDataWhenStatusError == true) {
          final res = await transformer.transformResponse(
            e.response!.requestOptions..responseType = ResponseType.json,
            e.response!.data as ResponseBody,
          );
          e.response!.data = res;
        } else {
          e.response!.data = null;
        }
      }
      rethrow;
    }
    final File file;

    // if (savePath is FutureOr<String> Function(Headers)) {
    //   // Add real Uri and redirect information to headers.
    //   response.headers
    //     ..add('redirects', response.redirects.length.toString())
    //     ..add('uri', response.realUri.toString());
    //   file = File(await savePath(response.headers));
    // } else if (savePath is String) {
    //   file = File(savePath);
    // } else {
    //   throw ArgumentError.value(
    //     savePath.runtimeType,
    //     'savePath',
    //     'The type must be `String` or `FutureOr<String> Function(Headers)`.',
    //   );
    // }

    if (savePath is DioSavePath) {
      response.headers
        ..add('redirects', response.redirects.length.toString())
        ..add('uri', response.realUri.toString());
      file = File(savePath.path(response.headers));
    } else {
      throw ArgumentError.value(
        savePath.runtimeType,
        'savePath',
        'The type must be `DioSavePath`.',
      );
    }

    // If the directory (or file) doesn't exist yet, the entire method fails.
    file.createSync(recursive: true);

    // Shouldn't call file.writeAsBytesSync(list, flush: flush),
    // because it can write all bytes by once. Consider that the file is
    // a very big size (up to 1 Gigabytes), it will be expensive in memory.
    RandomAccessFile raf = file.openSync(mode: FileMode.write);

    // Create a Completer to notify the success/error state.
    final completer = Completer<Response>();
    Future<Response> future = completer.future;
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
        await raf.close();
        if (deleteOnError && file.existsSync()) {
          await file.delete();
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
            await subscription.cancel();
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
          await raf.close();
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
            DioMixin.assureDioException(e as Object, response.requestOptions),
          );
        }
      },
      cancelOnError: true,
    );
    cancelToken?.whenCancel.then((_) async {
      await subscription.cancel();
      await closeAndDelete();
    });

    final timeout = response.requestOptions.receiveTimeout;
    if (timeout != null) {
      future = future.timeout(timeout).catchError(
        (dynamic e, StackTrace s) async {
          await subscription.cancel();
          await closeAndDelete();
          if (e is TimeoutException) {
            throw DioException.receiveTimeout(
              timeout: timeout,
              requestOptions: response.requestOptions,
              error: e,
            );
          } else {
            throw e as Object;
          }
        },
      );
    }
    return DioMixin.listenCancelForAsyncTask(cancelToken, future);
  }
}
