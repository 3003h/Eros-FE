import 'package:flutter/foundation.dart';
import 'package:quiver/core.dart';

import 'index.dart';

@immutable
class BlockRule {

  const BlockRule({
    this.blockType,
    this.enabled,
    this.enableRegex,
    this.ruleText,
  });

  final String? blockType;
  final bool? enabled;
  final bool? enableRegex;
  final String? ruleText;

  factory BlockRule.fromJson(Map<String,dynamic> json) => BlockRule(
    blockType: json['block_type']?.toString(),
    enabled: json['enabled'] != null ? bool.tryParse('${json['enabled']}', caseSensitive: false) ?? false : null,
    enableRegex: json['enable_regex'] != null ? bool.tryParse('${json['enable_regex']}', caseSensitive: false) ?? false : null,
    ruleText: json['rule_text']?.toString()
  );
  
  Map<String, dynamic> toJson() => {
    'block_type': blockType,
    'enabled': enabled,
    'enable_regex': enableRegex,
    'rule_text': ruleText
  };

  BlockRule clone() => BlockRule(
    blockType: blockType,
    enabled: enabled,
    enableRegex: enableRegex,
    ruleText: ruleText
  );


  BlockRule copyWith({
    Optional<String?>? blockType,
    Optional<bool?>? enabled,
    Optional<bool?>? enableRegex,
    Optional<String?>? ruleText
  }) => BlockRule(
    blockType: checkOptional(blockType, () => this.blockType),
    enabled: checkOptional(enabled, () => this.enabled),
    enableRegex: checkOptional(enableRegex, () => this.enableRegex),
    ruleText: checkOptional(ruleText, () => this.ruleText),
  );

  @override
  bool operator ==(Object other) => identical(this, other)
    || other is BlockRule && blockType == other.blockType && enabled == other.enabled && enableRegex == other.enableRegex && ruleText == other.ruleText;

  @override
  int get hashCode => blockType.hashCode ^ enabled.hashCode ^ enableRegex.hashCode ^ ruleText.hashCode;
}
