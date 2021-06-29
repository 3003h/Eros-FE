part of 'download.dart';

enum _RequestType {
  addTask,
  pauseTask,
  resumeTask,
  cancelTask,
  initLogger,
}

enum _ResponseType {
  initDtl,
  progress,
  enqueued,
  complete,
  error,
}

class ProgessBean {
  ProgessBean({
    this.totCount,
    this.completCount,
    this.updateImages,
  });

  final int? totCount;
  final int? completCount;
  final List<GalleryImageTask>? updateImages;
}

class _RequestBean {
  _RequestBean({
    this.appSupportPath,
    this.appDocPath,
    this.extStorePath,
    this.isSiteEx,
    this.downloadPath,
    this.initImages,
    this.galleryTask,
    this.imageTasks,
    this.loginfo,
  });

  final String? appSupportPath;
  final String? appDocPath;
  final String? extStorePath;
  final bool? isSiteEx;
  final String? downloadPath;
  final List<GalleryImage>? initImages;
  final GalleryTask? galleryTask;
  final List<GalleryImageTask>? imageTasks;
  final List<String?>? loginfo;
}

class _ResponseBean {
  _ResponseBean({
    this.images,
    this.progess,
    this.galleryTask,
    this.msg,
    this.desc,
  });

  final List<GalleryImage>? images;
  final ProgessBean? progess;
  final GalleryTask? galleryTask;
  final String? msg;
  final String? desc;
}

class _RequestProtocol {
  const _RequestProtocol({this.requestType, this.data});

  const _RequestProtocol.addTask(this.data)
      : requestType = _RequestType.addTask;

  const _RequestProtocol.pauseTask(this.data)
      : requestType = _RequestType.pauseTask;

  const _RequestProtocol.resumeTask(this.data)
      : requestType = _RequestType.resumeTask;

  const _RequestProtocol.cancelTask(this.data)
      : requestType = _RequestType.cancelTask;

  const _RequestProtocol.initLogger(this.data)
      : requestType = _RequestType.initLogger;

  final _RequestType? requestType;

  final dynamic data;
}

class _ResponseProtocol {
  const _ResponseProtocol({this.responseType, this.data});

  const _ResponseProtocol.initDtl(this.data)
      : responseType = _ResponseType.initDtl;

  const _ResponseProtocol.progress(this.data)
      : responseType = _ResponseType.progress;

  const _ResponseProtocol.enqueued(this.data)
      : responseType = _ResponseType.enqueued;

  const _ResponseProtocol.complete(this.data)
      : responseType = _ResponseType.complete;

  const _ResponseProtocol.error(this.data) : responseType = _ResponseType.error;

  final _ResponseType? responseType;

  final dynamic data;
}

class TaskStatus {
  const TaskStatus(int value) : _value = value;
  final int _value;

  int get value => _value;

  static TaskStatus from(int value) => TaskStatus(value);

  static const undefined = TaskStatus(0);
  static const enqueued = TaskStatus(1);
  static const running = TaskStatus(2);
  static const complete = TaskStatus(3);
  static const failed = TaskStatus(4);
  static const canceled = TaskStatus(5);
  static const paused = TaskStatus(6);

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) {
      return true;
    }

    return o is TaskStatus && o._value == _value;
  }

  @override
  int get hashCode => _value.hashCode;

  @override
  String toString() => 'TaskStatus($_value)';
}
