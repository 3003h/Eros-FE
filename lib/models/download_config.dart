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
    preloadImage: json['preload_image'] != null ? json['preload_image'] as int : null,
    multiDownload: json['multi_download'] != null ? json['multi_download'] as int : null,
    downloadLocatino: json['download_locatino'] != null ? json['download_locatino'] as String : null,
    downloadOrigImage: json['download_orig_image'] != null ? json['download_orig_image'] as bool : null
  );
  
  Map<String, dynamic> toJson() => {
    'preload_image': preloadImage,
    'multi_download': multiDownload,
    'download_locatino': downloadLocatino,
    'download_orig_image': downloadOrigImage
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
