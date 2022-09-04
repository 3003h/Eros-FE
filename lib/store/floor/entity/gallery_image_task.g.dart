// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gallery_image_task.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$GalleryImageTaskCWProxy {
  GalleryImageTask filePath(String? filePath);

  GalleryImageTask gid(int gid);

  GalleryImageTask href(String? href);

  GalleryImageTask imageUrl(String? imageUrl);

  GalleryImageTask ser(int ser);

  GalleryImageTask sourceId(String? sourceId);

  GalleryImageTask status(int? status);

  GalleryImageTask token(String token);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GalleryImageTask(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
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
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfGalleryImageTask.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfGalleryImageTask.copyWith.fieldName(...)`
class _$GalleryImageTaskCWProxyImpl implements _$GalleryImageTaskCWProxy {
  final GalleryImageTask _value;

  const _$GalleryImageTaskCWProxyImpl(this._value);

  @override
  GalleryImageTask filePath(String? filePath) => this(filePath: filePath);

  @override
  GalleryImageTask gid(int gid) => this(gid: gid);

  @override
  GalleryImageTask href(String? href) => this(href: href);

  @override
  GalleryImageTask imageUrl(String? imageUrl) => this(imageUrl: imageUrl);

  @override
  GalleryImageTask ser(int ser) => this(ser: ser);

  @override
  GalleryImageTask sourceId(String? sourceId) => this(sourceId: sourceId);

  @override
  GalleryImageTask status(int? status) => this(status: status);

  @override
  GalleryImageTask token(String token) => this(token: token);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GalleryImageTask(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GalleryImageTask(...).copyWith(id: 12, name: "My name")
  /// ````
  GalleryImageTask call({
    Object? filePath = const $CopyWithPlaceholder(),
    Object? gid = const $CopyWithPlaceholder(),
    Object? href = const $CopyWithPlaceholder(),
    Object? imageUrl = const $CopyWithPlaceholder(),
    Object? ser = const $CopyWithPlaceholder(),
    Object? sourceId = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? token = const $CopyWithPlaceholder(),
  }) {
    return GalleryImageTask(
      filePath: filePath == const $CopyWithPlaceholder()
          ? _value.filePath
          // ignore: cast_nullable_to_non_nullable
          : filePath as String?,
      gid: gid == const $CopyWithPlaceholder() || gid == null
          ? _value.gid
          // ignore: cast_nullable_to_non_nullable
          : gid as int,
      href: href == const $CopyWithPlaceholder()
          ? _value.href
          // ignore: cast_nullable_to_non_nullable
          : href as String?,
      imageUrl: imageUrl == const $CopyWithPlaceholder()
          ? _value.imageUrl
          // ignore: cast_nullable_to_non_nullable
          : imageUrl as String?,
      ser: ser == const $CopyWithPlaceholder() || ser == null
          ? _value.ser
          // ignore: cast_nullable_to_non_nullable
          : ser as int,
      sourceId: sourceId == const $CopyWithPlaceholder()
          ? _value.sourceId
          // ignore: cast_nullable_to_non_nullable
          : sourceId as String?,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as int?,
      token: token == const $CopyWithPlaceholder() || token == null
          ? _value.token
          // ignore: cast_nullable_to_non_nullable
          : token as String,
    );
  }
}

extension $GalleryImageTaskCopyWith on GalleryImageTask {
  /// Returns a callable class that can be used as follows: `instanceOfGalleryImageTask.copyWith(...)` or like so:`instanceOfGalleryImageTask.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$GalleryImageTaskCWProxy get copyWith => _$GalleryImageTaskCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GalleryImageTask _$GalleryImageTaskFromJson(Map<String, dynamic> json) =>
    GalleryImageTask(
      gid: json['gid'] as int,
      token: json['token'] as String,
      href: json['href'] as String?,
      sourceId: json['sourceId'] as String?,
      imageUrl: json['imageUrl'] as String?,
      ser: json['ser'] as int,
      filePath: json['filePath'] as String?,
      status: json['status'] as int?,
    );

Map<String, dynamic> _$GalleryImageTaskToJson(GalleryImageTask instance) =>
    <String, dynamic>{
      'gid': instance.gid,
      'ser': instance.ser,
      'token': instance.token,
      'href': instance.href,
      'sourceId': instance.sourceId,
      'imageUrl': instance.imageUrl,
      'filePath': instance.filePath,
      'status': instance.status,
    };
