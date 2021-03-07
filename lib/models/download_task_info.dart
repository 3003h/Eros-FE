import 'package:flutter/foundation.dart';


@immutable
class DownloadTaskInfo {
  
  const DownloadTaskInfo({
    this.tag,
    this.gid,
    this.type,
    this.title,
    this.taskId,
    this.dowmloadType,
    this.status,
    this.progress,
  });

  final String? tag;
  final String? gid;
  final String? type;
  final String? title;
  final String? taskId;
  final String? dowmloadType;
  final int? status;
  final int? progress;

  factory DownloadTaskInfo.fromJson(Map<String,dynamic> json) => DownloadTaskInfo(
    tag: json['tag'] != null ? json['tag'] as String : null,
    gid: json['gid'] != null ? json['gid'] as String : null,
    type: json['type'] != null ? json['type'] as String : null,
    title: json['title'] != null ? json['title'] as String : null,
    taskId: json['task_id'] != null ? json['task_id'] as String : null,
    dowmloadType: json['dowmload_type'] != null ? json['dowmload_type'] as String : null,
    status: json['status'] != null ? json['status'] as int : null,
    progress: json['progress'] != null ? json['progress'] as int : null
  );
  
  Map<String, dynamic> toJson() => {
    'tag': tag,
    'gid': gid,
    'type': type,
    'title': title,
    'task_id': taskId,
    'dowmload_type': dowmloadType,
    'status': status,
    'progress': progress
  };

  DownloadTaskInfo clone() => DownloadTaskInfo(
    tag: tag,
    gid: gid,
    type: type,
    title: title,
    taskId: taskId,
    dowmloadType: dowmloadType,
    status: status,
    progress: progress
  );

    
  DownloadTaskInfo copyWith({
    String? tag,
    String? gid,
    String? type,
    String? title,
    String? taskId,
    String? dowmloadType,
    int? status,
    int? progress
  }) => DownloadTaskInfo(
    tag: tag ?? this.tag,
    gid: gid ?? this.gid,
    type: type ?? this.type,
    title: title ?? this.title,
    taskId: taskId ?? this.taskId,
    dowmloadType: dowmloadType ?? this.dowmloadType,
    status: status ?? this.status,
    progress: progress ?? this.progress,
  );  

  @override
  bool operator ==(Object other) => identical(this, other) 
    || other is DownloadTaskInfo && tag == other.tag && gid == other.gid && type == other.type && title == other.title && taskId == other.taskId && dowmloadType == other.dowmloadType && status == other.status && progress == other.progress;

  @override
  int get hashCode => tag.hashCode ^ gid.hashCode ^ type.hashCode ^ title.hashCode ^ taskId.hashCode ^ dowmloadType.hashCode ^ status.hashCode ^ progress.hashCode;
}
