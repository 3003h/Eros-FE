import 'package:flutter/foundation.dart';


@immutable
class DownloadArchiverTaskInfo {
  
  const DownloadArchiverTaskInfo({
    this.tag,
    this.gid,
    this.type,
    this.title,
    this.taskId,
    this.savedDir,
    this.fileName,
    this.url,
    this.imgUrl,
    this.galleryUrl,
    this.dowmloadType,
    this.status,
    this.progress,
    this.timeCreated,
    this.resolution,
    this.safUri,
  });

  final String? tag;
  final String? gid;
  final String? type;
  final String? title;
  final String? taskId;
  final String? savedDir;
  final String? fileName;
  final String? url;
  final String? imgUrl;
  final String? galleryUrl;
  final String? dowmloadType;
  final int? status;
  final int? progress;
  final int? timeCreated;
  final String? resolution;
  final String? safUri;

  factory DownloadArchiverTaskInfo.fromJson(Map<String,dynamic> json) => DownloadArchiverTaskInfo(
    tag: json['tag'] != null ? json['tag'] as String : null,
    gid: json['gid'] != null ? json['gid'] as String : null,
    type: json['type'] != null ? json['type'] as String : null,
    title: json['title'] != null ? json['title'] as String : null,
    taskId: json['taskId'] != null ? json['taskId'] as String : null,
    savedDir: json['savedDir'] != null ? json['savedDir'] as String : null,
    fileName: json['fileName'] != null ? json['fileName'] as String : null,
    url: json['url'] != null ? json['url'] as String : null,
    imgUrl: json['imgUrl'] != null ? json['imgUrl'] as String : null,
    galleryUrl: json['galleryUrl'] != null ? json['galleryUrl'] as String : null,
    dowmloadType: json['dowmloadType'] != null ? json['dowmloadType'] as String : null,
    status: json['status'] != null ? json['status'] as int : null,
    progress: json['progress'] != null ? json['progress'] as int : null,
    timeCreated: json['timeCreated'] != null ? json['timeCreated'] as int : null,
    resolution: json['resolution'] != null ? json['resolution'] as String : null,
    safUri: json['safUri'] != null ? json['safUri'] as String : null
  );
  
  Map<String, dynamic> toJson() => {
    'tag': tag,
    'gid': gid,
    'type': type,
    'title': title,
    'taskId': taskId,
    'savedDir': savedDir,
    'fileName': fileName,
    'url': url,
    'imgUrl': imgUrl,
    'galleryUrl': galleryUrl,
    'dowmloadType': dowmloadType,
    'status': status,
    'progress': progress,
    'timeCreated': timeCreated,
    'resolution': resolution,
    'safUri': safUri
  };

  DownloadArchiverTaskInfo clone() => DownloadArchiverTaskInfo(
    tag: tag,
    gid: gid,
    type: type,
    title: title,
    taskId: taskId,
    savedDir: savedDir,
    fileName: fileName,
    url: url,
    imgUrl: imgUrl,
    galleryUrl: galleryUrl,
    dowmloadType: dowmloadType,
    status: status,
    progress: progress,
    timeCreated: timeCreated,
    resolution: resolution,
    safUri: safUri
  );

    
  DownloadArchiverTaskInfo copyWith({
    String? tag,
    String? gid,
    String? type,
    String? title,
    String? taskId,
    String? savedDir,
    String? fileName,
    String? url,
    String? imgUrl,
    String? galleryUrl,
    String? dowmloadType,
    int? status,
    int? progress,
    int? timeCreated,
    String? resolution,
    String? safUri
  }) => DownloadArchiverTaskInfo(
    tag: tag ?? this.tag,
    gid: gid ?? this.gid,
    type: type ?? this.type,
    title: title ?? this.title,
    taskId: taskId ?? this.taskId,
    savedDir: savedDir ?? this.savedDir,
    fileName: fileName ?? this.fileName,
    url: url ?? this.url,
    imgUrl: imgUrl ?? this.imgUrl,
    galleryUrl: galleryUrl ?? this.galleryUrl,
    dowmloadType: dowmloadType ?? this.dowmloadType,
    status: status ?? this.status,
    progress: progress ?? this.progress,
    timeCreated: timeCreated ?? this.timeCreated,
    resolution: resolution ?? this.resolution,
    safUri: safUri ?? this.safUri,
  );  

  @override
  bool operator ==(Object other) => identical(this, other) 
    || other is DownloadArchiverTaskInfo && tag == other.tag && gid == other.gid && type == other.type && title == other.title && taskId == other.taskId && savedDir == other.savedDir && fileName == other.fileName && url == other.url && imgUrl == other.imgUrl && galleryUrl == other.galleryUrl && dowmloadType == other.dowmloadType && status == other.status && progress == other.progress && timeCreated == other.timeCreated && resolution == other.resolution && safUri == other.safUri;

  @override
  int get hashCode => tag.hashCode ^ gid.hashCode ^ type.hashCode ^ title.hashCode ^ taskId.hashCode ^ savedDir.hashCode ^ fileName.hashCode ^ url.hashCode ^ imgUrl.hashCode ^ galleryUrl.hashCode ^ dowmloadType.hashCode ^ status.hashCode ^ progress.hashCode ^ timeCreated.hashCode ^ resolution.hashCode ^ safUri.hashCode;
}
