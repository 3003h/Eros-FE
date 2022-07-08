import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:fehviewer/utils/p_hash/phash_base.dart' as phash;
import 'package:fehviewer/utils/p_hash/phash_helper.dart';
import 'package:get/get.dart';

import '../../fehviewer.dart';

class ImageHideController extends GetxController {
  final RxList<ImageHide> customHides = <ImageHide>[].obs;

  @override
  void onInit() {
    super.onInit();
    customHides(hiveHelper.getAllCustomImageHide());
    debounce<List<ImageHide>>(customHides, (value) {
      hiveHelper.setAllCustomImageHide(value);
    }, time: const Duration(seconds: 2));
  }

  Future<void> addCustomImageHide(String imageUrl) async {
    File? imageFile;
    if (await cachedImageExists(imageUrl)) {
      imageFile = await getCachedImageFile(imageUrl);
    }

    imageFile ??= await imageCacheManager.getSingleFile(imageUrl,
        headers: {'cookie': Global.profile.user.cookie});

    final data = imageFile.readAsBytesSync();
    final pHash = phash.calculatePHash(phash.getValidImage(data));
    customHides
        .add(ImageHide(pHash: pHash.toRadixString(16), imageUrl: imageUrl));
  }

  Future<bool> checkHide(String url) async {
    final hash = await pHashHelper.calculatePHashFromUrl(url);
    return customHides.any((e) =>
        phash.hammingDistance(
            BigInt.tryParse(e.pHash, radix: 16) ?? BigInt.from(0), hash) <=
        4);
  }
}
