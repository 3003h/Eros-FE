import 'dart:convert';

import 'package:fehviewer/models/gallery_provider.dart';
import 'package:fehviewer/store/db/entity/view_history.dart';

import 'isar.dart';

Future<void> addHistory(Map<String, dynamic> galleryProviderMap) async {
  final galleryProvider = GalleryProvider.fromJson(galleryProviderMap);

  final gid = int.tryParse(galleryProvider.gid ?? '0') ?? 0;
  final lastViewTime = galleryProvider.lastViewTime ?? 0;
  final isar = await openIsar();
  isar.writeTxnSync(() {
    isar.viewHistories.putSync(ViewHistory(
        gid: gid,
        lastViewTime: lastViewTime,
        galleryProviderText: jsonEncode(galleryProvider)));
  });
}
