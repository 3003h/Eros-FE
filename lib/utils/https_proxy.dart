import 'dart:convert';
import 'dart:io';

import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/models/dnsCache.dart';
import 'package:FEhViewer/utils/dns_util.dart';

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
    return _instance;
  }

  /// 单例对象
  static CustomHttpsProxy _instance;

  ServerSocket serverSocket;

  Future<ServerSocket> init() async {
    if (serverSocket == null) {
      await ServerSocket.bind(InternetAddress.anyIPv4, kProxyPort)
          .then((ServerSocket serverSocket) {
        this.serverSocket = serverSocket;
        serverSocket.listen((Socket client) {
          try {
            ClientConnectionHandler(client).handle();
          } catch (e) {
            print('ClientConnectionHandler exception $e');
          }
        });
      }).catchError((e) {
        print('serverSocket 处理异常$e');
      });
    }

    return serverSocket;
  }

  void close() {
    if (serverSocket != null) {
      serverSocket.close();
    }
  }
}

class ClientConnectionHandler {
  ClientConnectionHandler(this.client);

  final RegExp regx = RegExp(r'CONNECT ([^ :]+)(?::([0-9]+))? HTTP/1.1\r\n');

  Socket server;
  Socket client;
  String content = '';
  String _oriHost;
  int port;

  void closeSockets() {
//    print('socket is going to destroy');
    if (server != null) {
      server.destroy();
    }
    client.destroy();
  }

  void dataHandler(data) async {
    // 自定义hosts
    final List<DnsCache> _customHosts =
        Global.profile.dnsConfig.hosts ?? <DnsCache>[];
    final bool enableDoH = Global.profile.dnsConfig.enableDoH;

    if (server == null) {
      content += utf8.decode(data);
      Global.logger.d('\n$content');
      final RegExpMatch m = regx.firstMatch(content);
      if (m != null) {
        _oriHost = m.group(1);
        port = m.group(2) == null ? 443 : int.parse(m.group(2));

        // 更新doh
        if (enableDoH) {
          await DnsUtil.updateDoHCache(_oriHost);
          // Global.logger.d(' updateDoHCache end');
        }

        String realHost = _oriHost;
        try {
          final List<DnsCache> _dohDnsCacheList =
              Global.profile.dnsConfig.dohCache ?? <DnsCache>[];

          // 查询自定义hosts
          final int customDnsCacheIndex = _customHosts
              .indexWhere((DnsCache element) => element.host == _oriHost);
          final DnsCache customDnsCache = customDnsCacheIndex > -1
              ? _customHosts[customDnsCacheIndex]
              : null;

          if (enableDoH) {
            final int _dohDnsCacheIndex = Global.profile.dnsConfig.dohCache
                .indexWhere((DnsCache element) => element.host == _oriHost);
            Global.logger.d('$_oriHost $_dohDnsCacheIndex');
            final DnsCache dohDnsCache = _dohDnsCacheIndex > -1
                ? _dohDnsCacheList[_dohDnsCacheIndex]
                : null;
            if (Global.profile.dnsConfig.enableCustomHosts) {
              realHost = customDnsCache?.addr ?? dohDnsCache?.addr ?? _oriHost;
            } else {
              realHost = dohDnsCache?.addr ?? _oriHost;
            }
          } else {
            realHost = customDnsCache?.addr ?? _oriHost;
          }
        } catch (e, stack) {
          Global.logger.e('$e \n $stack');
        }

        Global.logger.i('$_oriHost  =>  $realHost');
        try {
          ServerConnectionHandler(realHost, port, this)
              .handle()
              .catchError((e) {
            Global.logger.e('Server error $e');
            closeSockets();
          });
        } catch (e) {
          Global.logger.e('Server exception $e');
          closeSockets();
        }
      }
    } else {
      try {
        server.add(data);
      } catch (e) {
        print('sever has been shut down');
        closeSockets();
      }
    }
  }

  void errorHandler(error, StackTrace trace) {
    print('client socket error: $error');
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
  Socket server;
  Socket client;
  String content = '';

  //接收报文
  void dataHandler(data) {
    try {
      client.add(data);
    } on Exception catch (e) {
      print('client has been shut down $e');
      handler.closeSockets();
    }
  }

  void errorHandler(error, StackTrace trace) {
    Global.logger.e('server socket error: $error \n $trace');
  }

  void doneHandler() {
    handler.closeSockets();
  }

  Future handle() async {
//    print('尝试建立连接： $host:$port');
    server =
        await Socket.connect(host, port, timeout: const Duration(seconds: 60));
    server.listen(dataHandler,
        onError: errorHandler, onDone: doneHandler, cancelOnError: true);
    handler.server = server;
    client.write(responce);
  }
}

class HttpProxy extends HttpOverrides {
  HttpProxy(this.host, this.port);

  String host;
  String port;

  @override
  HttpClient createHttpClient(SecurityContext context) {
    final HttpClient client = super.createHttpClient(context);
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) {
      return true;
    };
    return client;
  }

  @override
  String findProxyFromEnvironment(Uri url, Map<String, String> environment) {
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
