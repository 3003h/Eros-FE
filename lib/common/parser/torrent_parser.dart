import 'package:eros_fe/models/base/eh_models.dart';
import 'package:eros_fe/pages/gallery/controller/torrent_controller.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;

TorrentProvider parseTorrent(String response) {
  final Document document = parse(response);

  final List<GalleryTorrent> torrents = [];

  String _torrentToken = '';

  final List<Element> _elmTorrents =
      document.querySelectorAll('#torrentinfo > div:nth-child(1) > form');
  for (final torrent in _elmTorrents) {
    final Element? _tbodyElm = torrent.querySelector('div > table > tbody');

    final Element? trTopElm = _tbodyElm?.children[0];
    final _posted =
        trTopElm?.children[0].text.split(':').sublist(1).join(':').trim();
    final _sizeText =
        trTopElm?.children[1].text.split(':').sublist(1).join(':').trim();
    final _seeds =
        trTopElm?.children[3].text.split(':').sublist(1).join(':').trim();
    final _peers =
        trTopElm?.children[4].text.split(':').sublist(1).join(':').trim();
    final _downloads =
        trTopElm?.children[5].text.split(':').sublist(1).join(':').trim();

    final Element? trUploaderElm = _tbodyElm?.children[1];
    final _uploader = trUploaderElm?.children[0].text;

    final Element? _flieElm = _tbodyElm?.children[2].querySelector('td > a');

    if (_flieElm == null) {
      continue;
    }

    final String _fileName = _flieElm.text;

    final String _href = _flieElm.attributes['href'] ?? '';
    final String _hash =
        RegExp(r'([0-9a-f]{40})').firstMatch(_href)?.group(1) ?? '';

    if (_torrentToken.isEmpty) {
      _torrentToken =
          RegExp(r'/(get|torrent)/(\d+)/').firstMatch(_href)?.group(2) ?? '';
    }

    torrents.add(GalleryTorrent(
      posted: _posted,
      sizeText: _sizeText,
      seeds: _seeds,
      peerd: _peers,
      downloads: _downloads,
      uploader: _uploader,
      name: _fileName,
      hash: _hash,
    ));
  }

  return TorrentProvider()
    ..torrents = torrents
    ..torrentToken = _torrentToken;
}
