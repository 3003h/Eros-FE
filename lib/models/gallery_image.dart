import 'package:flutter/foundation.dart';
import 'package:quiver/core.dart';

import 'index.dart';

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
    this.oriHeight,
    this.oriWidth,
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
    this.showKey,
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
  final double? oriHeight;
  final double? oriWidth;
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
  final String? showKey;

  factory GalleryImage.fromJson(Map<String,dynamic> json) => GalleryImage(
    largeThumb: json['largeThumb'] != null ? bool.tryParse('${json['largeThumb']}', caseSensitive: false) ?? false : null,
    completeCache: json['completeCache'] != null ? bool.tryParse('${json['completeCache']}', caseSensitive: false) ?? false : null,
    startPrecache: json['startPrecache'] != null ? bool.tryParse('${json['startPrecache']}', caseSensitive: false) ?? false : null,
    ser: int.tryParse('${json['ser']}') ?? 0,
    href: json['href']?.toString(),
    imageUrl: json['imageUrl']?.toString(),
    originImageUrl: json['originImageUrl']?.toString(),
    thumbUrl: json['thumbUrl']?.toString(),
    thumbHeight: json['thumbHeight'] != null ? double.tryParse('${json['thumbHeight']}') ?? 0.0 : null,
    thumbWidth: json['thumbWidth'] != null ? double.tryParse('${json['thumbWidth']}') ?? 0.0 : null,
    imageHeight: json['imageHeight'] != null ? double.tryParse('${json['imageHeight']}') ?? 0.0 : null,
    imageWidth: json['imageWidth'] != null ? double.tryParse('${json['imageWidth']}') ?? 0.0 : null,
    oriHeight: json['oriHeight'] != null ? double.tryParse('${json['oriHeight']}') ?? 0.0 : null,
    oriWidth: json['oriWidth'] != null ? double.tryParse('${json['oriWidth']}') ?? 0.0 : null,
    offSet: json['offSet'] != null ? double.tryParse('${json['offSet']}') ?? 0.0 : null,
    sourceId: json['sourceId']?.toString(),
    completeHeight: json['completeHeight'] != null ? bool.tryParse('${json['completeHeight']}', caseSensitive: false) ?? false : null,
    gid: json['gid']?.toString(),
    token: json['token']?.toString(),
    completeDownload: json['completeDownload'] != null ? bool.tryParse('${json['completeDownload']}', caseSensitive: false) ?? false : null,
    filePath: json['filePath']?.toString(),
    changeSource: json['changeSource'] != null ? bool.tryParse('${json['changeSource']}', caseSensitive: false) ?? false : null,
    hide: json['hide'] != null ? bool.tryParse('${json['hide']}', caseSensitive: false) ?? false : null,
    checkHide: json['checkHide'] != null ? bool.tryParse('${json['checkHide']}', caseSensitive: false) ?? false : null,
    downloadProcess: json['downloadProcess'] != null ? double.tryParse('${json['downloadProcess']}') ?? 0.0 : null,
    errorInfo: json['errorInfo']?.toString(),
    tempPath: json['tempPath']?.toString(),
    filename: json['filename']?.toString(),
    showKey: json['showKey']?.toString()
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
    'oriHeight': oriHeight,
    'oriWidth': oriWidth,
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
    'filename': filename,
    'showKey': showKey
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
    oriHeight: oriHeight,
    oriWidth: oriWidth,
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
    filename: filename,
    showKey: showKey
  );


  GalleryImage copyWith({
    Optional<bool?>? largeThumb,
    Optional<bool?>? completeCache,
    Optional<bool?>? startPrecache,
    int? ser,
    Optional<String?>? href,
    Optional<String?>? imageUrl,
    Optional<String?>? originImageUrl,
    Optional<String?>? thumbUrl,
    Optional<double?>? thumbHeight,
    Optional<double?>? thumbWidth,
    Optional<double?>? imageHeight,
    Optional<double?>? imageWidth,
    Optional<double?>? oriHeight,
    Optional<double?>? oriWidth,
    Optional<double?>? offSet,
    Optional<String?>? sourceId,
    Optional<bool?>? completeHeight,
    Optional<String?>? gid,
    Optional<String?>? token,
    Optional<bool?>? completeDownload,
    Optional<String?>? filePath,
    Optional<bool?>? changeSource,
    Optional<bool?>? hide,
    Optional<bool?>? checkHide,
    Optional<double?>? downloadProcess,
    Optional<String?>? errorInfo,
    Optional<String?>? tempPath,
    Optional<String?>? filename,
    Optional<String?>? showKey
  }) => GalleryImage(
    largeThumb: checkOptional(largeThumb, () => this.largeThumb),
    completeCache: checkOptional(completeCache, () => this.completeCache),
    startPrecache: checkOptional(startPrecache, () => this.startPrecache),
    ser: ser ?? this.ser,
    href: checkOptional(href, () => this.href),
    imageUrl: checkOptional(imageUrl, () => this.imageUrl),
    originImageUrl: checkOptional(originImageUrl, () => this.originImageUrl),
    thumbUrl: checkOptional(thumbUrl, () => this.thumbUrl),
    thumbHeight: checkOptional(thumbHeight, () => this.thumbHeight),
    thumbWidth: checkOptional(thumbWidth, () => this.thumbWidth),
    imageHeight: checkOptional(imageHeight, () => this.imageHeight),
    imageWidth: checkOptional(imageWidth, () => this.imageWidth),
    oriHeight: checkOptional(oriHeight, () => this.oriHeight),
    oriWidth: checkOptional(oriWidth, () => this.oriWidth),
    offSet: checkOptional(offSet, () => this.offSet),
    sourceId: checkOptional(sourceId, () => this.sourceId),
    completeHeight: checkOptional(completeHeight, () => this.completeHeight),
    gid: checkOptional(gid, () => this.gid),
    token: checkOptional(token, () => this.token),
    completeDownload: checkOptional(completeDownload, () => this.completeDownload),
    filePath: checkOptional(filePath, () => this.filePath),
    changeSource: checkOptional(changeSource, () => this.changeSource),
    hide: checkOptional(hide, () => this.hide),
    checkHide: checkOptional(checkHide, () => this.checkHide),
    downloadProcess: checkOptional(downloadProcess, () => this.downloadProcess),
    errorInfo: checkOptional(errorInfo, () => this.errorInfo),
    tempPath: checkOptional(tempPath, () => this.tempPath),
    filename: checkOptional(filename, () => this.filename),
    showKey: checkOptional(showKey, () => this.showKey),
  );

  @override
  bool operator ==(Object other) => identical(this, other)
    || other is GalleryImage && largeThumb == other.largeThumb && completeCache == other.completeCache && startPrecache == other.startPrecache && ser == other.ser && href == other.href && imageUrl == other.imageUrl && originImageUrl == other.originImageUrl && thumbUrl == other.thumbUrl && thumbHeight == other.thumbHeight && thumbWidth == other.thumbWidth && imageHeight == other.imageHeight && imageWidth == other.imageWidth && oriHeight == other.oriHeight && oriWidth == other.oriWidth && offSet == other.offSet && sourceId == other.sourceId && completeHeight == other.completeHeight && gid == other.gid && token == other.token && completeDownload == other.completeDownload && filePath == other.filePath && changeSource == other.changeSource && hide == other.hide && checkHide == other.checkHide && downloadProcess == other.downloadProcess && errorInfo == other.errorInfo && tempPath == other.tempPath && filename == other.filename && showKey == other.showKey;

  @override
  int get hashCode => largeThumb.hashCode ^ completeCache.hashCode ^ startPrecache.hashCode ^ ser.hashCode ^ href.hashCode ^ imageUrl.hashCode ^ originImageUrl.hashCode ^ thumbUrl.hashCode ^ thumbHeight.hashCode ^ thumbWidth.hashCode ^ imageHeight.hashCode ^ imageWidth.hashCode ^ oriHeight.hashCode ^ oriWidth.hashCode ^ offSet.hashCode ^ sourceId.hashCode ^ completeHeight.hashCode ^ gid.hashCode ^ token.hashCode ^ completeDownload.hashCode ^ filePath.hashCode ^ changeSource.hashCode ^ hide.hashCode ^ checkHide.hashCode ^ downloadProcess.hashCode ^ errorInfo.hashCode ^ tempPath.hashCode ^ filename.hashCode ^ showKey.hashCode;
}
