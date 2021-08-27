import 'dart:async';
import 'dart:convert';

import 'package:fehviewer/models/openl_translation.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/openl/openl_translator.dart';
import 'package:flutter/services.dart';
import 'package:translator/translator.dart';

import 'language.dart';

class TranslatorHelper {
  static Future<String> getOpenLApikey() async {
    final String openl = await rootBundle.loadString('assets/openl.json');
    final openlJson = json.decode(openl);
    return openlJson['apikey'] as String? ?? '';
  }

  static GoogleTranslator googleTranslator = GoogleTranslator();

  static Future<OpenlTranslation> openLtranslate(
    String sourceText, {
    String from = 'auto',
    String to = 'en',
    String service = 'deepl',
  }) async {
    final String apikey = await getOpenLApikey();

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
    String rultText = '';
    if (OpenLLanguageList.contains(from)) {
      final OpenlTranslation rult =
          await openLtranslate(sourceText, from: from, to: to);
      logger.v(rult.toJson());
      rultText = rult.result ?? '';
    } else {
      try {
        final googleTranslateRult = await googleTranslator.translate(sourceText,
            to: to == 'zh' ? 'zh-cn' : to);
        rultText = googleTranslateRult.text;
      } catch (e, stack) {
        logger.e('$e\n$stack');
      }
    }

    return rultText;
  }
}
