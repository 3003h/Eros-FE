import 'package:flutter/foundation.dart';
import 'package:quiver/core.dart';

import 'index.dart';

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
    currentLimit: json['currentLimit'] != null ? int.tryParse('${json['currentLimit']}') ?? 0 : null,
    totLimit: json['totLimit'] != null ? int.tryParse('${json['totLimit']}') ?? 0 : null,
    resetCost: json['resetCost'] != null ? int.tryParse('${json['resetCost']}') ?? 0 : null
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
    Optional<int?>? currentLimit,
    Optional<int?>? totLimit,
    Optional<int?>? resetCost
  }) => EhHome(
    currentLimit: checkOptional(currentLimit, () => this.currentLimit),
    totLimit: checkOptional(totLimit, () => this.totLimit),
    resetCost: checkOptional(resetCost, () => this.resetCost),
  );

  @override
  bool operator ==(Object other) => identical(this, other)
    || other is EhHome && currentLimit == other.currentLimit && totLimit == other.totLimit && resetCost == other.resetCost;

  @override
  int get hashCode => currentLimit.hashCode ^ totLimit.hashCode ^ resetCost.hashCode;
}
