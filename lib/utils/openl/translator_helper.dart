import 'dart:async';

import 'package:fehviewer/config/config.dart';
import 'package:fehviewer/fehviewer.dart';
import 'package:fehviewer/models/openl_translation.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:fehviewer/utils/openl/openl_translator.dart';
// import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';
import 'package:translator/translator.dart';

import 'language.dart';

TranslatorHelper translatorHelper = TranslatorHelper();

class TranslatorHelper {
  final _languageIdentifier = LanguageIdentifier(confidenceThreshold: 0.5);

  // final _modelManager = OnDeviceTranslatorModelManager();
  // final _targetLanguage = TranslateLanguage.chinese;
  //
  // Future<void> _downloadModel(TranslateLanguage language) async {
  //   showToast('DownloadModel ${language.bcpCode}');
  //   await _modelManager.downloadModel(language.bcpCode, isWifiRequired: false);
  // }
  //
  // Future<bool> _isDownloaded(TranslateLanguage language) async {
  //   return await _modelManager.isModelDownloaded(language.bcpCode);
  // }
  //
  // Future<String> _onDeviceTranslateTextMultiLine(
  //   String sourceText, {
  //   String? sourceBcpCode,
  // }) async {
  //   final sourceList = sourceText.split('\n');
  //   List<Future<String>> futures = [];
  //   for (final sourceText in sourceList) {
  //     futures.add(
  //         _onDeviceTranslateText(sourceText, sourceBcpCode: sourceBcpCode));
  //   }
  //
  //   final rult = await Future.wait(futures);
  //   return rult.join("\n");
  // }
  //
  // Future<String> _onDeviceTranslateText(
  //   String sourceText, {
  //   String? sourceBcpCode,
  // }) async {
  //   // logger.d('_onDeviceTranslateText');
  //
  //   late final TranslateLanguage? _sourceLanguage;
  //   if (sourceBcpCode != null) {
  //     _sourceLanguage = _fromRawValue(sourceBcpCode);
  //   } else {
  //     final identifyLanguage =
  //         await _languageIdentifier.identifyLanguage(sourceText);
  //     logger.d('identifyLanguage: $identifyLanguage');
  //     _sourceLanguage = _fromRawValue(identifyLanguage);
  //   }
  //
  //   if (_sourceLanguage == null ||
  //       _sourceLanguage.bcpCode == _targetLanguage.bcpCode) {
  //     return sourceText;
  //   }
  //
  //   logger.d('_onDeviceTranslateText _sourceLanguage: $_sourceLanguage');
  //
  //   if (!await _isDownloaded(_sourceLanguage)) {
  //     await _downloadModel(_sourceLanguage);
  //   }
  //
  //   if (!await _isDownloaded(_targetLanguage)) {
  //     await _downloadModel(_targetLanguage);
  //   }
  //
  //   final _onDeviceTranslator = OnDeviceTranslator(
  //       sourceLanguage: _sourceLanguage, targetLanguage: _targetLanguage);
  //   final result = await _onDeviceTranslator.translateText(sourceText);
  //   return result;
  // }
  //
  // TranslateLanguage? _fromRawValue(String bcpCode) {
  //   try {
  //     return TranslateLanguage.values
  //         .firstWhere((element) => element.bcpCode == bcpCode);
  //   } catch (_) {
  //     return null;
  //   }
  // }

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
    // test
    // final rultOnDeviceTranslate =
    //     await _onDeviceTranslateTextMultiLine(sourceText);

    final sourceLanguage =
        await _languageIdentifier.identifyLanguage(sourceText);
    logger.d('sourceLanguage: $sourceLanguage');

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
