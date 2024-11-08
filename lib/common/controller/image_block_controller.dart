import 'dart:io';
import 'dart:ui' hide Image;

import 'package:collection/collection.dart';
import 'package:eros_fe/common/service/ehsetting_service.dart';
import 'package:eros_fe/utils/p_hash/phash_base.dart' as phash;
import 'package:eros_fe/utils/p_hash/phash_helper.dart';
import 'package:extended_image/extended_image.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:image/image.dart';

import '../../index.dart';

// const int kMaxPhashDiff = 10;

class ImageBlockController extends GetxController {
  final RxList<ImageHide> customBlockList = <ImageHide>[].obs;
  final Map<String, BigInt> pHashMap = <String, BigInt>{};

  EhSettingService get _ehSettingService => Get.find();

  @override
  void onInit() {
    super.onInit();
    customBlockList(hiveHelper.getAllCustomImageHide());
    debounce<List<ImageHide>>(customBlockList, (value) {
      hiveHelper.setAllCustomImageHide(value);
    }, time: const Duration(seconds: 2));
  }

  Future<void> addCustomImageHide(String imageUrl, {Rect? sourceRect}) async {
    if (customBlockList.any((e) => e.imageUrl == imageUrl)) {
      return;
    }

    File? imageFile;
    if (await cachedImageExists(imageUrl)) {
      imageFile = await getCachedImageFile(imageUrl);
    }

    imageFile ??= await imageCacheManager().getSingleFile(imageUrl,
        headers: {'cookie': Global.profile.user.cookie});

    final data = imageFile.readAsBytesSync();
    final image = phash.getValidImage(data);

    // 如果提供了 sourceRect 参数，则裁剪图像
    Image processedImage = image;
    if (sourceRect != null) {
      processedImage = copyCrop(
        image,
        x: sourceRect.left.toInt(),
        y: sourceRect.top.toInt(),
        width: sourceRect.width.toInt(),
        height: sourceRect.height.toInt(),
      );
    }

    final pHash = phash.calculatePHash(processedImage);
    if (customBlockList.any((e) => e.pHash == pHash.toRadixString(16))) {
      return;
    }

    customBlockList.insert(
        0,
        ImageHide(
          pHash: pHash.toRadixString(16),
          imageUrl: imageUrl,
          left: sourceRect?.left.toInt(),
          top: sourceRect?.top.toInt(),
          width: sourceRect?.width.toInt(),
          height: sourceRect?.height.toInt(),
        ));
  }

  Future<bool> checkPHashHide(String url, {Rect? sourceRect}) async {
    BigInt? hash = await calculatePHash(url, sourceRect: sourceRect);
    // BigInt? hash = BigInt.one;
    loggerSimple.t('checkHide url:$url hash:${hash.toRadixString(16)}');

    return customBlockList.any(
      (e) {
        final diff = phash.hammingDistance(
            BigInt.tryParse(e.pHash, radix: 16) ?? BigInt.from(0), hash);
        // logger.d('diff $diff');
        if (diff <= _ehSettingService.pHashThreshold) {
          logger.d('diff $diff');
        }
        return diff <= _ehSettingService.pHashThreshold;
      },
    );
  }

  Future<bool> checkQRCodeHide(String url, {Rect? sourceRect}) async {
    final barcode = await scanQRCodeFromUrl(url, sourceRect: sourceRect);
    if (barcode != null) {
      logger.d('barcode ${barcode.type} ${barcode.displayValue} , url: $url');
    }

    return barcode?.type == BarcodeType.url;
  }

  Future<BigInt> calculatePHash(String url, {Rect? sourceRect}) async {
    logger.t('calculatePHash url:$url');
    BigInt? hash;

    late final String key;
    if (sourceRect != null) {
      key =
          '$url#${sourceRect.left}_${sourceRect.top}_${sourceRect.width}_${sourceRect.height}';
    } else {
      key = url;
    }

    if (pHashMap.containsKey(key)) {
      hash = pHashMap[key]!;
    }

    if (hash == null) {
      hash = await pHashHelper.calculatePHashFromUrl(
        url,
        sourceRect: sourceRect,
      );
      pHashMap[key] = hash;
    }

    return hash;
  }

  Future<Barcode?> scanQRCodeFromUrl(
    String imageUrl, {
    Rect? sourceRect,
  }) async {
    File? imageFile;
    if (await cachedImageExists(imageUrl)) {
      imageFile = await getCachedImageFile(imageUrl);
    }

    imageFile ??= await imageCacheManager().getSingleFile(imageUrl,
        headers: {'cookie': Global.profile.user.cookie});

    final path = imageFile.path;

    // final Uint8List data = imageFile.readAsBytesSync();

    final inputImage = InputImage.fromFilePath(path);

    BarcodeScanner scanner = BarcodeScanner(formats: [
      BarcodeFormat.qrCode,
    ]);

    final list = await scanner.processImage(inputImage);
    return list.firstOrNull;
  }
}
