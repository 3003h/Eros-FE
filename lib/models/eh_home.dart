import 'package:flutter/foundation.dart';
import 'package:quiver/core.dart';

import 'index.dart';

@immutable
class EhHome {

  const EhHome({
    this.currentLimit,
    this.totLimit,
    this.resetCost,
    this.highResolutionLimited,
    this.unlockCost,
  });

  final int? currentLimit;
  final int? totLimit;
  final int? resetCost;
  final bool? highResolutionLimited;
  final int? unlockCost;

  factory EhHome.fromJson(Map<String,dynamic> json) => EhHome(
    currentLimit: json['currentLimit'] != null ? int.tryParse('${json['currentLimit']}') ?? 0 : null,
    totLimit: json['totLimit'] != null ? int.tryParse('${json['totLimit']}') ?? 0 : null,
    resetCost: json['resetCost'] != null ? int.tryParse('${json['resetCost']}') ?? 0 : null,
    highResolutionLimited: json['high-resolutionLimited'] != null ? bool.tryParse('${json['high-resolutionLimited']}', caseSensitive: false) ?? false : null,
    unlockCost: json['unlockCost'] != null ? int.tryParse('${json['unlockCost']}') ?? 0 : null
  );
  
  Map<String, dynamic> toJson() => {
    'currentLimit': currentLimit,
    'totLimit': totLimit,
    'resetCost': resetCost,
    'high-resolutionLimited': highResolutionLimited,
    'unlockCost': unlockCost
  };

  EhHome clone() => EhHome(
    currentLimit: currentLimit,
    totLimit: totLimit,
    resetCost: resetCost,
    highResolutionLimited: highResolutionLimited,
    unlockCost: unlockCost
  );


  EhHome copyWith({
    Optional<int?>? currentLimit,
    Optional<int?>? totLimit,
    Optional<int?>? resetCost,
    Optional<bool?>? highResolutionLimited,
    Optional<int?>? unlockCost
  }) => EhHome(
    currentLimit: checkOptional(currentLimit, () => this.currentLimit),
    totLimit: checkOptional(totLimit, () => this.totLimit),
    resetCost: checkOptional(resetCost, () => this.resetCost),
    highResolutionLimited: checkOptional(highResolutionLimited, () => this.highResolutionLimited),
    unlockCost: checkOptional(unlockCost, () => this.unlockCost),
  );

  @override
  bool operator ==(Object other) => identical(this, other)
    || other is EhHome && currentLimit == other.currentLimit && totLimit == other.totLimit && resetCost == other.resetCost && highResolutionLimited == other.highResolutionLimited && unlockCost == other.unlockCost;

  @override
  int get hashCode => currentLimit.hashCode ^ totLimit.hashCode ^ resetCost.hashCode ^ highResolutionLimited.hashCode ^ unlockCost.hashCode;
}
