import 'package:FEhViewer/models/index.dart';

/// 避免json_model工具生成的代码覆盖 models类不加入构造方法 初始化方法再这里写
extension GalleryTagExt on GalleryTag {
  GalleryTag init(String title, {String type, String tagTranslat}) {
    this.title = title;
    this.type = type ?? '';
    this.tagTranslat = tagTranslat ?? '';
    return this;
  }
}

extension TagGroupExt on TagGroup {
  init(String tagType, {List<String> tags, List<GalleryTag> galleryTags}) {
    this.tagType = tagType;
    this.galleryTags = [];
    if (galleryTags.isEmpty) {
      tags.forEach((tag) {
        this.galleryTags.add(GalleryTag().init(tag));
      });
    } else {
      galleryTags.forEach((tag) {
        this.galleryTags.add(tag);
      });
    }

    return this;
  }
}
