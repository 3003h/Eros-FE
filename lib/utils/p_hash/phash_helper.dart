import 'dart:io';

import 'package:eros_fe/index.dart';
import 'package:eros_fe/isolate.dart';
import 'package:extended_image/extended_image.dart';

import 'phash_base.dart';

final PHashHelper pHashHelper = PHashHelper();

class PHashHelper {
  BigInt? lastHash;
  Future<void> compareLast(String imageUrl) async {
    File? imageFile;
    if (await cachedImageExists(imageUrl)) {
      imageFile = await getCachedImageFile(imageUrl);
    }

    imageFile ??= await imageCacheManager().getSingleFile(imageUrl,
        headers: {'cookie': Global.profile.user.cookie});

    final data = imageFile.readAsBytesSync();
    final pHash = calculatePHash(getValidImage(data));

    if (lastHash != null) {
      final diff = hammingDistance(lastHash!, pHash);
      showToast(
          '${pHash.toRadixString(16)}\n${lastHash!.toRadixString(16)}\n$diff');
    } else {
      showToast(pHash.toRadixString(16));
    }

    lastHash = pHash;
  }

  Future<BigInt> calculatePHashFromUrl(String imageUrl) async {
    logger.t('calculatePHashFromUrl $imageUrl');
    File? imageFile;
    if (await cachedImageExists(imageUrl)) {
      // logger.d('calculatePHashFromUrl from cache');
      imageFile = await getCachedImageFile(imageUrl);
    }

    imageFile ??= await imageCacheManager().getSingleFile(imageUrl,
        headers: {'cookie': Global.profile.user.cookie});

    final path = imageFile.path;

    logger.t('calculatePHashFromUrl $path');

    // final List<int> data = imageFile.readAsBytesSync();

    final lb = await loadBalancer;
    // final pHash = await lb.run(calculateFromList, data);
    final pHash = await lb.run(calculateFromFile, path);

    // final pHash = calculateFromList(data);
    // final pHash = await compute(calculateFromList, data);
    return pHash;
  }
}
