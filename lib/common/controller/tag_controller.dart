import 'package:eros_fe/index.dart';
import 'package:eros_fe/pages/setting/controller/eh_mytags_controller.dart';
import 'package:get/get.dart';

class TagController extends GetxController {
  // tag数据
  List<GalleryTag> galleryTags = [];

  List<GalleryTag> get hideTags =>
      galleryTags.where((e) => e.hide ?? false).toList();

  EhMyTagsController get ehMyTagsController => Get.find();

  @override
  void onReady() {
    initTags();
  }

  Future<void> initTags() async {
    logger.t('initTags 初始化 请求mytag页面 全量更新tag');

    await 5.seconds.delay();
    // 初始化 请求mytag页面 全量更新tag一次
    ehMyTagsController.loadData();
  }

  /// 获取tag颜色
  GalleryTag getColorCode(GalleryTag tag) {
    GalleryTag? tag0;
    tag0 = galleryTags.firstWhereOrNull(
        (element) => element.title == '${tag.type}:${tag.title}');
    tag0 ??= galleryTags.firstWhereOrNull(
        (element) => element.title.trim() == tag.title.trim());

    return tag.copyWith(
        color: tag0?.color.oN, backgrondColor: tag0?.backgrondColor.oN);
  }

  bool needHide(List<SimpleTag> simpleTags) {
    return simpleTags.any((simpleTag) {
      if (simpleTag.text!.contains(':')) {
        final RegExp rpfx = RegExp(r'(\w+):"?([^$]+)\$?"?');
        final RegExpMatch? rult =
            rpfx.firstMatch(simpleTag.text!.toLowerCase());
        String nameSpase = rult?.group(1) ?? '';
        if (nameSpase.length == 1) {
          nameSpase = EHConst.prefixToNameSpaceMap[nameSpase] ?? nameSpase;
        }

        final String tag = rult?.group(2) ?? '';

        return hideTags.any((hideTag) => hideTag.title == tag.trim());
      } else {
        return hideTags.any((hideTag) => hideTag.title == simpleTag.text);
      }
    });
  }

  /// 由 SimpleTag 数据添加
  /// 主要场景：加载列表的时候
  void addAllSimpleTag(List<SimpleTag> simpleTags) {
    for (final simpleTag in simpleTags) {
      if (simpleTag.backgrondColor == null ||
          (simpleTag.backgrondColor?.isEmpty ?? true)) {
        continue;
      }

      if (simpleTag.text == null) {
        continue;
      }

      late GalleryTag gTags;

      if (simpleTag.text!.contains(':')) {
        final RegExp rpfx = RegExp(r'(\w+):"?([^$]+)\$?"?');
        final RegExpMatch? rult =
            rpfx.firstMatch(simpleTag.text!.toLowerCase());
        String nameSpase = rult?.group(1) ?? '';
        if (nameSpase.length == 1) {
          nameSpase = EHConst.prefixToNameSpaceMap[nameSpase] ?? nameSpase;
        }

        final String tag = rult?.group(2) ?? '';

        gTags = GalleryTag(
          title: tag.trim(),
          color: simpleTag.color,
          backgrondColor: simpleTag.backgrondColor,
          type: nameSpase,
          tagTranslat: '',
        );
      } else {
        gTags = GalleryTag(
          title: simpleTag.text?.trim() ?? '',
          color: simpleTag.color,
          backgrondColor: simpleTag.backgrondColor,
          type: '',
          tagTranslat: '',
        );
      }

      // logger.d('${_gTags.toJson()}');
      _addGalleryTag(gTags);
    }
  }

  /// 由 EhUsertag 数据添加
  /// 主要场景：访问 Usertag 页面。加载数据的时候
  void addAllTags(List<EhUsertag>? tags) {
    if (tags == null) {
      return;
    }

    for (final tag in tags) {
      final RegExp rpfx = RegExp(r'(\w+):"?([^$]+)\$?"?');
      final RegExpMatch? rult = rpfx.firstMatch(tag.title.toLowerCase());
      String nameSpase = rult?.group(1) ?? '';
      if (nameSpase.length == 1) {
        nameSpase = EHConst.prefixToNameSpaceMap[nameSpase] ?? nameSpase;
      }

      final String tagStr = rult?.group(2) ?? '';

      final gTags = GalleryTag(
        title: tagStr,
        color: tag.textColor,
        backgrondColor: tag.colorCode,
        type: nameSpase,
        tagTranslat: '',
        hide: tag.hide,
        watch: tag.watch,
      );
      _addGalleryTag(gTags);
    }
  }

  /// 添加和替换
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
