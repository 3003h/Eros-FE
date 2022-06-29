import '../../fehviewer.dart';

AdvanceSearch parserAdvanceSearch(String? param) {
  final uri = Uri.parse(param ?? '');
  final queryParameters = uri.queryParameters;
  return AdvanceSearch(
      searchGalleryName: queryParameters['f_sname'] == 'on',
      searchGalleryTags: queryParameters['f_stags'] == 'on',
      searchGalleryDesc: queryParameters['f_sdesc'] == 'on',
      searchToreenFilenames: queryParameters['f_storr'] == 'on',
      onlyShowWhithTorrents: queryParameters['f_sto'] == 'on',
      searchLowPowerTags: queryParameters['f_sdt1'] == 'on',
      searchDownvotedTags: queryParameters['f_sdt2'] == 'on',
      searchExpunged: queryParameters['f_sh'] == 'on',
      searchWithminRating: queryParameters['f_sr'] == 'on',
      minRating: int.parse(queryParameters['f_srdd'] ?? '2'),
      searchBetweenpage: queryParameters['f_sp'] == 'on',
      startPage: queryParameters['f_spf'] ?? '',
      endPage: queryParameters['f_spt'] ?? '',
      disableDFLanguage: queryParameters['f_sfl'] == 'on',
      disableDFUploader: queryParameters['disableDFUploader'] == 'on',
      disableDFTags: queryParameters['f_sfu'] == 'on',
      favSearchName: queryParameters['f_sfl'] == 'on',
      favSearchTags: queryParameters['f_sfu'] == 'on',
      favSearchNote: queryParameters['f_sft'] == 'on');
}
