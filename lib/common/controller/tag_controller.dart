import 'package:fehviewer/fehviewer.dart';
import 'package:get/get.dart';

class TagController extends GetxController {
  List<GalleryTag> galleryTags = [];

  GalleryTag getColorCode(GalleryTag tag) {
    GalleryTag? _tag;
    _tag = galleryTags.firstWhereOrNull(
        (element) => element.title == '${tag.type}:${tag.title}');
    _tag ??=
        galleryTags.firstWhereOrNull((element) => element.title == tag.title);

    return tag.copyWith(
        color: _tag?.color, backgrondColor: _tag?.backgrondColor);
  }

  void addAllSimpleTag(List<SimpleTag> simpleTag) {
    for (final sTag in simpleTag) {
      if (sTag.backgrondColor == null ||
          (sTag.backgrondColor?.isEmpty ?? true)) {
        continue;
      }

      if (sTag.text == null) {
        continue;
      }

      late GalleryTag _gTags;

      if (sTag.text!.contains(':')) {
        final RegExp rpfx = RegExp(r'(\w+):"?([^\$]+)\$?"?');
        final RegExpMatch? rult = rpfx.firstMatch(sTag.text!.toLowerCase());
        String _nameSpase = rult?.group(1) ?? '';
        if (_nameSpase.length == 1) {
          _nameSpase = EHConst.prefixToNameSpaceMap[_nameSpase] ?? _nameSpase;
        }

        final String _tag = rult?.group(2) ?? '';

        _gTags = GalleryTag(
          title: _tag,
          color: sTag.color,
          backgrondColor: sTag.backgrondColor,
          type: _nameSpase,
          tagTranslat: '',
        );
      } else {
        _gTags = GalleryTag(
          title: sTag.text ?? '',
          color: sTag.color,
          backgrondColor: sTag.backgrondColor,
          type: '',
          tagTranslat: '',
        );
      }
      _addGalleryTag(_gTags);
    }
  }

  void addAllTags(List<EhUsertag>? tags) {
    if (tags == null) {
      return;
    }

    for (final tag in tags) {
      final RegExp rpfx = RegExp(r'(\w+):"?([^\$]+)\$?"?');
      final RegExpMatch? rult = rpfx.firstMatch(tag.title.toLowerCase());
      String _nameSpase = rult?.group(1) ?? '';
      if (_nameSpase.length == 1) {
        _nameSpase = EHConst.prefixToNameSpaceMap[_nameSpase] ?? _nameSpase;
      }

      final String _tag = rult?.group(2) ?? '';

      final _gTags = GalleryTag(
        title: _tag,
        color: tag.textColor,
        backgrondColor: tag.colorCode,
        type: _nameSpase,
        tagTranslat: '',
      );
      _addGalleryTag(_gTags);
    }
  }

  void _addGalleryTag(GalleryTag tag) {
    final index =
        galleryTags.indexWhere((element) => element.title == tag.title);
    if (index > -1) {
      galleryTags[index] = tag;
    } else {
      galleryTags.add(tag);
    }
  }
}
