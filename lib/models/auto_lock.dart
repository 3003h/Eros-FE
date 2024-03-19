import 'package:flutter/foundation.dart';
import 'package:quiver/core.dart';

import 'index.dart';

@immutable
class AutoLock {

  const AutoLock({
    this.lastLeaveTime,
    this.isLocking,
  });

  final int? lastLeaveTime;
  final bool? isLocking;

  factory AutoLock.fromJson(Map<String,dynamic> json) => AutoLock(
    lastLeaveTime: json['lastLeaveTime'] != null ? json['lastLeaveTime'] as int : null,
    isLocking: json['isLocking'] != null ? json['isLocking'] as bool : null
  );
  
  Map<String, dynamic> toJson() => {
    'lastLeaveTime': lastLeaveTime,
    'isLocking': isLocking
  };

  AutoLock clone() => AutoLock(
    lastLeaveTime: lastLeaveTime,
    isLocking: isLocking
  );


  AutoLock copyWith({
    Optional<int?>? lastLeaveTime,
    Optional<bool?>? isLocking
  }) => AutoLock(
    lastLeaveTime: checkOptional(lastLeaveTime, () => this.lastLeaveTime),
    isLocking: checkOptional(isLocking, () => this.isLocking),
  );

  @override
  bool operator ==(Object other) => identical(this, other)
    || other is AutoLock && lastLeaveTime == other.lastLeaveTime && isLocking == other.isLocking;

  @override
  int get hashCode => lastLeaveTime.hashCode ^ isLocking.hashCode;
}
