import 'package:flutter/foundation.dart';


@immutable
class BlockConfig {
  
  const BlockConfig({
    this.filterCommentsByScore,
    this.scoreFilteringThreshold,
  });

  final bool? filterCommentsByScore;
  final int? scoreFilteringThreshold;

  factory BlockConfig.fromJson(Map<String,dynamic> json) => BlockConfig(
    filterCommentsByScore: json['filter_comments_by_score'] != null ? json['filter_comments_by_score'] as bool : null,
    scoreFilteringThreshold: json['score_filtering_threshold'] != null ? json['score_filtering_threshold'] as int : null
  );
  
  Map<String, dynamic> toJson() => {
    'filter_comments_by_score': filterCommentsByScore,
    'score_filtering_threshold': scoreFilteringThreshold
  };

  BlockConfig clone() => BlockConfig(
    filterCommentsByScore: filterCommentsByScore,
    scoreFilteringThreshold: scoreFilteringThreshold
  );

    
  BlockConfig copyWith({
    bool? filterCommentsByScore,
    int? scoreFilteringThreshold
  }) => BlockConfig(
    filterCommentsByScore: filterCommentsByScore ?? this.filterCommentsByScore,
    scoreFilteringThreshold: scoreFilteringThreshold ?? this.scoreFilteringThreshold,
  );  

  @override
  bool operator ==(Object other) => identical(this, other) 
    || other is BlockConfig && filterCommentsByScore == other.filterCommentsByScore && scoreFilteringThreshold == other.scoreFilteringThreshold;

  @override
  int get hashCode => filterCommentsByScore.hashCode ^ scoreFilteringThreshold.hashCode;
}
