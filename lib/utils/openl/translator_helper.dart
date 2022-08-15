import 'dart:async';

import 'package:fehviewer/config/config.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/utils/openl/openl_translator.dart';
import 'package:learning_language/learning_language.dart';
import 'package:translator/translator.dart';

import 'language.dart';

TranslatorHelper translatorHelper = TranslatorHelper();

class TranslatorHelper {
  final _languageIdentifier = LanguageIdentifier();

  GoogleTranslator googleTranslator = GoogleTranslator();

  Future<String?> getOpenLApikey() async {
    return FeConfig.openLapikey;
  }

  Future<OpenlTranslation?> openLtranslate(
    String sourceText, {
    String from = 'auto',
    String to = 'en',
    String service = 'deepl',
  }) async {
    final String? apikey = await getOpenLApikey();
    if (apikey == null || apikey.isEmpty) {
      return null;
    }

    final OpenLTranslator openLTranslator = OpenLTranslator(apikey: apikey);
    return openLTranslator.translate(
      sourceText,
      from: from,
      to: to,
      service: service,
    );
  }

  Future<String?> getfallbackService() async {
    final String? apikey = await getOpenLApikey();
    if (apikey == null || apikey.isEmpty) {
      return null;
    }
    final OpenLTranslator openLTranslator = OpenLTranslator(apikey: apikey);
    return await openLTranslator.getfallbackService();
  }

  Future<String> translateText(
    String sourceText, {
    String to = 'zh',
    String service = 'deepl',
  }) async {
    logger.d('translateText');

    final sourceLanguage = await _languageIdentifier.identify(sourceText);
    logger.d('sourceLanguage: $sourceLanguage');

    // final sourceLanguage = 'en';

    bool useGoogleTranslate = false;
    String rultText = '';
    if (OpenLLanguageList.contains(sourceLanguage)) {
      OpenlTranslation? rult =
          await openLtranslate(sourceText, from: sourceLanguage, to: to);

      if (rult == null) {
        useGoogleTranslate = true;
      } else if (rult.status != true) {
        final service = await getfallbackService();
        if (service != null) {
          logger.d('getfallbackService $service');
          try {
            rult = await openLtranslate(
              sourceText,
              from: sourceLanguage,
              to: to,
              service: service,
            );
          } catch (e, stack) {
            logger.e('$e\n$stack');
            useGoogleTranslate = true;
          }
        }
      }
      rultText = rult?.result ?? '';
    } else {
      useGoogleTranslate = true;
    }

    if (useGoogleTranslate) {
      logger.d('useGoogleTranslate');
      try {
        final googleTranslateRult = await googleTranslator.translate(
          sourceText,
          from: sourceLanguage,
          to: to == 'zh' ? 'zh-cn' : to,
        );
        rultText = googleTranslateRult.text;
      } catch (e, stack) {
        logger.e('$e\n$stack');
      }
    }

    // return '$sourceText\n##########\n$rultText\n##########\n$rultOnDeviceTranslate';

    return rultText;
  }
}
