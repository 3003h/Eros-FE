import 'package:flutter/foundation.dart';


@immutable
class EhHome {
  
  const EhHome({
    required this.currentLimit,
    required this.totLimit,
    required this.resetCost,
  });

  final int currentLimit;
  final int totLimit;
  final int resetCost;

  factory EhHome.fromJson(Map<String,dynamic> json) => EhHome(
    currentLimit: json['currentLimit'] as int,
    totLimit: json['totLimit'] as int,
    resetCost: json['resetCost'] as int
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
