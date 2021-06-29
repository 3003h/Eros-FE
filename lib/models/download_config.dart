import 'package:flutter/foundation.dart';


@immutable
class DownloadConfig {
  
  const DownloadConfig({
    this.preloadImage,
    this.multiDownload,
    this.downloadLocation,
    this.downloadOrigImage,
  });

  final int? preloadImage;
  final int? multiDownload;
  final String? downloadLocation;
  final bool? downloadOrigImage;

  factory DownloadConfig.fromJson(Map<String,dynamic> json) => DownloadConfig(
    preloadImage: json['preloadImage'] != null ? json['preloadImage'] as int : null,
    multiDownload: json['multiDownload'] != null ? json['multiDownload'] as int : null,
    downloadLocation: json['downloadLocation'] != null ? json['downloadLocation'] as String : null,
    downloadOrigImage: json['downloadOrigImage'] != null ? json['downloadOrigImage'] as bool : null
  );
  
  Map<String, dynamic> toJson() => {
    'preloadImage': preloadImage,
    'multiDownload': multiDownload,
    'downloadLocation': downloadLocation,
    'downloadOrigImage': downloadOrigImage
  };

  DownloadConfig clone() => DownloadConfig(
    preloadImage: preloadImage,
    multiDownload: multiDownload,
    downloadLocation: downloadLocation,
    downloadOrigImage: downloadOrigImage
  );

    
  DownloadConfig copyWith({
    int? preloadImage,
    int? multiDownload,
    String? downloadLocation,
    bool? downloadOrigImage
  }) => DownloadConfig(
    preloadImage: preloadImage ?? this.preloadImage,
    multiDownload: multiDownload ?? this.multiDownload,
    downloadLocation: downloadLocation ?? this.downloadLocation,
    downloadOrigImage: downloadOrigImage ?? this.downloadOrigImage,
  );  

  @override
  bool operator ==(Object other) => identical(this, other) 
    || other is DownloadConfig && preloadImage == other.preloadImage && multiDownload == other.multiDownload && downloadLocation == other.downloadLocation && downloadOrigImage == other.downloadOrigImage;

  @override
  int get hashCode => preloadImage.hashCode ^ multiDownload.hashCode ^ downloadLocation.hashCode ^ downloadOrigImage.hashCode;
}
