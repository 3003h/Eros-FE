import 'package:flutter/foundation.dart';


@immutable
class DownloadArchiverTaskInfo {
  
  const DownloadArchiverTaskInfo({
    this.tag,
    this.gid,
    this.type,
    this.title,
    this.taskId,
    this.filePath,
    this.imgUrl,
    this.galleryUrl,
    this.dowmloadType,
    this.status,
    this.progress,
  });

  final String? tag;
  final String? gid;
  final String? type;
  final String? title;
  final String? taskId;
  final String? filePath;
  final String? imgUrl;
  final String? galleryUrl;
  final String? dowmloadType;
  final int? status;
  final int? progress;

  factory DownloadArchiverTaskInfo.fromJson(Map<String,dynamic> json) => DownloadArchiverTaskInfo(
    tag: json['tag'] != null ? json['tag'] as String : null,
    gid: json['gid'] != null ? json['gid'] as String : null,
    type: json['type'] != null ? json['type'] as String : null,
    title: json['title'] != null ? json['title'] as String : null,
    taskId: json['taskId'] != null ? json['taskId'] as String : null,
    filePath: json['filePath'] != null ? json['filePath'] as String : null,
    imgUrl: json['imgUrl'] != null ? json['imgUrl'] as String : null,
    galleryUrl: json['galleryUrl'] != null ? json['galleryUrl'] as String : null,
    dowmloadType: json['dowmloadType'] != null ? json['dowmloadType'] as String : null,
    status: json['status'] != null ? json['status'] as int : null,
    progress: json['progress'] != null ? json['progress'] as int : null
  );
  
  Map<String, dynamic> toJson() => {
    'tag': tag,
    'gid': gid,
    'type': type,
    'title': title,
    'taskId': taskId,
    'filePath': filePath,
    'imgUrl': imgUrl,
    'galleryUrl': galleryUrl,
    'dowmloadType': dowmloadType,
    'status': status,
    'progress': progress
  };

  DownloadArchiverTaskInfo clone() => DownloadArchiverTaskInfo(
    tag: tag,
    gid: gid,
    type: type,
    title: title,
    taskId: taskId,
    filePath: filePath,
    imgUrl: imgUrl,
    galleryUrl: galleryUrl,
    dowmloadType: dowmloadType,
    status: status,
    progress: progress
  );

    
  DownloadArchiverTaskInfo copyWith({
    String? tag,
    String? gid,
    String? type,
    String? title,
    String? taskId,
    String? filePath,
    String? imgUrl,
    String? galleryUrl,
    String? dowmloadType,
    int? status,
    int? progress
  }) => DownloadArchiverTaskInfo(
    tag: tag ?? this.tag,
    gid: gid ?? this.gid,
    type: type ?? this.type,
    title: title ?? this.title,
    taskId: taskId ?? this.taskId,
    filePath: filePath ?? this.filePath,
    imgUrl: imgUrl ?? this.imgUrl,
    galleryUrl: galleryUrl ?? this.galleryUrl,
    dowmloadType: dowmloadType ?? this.dowmloadType,
    status: status ?? this.status,
    progress: progress ?? this.progress,
  );  

  @override
  bool operator ==(Object other) => identical(this, other) 
    || other is DownloadArchiverTaskInfo && tag == other.tag && gid == other.gid && type == other.type && title == other.title && taskId == other.taskId && filePath == other.filePath && imgUrl == other.imgUrl && galleryUrl == other.galleryUrl && dowmloadType == other.dowmloadType && status == other.status && progress == other.progress;

  @override
  int get hashCode => tag.hashCode ^ gid.hashCode ^ type.hashCode ^ title.hashCode ^ taskId.hashCode ^ filePath.hashCode ^ imgUrl.hashCode ^ galleryUrl.hashCode ^ dowmloadType.hashCode ^ status.hashCode ^ progress.hashCode;
}
