import 'package:flutter/foundation.dart';
import 'package:quiver/core.dart';

import 'index.dart';

@immutable
class EhLayout {

  const EhLayout({
    this.sideProportion,
  });

  final double? sideProportion;

  factory EhLayout.fromJson(Map<String,dynamic> json) => EhLayout(
    sideProportion: json['sideProportion'] != null ? double.tryParse('${json['sideProportion']}') ?? 0.0 : null
  );
  
  Map<String, dynamic> toJson() => {
    'sideProportion': sideProportion
  };

  EhLayout clone() => EhLayout(
    sideProportion: sideProportion
  );


  EhLayout copyWith({
    Optional<double?>? sideProportion
  }) => EhLayout(
    sideProportion: checkOptional(sideProportion, () => this.sideProportion),
  );

  @override
  bool operator ==(Object other) => identical(this, other)
    || other is EhLayout && sideProportion == other.sideProportion;

  @override
  int get hashCode => sideProportion.hashCode;
}
