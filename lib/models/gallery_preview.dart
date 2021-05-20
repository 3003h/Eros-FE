import 'package:flutter/foundation.dart';


@immutable
class GalleryPreview {
  
  const GalleryPreview({
    this.isLarge,
    this.isCache,
    this.startPrecache,
    required this.ser,
    this.href,
    this.largeImageUrl,
    this.imgUrl,
    this.height,
    this.width,
    this.largeImageHeight,
    this.largeImageWidth,
    this.offSet,
    this.sourceId,
    this.completeHeight,
  });

  final bool? isLarge;
  final bool? isCache;
  final bool? startPrecache;
  final int ser;
  final String? href;
  final String? largeImageUrl;
  final String? imgUrl;
  final double? height;
  final double? width;
  final double? largeImageHeight;
  final double? largeImageWidth;
  final double? offSet;
  final String? sourceId;
  final bool? completeHeight;

  factory GalleryPreview.fromJson(Map<String,dynamic> json) => GalleryPreview(
    isLarge: json['isLarge'] != null ? json['isLarge'] as bool : null,
    isCache: json['isCache'] != null ? json['isCache'] as bool : null,
    startPrecache: json['startPrecache'] != null ? json['startPrecache'] as bool : null,
    ser: json['ser'] as int,
    href: json['href'] != null ? json['href'] as String : null,
    largeImageUrl: json['largeImageUrl'] != null ? json['largeImageUrl'] as String : null,
    imgUrl: json['imgUrl'] != null ? json['imgUrl'] as String : null,
    height: json['height'] != null ? json['height'] as double : null,
    width: json['width'] != null ? json['width'] as double : null,
    largeImageHeight: json['largeImageHeight'] != null ? json['largeImageHeight'] as double : null,
    largeImageWidth: json['largeImageWidth'] != null ? json['largeImageWidth'] as double : null,
    offSet: json['offSet'] != null ? json['offSet'] as double : null,
    sourceId: json['sourceId'] != null ? json['sourceId'] as String : null,
    completeHeight: json['completeHeight'] != null ? json['completeHeight'] as bool : null
  );
  
  Map<String, dynamic> toJson() => {
    'isLarge': isLarge,
    'isCache': isCache,
    'startPrecache': startPrecache,
    'ser': ser,
    'href': href,
    'largeImageUrl': largeImageUrl,
    'imgUrl': imgUrl,
    'height': height,
    'width': width,
    'largeImageHeight': largeImageHeight,
    'largeImageWidth': largeImageWidth,
    'offSet': offSet,
    'sourceId': sourceId,
    'completeHeight': completeHeight
  };

  GalleryPreview clone() => GalleryPreview(
    isLarge: isLarge,
    isCache: isCache,
    startPrecache: startPrecache,
    ser: ser,
    href: href,
    largeImageUrl: largeImageUrl,
    imgUrl: imgUrl,
    height: height,
    width: width,
    largeImageHeight: largeImageHeight,
    largeImageWidth: largeImageWidth,
    offSet: offSet,
    sourceId: sourceId,
    completeHeight: completeHeight
  );

    
  GalleryPreview copyWith({
    bool? isLarge,
    bool? isCache,
    bool? startPrecache,
    int? ser,
    String? href,
    String? largeImageUrl,
    String? imgUrl,
    double? height,
    double? width,
    double? largeImageHeight,
    double? largeImageWidth,
    double? offSet,
    String? sourceId,
    bool? completeHeight
  }) => GalleryPreview(
    isLarge: isLarge ?? this.isLarge,
    isCache: isCache ?? this.isCache,
    startPrecache: startPrecache ?? this.startPrecache,
    ser: ser ?? this.ser,
    href: href ?? this.href,
    largeImageUrl: largeImageUrl ?? this.largeImageUrl,
    imgUrl: imgUrl ?? this.imgUrl,
    height: height ?? this.height,
    width: width ?? this.width,
    largeImageHeight: largeImageHeight ?? this.largeImageHeight,
    largeImageWidth: largeImageWidth ?? this.largeImageWidth,
    offSet: offSet ?? this.offSet,
    sourceId: sourceId ?? this.sourceId,
    completeHeight: completeHeight ?? this.completeHeight,
  );  

  @override
  bool operator ==(Object other) => identical(this, other) 
    || other is GalleryPreview && isLarge == other.isLarge && isCache == other.isCache && startPrecache == other.startPrecache && ser == other.ser && href == other.href && largeImageUrl == other.largeImageUrl && imgUrl == other.imgUrl && height == other.height && width == other.width && largeImageHeight == other.largeImageHeight && largeImageWidth == other.largeImageWidth && offSet == other.offSet && sourceId == other.sourceId && completeHeight == other.completeHeight;

  @override
  int get hashCode => isLarge.hashCode ^ isCache.hashCode ^ startPrecache.hashCode ^ ser.hashCode ^ href.hashCode ^ largeImageUrl.hashCode ^ imgUrl.hashCode ^ height.hashCode ^ width.hashCode ^ largeImageHeight.hashCode ^ largeImageWidth.hashCode ^ offSet.hashCode ^ sourceId.hashCode ^ completeHeight.hashCode;
}
