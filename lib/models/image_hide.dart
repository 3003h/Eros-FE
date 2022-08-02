import 'package:flutter/foundation.dart';


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
    pHash: json['pHash'] as String,
    imageUrl: json['imageUrl'] != null ? json['imageUrl'] as String : null,
    threshold: json['threshold'] != null ? json['threshold'] as int : null
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
    String? imageUrl,
    int? threshold
  }) => ImageHide(
    pHash: pHash ?? this.pHash,
    imageUrl: imageUrl ?? this.imageUrl,
    threshold: threshold ?? this.threshold,
  );  

  @override
  bool operator ==(Object other) => identical(this, other) 
    || other is ImageHide && pHash == other.pHash && imageUrl == other.imageUrl && threshold == other.threshold;

  @override
  int get hashCode => pHash.hashCode ^ imageUrl.hashCode ^ threshold.hashCode;
}
