import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../component/exception/error.dart';
import '../../../index.dart';
import '../../../network/request.dart';
import 'default_tabview_controller.dart';
import 'enum.dart';
import 'search_page_controller.dart';

class SearchImageController extends DefaultTabViewController {
  final String tabIndex = 'search_image';

  final _imagePath = ''.obs;
  String get imagePath => _imagePath.value;
  set imagePath(String val) => _imagePath.value = val;

  final Rx<ListType> _listType = ListType.init.obs;
  ListType get listType => _listType.value;
  set listType(ListType val) => _listType.value = val;

  Future<void> selectSearchImage(BuildContext context) async {
    // 权限检查
    if (!await _checkPermission(context)) {
      return;
    }

    // 选取图片
    FilePickerResult? result;
    try {
      result = await FilePicker.platform.pickFiles(type: FileType.image);
    } on Exception catch (e) {
      logger.e('Pick file failed', error: e);
    }
    imagePath = result?.files.single.path ?? '';
    if (imagePath.isEmpty) {
      return;
    }
  }

  Future<void> startSearch({bool clear = true}) async {
    if (imagePath.isEmpty) {
      return;
    }

    listType = ListType.gallery;

    resetResultPage();

    if (clear) {
      change(state, status: RxStatus.loading());
    }

    try {
      logger.d('startSearch');
      final rult = await fetchData(refresh: true);
      if (rult == null) {
        change(null, status: RxStatus.loading());
        return;
      }

      nextGid = rult.nextGid;
      prevGid = rult.prevGid;
      nextPage = rult.nextPage;
      prevPage = rult.prevPage;
      maxPage = rult.maxPage;

      change(rult.gallerys ?? [], status: RxStatus.success());
    } catch (err) {
      change(null, status: RxStatus.error(err.toString()));
    }
  }

  @override
  Future<void> firstLoad() async {
    change(<GalleryProvider>[], status: RxStatus.empty());
  }

  @override
  Future<GalleryList?> fetchData({bool refresh = false}) async {
    cancelToken = CancelToken();

    pageState = PageState.Loading;

    try {
      final GalleryList? rult = await searchImage(
        imagePath,
        cancelToken: cancelToken,
      );

      if (cancelToken?.isCancelled ?? false) {
        return null;
      }

      pageState = PageState.None;

      final _list = rult?.gallerys
              ?.map((e) => e.simpleTags ?? [])
              .expand((List<SimpleTag> element) => element)
              .toList() ??
          [];

      tagController.addAllSimpleTag(_list);
      return rult;
    } on EhError catch (eherror) {
      logger.e('type:${eherror.type}\n${eherror.message}');
      showToast(eherror.message);
      pageState = PageState.LoadingError;
      rethrow;
    } on Exception catch (e) {
      pageState = PageState.LoadingError;
      rethrow;
    }
  }

  Future<bool> _checkPermission(BuildContext context) async {
    Future<bool?> _jumpToAppSettings(BuildContext context) async {
      return await jumpToAppSettings(
          context,
          'You have disabled the necessary permissions for the application:'
          '\nRead and write phone storage, is it allowed in the settings?');
    }

    if (GetPlatform.isIOS) {
      final PermissionStatus statusPhotos = await Permission.photos.status;
      final PermissionStatus statusPhotosAdd =
          await Permission.photosAddOnly.status;

      if (statusPhotos.isPermanentlyDenied &&
          statusPhotosAdd.isPermanentlyDenied) {
        _jumpToAppSettings(context);
        return false;
      }

      final requestAddOnly =
          () async => await Permission.photosAddOnly.request();
      final requestAll = () async => await Permission.photos.request();

      if (await requestAddOnly().isGranted ||
          await requestAddOnly().isLimited ||
          await requestAll().isGranted ||
          await requestAll().isLimited) {
        return true;
      } else {
        throw 'Unable to read pictures, please authorize first~';
      }
    }

    final PermissionStatus status = await Permission.storage.status;

    if (status.isPermanentlyDenied) {
      if (await Permission.storage.request().isGranted) {
        return true;
      } else {
        await _jumpToAppSettings(context);
        return false;
      }
    } else {
      if (await Permission.storage.request().isGranted) {
        return true;
      } else {
        throw 'Unable to read pictures, please authorize first~';
      }
    }
  }
}
