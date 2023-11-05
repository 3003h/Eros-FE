import 'package:flutter/foundation.dart';


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
    blockType: json['block_type'] != null ? json['block_type'] as String : null,
    enabled: json['enabled'] != null ? json['enabled'] as bool : null,
    enableRegex: json['enable_regex'] != null ? json['enable_regex'] as bool : null,
    ruleText: json['rule_text'] != null ? json['rule_text'] as String : null
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
    String? blockType,
    bool? enabled,
    bool? enableRegex,
    String? ruleText
  }) => BlockRule(
    blockType: blockType ?? this.blockType,
    enabled: enabled ?? this.enabled,
    enableRegex: enableRegex ?? this.enableRegex,
    ruleText: ruleText ?? this.ruleText,
  );  

  @override
  bool operator ==(Object other) => identical(this, other) 
    || other is BlockRule && blockType == other.blockType && enabled == other.enabled && enableRegex == other.enableRegex && ruleText == other.ruleText;

  @override
  int get hashCode => blockType.hashCode ^ enabled.hashCode ^ enableRegex.hashCode ^ ruleText.hashCode;
}
