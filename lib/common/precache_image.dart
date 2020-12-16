import 'dart:isolate';

import 'package:FEhViewer/utils/logger.dart';
import 'package:flutter/cupertino.dart';

/// 缓存图片的顶级函数
Future<void> _precacheImage(PrecacheMessageProtocol protocol) async {
  // logger.i('start precacheImageCompute ${protocol.url}');
  logger.i('start _precacheImage ');
  protocol.sendPort.send(' 123456');
  // await precacheImage(
  //     ExtendedNetworkImageProvider(
  //       protocol.url,
  //       cache: true,
  //       retries: 5,
  //     ),
  //     protocol.context);
}

class PrecacheMessageProtocol {
  PrecacheMessageProtocol({this.context, this.url, this.sendPort});
  final BuildContext context;
  final String url;
  final SendPort sendPort;
}

class PreCacheImage {
  static Future<void> createIsolate(BuildContext context, String url) async {
    //创建一个 ReceivePort
    final ReceivePort receivePort = ReceivePort();
    //创建 isolate ， 并且将和 ReceivePort 对应的 SendPort 传给 isolate
    final PrecacheMessageProtocol protocol = PrecacheMessageProtocol(
      url: url,
      sendPort: receivePort.sendPort,
    );
    Isolate isolate;
    try {
      isolate = await Isolate.spawn(
        _precacheImage,
        protocol,
        debugName: 'precacheImageIsolate',
      );
      receivePort.listen((dynamic message) {
        print(message.toString());
      });
    } catch (e, stack) {
      logger.e('$e /n $stack');
    } finally {
      isolate.addOnExitListener(receivePort.sendPort,
          response: 'isolate has been killed');
    }
    isolate?.kill();
  }
}

/// Compute方式 不支持传入异步方法 放弃使用
// Future<void> precacheImageCompute(BuildContext context, String url) async {
//   final PrecacheMessageProtocol protocol =
//       PrecacheMessageProtocol(context, url);
//   await compute(_precacheImage, protocol);
// }
