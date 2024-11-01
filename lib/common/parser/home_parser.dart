import 'package:eros_fe/utils/logger.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;

import '../../models/base/eh_models.dart';

EhHome parserEhHome(String response) {
  final Document document = parse(response);

  final homeboxEml =
      document.querySelector('body > div.stuffbox > div.homebox');
  logger.d('homeboxEml: ${homeboxEml?.text}');

  final bool highResolutionLimited =
      homeboxEml?.text.contains('high-resolution images can be limited') ??
          false;

  final limitTextElms = document
      .querySelectorAll('body > div.stuffbox > div.homebox > p > strong');
  logger.d('limitTextElms len: ${limitTextElms.length}');

  logger.d('limitTextElms: ${limitTextElms.map((e) => e.text).toList()}');

  if (limitTextElms.length < 3) {
    final unlockCost =
        int.tryParse(limitTextElms[0].text.replaceAll(',', '')) ?? 0;
    logger.d('unlockCost: $unlockCost');
    return EhHome(
      highResolutionLimited: highResolutionLimited,
      unlockCost: unlockCost,
    );
  }

  final currentLimit =
      int.tryParse(limitTextElms[0].text.replaceAll(',', '')) ?? 0;
  final totLimit = int.tryParse(limitTextElms[1].text.replaceAll(',', '')) ?? 0;
  final resetCost =
      int.tryParse(limitTextElms[2].text.replaceAll(',', '')) ?? 0;

  return EhHome(
    resetCost: resetCost,
    currentLimit: currentLimit,
    totLimit: totLimit,
    highResolutionLimited: highResolutionLimited,
  );
}
