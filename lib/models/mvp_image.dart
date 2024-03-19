import 'package:flutter/foundation.dart';
import 'package:quiver/core.dart';

import 'index.dart';

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
    n: json['n']?.toString(),
    k: json['k']?.toString(),
    t: json['t']?.toString()
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
    Optional<String?>? n,
    Optional<String?>? k,
    Optional<String?>? t
  }) => MvpImage(
    n: checkOptional(n, () => this.n),
    k: checkOptional(k, () => this.k),
    t: checkOptional(t, () => this.t),
  );

  @override
  bool operator ==(Object other) => identical(this, other)
    || other is MvpImage && n == other.n && k == other.k && t == other.t;

  @override
  int get hashCode => n.hashCode ^ k.hashCode ^ t.hashCode;
}
