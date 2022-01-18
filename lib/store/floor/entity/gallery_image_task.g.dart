// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gallery_image_task.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

/// Proxy class for `CopyWith` functionality. This is a callable class and can be used as follows: `instanceOfGalleryImageTask.copyWith(...)`. Be aware that this kind of usage does not support nullification and all passed `null` values will be ignored. Prefer to copy the instance with a specific field change that handles nullification of fields correctly, e.g. like this:`instanceOfGalleryImageTask.copyWith.fieldName(...)`
class _GalleryImageTaskCWProxy {
  final GalleryImageTask _value;

  const _GalleryImageTaskCWProxy(this._value);

  /// This function does not support nullification of optional types, all `null` values passed to this function will be ignored. For nullification, use `GalleryImageTask(...).copyWithNull(...)` to set certain fields to `null`. Prefer `GalleryImageTask(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GalleryImageTask(...).copyWith(id: 12, name: "My name")
  /// ````
  GalleryImageTask call({
    String? filePath,
    int? gid,
    String? href,
    String? imageUrl,
    int? ser,
    String? sourceId,
    int? status,
    String? token,
  }) {
    return GalleryImageTask(
      filePath: filePath ?? _value.filePath,
      gid: gid ?? _value.gid,
      href: href ?? _value.href,
      imageUrl: imageUrl ?? _value.imageUrl,
      ser: ser ?? _value.ser,
      sourceId: sourceId ?? _value.sourceId,
      status: status ?? _value.status,
      token: token ?? _value.token,
    );
  }

  GalleryImageTask filePath(String? filePath) => filePath == null
      ? _value._copyWithNull(filePath: true)
      : this(filePath: filePath);

  GalleryImageTask href(String? href) =>
      href == null ? _value._copyWithNull(href: true) : this(href: href);

  GalleryImageTask imageUrl(String? imageUrl) => imageUrl == null
      ? _value._copyWithNull(imageUrl: true)
      : this(imageUrl: imageUrl);

  GalleryImageTask sourceId(String? sourceId) => sourceId == null
      ? _value._copyWithNull(sourceId: true)
      : this(sourceId: sourceId);

  GalleryImageTask status(int? status) => status == null
      ? _value._copyWithNull(status: true)
      : this(status: status);

  GalleryImageTask gid(int gid) => this(gid: gid);

  GalleryImageTask ser(int ser) => this(ser: ser);

  GalleryImageTask token(String token) => this(token: token);
}

extension GalleryImageTaskCopyWith on GalleryImageTask {
  /// CopyWith feature provided by `copy_with_extension_gen` library. Returns a callable class and can be used as follows: `instanceOfclass GalleryImageTask.name.copyWith(...)`. Be aware that this kind of usage does not support nullification and all passed `null` values will be ignored. Prefer to copy the instance with a specific field change that handles nullification of fields correctly, e.g. like this:`instanceOfclass GalleryImageTask.name.copyWith.fieldName(...)`
  _GalleryImageTaskCWProxy get copyWith => _GalleryImageTaskCWProxy(this);

  GalleryImageTask _copyWithNull({
    bool filePath = false,
    bool href = false,
    bool imageUrl = false,
    bool sourceId = false,
    bool status = false,
  }) {
    return GalleryImageTask(
      filePath: filePath == true ? null : this.filePath,
      gid: gid,
      href: href == true ? null : this.href,
      imageUrl: imageUrl == true ? null : this.imageUrl,
      ser: ser,
      sourceId: sourceId == true ? null : this.sourceId,
      status: status == true ? null : this.status,
      token: token,
    );
  }
}
