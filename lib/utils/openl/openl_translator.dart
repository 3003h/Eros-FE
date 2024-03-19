import 'dart:convert' show jsonDecode, jsonEncode;

import 'package:eros_fe/models/base/eh_models.dart';
import 'package:eros_fe/utils/openl/language.dart';
import 'package:http/http.dart' as http;

import '../logger.dart';

const String _baseUrl = 'api.openl.club';

class OpenLTranslator {
  OpenLTranslator({required this.apikey});

  final String apikey;

  static const _fallbackServices = <String>[
    'deepl',
    'tencent',
    'google',
    'youdao',
  ];

  Future<OpenlTranslation> translate(
    String sourceText, {
    String from = 'auto',
    String to = 'en',
    String service = 'deepl',
  }) async {
    for (final String each in [from, to]) {
      if (!OpenLLanguageList.contains(each)) {
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
      throw http.ClientException("Error: Can't parse json data");
    }

    final rult = OpenlTranslation.fromJson(jsonData as Map<String, dynamic>);

    return rult;
  }

  Future<String?> getFallbackService() async {
    for (final service in _fallbackServices) {
      final String _path = '/services/$service';
      final Uri url = Uri.https(_baseUrl, _path);
      final data = await http.get(url);
      if (data.statusCode != 200) {
        continue;
      }
      final jsonData = jsonDecode(data.body);
      if (jsonData == null) {
        continue;
      }
      final state = (jsonData as Map<String, dynamic>)['state'];
      logger.d(jsonData);
      logger.d('${state.runtimeType}');
      if (state is String && state == 'ACTIVE') {
        logger.d('getFallbackService: $service');
        return service;
      }
    }
    return null;
  }
}
