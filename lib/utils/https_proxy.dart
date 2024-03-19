import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:eros_fe/common/global.dart';
import 'package:eros_fe/common/service/dns_service.dart';
import 'package:eros_fe/models/base/eh_models.dart';
import 'package:eros_fe/utils/logger.dart';
import 'package:eros_fe/utils/utility.dart';
import 'package:get/get.dart';

class CustomHttpsProxy {
  /// 内部构造方法，可避免外部暴露构造函数，进行实例化
  CustomHttpsProxy._internal();

  /// 工厂构造方法，这里使用命名构造函数方式进行声明
  factory CustomHttpsProxy.getInstance() => _getInstance();

  static CustomHttpsProxy get instance => _getInstance();

  /// 获取单例内部方法
  static CustomHttpsProxy _getInstance() {
    // 只能有一个实例
    _instance ??= CustomHttpsProxy._internal();
    return _instance!;
  }

  /// 单例对象
  static CustomHttpsProxy? _instance;

  ServerSocket? serverSocket;

  Future<ServerSocket?> init() async {
    if (serverSocket == null) {
      await ServerSocket.bind(InternetAddress.anyIPv4, kProxyPort)
          .then((ServerSocket serverSocket) {
        this.serverSocket = serverSocket;
        serverSocket.listen((Socket client) {
          try {
            ClientConnectionHandler(client).handle();
          } catch (e) {
            logger.e('ClientConnectionHandler exception $e');
          }
        });
      }).catchError((e) {
        logger.e('serverSocket 处理异常$e');
      });
    }

    return serverSocket;
  }

  void close() {
    if (serverSocket != null) {
      serverSocket?.close();
    }
  }
}

class ClientConnectionHandler {
  ClientConnectionHandler(this.client);

  final RegExp regx = RegExp(r'CONNECT ([^ :]+)(?::([0-9]+))? HTTP/1.1\r\n');

  Socket? server;
  Socket client;
  String content = '';
  late String _oriHost;
  late int port;

  final DnsService dnsConfigController = Get.find();

  void closeSockets() {
//    logger.d('socket is going to destroy');
    if (server != null) {
      server?.destroy();
    }
    client.destroy();
  }

  Future<void> dataHandler(dynamic data) async {
    // 自定义hosts
    final List<DnsCache> _customHosts = dnsConfigController.hosts;
    final bool enableDoH = dnsConfigController.enableDoH;

    if (server == null) {
      // 建立连接
      content += utf8.decode(data as List<int>);
      logger.d('\n$content');
      final RegExpMatch? m = regx.firstMatch(content);
      if (m != null) {
        _oriHost = m.group(1)!;
        port = m.group(2) == null ? 443 : int.parse(m.group(2)!);

        // 更新doh
        if (enableDoH) {
          await dnsConfigController.getDoHCache(_oriHost);
          // logger.d(' updateDoHCache end');
        }

        String realHost = _oriHost;
        try {
          final List<DnsCache> _dohDnsCacheList = dnsConfigController.dohCache;

          // 查询自定义hosts
          final int customDnsCacheIndex = _customHosts
              .indexWhere((DnsCache element) => element.host == _oriHost);
          final DnsCache? customDnsCache = customDnsCacheIndex > -1
              ? _customHosts[customDnsCacheIndex]
              : null;

          if (enableDoH) {
            final int _dohDnsCacheIndex = dnsConfigController.dohCache
                .indexWhere((DnsCache element) => element.host == _oriHost);

            final DnsCache? dohDnsCache = _dohDnsCacheIndex > -1
                ? _dohDnsCacheList[_dohDnsCacheIndex]
                : null;
            if (dnsConfigController.enableCustomHosts) {
              realHost = customDnsCache?.addr ?? dohDnsCache?.addr ?? _oriHost;
            } else {
              realHost = dohDnsCache?.addr ?? _oriHost;
            }
          } else {
            realHost = customDnsCache?.addr ?? _oriHost;
          }
        } catch (e, stack) {
          logger.e('$e \n $stack');
          closeSockets();
        }

        logger.d('$_oriHost  =>  $realHost');
        try {
          ServerConnectionHandler(realHost, port, this)
              .handle()
              .catchError((e) {
            logger.e('Server error $e');
            closeSockets();
          });
        } catch (e) {
          logger.e('Server exception $e');
          closeSockets();
        }
      }
    } else {
      // debugPrint('${data.runtimeType}');
      final String hex = EHUtils.formatBytesAsHexString(data as Uint8List);
      // logger.t(hex);
      // logger.d(EHUtils.stringToHex('e-hentai.org'));
      if (hex.contains(EHUtils.stringToHex('e-hentai.org')) ||
          hex.contains(EHUtils.stringToHex('exhentai.org')) ||
          hex.contains(EHUtils.stringToHex('ehgt.org')) ||
          hex.contains(EHUtils.stringToHex('hath.network'))) {
        logger.t('client hello [$hex]');
        // final String _newHex = hex.replaceFirst(
        //     EHUtils.stringToHex('e-hentai.org'),
        //     EHUtils.stringToHex('12345678.org'));
        // .replaceFirst(EHUtils.stringToHex('exhentai.org'),
        //     EHUtils.stringToHex('xxxxxxxxxxxx'))
        // .replaceFirst(EHUtils.stringToHex('ehgt.org'),
        //     EHUtils.stringToHex('xxxxxxxx'))
        // .replaceFirst(EHUtils.stringToHex('hath.network'),
        //     EHUtils.stringToHex('xxxxxxxxxxxx'));

        data = EHUtils.createUint8ListFromHexString(hex);
      }

      try {
        server?.add(data);
      } catch (e) {
        logger.e('sever has been shut down');
        closeSockets();
      }
    }
  }

  void errorHandler(error, StackTrace trace) {
    logger.e('client socket error: $error');
  }

  void doneHandler() {
    closeSockets();
  }

  void handle() {
    client.listen(dataHandler,
        onError: errorHandler, onDone: doneHandler, cancelOnError: true);
  }
}

class ServerConnectionHandler {
  ServerConnectionHandler(this.host, this.port, this.handler) {
    client = handler.client;
  }

  final String responce = 'HTTP/1.1 200 Connection Established\r\n\r\n';
  final String host;
  final int port;
  final ClientConnectionHandler handler;
  Socket? server;
  Socket? client;
  String content = '';

  //接收报文
  void dataHandler(Uint8List data) {
    try {
      client?.add(data);
    } on Exception catch (e) {
      logger.t('client has been shut down $e');
      handler.closeSockets();
    }
  }

  void errorHandler(error, StackTrace trace) {
    logger.e('server socket error: $error \n $trace');
    handler.closeSockets();
    throw error as Exception;
  }

  void doneHandler() {
    handler.closeSockets();
  }

  Future handle() async {
    // logger.d('尝试建立连接： $host:$port');
    server = await Socket.connect(host, port,
        timeout: const Duration(milliseconds: 10000));
    server?.listen(dataHandler,
        onError: errorHandler, onDone: doneHandler, cancelOnError: true);
    handler.server = server;
    client?.write(responce);
  }
}

class HttpProxy extends HttpOverrides {
  HttpProxy(this.host, this.port);

  String? host;
  String? port;

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final HttpClient client = super.createHttpClient(context);
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) {
      return true;
    };
    return client;
  }

  @override
  String findProxyFromEnvironment(Uri url, Map<String, String>? environment) {
    if (host == null) {
      return super.findProxyFromEnvironment(url, environment);
    }

    environment ??= {};

    if (port != null) {
      environment['http_proxy'] = '$host:$port';
      environment['https_proxy'] = '$host:$port';
    } else {
      environment['http_proxy'] = '$host:8888';
      environment['https_proxy'] = '$host:8888';
    }

    return super.findProxyFromEnvironment(url, environment);
  }
}
