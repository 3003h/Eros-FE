import '../../index.dart';

AdvanceSearch parserAdvanceSearch(String? param) {
  final uri = Uri.parse(param ?? '');
  final queryParameters = uri.queryParameters;
  return AdvanceSearch(
    requireGalleryTorrent: queryParameters['f_sto'] == 'on',
    browseExpungedGalleries: queryParameters['f_sh'] == 'on',
    searchWithMinRating: queryParameters['f_sr'] == 'on',
    minRating: int.parse(queryParameters['f_srdd'] ?? '2'),
    searchBetweenPage: queryParameters['f_sp'] == 'on',
    startPage: queryParameters['f_spf'] ?? '',
    endPage: queryParameters['f_spt'] ?? '',
    disableCustomFilterLanguage: queryParameters['f_sfl'] == 'on',
    disableCustomFilterUploader: queryParameters['disableDFUploader'] == 'on',
    disableCustomFilterTags: queryParameters['f_sfu'] == 'on',
  );
}
