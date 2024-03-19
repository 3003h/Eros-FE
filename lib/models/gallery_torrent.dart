import 'package:flutter/foundation.dart';
import 'package:quiver/core.dart';

import 'index.dart';

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
    hash: json['hash']?.toString(),
    added: json['added']?.toString(),
    name: json['name']?.toString(),
    tsize: json['tsize']?.toString(),
    fsize: json['fsize']?.toString(),
    posted: json['posted']?.toString(),
    sizeText: json['sizeText']?.toString(),
    seeds: json['seeds']?.toString(),
    peerd: json['peerd']?.toString(),
    downloads: json['downloads']?.toString(),
    uploader: json['uploader']?.toString()
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
    Optional<String?>? hash,
    Optional<String?>? added,
    Optional<String?>? name,
    Optional<String?>? tsize,
    Optional<String?>? fsize,
    Optional<String?>? posted,
    Optional<String?>? sizeText,
    Optional<String?>? seeds,
    Optional<String?>? peerd,
    Optional<String?>? downloads,
    Optional<String?>? uploader
  }) => GalleryTorrent(
    hash: checkOptional(hash, () => this.hash),
    added: checkOptional(added, () => this.added),
    name: checkOptional(name, () => this.name),
    tsize: checkOptional(tsize, () => this.tsize),
    fsize: checkOptional(fsize, () => this.fsize),
    posted: checkOptional(posted, () => this.posted),
    sizeText: checkOptional(sizeText, () => this.sizeText),
    seeds: checkOptional(seeds, () => this.seeds),
    peerd: checkOptional(peerd, () => this.peerd),
    downloads: checkOptional(downloads, () => this.downloads),
    uploader: checkOptional(uploader, () => this.uploader),
  );

  @override
  bool operator ==(Object other) => identical(this, other)
    || other is GalleryTorrent && hash == other.hash && added == other.added && name == other.name && tsize == other.tsize && fsize == other.fsize && posted == other.posted && sizeText == other.sizeText && seeds == other.seeds && peerd == other.peerd && downloads == other.downloads && uploader == other.uploader;

  @override
  int get hashCode => hash.hashCode ^ added.hashCode ^ name.hashCode ^ tsize.hashCode ^ fsize.hashCode ^ posted.hashCode ^ sizeText.hashCode ^ seeds.hashCode ^ peerd.hashCode ^ downloads.hashCode ^ uploader.hashCode;
}
