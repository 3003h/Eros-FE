import 'dart:convert' show jsonDecode, jsonEncode;

import 'package:fehviewer/models/base/eh_models.dart';
import 'package:fehviewer/utils/openl/language.dart';
import 'package:http/http.dart' as http;

const String _baseUrl = 'api.openl.club';

class OpenLTranslator {
  OpenLTranslator({required this.apikey});

  final String apikey;

  Future<OpenlTranslation> translate(
    String sourceText, {
    String from = 'auto',
    String to = 'en',
    String service = 'deepl',
  }) async {
    for (final String each in [from, to]) {
      if (!LanguageList.contains(each)) {
        throw LanguageNotSupportedException(each);
      }
    }

    final String _path = '/services/$service/translate';

    final Map<String, String> reqMap = {
      'apikey': apikey,
      'text': sourceText,
      'source_lang': from,
      'target_lang': to,
    };

    final Uri url = Uri.https(_baseUrl, _path);
    final data = await http.post(url, body: jsonEncode(reqMap));

    if (data.statusCode != 200) {
      throw http.ClientException('Error ${data.statusCode}: ${data.body}', url);
    }

    final jsonData = jsonDecode(data.body);
    if (jsonData == null) {
      throw http.ClientException('Error: Can\'t parse json data');
    }

    return OpenlTranslation.fromJson(jsonData);
  }
}
