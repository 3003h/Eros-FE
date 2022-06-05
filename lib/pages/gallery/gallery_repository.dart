import '../../models/gallery_provider.dart';

class GalleryRepository {
  GalleryRepository({
    this.tabTag,
    this.item,
    this.url,
    this.jumpSer,
  });

  final dynamic tabTag;
  final GalleryProvider? item;
  final String? url;
  final int? jumpSer;
}
