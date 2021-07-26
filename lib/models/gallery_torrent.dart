import 'package:flutter/foundation.dart';


@immutable
class GalleryTorrent {
  
  const GalleryTorrent({
    this.hash,
    this.added,
    this.name,
    this.tsize,
    this.fsize,
    this.posted,
    this.sizeText,
    this.seeds,
    this.peerd,
    this.downloads,
    this.uploader,
  });

  final String? hash;
  final String? added;
  final String? name;
  final String? tsize;
  final String? fsize;
  final String? posted;
  final String? sizeText;
  final String? seeds;
  final String? peerd;
  final String? downloads;
  final String? uploader;

  factory GalleryTorrent.fromJson(Map<String,dynamic> json) => GalleryTorrent(
    hash: json['hash'] != null ? json['hash'] as String : null,
    added: json['added'] != null ? json['added'] as String : null,
    name: json['name'] != null ? json['name'] as String : null,
    tsize: json['tsize'] != null ? json['tsize'] as String : null,
    fsize: json['fsize'] != null ? json['fsize'] as String : null,
    posted: json['posted'] != null ? json['posted'] as String : null,
    sizeText: json['sizeText'] != null ? json['sizeText'] as String : null,
    seeds: json['seeds'] != null ? json['seeds'] as String : null,
    peerd: json['peerd'] != null ? json['peerd'] as String : null,
    downloads: json['downloads'] != null ? json['downloads'] as String : null,
    uploader: json['uploader'] != null ? json['uploader'] as String : null
  );
  
  Map<String, dynamic> toJson() => {
    'hash': hash,
    'added': added,
    'name': name,
    'tsize': tsize,
    'fsize': fsize,
    'posted': posted,
    'sizeText': sizeText,
    'seeds': seeds,
    'peerd': peerd,
    'downloads': downloads,
    'uploader': uploader
  };

  GalleryTorrent clone() => GalleryTorrent(
    hash: hash,
    added: added,
    name: name,
    tsize: tsize,
    fsize: fsize,
    posted: posted,
    sizeText: sizeText,
    seeds: seeds,
    peerd: peerd,
    downloads: downloads,
    uploader: uploader
  );

    
  GalleryTorrent copyWith({
    String? hash,
    String? added,
    String? name,
    String? tsize,
    String? fsize,
    String? posted,
    String? sizeText,
    String? seeds,
    String? peerd,
    String? downloads,
    String? uploader
  }) => GalleryTorrent(
    hash: hash ?? this.hash,
    added: added ?? this.added,
    name: name ?? this.name,
    tsize: tsize ?? this.tsize,
    fsize: fsize ?? this.fsize,
    posted: posted ?? this.posted,
    sizeText: sizeText ?? this.sizeText,
    seeds: seeds ?? this.seeds,
    peerd: peerd ?? this.peerd,
    downloads: downloads ?? this.downloads,
    uploader: uploader ?? this.uploader,
  );  

  @override
  bool operator ==(Object other) => identical(this, other) 
    || other is GalleryTorrent && hash == other.hash && added == other.added && name == other.name && tsize == other.tsize && fsize == other.fsize && posted == other.posted && sizeText == other.sizeText && seeds == other.seeds && peerd == other.peerd && downloads == other.downloads && uploader == other.uploader;

  @override
  int get hashCode => hash.hashCode ^ added.hashCode ^ name.hashCode ^ tsize.hashCode ^ fsize.hashCode ^ posted.hashCode ^ sizeText.hashCode ^ seeds.hashCode ^ peerd.hashCode ^ downloads.hashCode ^ uploader.hashCode;
}
