import 'package:flutter/foundation.dart';
import 'package:quiver/core.dart';

import 'index.dart';

@immutable
class DownloadConfig {

  const DownloadConfig({
    this.preloadImage,
    this.multiDownload,
    this.downloadLocation,
    this.downloadOrigImage,
    this.downloadOrigImageType,
    this.allowMediaScan,
    this.concurrentGalleries,
  });

  final int? preloadImage;
  final int? multiDownload;
  final String? downloadLocation;
  final bool? downloadOrigImage;
  final String? downloadOrigImageType;
  final bool? allowMediaScan;
  final int? concurrentGalleries;

  factory DownloadConfig.fromJson(Map<String,dynamic> json) => DownloadConfig(
    preloadImage: json['preloadImage'] != null ? int.tryParse('${json['preloadImage']}') ?? 0 : null,
    multiDownload: json['multiDownload'] != null ? int.tryParse('${json['multiDownload']}') ?? 0 : null,
    downloadLocation: json['downloadLocation']?.toString(),
    downloadOrigImage: json['downloadOrigImage'] != null ? bool.tryParse('${json['downloadOrigImage']}', caseSensitive: false) ?? false : null,
    downloadOrigImageType: json['downloadOrigImageType']?.toString(),
    allowMediaScan: json['allowMediaScan'] != null ? bool.tryParse('${json['allowMediaScan']}', caseSensitive: false) ?? false : null,
    concurrentGalleries: json['concurrentGalleries'] != null ? int.tryParse('${json['concurrentGalleries']}') ?? 0 : null
  );
  
  Map<String, dynamic> toJson() => {
    'preloadImage': preloadImage,
    'multiDownload': multiDownload,
    'downloadLocation': downloadLocation,
    'downloadOrigImage': downloadOrigImage,
    'downloadOrigImageType': downloadOrigImageType,
    'allowMediaScan': allowMediaScan,
    'concurrentGalleries': concurrentGalleries
  };

  DownloadConfig clone() => DownloadConfig(
    preloadImage: preloadImage,
    multiDownload: multiDownload,
    downloadLocation: downloadLocation,
    downloadOrigImage: downloadOrigImage,
    downloadOrigImageType: downloadOrigImageType,
    allowMediaScan: allowMediaScan,
    concurrentGalleries: concurrentGalleries
  );


  DownloadConfig copyWith({
    Optional<int?>? preloadImage,
    Optional<int?>? multiDownload,
    Optional<String?>? downloadLocation,
    Optional<bool?>? downloadOrigImage,
    Optional<String?>? downloadOrigImageType,
    Optional<bool?>? allowMediaScan,
    Optional<int?>? concurrentGalleries
  }) => DownloadConfig(
    preloadImage: checkOptional(preloadImage, () => this.preloadImage),
    multiDownload: checkOptional(multiDownload, () => this.multiDownload),
    downloadLocation: checkOptional(downloadLocation, () => this.downloadLocation),
    downloadOrigImage: checkOptional(downloadOrigImage, () => this.downloadOrigImage),
    downloadOrigImageType: checkOptional(downloadOrigImageType, () => this.downloadOrigImageType),
    allowMediaScan: checkOptional(allowMediaScan, () => this.allowMediaScan),
    concurrentGalleries: checkOptional(concurrentGalleries, () => this.concurrentGalleries),
  );

  @override
  bool operator ==(Object other) => identical(this, other)
    || other is DownloadConfig && preloadImage == other.preloadImage && multiDownload == other.multiDownload && downloadLocation == other.downloadLocation && downloadOrigImage == other.downloadOrigImage && downloadOrigImageType == other.downloadOrigImageType && allowMediaScan == other.allowMediaScan && concurrentGalleries == other.concurrentGalleries;

  @override
  int get hashCode => preloadImage.hashCode ^ multiDownload.hashCode ^ downloadLocation.hashCode ^ downloadOrigImage.hashCode ^ downloadOrigImageType.hashCode ^ allowMediaScan.hashCode ^ concurrentGalleries.hashCode;
}
