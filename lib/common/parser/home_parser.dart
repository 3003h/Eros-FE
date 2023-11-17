import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;

import '../../models/base/eh_models.dart';

EhHome parserEhHome(String response) {
  final Document document = parse(response);

  final limitTextElms = document
      .querySelectorAll('body > div.stuffbox > div.homebox > p > strong');
  // logger.d('${limitTextElms.length}');

  final _currentLimit = int.tryParse(limitTextElms[0].text) ?? 0;
  final _totLimit = int.tryParse(limitTextElms[1].text) ?? 5000;
  final _resetCost = int.tryParse(limitTextElms[2].text) ?? 0;

  return EhHome(
    resetCost: _resetCost,
    currentLimit: _currentLimit,
    totLimit: _totLimit,
  );
}
