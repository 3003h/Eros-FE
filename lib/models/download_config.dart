import 'package:flutter/foundation.dart';


@immutable
class DownloadConfig {
  
  const DownloadConfig({
    this.preloadImage,
    this.multiDownload,
    this.downloadLocatino,
    this.downloadOrigImage,
  });

  final int? preloadImage;
  final int? multiDownload;
  final String? downloadLocatino;
  final bool? downloadOrigImage;

  factory DownloadConfig.fromJson(Map<String,dynamic> json) => DownloadConfig(
    preloadImage: json['preloadImage'] != null ? json['preloadImage'] as int : null,
    multiDownload: json['multiDownload'] != null ? json['multiDownload'] as int : null,
    downloadLocatino: json['downloadLocatino'] != null ? json['downloadLocatino'] as String : null,
    downloadOrigImage: json['downloadOrigImage'] != null ? json['downloadOrigImage'] as bool : null
  );
  
  Map<String, dynamic> toJson() => {
    'preloadImage': preloadImage,
    'multiDownload': multiDownload,
    'downloadLocatino': downloadLocatino,
    'downloadOrigImage': downloadOrigImage
  };

  DownloadConfig clone() => DownloadConfig(
    preloadImage: preloadImage,
    multiDownload: multiDownload,
    downloadLocatino: downloadLocatino,
    downloadOrigImage: downloadOrigImage
  );

    
  DownloadConfig copyWith({
    int? preloadImage,
    int? multiDownload,
    String? downloadLocatino,
    bool? downloadOrigImage
  }) => DownloadConfig(
    preloadImage: preloadImage ?? this.preloadImage,
    multiDownload: multiDownload ?? this.multiDownload,
    downloadLocatino: downloadLocatino ?? this.downloadLocatino,
    downloadOrigImage: downloadOrigImage ?? this.downloadOrigImage,
  );  

  @override
  bool operator ==(Object other) => identical(this, other) 
    || other is DownloadConfig && preloadImage == other.preloadImage && multiDownload == other.multiDownload && downloadLocatino == other.downloadLocatino && downloadOrigImage == other.downloadOrigImage;

  @override
  int get hashCode => preloadImage.hashCode ^ multiDownload.hashCode ^ downloadLocatino.hashCode ^ downloadOrigImage.hashCode;
}
