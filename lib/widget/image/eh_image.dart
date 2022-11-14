// @dart=2.17

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui show Codec, ImmutableBuffer;

import 'package:dio/dio.dart';
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
  ImageStreamCompleter load(EhImageProvider key, DecoderCallback decode) {
    final chunkEventsController = StreamController<EhImageChunkEvent>();
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, chunkEventsController, decode),
      chunkEvents: chunkEventsController.stream,
      scale: key.scale,
      informationCollector: () sync* {
        yield ErrorDescription('PageInfo: $pageInfo');
      },
    );
  }

  // @override
  // ImageStreamCompleter loadBuffer(
  //     EhImageProvider key, DecoderBufferCallback decode) {
  //   final chunkEventsController = StreamController<EhImageChunkEvent>();
  //   return MultiFrameImageStreamCompleter(
  //     codec: _loadBufferAsync(key, chunkEventsController),
  //     scale: key.scale,
  //     chunkEvents: chunkEventsController.stream,
  //     informationCollector: () sync* {
  //       yield ErrorDescription('PageInfo: $pageInfo');
  //     },
  //   );
  // }

  Future<ui.Codec> _loadAsync(
      EhImageProvider key,
      StreamController<ImageChunkEvent> chunkEvents,
      DecoderCallback decode) async {
    assert(key == this);

    final bytes = await getImageData(key, chunkEvents);

    if (bytes.lengthInBytes == 0) {
      throw 'bytes and loadedCallback is null';
    }

    return decode(bytes);
  }

  // Future<ui.Codec?> _loadBufferAsync(EhImageProvider key,
  //     StreamController<ImageChunkEvent> chunkEvents) async {
  //   assert(key == this);
  //
  //   final data = await getImageData(key, chunkEvents);
  //
  //   if (data.lengthInBytes == 0) {
  //     throw 'bytes and loadedCallback is null';
  //   }
  //   final buff = await ui.ImmutableBuffer.fromUint8List(data);
  //   return await PaintingBinding.instance.instantiateImageCodecFromBuffer(buff);
  // }

  Future<Uint8List> getImageData(EhImageProvider key,
      StreamController<ImageChunkEvent> chunkEvents) async {
    Uint8List? bytes;
    final downloadOrigImage = Get.find<EhConfigService>().downloadOrigImage;

    chunkEvents.sink.add(EhImageChunkEvent(
        stage: '加载画廊', ser: key.pageInfo.ser, cumulativeBytesLoaded: 0));

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
          'temp_${key.pageInfo.gid}_${galleryImage.ser}_${downloadOrigImage ? 'ori' : 'res'}');
      // temp file exist
      if (File(tempPath).existsSync()) {
        logger.d('tempPath file... $tempPath');
        bytes = await File(tempPath).readAsBytes();
      } else {
        // 下载图片
        final imageUrl = downloadOrigImage
            ? galleryImage.originImageUrl
            : galleryImage.imageUrl;
        logger.v('imageUrl... $imageUrl');
        try {
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
        } on DioError catch (e) {
          if (e.type == DioErrorType.response &&
              e.response?.statusCode == 403) {
            logger
                .d('403 ${key.pageInfo.gid}.${key.pageInfo.ser}下载链接已经失效 需要更新');
            final imageFetched = await _fetchImageInfo(galleryImage.href!,
                itemSer: key.pageInfo.ser,
                image: galleryImage,
                gid: key.pageInfo.gid,
                changeSource: true);
            logger.d('imageFetched... ${imageFetched.toJson()}');
            final imageUrl = downloadOrigImage
                ? imageFetched.originImageUrl
                : imageFetched.imageUrl;
            if (imageUrl != null) {
              await ehDownload(
                  url: imageUrl,
                  savePath: tempPath,
                  progressCallback: (int count, int total) {
                    chunkEvents.sink.add(EhImageChunkEvent(
                        stage: '下载图片',
                        ser: key.pageInfo.ser,
                        cumulativeBytesLoaded: count,
                        expectedTotalBytes: total));
                  });
            } else {
              throw Exception('fetchImage error');
            }
          }
        }

        bytes = await File(tempPath).readAsBytes();
      }
    }

    return bytes;
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

Future<GalleryImage> _fetchImageInfo(
  String href, {
  required int itemSer,
  required GalleryImage image,
  required int gid,
  bool changeSource = false,
  String? sourceId,
  CancelToken? cancelToken,
}) async {
  final String? _sourceId = changeSource ? sourceId : '';

  final GalleryImage? _image = await fetchImageInfo(
    href,
    refresh: changeSource,
    sourceId: _sourceId,
    cancelToken: cancelToken,
  );

  logger.v('_image from fetch ${_image?.toJson()}');

  if (_image == null) {
    return image;
  }

  final GalleryImage _imageCopyWith = image.copyWith(
    sourceId: _image.sourceId,
    imageUrl: _image.imageUrl,
    imageWidth: _image.imageWidth,
    imageHeight: _image.imageHeight,
    originImageUrl: _image.originImageUrl,
    filename: _image.filename,
  );

  return _imageCopyWith;
}
