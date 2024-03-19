import 'package:eros_fe/pages/gallery/controller/archiver_controller.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;

ArchiverProvider parseArchiver(String response) {
  final Document document = parse(response);

  String gp = '';
  String credits = '';
  final Element? currentFunds = document.querySelector('#db > p:nth-child(4)');
  if (currentFunds != null) {
    final RegExp fundsRegx = RegExp(r'([0-9,]+?)\s+GP.+?([0-9,]+?)\s+Credits');
    final RegExpMatch? match = fundsRegx.firstMatch(currentFunds.text);
    gp = match?.group(1)?.replaceAll(',', '') ?? '';
    credits = match?.group(2)?.replaceAll(',', '') ?? '';
  }

  // logger.d('$response');

  final List<ArchiverProviderItem> _dlItems = <ArchiverProviderItem>[];

  final List<Element> dlElms =
      document.querySelectorAll('#db > div').elementAt(0).children;
  dlElms.removeLast();
  for (final Element dlElm in dlElms) {
    final String _price = RegExp(r':\s+([\w,. ]+)!?$')
            .firstMatch(dlElm.children[0].text)
            ?.group(1) ??
        dlElm.children[0].text;

    final String _size = RegExp(r':\s+([\w,. ]+)!?$')
            .firstMatch(dlElm.children[2].text)
            ?.group(1) ??
        dlElm.children[2].text;

    final String _dltype =
        dlElm.children[1].children.first.attributes['value'] ?? '';

    _dlItems.add(
      ArchiverProviderItem()
        ..dltype = _dltype
        ..size = _size
        ..price = _price,
    );
  }

  final List<ArchiverProviderItem> _hItems = <ArchiverProviderItem>[];
  final List<Element> archiverElms = document
      .querySelectorAll('#db > div')
      .elementAt(1)
      .querySelectorAll('table > tbody > tr > td');

  for (final Element archiverElm in archiverElms) {
    final List<Element> children = archiverElm.children;
    if (children.length >= 3) {
      if (children[1].text.toUpperCase() != 'N/A') {
        final String onClick =
            children[0].children.first.attributes['onclick'] ?? '';
        final String res =
            RegExp(r"\('(\w+)'\)").firstMatch(onClick)?.group(1) ?? '';
        _hItems.add(
          ArchiverProviderItem()
            ..dltype = 'h'
            ..resolution = children[0].text
            ..dlres = res
            ..size = children[1].text
            ..price = children[2].text,
        );
      }
    }
  }

  return ArchiverProvider()
    ..hItems = _hItems
    ..dlItems = _dlItems
    ..gp = gp
    ..credits = credits;
}

String parseArchiverDownload(String response) {
  final Document document = parse(response);
  return document.querySelector('#db > p')?.text ?? '';
}
