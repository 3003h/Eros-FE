import 'package:flutter/foundation.dart';
import 'package:quiver/core.dart';

import 'index.dart';

@immutable
class ImageHide {

  const ImageHide({
    required this.pHash,
    this.imageUrl,
    this.threshold,
  });

  final String pHash;
  final String? imageUrl;
  final int? threshold;

  factory ImageHide.fromJson(Map<String,dynamic> json) => ImageHide(
    pHash: json['pHash'].toString(),
    imageUrl: json['imageUrl']?.toString(),
    threshold: json['threshold'] != null ? int.tryParse('${json['threshold']}') ?? 0 : null
  );
  
  Map<String, dynamic> toJson() => {
    'pHash': pHash,
    'imageUrl': imageUrl,
    'threshold': threshold
  };

  ImageHide clone() => ImageHide(
    pHash: pHash,
    imageUrl: imageUrl,
    threshold: threshold
  );


  ImageHide copyWith({
    String? pHash,
    Optional<String?>? imageUrl,
    Optional<int?>? threshold
  }) => ImageHide(
    pHash: pHash ?? this.pHash,
    imageUrl: checkOptional(imageUrl, () => this.imageUrl),
    threshold: checkOptional(threshold, () => this.threshold),
  );

  @override
  bool operator ==(Object other) => identical(this, other)
    || other is ImageHide && pHash == other.pHash && imageUrl == other.imageUrl && threshold == other.threshold;

  @override
  int get hashCode => pHash.hashCode ^ imageUrl.hashCode ^ threshold.hashCode;
}
