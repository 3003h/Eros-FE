import 'package:fehviewer/pages/gallery_main/controller/archiver_controller.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;

ArchiverProvider parseArchiver(String response) {
  final Document document = parse(response);

  String gp = '';
  String credits = '';
  final Element currentFunds = document.querySelector('#db > p:nth-child(4)');
  if (currentFunds != null) {
    // logger.d('${currentFunds.text}');
    final RegExp fundsRegx = RegExp(r'([0-9,]+?)\s+GP.+?([0-9,]+?)\s+Credits');
    final RegExpMatch match = fundsRegx.firstMatch(currentFunds.text);
    // logger.d('${match.group(1)}\n${match.group(2)}');
    gp = match.group(1).replaceAll(',', '');
    credits = match.group(2).replaceAll(',', '');
  }

  // logger.d('$response');

  final List<Element> archiverElms = document
      .querySelectorAll('#db > div')
      .elementAt(1)
      .querySelectorAll('table > tbody > tr > td');

  final List<ArchiverProviderItem> _items = <ArchiverProviderItem>[];
  for (final Element archiverElm in archiverElms) {
    final List<Element> children = archiverElm.children;
    if (children.length >= 3) {
      // logger.d(
      //     '${children[0].text} \n${children[1].text} \n${children[2].text} ');

      if (children[1].text.toUpperCase() != 'N/A') {
        final String onClick = children[0].children.first.attributes['onclick'];
        final String res = RegExp(r"\('(\w+)'\)").firstMatch(onClick).group(1);
        // logger.d('$res');
        _items.add(
          ArchiverProviderItem()
            ..resolution = children[0].text
            ..dlres = res
            ..size = children[1].text
            ..price = children[2].text,
        );
      }
    }
  }

  return ArchiverProvider()
    ..items = _items
    ..gp = gp
    ..credits = credits;
}

String parseArchiverDownload(String response) {
  final Document document = parse(response);
  return document.querySelector('#db > p').text;
}
