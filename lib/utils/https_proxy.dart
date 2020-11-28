import 'dart:convert';
import 'dart:io';

import 'package:FEhViewer/common/global.dart';
import 'package:FEhViewer/models/dnsCache.dart';

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
  String host;
  int port;

  void closeSockets() {
//    print('socket is going to destroy');
    if (server != null) {
      server.destroy();
    }
    client.destroy();
  }

  void dataHandler(data) {
    final List<DnsCache> _hosts = Global.profile.dnsConfig.hosts;
    if (server == null) {
      content += utf8.decode(data);
      // Global.logger.v('$content');
      final RegExpMatch m = regx.firstMatch(content);
      if (m != null) {
        host = m.group(1);
        port = m.group(2) == null ? 443 : int.parse(m.group(2));
        final int _index =
            _hosts.indexWhere((DnsCache element) => element.host == host);
        final realHost =
            _hosts != null && _index >= 0 ? _hosts[_index].addr : host;
        try {
          ServerConnectionHandler(realHost, port, this)
              .handle()
              .catchError((e) {
            print('Server error $e');
            closeSockets();
          });
        } catch (e) {
          print('Server exception $e');
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
    print('server socket error: $error');
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
