import 'package:flutter/foundation.dart';


@immutable
class EhHome {
  
  const EhHome({
    this.currentLimit,
    this.totLimit,
    this.resetCost,
  });

  final int? currentLimit;
  final int? totLimit;
  final int? resetCost;

  factory EhHome.fromJson(Map<String,dynamic> json) => EhHome(
    currentLimit: json['currentLimit'] != null ? json['currentLimit'] as int : null,
    totLimit: json['totLimit'] != null ? json['totLimit'] as int : null,
    resetCost: json['resetCost'] != null ? json['resetCost'] as int : null
  );
  
  Map<String, dynamic> toJson() => {
    'currentLimit': currentLimit,
    'totLimit': totLimit,
    'resetCost': resetCost
  };

  EhHome clone() => EhHome(
    currentLimit: currentLimit,
    totLimit: totLimit,
    resetCost: resetCost
  );

    
  EhHome copyWith({
    int? currentLimit,
    int? totLimit,
    int? resetCost
  }) => EhHome(
    currentLimit: currentLimit ?? this.currentLimit,
    totLimit: totLimit ?? this.totLimit,
    resetCost: resetCost ?? this.resetCost,
  );  

  @override
  bool operator ==(Object other) => identical(this, other) 
    || other is EhHome && currentLimit == other.currentLimit && totLimit == other.totLimit && resetCost == other.resetCost;

  @override
  int get hashCode => currentLimit.hashCode ^ totLimit.hashCode ^ resetCost.hashCode;
}
