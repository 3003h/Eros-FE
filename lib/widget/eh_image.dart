import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui show Codec, ImmutableBuffer;

import 'package:fehviewer/common/service/ehconfig_service.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/network/request.dart';
import 'package:fehviewer/pages/image_view/controller/view_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;

/// 页面信息
@immutable
class EhPageInfo {
  const EhPageInfo({
    this.pageUrl,
    required this.gid,
    required this.ser,
  });
  final String? pageUrl;
  final int gid;
  final int ser;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EhPageInfo &&
          runtimeType == other.runtimeType &&
          gid == other.gid &&
          ser == other.ser;

  @override
  int get hashCode => gid.hashCode ^ ser.hashCode;
}

/// 进度 额外增加处理阶段
class EhImageChunkEvent extends ImageChunkEvent {
  const EhImageChunkEvent({
    required this.stage,
    this.ser,
    required int cumulativeBytesLoaded,
    int? expectedTotalBytes,
  }) : super(
          cumulativeBytesLoaded: cumulativeBytesLoaded,
          expectedTotalBytes: expectedTotalBytes,
        );
  final String stage;
  final int? ser;
}

@immutable
class EhImageProvider extends ImageProvider<EhImageProvider> {
  const EhImageProvider(this.pageInfo, {this.scale = 1.0});

  final EhPageInfo pageInfo;

  final double scale;

  @override
  Future<EhImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<EhImageProvider>(this);
  }

  @override
  ImageStreamCompleter loadBuffer(
      EhImageProvider key, DecoderBufferCallback decode) {
    final chunkEventsController = StreamController<EhImageChunkEvent>();
    return MultiFrameImageStreamCompleter(
      codec: _loadBufferAsync(key, chunkEventsController),
      scale: key.scale,
      chunkEvents: chunkEventsController.stream,
      informationCollector: () sync* {
        yield ErrorDescription('PageInfo: $pageInfo');
      },
    );
  }

  Future<ui.Codec> _loadBufferAsync(EhImageProvider key,
      StreamController<ImageChunkEvent> chunkEvents) async {
    assert(key == this);

    Uint8List? bytes;
    final downloadOrigImage = Get.find<EhConfigService>().downloadOrigImage;

    chunkEvents.sink.add(EhImageChunkEvent(
        stage: '加载画廊',
        ser: key.pageInfo.ser,
        cumulativeBytesLoaded: 0,
        expectedTotalBytes: 0));
    // chunkEvents.sink.add(EhImageChunkEvent(
    //     stage: '获取图片地址', cumulativeBytesLoaded: 0, expectedTotalBytes: 0));

    final ViewExtController viewExtController = Get.find();
    final galleryImage = await viewExtController.fetchImage(key.pageInfo.ser);
    if (galleryImage == null) {
      throw Exception('fetchImage error');
    }

    if (galleryImage.filePath?.isNotEmpty ?? false) {
      logger.d('图片文件已下载 file... ${galleryImage.filePath}');
      bytes = await File(galleryImage.filePath!).readAsBytes();
    }

    if (galleryImage.tempPath?.isNotEmpty ?? false) {
      logger.d('tempPath file... ${galleryImage.tempPath}');
      bytes = await File(galleryImage.tempPath!).readAsBytes();
    }

    if (bytes == null) {
      final tempPath = path.join(Global.tempPath, 'temp_gallery_image',
          'temp_${key.pageInfo.gid}_${galleryImage.ser}');
      // temp file exist
      if (File(tempPath).existsSync()) {
        logger.d('tempPath file... $tempPath');
        bytes = await File(tempPath).readAsBytes();
      } else {
        // 下载图片
        final imageUrl = downloadOrigImage
            ? galleryImage.originImageUrl
            : galleryImage.imageUrl;
        logger.d('imageUrl... $imageUrl');
        await ehDownload(
            url: '$imageUrl',
            savePath: tempPath,
            progressCallback: (int count, int total) {
              chunkEvents.sink.add(EhImageChunkEvent(
                  stage: '下载图片',
                  ser: key.pageInfo.ser,
                  cumulativeBytesLoaded: count,
                  expectedTotalBytes: total));
            });
        bytes = await File(tempPath).readAsBytes();
      }
    }

    // chunkEvents.sink.add(EhImageChunkEvent(
    //     stage: '加载图片', cumulativeBytesLoaded: 0, expectedTotalBytes: 1000));

    if (bytes.lengthInBytes == 0) {
      throw 'bytes and loadedCallback is null';
    }
    final buff = await ui.ImmutableBuffer.fromUint8List(bytes);
    return await PaintingBinding.instance.instantiateImageCodecFromBuffer(buff);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EhImageProvider &&
          runtimeType == other.runtimeType &&
          pageInfo == other.pageInfo &&
          scale == other.scale;

  @override
  int get hashCode => pageInfo.hashCode ^ scale.hashCode;

  @override
  String toString() {
    return 'EhImage{pageInfo: $pageInfo, scale: $scale}';
  }
}
