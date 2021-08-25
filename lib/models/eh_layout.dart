import 'package:flutter/foundation.dart';


@immutable
class EhLayout {
  
  const EhLayout({
    this.sideProportion,
  });

  final double? sideProportion;

  factory EhLayout.fromJson(Map<String,dynamic> json) => EhLayout(
    sideProportion: json['sideProportion'] != null ? json['sideProportion'] as double : null
  );
  
  Map<String, dynamic> toJson() => {
    'sideProportion': sideProportion
  };

  EhLayout clone() => EhLayout(
    sideProportion: sideProportion
  );

    
  EhLayout copyWith({
    double? sideProportion
  }) => EhLayout(
    sideProportion: sideProportion ?? this.sideProportion,
  );  

  @override
  bool operator ==(Object other) => identical(this, other) 
    || other is EhLayout && sideProportion == other.sideProportion;

  @override
  int get hashCode => sideProportion.hashCode;
}
