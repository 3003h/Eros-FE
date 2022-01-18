// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gallery_task.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

/// Proxy class for `CopyWith` functionality. This is a callable class and can be used as follows: `instanceOfGalleryTask.copyWith(...)`. Be aware that this kind of usage does not support nullification and all passed `null` values will be ignored. Prefer to copy the instance with a specific field change that handles nullification of fields correctly, e.g. like this:`instanceOfGalleryTask.copyWith.fieldName(...)`
class _GalleryTaskCWProxy {
  final GalleryTask _value;

  const _GalleryTaskCWProxy(this._value);

  /// This function does not support nullification of optional types, all `null` values passed to this function will be ignored. For nullification, use `GalleryTask(...).copyWithNull(...)` to set certain fields to `null`. Prefer `GalleryTask(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GalleryTask(...).copyWith(id: 12, name: "My name")
  /// ````
  GalleryTask call({
    int? addTime,
    String? category,
    int? completCount,
    String? coverImage,
    String? coverUrl,
    String? dirPath,
    bool? downloadOrigImage,
    int? fileCount,
    int? gid,
    String? jsonString,
    double? rating,
    int? status,
    String? tag,
    String? title,
    String? token,
    String? uploader,
    String? url,
  }) {
    return GalleryTask(
      addTime: addTime ?? _value.addTime,
      category: category ?? _value.category,
      completCount: completCount ?? _value.completCount,
      coverImage: coverImage ?? _value.coverImage,
      coverUrl: coverUrl ?? _value.coverUrl,
      dirPath: dirPath ?? _value.dirPath,
      downloadOrigImage: downloadOrigImage ?? _value.downloadOrigImage,
      fileCount: fileCount ?? _value.fileCount,
      gid: gid ?? _value.gid,
      jsonString: jsonString ?? _value.jsonString,
      rating: rating ?? _value.rating,
      status: status ?? _value.status,
      tag: tag ?? _value.tag,
      title: title ?? _value.title,
      token: token ?? _value.token,
      uploader: uploader ?? _value.uploader,
      url: url ?? _value.url,
    );
  }

  GalleryTask addTime(int? addTime) => addTime == null
      ? _value._copyWithNull(addTime: true)
      : this(addTime: addTime);

  GalleryTask category(String? category) => category == null
      ? _value._copyWithNull(category: true)
      : this(category: category);

  GalleryTask completCount(int? completCount) => completCount == null
      ? _value._copyWithNull(completCount: true)
      : this(completCount: completCount);

  GalleryTask coverImage(String? coverImage) => coverImage == null
      ? _value._copyWithNull(coverImage: true)
      : this(coverImage: coverImage);

  GalleryTask coverUrl(String? coverUrl) => coverUrl == null
      ? _value._copyWithNull(coverUrl: true)
      : this(coverUrl: coverUrl);

  GalleryTask dirPath(String? dirPath) => dirPath == null
      ? _value._copyWithNull(dirPath: true)
      : this(dirPath: dirPath);

  GalleryTask downloadOrigImage(bool? downloadOrigImage) =>
      downloadOrigImage == null
          ? _value._copyWithNull(downloadOrigImage: true)
          : this(downloadOrigImage: downloadOrigImage);

  GalleryTask jsonString(String? jsonString) => jsonString == null
      ? _value._copyWithNull(jsonString: true)
      : this(jsonString: jsonString);

  GalleryTask rating(double? rating) => rating == null
      ? _value._copyWithNull(rating: true)
      : this(rating: rating);

  GalleryTask status(int? status) => status == null
      ? _value._copyWithNull(status: true)
      : this(status: status);

  GalleryTask tag(String? tag) =>
      tag == null ? _value._copyWithNull(tag: true) : this(tag: tag);

  GalleryTask uploader(String? uploader) => uploader == null
      ? _value._copyWithNull(uploader: true)
      : this(uploader: uploader);

  GalleryTask url(String? url) =>
      url == null ? _value._copyWithNull(url: true) : this(url: url);

  GalleryTask fileCount(int fileCount) => this(fileCount: fileCount);

  GalleryTask gid(int gid) => this(gid: gid);

  GalleryTask title(String title) => this(title: title);

  GalleryTask token(String token) => this(token: token);
}

extension GalleryTaskCopyWith on GalleryTask {
  /// CopyWith feature provided by `copy_with_extension_gen` library. Returns a callable class and can be used as follows: `instanceOfclass GalleryTask.name.copyWith(...)`. Be aware that this kind of usage does not support nullification and all passed `null` values will be ignored. Prefer to copy the instance with a specific field change that handles nullification of fields correctly, e.g. like this:`instanceOfclass GalleryTask.name.copyWith.fieldName(...)`
  _GalleryTaskCWProxy get copyWith => _GalleryTaskCWProxy(this);

  GalleryTask _copyWithNull({
    bool addTime = false,
    bool category = false,
    bool completCount = false,
    bool coverImage = false,
    bool coverUrl = false,
    bool dirPath = false,
    bool downloadOrigImage = false,
    bool jsonString = false,
    bool rating = false,
    bool status = false,
    bool tag = false,
    bool uploader = false,
    bool url = false,
  }) {
    return GalleryTask(
      addTime: addTime == true ? null : this.addTime,
      category: category == true ? null : this.category,
      completCount: completCount == true ? null : this.completCount,
      coverImage: coverImage == true ? null : this.coverImage,
      coverUrl: coverUrl == true ? null : this.coverUrl,
      dirPath: dirPath == true ? null : this.dirPath,
      downloadOrigImage:
          downloadOrigImage == true ? null : this.downloadOrigImage,
      fileCount: fileCount,
      gid: gid,
      jsonString: jsonString == true ? null : this.jsonString,
      rating: rating == true ? null : this.rating,
      status: status == true ? null : this.status,
      tag: tag == true ? null : this.tag,
      title: title,
      token: token,
      uploader: uploader == true ? null : this.uploader,
      url: url == true ? null : this.url,
    );
  }
}
