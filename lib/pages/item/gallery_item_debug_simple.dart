import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../index.dart';
import 'controller/galleryitem_controller.dart';

class GalleryItemDebugSimple extends StatelessWidget {
  const GalleryItemDebugSimple(
      {Key? key, this.tabTag, required this.galleryProvider})
      : super(key: key);

  final dynamic tabTag;
  final GalleryProvider galleryProvider;

  GalleryItemController get galleryProviderController =>
      Get.find(tag: galleryProvider.gid);

  @override
  Widget build(BuildContext context) {
    final container = Container(
      // height: 40,
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Center(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    galleryProviderController.title,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 4,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: container,
      onTap: () => galleryProviderController.onTap(tabTag),
      onLongPress: galleryProviderController.onLongPress,
    ).autoCompressKeyboard(context);
  }
}
