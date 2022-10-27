import 'package:flutter/foundation.dart';


@immutable
class GalleryImage {
  
  const GalleryImage({
    this.largeThumb,
    this.completeCache,
    this.startPrecache,
    required this.ser,
    this.href,
    this.imageUrl,
    this.originImageUrl,
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
    this.completeDownload,
    this.filePath,
    this.changeSource,
    this.hide,
    this.checkHide,
    this.downloadProcess,
    this.errorInfo,
    this.tempPath,
    this.filename,
  });

  final bool? largeThumb;
  final bool? completeCache;
  final bool? startPrecache;
  final int ser;
  final String? href;
  final String? imageUrl;
  final String? originImageUrl;
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
  final bool? completeDownload;
  final String? filePath;
  final bool? changeSource;
  final bool? hide;
  final bool? checkHide;
  final double? downloadProcess;
  final String? errorInfo;
  final String? tempPath;
  final String? filename;

  factory GalleryImage.fromJson(Map<String,dynamic> json) => GalleryImage(
    largeThumb: json['largeThumb'] != null ? json['largeThumb'] as bool : null,
    completeCache: json['completeCache'] != null ? json['completeCache'] as bool : null,
    startPrecache: json['startPrecache'] != null ? json['startPrecache'] as bool : null,
    ser: json['ser'] as int,
    href: json['href'] != null ? json['href'] as String : null,
    imageUrl: json['imageUrl'] != null ? json['imageUrl'] as String : null,
    originImageUrl: json['originImageUrl'] != null ? json['originImageUrl'] as String : null,
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
    completeDownload: json['completeDownload'] != null ? json['completeDownload'] as bool : null,
    filePath: json['filePath'] != null ? json['filePath'] as String : null,
    changeSource: json['changeSource'] != null ? json['changeSource'] as bool : null,
    hide: json['hide'] != null ? json['hide'] as bool : null,
    checkHide: json['checkHide'] != null ? json['checkHide'] as bool : null,
    downloadProcess: json['downloadProcess'] != null ? json['downloadProcess'] as double : null,
    errorInfo: json['errorInfo'] != null ? json['errorInfo'] as String : null,
    tempPath: json['tempPath'] != null ? json['tempPath'] as String : null,
    filename: json['filename'] != null ? json['filename'] as String : null
  );
  
  Map<String, dynamic> toJson() => {
    'largeThumb': largeThumb,
    'completeCache': completeCache,
    'startPrecache': startPrecache,
    'ser': ser,
    'href': href,
    'imageUrl': imageUrl,
    'originImageUrl': originImageUrl,
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
    'completeDownload': completeDownload,
    'filePath': filePath,
    'changeSource': changeSource,
    'hide': hide,
    'checkHide': checkHide,
    'downloadProcess': downloadProcess,
    'errorInfo': errorInfo,
    'tempPath': tempPath,
    'filename': filename
  };

  GalleryImage clone() => GalleryImage(
    largeThumb: largeThumb,
    completeCache: completeCache,
    startPrecache: startPrecache,
    ser: ser,
    href: href,
    imageUrl: imageUrl,
    originImageUrl: originImageUrl,
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
    completeDownload: completeDownload,
    filePath: filePath,
    changeSource: changeSource,
    hide: hide,
    checkHide: checkHide,
    downloadProcess: downloadProcess,
    errorInfo: errorInfo,
    tempPath: tempPath,
    filename: filename
  );

    
  GalleryImage copyWith({
    bool? largeThumb,
    bool? completeCache,
    bool? startPrecache,
    int? ser,
    String? href,
    String? imageUrl,
    String? originImageUrl,
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
    bool? completeDownload,
    String? filePath,
    bool? changeSource,
    bool? hide,
    bool? checkHide,
    double? downloadProcess,
    String? errorInfo,
    String? tempPath,
    String? filename
  }) => GalleryImage(
    largeThumb: largeThumb ?? this.largeThumb,
    completeCache: completeCache ?? this.completeCache,
    startPrecache: startPrecache ?? this.startPrecache,
    ser: ser ?? this.ser,
    href: href ?? this.href,
    imageUrl: imageUrl ?? this.imageUrl,
    originImageUrl: originImageUrl ?? this.originImageUrl,
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
    completeDownload: completeDownload ?? this.completeDownload,
    filePath: filePath ?? this.filePath,
    changeSource: changeSource ?? this.changeSource,
    hide: hide ?? this.hide,
    checkHide: checkHide ?? this.checkHide,
    downloadProcess: downloadProcess ?? this.downloadProcess,
    errorInfo: errorInfo ?? this.errorInfo,
    tempPath: tempPath ?? this.tempPath,
    filename: filename ?? this.filename,
  );  

  @override
  bool operator ==(Object other) => identical(this, other) 
    || other is GalleryImage && largeThumb == other.largeThumb && completeCache == other.completeCache && startPrecache == other.startPrecache && ser == other.ser && href == other.href && imageUrl == other.imageUrl && originImageUrl == other.originImageUrl && thumbUrl == other.thumbUrl && thumbHeight == other.thumbHeight && thumbWidth == other.thumbWidth && imageHeight == other.imageHeight && imageWidth == other.imageWidth && offSet == other.offSet && sourceId == other.sourceId && completeHeight == other.completeHeight && gid == other.gid && token == other.token && completeDownload == other.completeDownload && filePath == other.filePath && changeSource == other.changeSource && hide == other.hide && checkHide == other.checkHide && downloadProcess == other.downloadProcess && errorInfo == other.errorInfo && tempPath == other.tempPath && filename == other.filename;

  @override
  int get hashCode => largeThumb.hashCode ^ completeCache.hashCode ^ startPrecache.hashCode ^ ser.hashCode ^ href.hashCode ^ imageUrl.hashCode ^ originImageUrl.hashCode ^ thumbUrl.hashCode ^ thumbHeight.hashCode ^ thumbWidth.hashCode ^ imageHeight.hashCode ^ imageWidth.hashCode ^ offSet.hashCode ^ sourceId.hashCode ^ completeHeight.hashCode ^ gid.hashCode ^ token.hashCode ^ completeDownload.hashCode ^ filePath.hashCode ^ changeSource.hashCode ^ hide.hashCode ^ checkHide.hashCode ^ downloadProcess.hashCode ^ errorInfo.hashCode ^ tempPath.hashCode ^ filename.hashCode;
}
