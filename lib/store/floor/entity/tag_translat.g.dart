// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag_translat.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

/// Proxy class for `CopyWith` functionality. This is a callable class and can be used as follows: `instanceOfTagTranslat.copyWith(...)`. Be aware that this kind of usage does not support nullification and all passed `null` values will be ignored. Prefer to copy the instance with a specific field change that handles nullification of fields correctly, e.g. like this:`instanceOfTagTranslat.copyWith.fieldName(...)`
class _TagTranslatCWProxy {
  final TagTranslat _value;

  const _TagTranslatCWProxy(this._value);

  /// This function does not support nullification of optional types, all `null` values passed to this function will be ignored. For nullification, use `TagTranslat(...).copyWithNull(...)` to set certain fields to `null`. Prefer `TagTranslat(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
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
  }) {
    return TagTranslat(
      intro: intro ?? _value.intro,
      key: key ?? _value.key,
      links: links ?? _value.links,
      name: name ?? _value.name,
      namespace: namespace ?? _value.namespace,
    );
  }

  TagTranslat intro(String? intro) =>
      intro == null ? _value._copyWithNull(intro: true) : this(intro: intro);

  TagTranslat links(String? links) =>
      links == null ? _value._copyWithNull(links: true) : this(links: links);

  TagTranslat name(String? name) =>
      name == null ? _value._copyWithNull(name: true) : this(name: name);

  TagTranslat key(String key) => this(key: key);

  TagTranslat namespace(String namespace) => this(namespace: namespace);
}

extension TagTranslatCopyWith on TagTranslat {
  /// CopyWith feature provided by `copy_with_extension_gen` library. Returns a callable class and can be used as follows: `instanceOfclass TagTranslat.name.copyWith(...)`. Be aware that this kind of usage does not support nullification and all passed `null` values will be ignored. Prefer to copy the instance with a specific field change that handles nullification of fields correctly, e.g. like this:`instanceOfclass TagTranslat.name.copyWith.fieldName(...)`
  _TagTranslatCWProxy get copyWith => _TagTranslatCWProxy(this);

  TagTranslat _copyWithNull({
    bool intro = false,
    bool links = false,
    bool name = false,
  }) {
    return TagTranslat(
      intro: intro == true ? null : this.intro,
      key: key,
      links: links == true ? null : this.links,
      name: name == true ? null : this.name,
      namespace: namespace,
    );
  }
}
