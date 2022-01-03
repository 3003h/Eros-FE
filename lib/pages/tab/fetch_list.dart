import 'dart:async';

import 'package:dio/dio.dart';
import 'package:fehviewer/models/base/eh_models.dart';
import 'package:fehviewer/network/request.dart';

import 'controller/search_page_controller.dart';

enum GalleryListType {
  gallery,
  watched,
  toplist,
  favorite,
  popular,
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
      advanceSearchParam: fetchParams.advanceSearchParam,
    );
  }
}

class SearchFetchListClient extends FetchListClient {
  SearchFetchListClient({
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
      galleryListType: fetchParams.galleryListType,
      advanceSearchParam: fetchParams.advanceSearchParam,
    );
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

  @override
  Future<GalleryList?> fetch() async {
    return await getGallery(
      page: fetchParams.page,
      fromGid: fetchParams.fromGid,
      serach: fetchParams.searchText,
      cats: fetchParams.cats,
      cancelToken: fetchParams.cancelToken,
      refresh: fetchParams.refresh,
      galleryListType: GalleryListType.toplist,
      toplist: fetchParams.toplist,
    );
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
    this.advanceSearchParam,
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
  Map<String, dynamic>? advanceSearchParam;
}
