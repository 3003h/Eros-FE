import 'package:flutter/foundation.dart';

@immutable
class EhProfile {
  const EhProfile({
    required this.name,
    required this.value,
    required this.selected,
  });

  final String name;
  final int value;
  final bool selected;

  factory EhProfile.fromJson(Map<String, dynamic> json) => EhProfile(
      name: json['name'].toString(),
      value: int.tryParse('${json['value']}') ?? 0,
      selected:
          bool.tryParse('${json['selected']}', caseSensitive: false) ?? false);

  Map<String, dynamic> toJson() =>
      {'name': name, 'value': value, 'selected': selected};

  EhProfile clone() => EhProfile(name: name, value: value, selected: selected);

  EhProfile copyWith({String? name, int? value, bool? selected}) => EhProfile(
        name: name ?? this.name,
        value: value ?? this.value,
        selected: selected ?? this.selected,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EhProfile &&
          name == other.name &&
          value == other.value &&
          selected == other.selected;

  @override
  int get hashCode => name.hashCode ^ value.hashCode ^ selected.hashCode;
}
