import 'package:flutter/foundation.dart';
import 'package:quiver/core.dart';

import 'index.dart';

@immutable
class OpenlTranslation {

  const OpenlTranslation({
    this.status,
    this.text,
    this.result,
    this.sourceLang,
    this.targetLang,
  });

  final bool? status;
  final String? text;
  final String? result;
  final String? sourceLang;
  final String? targetLang;

  factory OpenlTranslation.fromJson(Map<String,dynamic> json) => OpenlTranslation(
    status: json['status'] != null ? bool.tryParse('${json['status']}', caseSensitive: false) ?? false : null,
    text: json['text']?.toString(),
    result: json['result']?.toString(),
    sourceLang: json['source_lang']?.toString(),
    targetLang: json['target_lang']?.toString()
  );
  
  Map<String, dynamic> toJson() => {
    'status': status,
    'text': text,
    'result': result,
    'source_lang': sourceLang,
    'target_lang': targetLang
  };

  OpenlTranslation clone() => OpenlTranslation(
    status: status,
    text: text,
    result: result,
    sourceLang: sourceLang,
    targetLang: targetLang
  );


  OpenlTranslation copyWith({
    Optional<bool?>? status,
    Optional<String?>? text,
    Optional<String?>? result,
    Optional<String?>? sourceLang,
    Optional<String?>? targetLang
  }) => OpenlTranslation(
    status: checkOptional(status, () => this.status),
    text: checkOptional(text, () => this.text),
    result: checkOptional(result, () => this.result),
    sourceLang: checkOptional(sourceLang, () => this.sourceLang),
    targetLang: checkOptional(targetLang, () => this.targetLang),
  );

  @override
  bool operator ==(Object other) => identical(this, other)
    || other is OpenlTranslation && status == other.status && text == other.text && result == other.result && sourceLang == other.sourceLang && targetLang == other.targetLang;

  @override
  int get hashCode => status.hashCode ^ text.hashCode ^ result.hashCode ^ sourceLang.hashCode ^ targetLang.hashCode;
}
