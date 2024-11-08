import 'dart:io';
import 'dart:ui' hide Image;

import 'package:eros_fe/index.dart';
import 'package:eros_fe/isolate.dart';
import 'package:extended_image/extended_image.dart';
import 'package:image/image.dart';

import 'phash_base.dart';

final PHashHelper pHashHelper = PHashHelper();

class PHashHelper {
  Future<BigInt> calculatePHashFromUrl(
    String imageUrl, {
    Rect? sourceRect,
  }) async {
    // return Future.value(BigInt.one);

    logger.t('calculatePHashFromUrl $imageUrl');
    File? imageFile;

    final isCachedImageExists = await cachedImageExists(imageUrl);
    if (isCachedImageExists) {
      imageFile = await getCachedImageFile(imageUrl);
    }

    imageFile ??= await imageCacheManager().getSingleFile(
      imageUrl,
      headers: {'cookie': Global.profile.user.cookie},
    );

    final filePath = imageFile.path;
    logger.d('calculatePHashFromUrl $imageUrl $filePath');

    // final lbCalculatePHash =
    //     await LoadBalancerHelper.getInstance(kIdentifierCalculatePHash, 4);

    final lbCalculatePHash = await loadBalancer;
    // final urlPara = (imageUrl: imageUrl, rect: sourceRect);
    // final result = await lbCalculatePHash.run(
    //   calculatePHashWithUrlRect,
    //   urlPara,
    // );

    final pathPara = (filePath: filePath, rect: sourceRect);
    final result = await lbCalculatePHash.run(
      calculatePHashWithPathRect,
      pathPara,
    );

    lbCalculatePHash.close();

    // final result = await compute<({String filePath, Rect? rect}), BigInt>(
    //   calculatePHashWithRect,
    //   para,
    // );

    return result;
  }
}

/// 在隔离中运行，避免阻塞主线程
/// 无法使用， getSingleFile 会获取不到图片
Future<BigInt> calculatePHashWithUrlRect(
  ({String imageUrl, Rect? rect}) para,
) async {
  logger.d('calculatePHashWithRect ${para.imageUrl} ${para.rect}');
  // return Future.value(BigInt.zero);
  final imageUrl = para.imageUrl;
  final sourceRect = para.rect;

  final isCachedImageExists = await cachedImageExists(imageUrl);
  logger.d('isCachedImageExists $isCachedImageExists');

  // 检查缓存和获取文件
  File? imageFile;
  if (await cachedImageExists(imageUrl)) {
    imageFile = await getCachedImageFile(imageUrl);
  }

  imageFile ??= await imageCacheManager().getSingleFile(
    imageUrl,
    headers: {'cookie': Global.profile.user.cookie},
  );
  final data = await imageFile.readAsBytes();

  logger.d('data length ${data.length}');

  // final data = await File(filePath).readAsBytes();
  final image = getValidImage(data);

  if (sourceRect != null) {
    final processedImage = copyCrop(
      image,
      x: sourceRect.left.toInt(),
      y: sourceRect.top.toInt(),
      width: sourceRect.width.toInt(),
      height: sourceRect.height.toInt(),
    );

    return calculatePHash(processedImage);
  } else {
    return calculatePHash(image);
  }
}

// 在隔离中运行，避免阻塞主线程
Future<BigInt> calculatePHashWithPathRect(
  ({String filePath, Rect? rect}) para,
) async {
  logger.d('calculatePHashWithRect ${para.filePath} ${para.rect}');

  final filePath = para.filePath;
  final sourceRect = para.rect;

  final data = await File(filePath).readAsBytes();
  final image = getValidImage(data);

  if (sourceRect != null) {
    final processedImage = copyCrop(
      image,
      x: sourceRect.left.toInt(),
      y: sourceRect.top.toInt(),
      width: sourceRect.width.toInt(),
      height: sourceRect.height.toInt(),
    );

    return calculatePHash(processedImage);
  } else {
    return calculatePHash(image);
  }
}
