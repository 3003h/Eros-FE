import 'package:dio/dio.dart';
import 'package:fehviewer/models/base/eh_models.dart';
import 'package:fehviewer/pages/tab/controller/search_page_controller.dart';
import 'package:get/get.dart';

import 'app_dio/pdio.dart';

Future<GallerysAndMaxpage?> getPopular({
  int? page,
  String? fromGid,
  String? serach,
  int? cats,
  bool refresh = false,
  SearchType searchType = SearchType.normal,
  CancelToken? cancelToken,
  String? favcat,
  String? toplist,
}) async {
  DioHttpClient dioHttpClient = Get.find(tag: 'EH');
  DioHttpResponse httpResponse = await dioHttpClient.get(
    '/popular',
    httpTransformer: GalleryListHttpTransformer(),
  );

  if (httpResponse.ok && httpResponse.data is GallerysAndMaxpage) {
    return httpResponse.data as GallerysAndMaxpage;
  }
}
