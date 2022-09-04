// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'view_history.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ViewHistoryCWProxy {
  ViewHistory galleryProviderText(String galleryProviderText);

  ViewHistory gid(int gid);

  ViewHistory lastViewTime(int lastViewTime);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ViewHistory(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ViewHistory(...).copyWith(id: 12, name: "My name")
  /// ````
  ViewHistory call({
    String? galleryProviderText,
    int? gid,
    int? lastViewTime,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfViewHistory.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfViewHistory.copyWith.fieldName(...)`
class _$ViewHistoryCWProxyImpl implements _$ViewHistoryCWProxy {
  final ViewHistory _value;

  const _$ViewHistoryCWProxyImpl(this._value);

  @override
  ViewHistory galleryProviderText(String galleryProviderText) =>
      this(galleryProviderText: galleryProviderText);

  @override
  ViewHistory gid(int gid) => this(gid: gid);

  @override
  ViewHistory lastViewTime(int lastViewTime) =>
      this(lastViewTime: lastViewTime);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ViewHistory(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ViewHistory(...).copyWith(id: 12, name: "My name")
  /// ````
  ViewHistory call({
    Object? galleryProviderText = const $CopyWithPlaceholder(),
    Object? gid = const $CopyWithPlaceholder(),
    Object? lastViewTime = const $CopyWithPlaceholder(),
  }) {
    return ViewHistory(
      galleryProviderText:
          galleryProviderText == const $CopyWithPlaceholder() ||
                  galleryProviderText == null
              ? _value.galleryProviderText
              // ignore: cast_nullable_to_non_nullable
              : galleryProviderText as String,
      gid: gid == const $CopyWithPlaceholder() || gid == null
          ? _value.gid
          // ignore: cast_nullable_to_non_nullable
          : gid as int,
      lastViewTime:
          lastViewTime == const $CopyWithPlaceholder() || lastViewTime == null
              ? _value.lastViewTime
              // ignore: cast_nullable_to_non_nullable
              : lastViewTime as int,
    );
  }
}

extension $ViewHistoryCopyWith on ViewHistory {
  /// Returns a callable class that can be used as follows: `instanceOfViewHistory.copyWith(...)` or like so:`instanceOfViewHistory.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ViewHistoryCWProxy get copyWith => _$ViewHistoryCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ViewHistory _$ViewHistoryFromJson(Map<String, dynamic> json) => ViewHistory(
      gid: json['gid'] as int,
      lastViewTime: json['lastViewTime'] as int,
      galleryProviderText: json['galleryProviderText'] as String,
    );

Map<String, dynamic> _$ViewHistoryToJson(ViewHistory instance) =>
    <String, dynamic>{
      'gid': instance.gid,
      'lastViewTime': instance.lastViewTime,
      'galleryProviderText': instance.galleryProviderText,
    };
