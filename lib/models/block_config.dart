import 'package:flutter/foundation.dart';


@immutable
class BlockConfig {
  
  const BlockConfig({
    this.filterCommentsByScore,
    this.filteringThreshold,
  });

  final bool? filterCommentsByScore;
  final int? filteringThreshold;

  factory BlockConfig.fromJson(Map<String,dynamic> json) => BlockConfig(
    filterCommentsByScore: json['filter_comments_by_score'] != null ? json['filter_comments_by_score'] as bool : null,
    filteringThreshold: json['filtering_threshold'] != null ? json['filtering_threshold'] as int : null
  );
  
  Map<String, dynamic> toJson() => {
    'filter_comments_by_score': filterCommentsByScore,
    'filtering_threshold': filteringThreshold
  };

  BlockConfig clone() => BlockConfig(
    filterCommentsByScore: filterCommentsByScore,
    filteringThreshold: filteringThreshold
  );

    
  BlockConfig copyWith({
    bool? filterCommentsByScore,
    int? filteringThreshold
  }) => BlockConfig(
    filterCommentsByScore: filterCommentsByScore ?? this.filterCommentsByScore,
    filteringThreshold: filteringThreshold ?? this.filteringThreshold,
  );  

  @override
  bool operator ==(Object other) => identical(this, other) 
    || other is BlockConfig && filterCommentsByScore == other.filterCommentsByScore && filteringThreshold == other.filteringThreshold;

  @override
  int get hashCode => filterCommentsByScore.hashCode ^ filteringThreshold.hashCode;
}
