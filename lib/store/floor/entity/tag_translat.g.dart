// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag_translat.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$TagTranslatCWProxy {
  TagTranslat intro(String? intro);

  TagTranslat key(String key);

  TagTranslat links(String? links);

  TagTranslat name(String? name);

  TagTranslat namespace(String namespace);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TagTranslat(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TagTranslat(...).copyWith(id: 12, name: "My name")
  /// ````
  TagTranslat call({
    String? intro,
    String? key,
    String? links,
    String? name,
    String? namespace,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfTagTranslat.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfTagTranslat.copyWith.fieldName(...)`
class _$TagTranslatCWProxyImpl implements _$TagTranslatCWProxy {
  final TagTranslat _value;

  const _$TagTranslatCWProxyImpl(this._value);

  @override
  TagTranslat intro(String? intro) => this(intro: intro);

  @override
  TagTranslat key(String key) => this(key: key);

  @override
  TagTranslat links(String? links) => this(links: links);

  @override
  TagTranslat name(String? name) => this(name: name);

  @override
  TagTranslat namespace(String namespace) => this(namespace: namespace);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TagTranslat(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TagTranslat(...).copyWith(id: 12, name: "My name")
  /// ````
  TagTranslat call({
    Object? intro = const $CopyWithPlaceholder(),
    Object? key = const $CopyWithPlaceholder(),
    Object? links = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? namespace = const $CopyWithPlaceholder(),
  }) {
    return TagTranslat(
      intro: intro == const $CopyWithPlaceholder()
          ? _value.intro
          // ignore: cast_nullable_to_non_nullable
          : intro as String?,
      key: key == const $CopyWithPlaceholder() || key == null
          ? _value.key
          // ignore: cast_nullable_to_non_nullable
          : key as String,
      links: links == const $CopyWithPlaceholder()
          ? _value.links
          // ignore: cast_nullable_to_non_nullable
          : links as String?,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String?,
      namespace: namespace == const $CopyWithPlaceholder() || namespace == null
          ? _value.namespace
          // ignore: cast_nullable_to_non_nullable
          : namespace as String,
    );
  }
}

extension $TagTranslatCopyWith on TagTranslat {
  /// Returns a callable class that can be used as follows: `instanceOfTagTranslat.copyWith(...)` or like so:`instanceOfTagTranslat.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$TagTranslatCWProxy get copyWith => _$TagTranslatCWProxyImpl(this);
}
