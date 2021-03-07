import 'package:flutter/foundation.dart';


@immutable
class GalleryTorrent {
  
  const GalleryTorrent({
    this.hash,
    this.added,
    this.name,
    this.tsize,
    this.fsize,
  });

  final String? hash;
  final String? added;
  final String? name;
  final String? tsize;
  final String? fsize;

  factory GalleryTorrent.fromJson(Map<String,dynamic> json) => GalleryTorrent(
    hash: json['hash'] != null ? json['hash'] as String : null,
    added: json['added'] != null ? json['added'] as String : null,
    name: json['name'] != null ? json['name'] as String : null,
    tsize: json['tsize'] != null ? json['tsize'] as String : null,
    fsize: json['fsize'] != null ? json['fsize'] as String : null
  );
  
  Map<String, dynamic> toJson() => {
    'hash': hash,
    'added': added,
    'name': name,
    'tsize': tsize,
    'fsize': fsize
  };

  GalleryTorrent clone() => GalleryTorrent(
    hash: hash,
    added: added,
    name: name,
    tsize: tsize,
    fsize: fsize
  );

    
  GalleryTorrent copyWith({
    String? hash,
    String? added,
    String? name,
    String? tsize,
    String? fsize
  }) => GalleryTorrent(
    hash: hash ?? this.hash,
    added: added ?? this.added,
    name: name ?? this.name,
    tsize: tsize ?? this.tsize,
    fsize: fsize ?? this.fsize,
  );  

  @override
  bool operator ==(Object other) => identical(this, other) 
    || other is GalleryTorrent && hash == other.hash && added == other.added && name == other.name && tsize == other.tsize && fsize == other.fsize;

  @override
  int get hashCode => hash.hashCode ^ added.hashCode ^ name.hashCode ^ tsize.hashCode ^ fsize.hashCode;
}
