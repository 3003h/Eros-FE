import 'package:flutter/foundation.dart';

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

  factory OpenlTranslation.fromJson(Map<String, dynamic> json) =>
      OpenlTranslation(
          status: json['status'] != null ? json['status'] as bool : null,
          text: json['text'] != null ? json['text'] as String : null,
          result: json['result'] != null ? json['result'] as String : null,
          sourceLang: json['source_lang'] != null
              ? json['source_lang'] as String
              : null,
          targetLang: json['target_lang'] != null
              ? json['target_lang'] as String
              : null);

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
      targetLang: targetLang);

  OpenlTranslation copyWith(
          {bool? status,
          String? text,
          String? result,
          String? sourceLang,
          String? targetLang}) =>
      OpenlTranslation(
        status: status ?? this.status,
        text: text ?? this.text,
        result: result ?? this.result,
        sourceLang: sourceLang ?? this.sourceLang,
        targetLang: targetLang ?? this.targetLang,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OpenlTranslation &&
          status == other.status &&
          text == other.text &&
          result == other.result &&
          sourceLang == other.sourceLang &&
          targetLang == other.targetLang;

  @override
  int get hashCode =>
      status.hashCode ^
      text.hashCode ^
      result.hashCode ^
      sourceLang.hashCode ^
      targetLang.hashCode;
}
