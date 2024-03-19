import 'package:eros_fe/common/controller/download_controller.dart';
import 'package:eros_fe/common/service/ehsetting_service.dart';
import 'package:eros_fe/network/api.dart';
import 'package:eros_fe/pages/gallery/gallery_repository.dart';
import 'package:get/get.dart';

import '../../../index.dart';
import '../../item/controller/galleryitem_controller.dart';

class GalleryPageState {
  GalleryPageState();

  final EhSettingService _ehSettingService = Get.find();
  DownloadController get _downloadController => Get.find();

  late final GalleryRepository? galleryRepository;

  /// 画廊数据对象
  GalleryProvider? galleryProvider;

  String get url =>
      '${galleryProvider!.url?.startsWith('http') ?? false ? '' : Api.getBaseUrl()}${galleryProvider!.url}';

  /// 画廊gid 唯一
  String get gid => galleryProvider?.gid ?? '0';

  bool isRefresh = false;

  final RxBool _fromUrl = false.obs;
  bool get fromUrl => _fromUrl.value;
  set fromUrl(bool val) => _fromUrl.value = val;

  final RxBool _isRatinged = false.obs;
  bool get isRatinged => _isRatinged.value;
  set isRatinged(bool val) => _isRatinged.value = val;

  final RxInt _lastIndex = 0.obs;
  int get lastIndex => _lastIndex.value;
  set lastIndex(int val) => _lastIndex.value = val;

  final RxList<GalleryImage> images = <GalleryImage>[].obs;
  Map<int, GalleryImage> get imageMap =>
      {for (GalleryImage v in images) v.ser: v};

  int get filecount => int.parse(galleryProvider?.filecount ?? '0');

  // 阅读按钮开关
  final RxBool _enableRead = false.obs;
  bool get enableRead => _enableRead.value;
  set enableRead(bool val) => _enableRead.value = val;

  bool get hasMoreImage {
    return int.parse(galleryProvider?.filecount ?? '0') >
        (firstPageImage.length);
  }

  // 控制隐藏导航栏按钮和封面
  final RxBool _hideNavigationBtn = true.obs;

  bool get hideNavigationBtn => _hideNavigationBtn.value;
  set hideNavigationBtn(bool val) => _hideNavigationBtn.value = val;

  // 第一页的缩略图对象数组
  List<GalleryImage>? _firstPageImage;
  List<GalleryImage> get firstPageImage => _firstPageImage ?? [];
  set firstPageImage(List<GalleryImage>? val) => _firstPageImage = val;

  String get showKey => galleryProvider?.showKey ?? '';

  /// 当前缩略图页码
  late int currentImagePage;

  // 正在获取href
  bool isImageInfoGeting = false;

  /// 是否已经存在本地收藏中
  set localFav(bool value) {
    galleryProvider = galleryProvider?.copyWith(localFav: value.oN);
  }

  bool get localFav => galleryProvider?.localFav ?? false;

  // 经过序号排序处理的图片对象list
  List<GalleryImage> get imagesFromMap {
    List<MapEntry<int, GalleryImage>> list = imageMap.entries
        .map((MapEntry<int, GalleryImage> e) => MapEntry(e.key, e.value))
        .toList();
    list.sort((a, b) => a.key.compareTo(b.key));

    return list.map((e) => e.value).toList();
  }

  final Map<int, Future<List<GalleryImage>>> mapLoadImagesForSer = {};
  final RxList<GalleryComment> comments = <GalleryComment>[].obs;

  // 副标题
  final _subTitle = ''.obs;
  set subTitle(String val) => _subTitle.value = val;
  String get subTitle {
    // logger.d('${galleryProvider.japaneseTitle} ${galleryProvider.englishTitle}');

    if ((_ehSettingService.jpnTitleInGalleryPage) &&
        (galleryProvider?.japaneseTitle?.isNotEmpty ?? false)) {
      return galleryProvider?.englishTitle ?? '';
    } else {
      return galleryProvider?.japaneseTitle ?? '';
    }

    // if (_subTitle.value.isNotEmpty) {
    //   return _subTitle.value;
    // }
    //
    // if (firstMainTitle == galleryProvider?.englishTitle) {
    //   _subTitle.value = galleryProvider?.japaneseTitle ?? '';
    //   // return galleryProvider?.japaneseTitle ?? '';
    // } else {
    //   // return galleryProvider?.englishTitle ?? '';
    //   _subTitle.value = galleryProvider?.englishTitle ?? '';
    // }
    //
    // return _subTitle.value;
  }

  String firstMainTitle = '';

  // 根据设置的语言显示的标题
  String get mainTitle {
    if ((_ehSettingService.jpnTitleInGalleryPage) &&
        (galleryProvider?.japaneseTitle?.isNotEmpty ?? false)) {
      return galleryProvider?.japaneseTitle ?? '';
    } else {
      return galleryProvider?.englishTitle ?? '';
    }

    // if (firstMainTitle.isEmpty) {
    //   firstMainTitle = galleryProvider?.englishTitle ?? '';
    // }
    //
    // if (firstMainTitle == galleryProvider?.englishTitle) {
    //   return galleryProvider?.englishTitle ?? '';
    // } else {
    //   return galleryProvider?.japaneseTitle ??
    //       galleryProvider?.englishTitle ??
    //       '';
    // }
  }

  GalleryItemController? get itemController {
    if (Get.isRegistered<GalleryItemController>(tag: gid)) {
      return Get.find<GalleryItemController>(tag: gid);
    }
    return null;
  }

  TaskStatus get downloadState => TaskStatus(
      _downloadController.dState.galleryTaskMap[int.parse(gid)]?.status ?? 0);

  double get downloadProcess {
    final task = _downloadController.dState.galleryTaskMap[int.parse(gid)];
    return (task?.completCount ?? 0) * 100.0 / (task?.fileCount ?? 1);
  }
}
