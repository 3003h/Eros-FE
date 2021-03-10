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
    isLarge: json['is_large'] != null ? json['is_large'] as bool : null,
    isCache: json['is_cache'] != null ? json['is_cache'] as bool : null,
    startPrecache: json['start_precache'] != null ? json['start_precache'] as bool : null,
    ser: json['ser'] as int,
    href: json['href'] != null ? json['href'] as String : null,
    largeImageUrl: json['large_image_url'] != null ? json['large_image_url'] as String : null,
    imgUrl: json['img_url'] != null ? json['img_url'] as String : null,
    height: json['height'] != null ? json['height'] as double : null,
    width: json['width'] != null ? json['width'] as double : null,
    largeImageHeight: json['large_image_height'] != null ? json['large_image_height'] as double : null,
    largeImageWidth: json['large_image_width'] != null ? json['large_image_width'] as double : null,
    offSet: json['off_set'] != null ? json['off_set'] as double : null,
    sourceId: json['source_id'] != null ? json['source_id'] as String : null,
    completeHeight: json['complete_height'] != null ? json['complete_height'] as bool : null
  );
  
  Map<String, dynamic> toJson() => {
    'is_large': isLarge,
    'is_cache': isCache,
    'start_precache': startPrecache,
    'ser': ser,
    'href': href,
    'large_image_url': largeImageUrl,
    'img_url': imgUrl,
    'height': height,
    'width': width,
    'large_image_height': largeImageHeight,
    'large_image_width': largeImageWidth,
    'off_set': offSet,
    'source_id': sourceId,
    'complete_height': completeHeight
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
