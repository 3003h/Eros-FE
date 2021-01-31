import 'package:fehviewer/pages/gallery/controller/torrent_controller.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;

TorrentProvider parseTorrent(String response) {
  final Document document = parse(response);

  final List<TorrentBean> torrents = [];

  String _torrentToken = '';

  final List<Element> _elmTorrents =
      document.querySelectorAll('#torrentinfo > div:nth-child(1) > form');
  for (final torrent in _elmTorrents) {
    final _elm = torrent
        .querySelector(' div > table > tbody')
        .children[2]
        .children
        .first
        .children
        .first;
    final String _fileName = _elm.text;

    final String _href = _elm.attributes['href'];
    final String _hash = RegExp(r'([0-9a-f]{40})').firstMatch(_href).group(1);

    if (_torrentToken.isEmpty) {
      _torrentToken =
          RegExp(r'/(get|torrent)/(\d+)/').firstMatch(_href).group(2);
    }

    logger.d('$_fileName $_hash');
    torrents.add(TorrentBean()
      ..fileName = _fileName
      ..hash = _hash);
  }

  return TorrentProvider()
    ..torrents = torrents
    ..torrentToken = _torrentToken;
}
