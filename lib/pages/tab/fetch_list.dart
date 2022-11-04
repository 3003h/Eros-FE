import 'dart:async';

import 'package:dio/dio.dart';
import 'package:fehviewer/common/controller/tag_controller.dart';
import 'package:fehviewer/models/base/eh_models.dart';
import 'package:fehviewer/network/request.dart';
import 'package:get/get.dart';

import '../../utils/logger.dart';
import 'controller/search_page_controller.dart';

enum GalleryListType {
  gallery,
  watched,
  toplist,
  favorite,
  popular,
  aggregate,
}

abstract class FetchListClient {
  FetchListClient({required this.fetchParams});
  FetchParams fetchParams;
  Future<GalleryList?> fetch();
}

class DefaultFetchListClient extends FetchListClient {
  DefaultFetchListClient({
    required FetchParams fetchParams,
  }) : super(fetchParams: fetchParams);

  @override
  Future<GalleryList?> fetch() async {
    // await Future<void>.delayed(const Duration(seconds: 15));
    return await getGallery(
      page: fetchParams.page,
      fromGid: fetchParams.fromGid,
      serach: fetchParams.searchText,
      cats: fetchParams.cats,
      cancelToken: fetchParams.cancelToken,
      refresh: fetchParams.refresh,
      advanceSearch: fetchParams.advanceSearch,
    );
  }
}

class SearchFetchListClient extends FetchListClient {
  SearchFetchListClient({
    required FetchParams fetchParams,
  }) : super(fetchParams: fetchParams);

  final TagController tagController = Get.find();

  @override
  Future<GalleryList?> fetch() async {
    final rult = await getGallery(
      page: fetchParams.page,
      fromGid: fetchParams.fromGid,
      serach: fetchParams.searchText,
      cats: fetchParams.cats,
      cancelToken: fetchParams.cancelToken,
      refresh: fetchParams.refresh,
      galleryListType: fetchParams.galleryListType,
      advanceSearch: fetchParams.advanceSearch,
    );

    // hide tag filter 20220606
    if ((fetchParams.galleryListType == GalleryListType.gallery &&
            !(fetchParams.advanceSearch?.disableDFTags ?? false)) ||
        fetchParams.galleryListType == GalleryListType.popular) {
      final gidList = rult?.gallerys
          ?.where((element) => tagController.needHide(element.simpleTags ?? []))
          .map((e) => e.gid);
      if (gidList != null && gidList.isNotEmpty) {
        logger.e('${fetchParams.galleryListType} remove gallery $gidList');
        rult?.gallerys?.removeWhere((element) => gidList.contains(element.gid));
      }
    }

    return rult;
  }
}

class WatchedFetchListClient extends FetchListClient {
  WatchedFetchListClient({
    required FetchParams fetchParams,
  }) : super(fetchParams: fetchParams);

  @override
  Future<GalleryList?> fetch() async {
    return await getGallery(
      page: fetchParams.page,
      fromGid: fetchParams.fromGid,
      serach: fetchParams.searchText,
      cats: fetchParams.cats,
      cancelToken: fetchParams.cancelToken,
      refresh: fetchParams.refresh,
      galleryListType: GalleryListType.watched,
    );
  }
}

class FavoriteFetchListClient extends FetchListClient {
  FavoriteFetchListClient({
    required FetchParams fetchParams,
  }) : super(fetchParams: fetchParams);

  @override
  Future<GalleryList?> fetch() async {
    return await getGallery(
      page: fetchParams.page,
      fromGid: fetchParams.fromGid,
      serach: fetchParams.searchText,
      cats: fetchParams.cats,
      cancelToken: fetchParams.cancelToken,
      refresh: fetchParams.refresh,
      favcat: fetchParams.favcat,
      galleryListType: GalleryListType.favorite,
    );
  }
}

class ToplistFetchListClient extends FetchListClient {
  ToplistFetchListClient({
    required FetchParams fetchParams,
  }) : super(fetchParams: fetchParams);

  final TagController tagController = Get.find();

  @override
  Future<GalleryList?> fetch() async {
    final rult = await getGallery(
      page: fetchParams.page,
      fromGid: fetchParams.fromGid,
      serach: fetchParams.searchText,
      cats: fetchParams.cats,
      cancelToken: fetchParams.cancelToken,
      refresh: fetchParams.refresh,
      galleryListType: GalleryListType.toplist,
      toplist: fetchParams.toplist,
    );

    final gidList = rult?.gallerys
        ?.where((element) => tagController.needHide(element.simpleTags ?? []))
        .map((e) => e.gid);
    if (gidList != null && gidList.isNotEmpty) {
      logger.i('${fetchParams.galleryListType} remove gallery $gidList');
      rult?.gallerys?.removeWhere((element) => gidList.contains(element.gid));
    }

    return rult;
  }
}

class PopularFetchListClient extends FetchListClient {
  PopularFetchListClient({
    required FetchParams fetchParams,
  }) : super(fetchParams: fetchParams);

  @override
  Future<GalleryList?> fetch() async {
    return await getGallery(
      galleryListType: GalleryListType.popular,
      refresh: fetchParams.refresh,
    );
  }
}

class FetchParams {
  FetchParams({
    this.page,
    this.fromGid,
    this.searchText,
    this.searchType = SearchType.normal,
    this.cats,
    this.refresh = false,
    this.cancelToken,
    this.favcat,
    this.toplist,
    this.galleryListType = GalleryListType.gallery,
    this.advanceSearch,
  });
  int? page;
  String? fromGid;
  String? searchText;
  int? cats;
  bool refresh = false;
  SearchType searchType = SearchType.normal;
  CancelToken? cancelToken;
  String? favcat;
  String? toplist;
  GalleryListType? galleryListType;
  AdvanceSearch? advanceSearch;
}
