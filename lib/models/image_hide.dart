import 'package:flutter/foundation.dart';
import 'package:quiver/core.dart';

import 'index.dart';

@immutable
class ImageHide {

  const ImageHide({
    required this.pHash,
    this.imageUrl,
    this.threshold,
    this.left,
    this.top,
    this.width,
    this.height,
  });

  final String pHash;
  final String? imageUrl;
  final int? threshold;
  final int? left;
  final int? top;
  final int? width;
  final int? height;

  factory ImageHide.fromJson(Map<String,dynamic> json) => ImageHide(
    pHash: json['pHash'].toString(),
    imageUrl: json['imageUrl']?.toString(),
    threshold: json['threshold'] != null ? int.tryParse('${json['threshold']}') ?? 0 : null,
    left: json['left'] != null ? int.tryParse('${json['left']}') ?? 0 : null,
    top: json['top'] != null ? int.tryParse('${json['top']}') ?? 0 : null,
    width: json['width'] != null ? int.tryParse('${json['width']}') ?? 0 : null,
    height: json['height'] != null ? int.tryParse('${json['height']}') ?? 0 : null
  );
  
  Map<String, dynamic> toJson() => {
    'pHash': pHash,
    'imageUrl': imageUrl,
    'threshold': threshold,
    'left': left,
    'top': top,
    'width': width,
    'height': height
  };

  ImageHide clone() => ImageHide(
    pHash: pHash,
    imageUrl: imageUrl,
    threshold: threshold,
    left: left,
    top: top,
    width: width,
    height: height
  );


  ImageHide copyWith({
    String? pHash,
    Optional<String?>? imageUrl,
    Optional<int?>? threshold,
    Optional<int?>? left,
    Optional<int?>? top,
    Optional<int?>? width,
    Optional<int?>? height
  }) => ImageHide(
    pHash: pHash ?? this.pHash,
    imageUrl: checkOptional(imageUrl, () => this.imageUrl),
    threshold: checkOptional(threshold, () => this.threshold),
    left: checkOptional(left, () => this.left),
    top: checkOptional(top, () => this.top),
    width: checkOptional(width, () => this.width),
    height: checkOptional(height, () => this.height),
  );

  @override
  bool operator ==(Object other) => identical(this, other)
    || other is ImageHide && pHash == other.pHash && imageUrl == other.imageUrl && threshold == other.threshold && left == other.left && top == other.top && width == other.width && height == other.height;

  @override
  int get hashCode => pHash.hashCode ^ imageUrl.hashCode ^ threshold.hashCode ^ left.hashCode ^ top.hashCode ^ width.hashCode ^ height.hashCode;
}
