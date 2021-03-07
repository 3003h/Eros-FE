import 'package:flutter/foundation.dart';


@immutable
class AutoLock {
  
  const AutoLock({
    this.lastLeaveTime,
    this.isLocking,
  });

  final int? lastLeaveTime;
  final bool? isLocking;

  factory AutoLock.fromJson(Map<String,dynamic> json) => AutoLock(
    lastLeaveTime: json['last_leave_time'] != null ? json['last_leave_time'] as int : null,
    isLocking: json['is_locking'] != null ? json['is_locking'] as bool : null
  );
  
  Map<String, dynamic> toJson() => {
    'last_leave_time': lastLeaveTime,
    'is_locking': isLocking
  };

  AutoLock clone() => AutoLock(
    lastLeaveTime: lastLeaveTime,
    isLocking: isLocking
  );

    
  AutoLock copyWith({
    int? lastLeaveTime,
    bool? isLocking
  }) => AutoLock(
    lastLeaveTime: lastLeaveTime ?? this.lastLeaveTime,
    isLocking: isLocking ?? this.isLocking,
  );  

  @override
  bool operator ==(Object other) => identical(this, other) 
    || other is AutoLock && lastLeaveTime == other.lastLeaveTime && isLocking == other.isLocking;

  @override
  int get hashCode => lastLeaveTime.hashCode ^ isLocking.hashCode;
}
