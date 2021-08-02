import 'package:flutter/foundation.dart';


@immutable
class GalleryImage {
  
  const GalleryImage({
    this.isLarge,
    this.isCache,
    this.startPrecache,
    required this.ser,
    this.href,
    this.imageUrl,
    this.thumbUrl,
    this.thumbHeight,
    this.thumbWidth,
    this.imageHeight,
    this.imageWidth,
    this.offSet,
    this.sourceId,
    this.completeHeight,
    this.gid,
    this.token,
    this.isDownloaded,
    this.filePath,
  });

  final bool? isLarge;
  final bool? isCache;
  final bool? startPrecache;
  final int ser;
  final String? href;
  final String? imageUrl;
  final String? thumbUrl;
  final double? thumbHeight;
  final double? thumbWidth;
  final double? imageHeight;
  final double? imageWidth;
  final double? offSet;
  final String? sourceId;
  final bool? completeHeight;
  final String? gid;
  final String? token;
  final bool? isDownloaded;
  final String? filePath;

  factory GalleryImage.fromJson(Map<String,dynamic> json) => GalleryImage(
    isLarge: json['isLarge'] != null ? json['isLarge'] as bool : null,
    isCache: json['isCache'] != null ? json['isCache'] as bool : null,
    startPrecache: json['startPrecache'] != null ? json['startPrecache'] as bool : null,
    ser: json['ser'] as int,
    href: json['href'] != null ? json['href'] as String : null,
    imageUrl: json['imageUrl'] != null ? json['imageUrl'] as String : null,
    thumbUrl: json['thumbUrl'] != null ? json['thumbUrl'] as String : null,
    thumbHeight: json['thumbHeight'] != null ? json['thumbHeight'] as double : null,
    thumbWidth: json['thumbWidth'] != null ? json['thumbWidth'] as double : null,
    imageHeight: json['imageHeight'] != null ? json['imageHeight'] as double : null,
    imageWidth: json['imageWidth'] != null ? json['imageWidth'] as double : null,
    offSet: json['offSet'] != null ? json['offSet'] as double : null,
    sourceId: json['sourceId'] != null ? json['sourceId'] as String : null,
    completeHeight: json['completeHeight'] != null ? json['completeHeight'] as bool : null,
    gid: json['gid'] != null ? json['gid'] as String : null,
    token: json['token'] != null ? json['token'] as String : null,
    isDownloaded: json['isDownloaded'] != null ? json['isDownloaded'] as bool : null,
    filePath: json['filePath'] != null ? json['filePath'] as String : null
  );
  
  Map<String, dynamic> toJson() => {
    'isLarge': isLarge,
    'isCache': isCache,
    'startPrecache': startPrecache,
    'ser': ser,
    'href': href,
    'imageUrl': imageUrl,
    'thumbUrl': thumbUrl,
    'thumbHeight': thumbHeight,
    'thumbWidth': thumbWidth,
    'imageHeight': imageHeight,
    'imageWidth': imageWidth,
    'offSet': offSet,
    'sourceId': sourceId,
    'completeHeight': completeHeight,
    'gid': gid,
    'token': token,
    'isDownloaded': isDownloaded,
    'filePath': filePath
  };

  GalleryImage clone() => GalleryImage(
    isLarge: isLarge,
    isCache: isCache,
    startPrecache: startPrecache,
    ser: ser,
    href: href,
    imageUrl: imageUrl,
    thumbUrl: thumbUrl,
    thumbHeight: thumbHeight,
    thumbWidth: thumbWidth,
    imageHeight: imageHeight,
    imageWidth: imageWidth,
    offSet: offSet,
    sourceId: sourceId,
    completeHeight: completeHeight,
    gid: gid,
    token: token,
    isDownloaded: isDownloaded,
    filePath: filePath
  );

    
  GalleryImage copyWith({
    bool? isLarge,
    bool? isCache,
    bool? startPrecache,
    int? ser,
    String? href,
    String? imageUrl,
    String? thumbUrl,
    double? thumbHeight,
    double? thumbWidth,
    double? imageHeight,
    double? imageWidth,
    double? offSet,
    String? sourceId,
    bool? completeHeight,
    String? gid,
    String? token,
    bool? isDownloaded,
    String? filePath
  }) => GalleryImage(
    isLarge: isLarge ?? this.isLarge,
    isCache: isCache ?? this.isCache,
    startPrecache: startPrecache ?? this.startPrecache,
    ser: ser ?? this.ser,
    href: href ?? this.href,
    imageUrl: imageUrl ?? this.imageUrl,
    thumbUrl: thumbUrl ?? this.thumbUrl,
    thumbHeight: thumbHeight ?? this.thumbHeight,
    thumbWidth: thumbWidth ?? this.thumbWidth,
    imageHeight: imageHeight ?? this.imageHeight,
    imageWidth: imageWidth ?? this.imageWidth,
    offSet: offSet ?? this.offSet,
    sourceId: sourceId ?? this.sourceId,
    completeHeight: completeHeight ?? this.completeHeight,
    gid: gid ?? this.gid,
    token: token ?? this.token,
    isDownloaded: isDownloaded ?? this.isDownloaded,
    filePath: filePath ?? this.filePath,
  );  

  @override
  bool operator ==(Object other) => identical(this, other) 
    || other is GalleryImage && isLarge == other.isLarge && isCache == other.isCache && startPrecache == other.startPrecache && ser == other.ser && href == other.href && imageUrl == other.imageUrl && thumbUrl == other.thumbUrl && thumbHeight == other.thumbHeight && thumbWidth == other.thumbWidth && imageHeight == other.imageHeight && imageWidth == other.imageWidth && offSet == other.offSet && sourceId == other.sourceId && completeHeight == other.completeHeight && gid == other.gid && token == other.token && isDownloaded == other.isDownloaded && filePath == other.filePath;

  @override
  int get hashCode => isLarge.hashCode ^ isCache.hashCode ^ startPrecache.hashCode ^ ser.hashCode ^ href.hashCode ^ imageUrl.hashCode ^ thumbUrl.hashCode ^ thumbHeight.hashCode ^ thumbWidth.hashCode ^ imageHeight.hashCode ^ imageWidth.hashCode ^ offSet.hashCode ^ sourceId.hashCode ^ completeHeight.hashCode ^ gid.hashCode ^ token.hashCode ^ isDownloaded.hashCode ^ filePath.hashCode;
}
