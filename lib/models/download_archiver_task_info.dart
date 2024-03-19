import 'package:flutter/foundation.dart';
import 'package:quiver/core.dart';

import 'index.dart';

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
    tag: json['tag']?.toString(),
    gid: json['gid']?.toString(),
    type: json['type']?.toString(),
    title: json['title']?.toString(),
    taskId: json['taskId']?.toString(),
    savedDir: json['savedDir']?.toString(),
    fileName: json['fileName']?.toString(),
    url: json['url']?.toString(),
    imgUrl: json['imgUrl']?.toString(),
    galleryUrl: json['galleryUrl']?.toString(),
    dowmloadType: json['dowmloadType']?.toString(),
    status: json['status'] != null ? int.tryParse('${json['status']}') ?? 0 : null,
    progress: json['progress'] != null ? int.tryParse('${json['progress']}') ?? 0 : null,
    timeCreated: json['timeCreated'] != null ? int.tryParse('${json['timeCreated']}') ?? 0 : null,
    resolution: json['resolution']?.toString(),
    safUri: json['safUri']?.toString()
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
    Optional<String?>? tag,
    Optional<String?>? gid,
    Optional<String?>? type,
    Optional<String?>? title,
    Optional<String?>? taskId,
    Optional<String?>? savedDir,
    Optional<String?>? fileName,
    Optional<String?>? url,
    Optional<String?>? imgUrl,
    Optional<String?>? galleryUrl,
    Optional<String?>? dowmloadType,
    Optional<int?>? status,
    Optional<int?>? progress,
    Optional<int?>? timeCreated,
    Optional<String?>? resolution,
    Optional<String?>? safUri
  }) => DownloadArchiverTaskInfo(
    tag: checkOptional(tag, () => this.tag),
    gid: checkOptional(gid, () => this.gid),
    type: checkOptional(type, () => this.type),
    title: checkOptional(title, () => this.title),
    taskId: checkOptional(taskId, () => this.taskId),
    savedDir: checkOptional(savedDir, () => this.savedDir),
    fileName: checkOptional(fileName, () => this.fileName),
    url: checkOptional(url, () => this.url),
    imgUrl: checkOptional(imgUrl, () => this.imgUrl),
    galleryUrl: checkOptional(galleryUrl, () => this.galleryUrl),
    dowmloadType: checkOptional(dowmloadType, () => this.dowmloadType),
    status: checkOptional(status, () => this.status),
    progress: checkOptional(progress, () => this.progress),
    timeCreated: checkOptional(timeCreated, () => this.timeCreated),
    resolution: checkOptional(resolution, () => this.resolution),
    safUri: checkOptional(safUri, () => this.safUri),
  );

  @override
  bool operator ==(Object other) => identical(this, other)
    || other is DownloadArchiverTaskInfo && tag == other.tag && gid == other.gid && type == other.type && title == other.title && taskId == other.taskId && savedDir == other.savedDir && fileName == other.fileName && url == other.url && imgUrl == other.imgUrl && galleryUrl == other.galleryUrl && dowmloadType == other.dowmloadType && status == other.status && progress == other.progress && timeCreated == other.timeCreated && resolution == other.resolution && safUri == other.safUri;

  @override
  int get hashCode => tag.hashCode ^ gid.hashCode ^ type.hashCode ^ title.hashCode ^ taskId.hashCode ^ savedDir.hashCode ^ fileName.hashCode ^ url.hashCode ^ imgUrl.hashCode ^ galleryUrl.hashCode ^ dowmloadType.hashCode ^ status.hashCode ^ progress.hashCode ^ timeCreated.hashCode ^ resolution.hashCode ^ safUri.hashCode;
}
