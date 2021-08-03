import 'dart:async';
import 'dart:convert';

import 'package:fehviewer/models/openl_translation.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/openl/openl_translator.dart';
import 'package:flutter/services.dart';

class TranslatorHelper {
  static Future<String> getApikey() async {
    final String openl = await rootBundle.loadString('assets/openl.json');
    final openlJson = json.decode(openl);
    return openlJson['apikey'] as String? ?? '';
  }

  static Future<OpenlTranslation> translate(
    String sourceText, {
    String from = 'auto',
    String to = 'en',
    String service = 'deepl',
  }) async {
    final String apikey = await getApikey();

    logger.v('apikey $apikey');

    final OpenLTranslator openLTranslator = OpenLTranslator(apikey: apikey);
    return openLTranslator.translate(sourceText, from: from, to: to);
  }

  static Future<String> translateText(
    String sourceText, {
    String from = 'auto',
    String to = 'en',
    String service = 'deepl',
  }) async {
    final OpenlTranslation rult =
        await translate(sourceText, from: from, to: to);

    logger.v(rult.toJson());

    return rult.result ?? '';
  }
}
