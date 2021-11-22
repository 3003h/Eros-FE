import 'package:flutter/foundation.dart';


@immutable
class MvpImage {
  
  const MvpImage({
    this.n,
    this.k,
    this.t,
  });

  final String? n;
  final String? k;
  final String? t;

  factory MvpImage.fromJson(Map<String,dynamic> json) => MvpImage(
    n: json['n'] != null ? json['n'] as String : null,
    k: json['k'] != null ? json['k'] as String : null,
    t: json['t'] != null ? json['t'] as String : null
  );
  
  Map<String, dynamic> toJson() => {
    'n': n,
    'k': k,
    't': t
  };

  MvpImage clone() => MvpImage(
    n: n,
    k: k,
    t: t
  );

    
  MvpImage copyWith({
    String? n,
    String? k,
    String? t
  }) => MvpImage(
    n: n ?? this.n,
    k: k ?? this.k,
    t: t ?? this.t,
  );  

  @override
  bool operator ==(Object other) => identical(this, other) 
    || other is MvpImage && n == other.n && k == other.k && t == other.t;

  @override
  int get hashCode => n.hashCode ^ k.hashCode ^ t.hashCode;
}
