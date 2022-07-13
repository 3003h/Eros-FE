import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:fehviewer/utils/p_hash/phash_base.dart' as phash;
import 'package:fehviewer/utils/p_hash/phash_helper.dart';
import 'package:get/get.dart';

import '../../fehviewer.dart';

class ImageHideController extends GetxController {
  final RxList<ImageHide> customHides = <ImageHide>[].obs;
  final Map<String, BigInt> pHashMap = <String, BigInt>{};

  @override
  void onInit() {
    super.onInit();
    customHides(hiveHelper.getAllCustomImageHide());
    debounce<List<ImageHide>>(customHides, (value) {
      hiveHelper.setAllCustomImageHide(value);
    }, time: const Duration(seconds: 2));
  }

  Future<void> addCustomImageHide(String imageUrl) async {
    if (customHides.any((e) => e.imageUrl == imageUrl)) {
      return;
    }

    File? imageFile;
    if (await cachedImageExists(imageUrl)) {
      imageFile = await getCachedImageFile(imageUrl);
    }

    imageFile ??= await imageCacheManager.getSingleFile(imageUrl,
        headers: {'cookie': Global.profile.user.cookie});

    final data = imageFile.readAsBytesSync();
    final pHash = phash.calculatePHash(phash.getValidImage(data));
    if (customHides.any((e) => e.pHash == pHash.toRadixString(16))) {
      return;
    }
    customHides
        .add(ImageHide(pHash: pHash.toRadixString(16), imageUrl: imageUrl));
  }

  Future<bool> checkHide(String url) async {
    BigInt? hash = await calculatePHash(url);
    loggerSimple.v('checkHide url:$url hash:${hash.toRadixString(16)}');

    return customHides.any((e) =>
        phash.hammingDistance(
            BigInt.tryParse(e.pHash, radix: 16) ?? BigInt.from(0), hash) <=
        4);
  }

  Future<BigInt> calculatePHash(String url) async {
    BigInt? hash;
    if (pHashMap.containsKey(url)) {
      hash = pHashMap[url]!;
    }

    if (hash == null) {
      hash = await pHashHelper.calculatePHashFromUrl(url);
      pHashMap[url] = hash;
    }

    return hash;
  }
}
