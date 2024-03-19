import 'package:flutter/foundation.dart';
import 'package:quiver/core.dart';

import 'index.dart';

@immutable
class BlockConfig {

  const BlockConfig({
    this.filterCommentsByScore,
    this.scoreFilteringThreshold,
    this.ruleForTitle,
    this.ruleForUploader,
    this.ruleForCommentator,
    this.ruleForComment,
  });

  final bool? filterCommentsByScore;
  final int? scoreFilteringThreshold;
  final List<BlockRule>? ruleForTitle;
  final List<BlockRule>? ruleForUploader;
  final List<BlockRule>? ruleForCommentator;
  final List<BlockRule>? ruleForComment;

  factory BlockConfig.fromJson(Map<String,dynamic> json) => BlockConfig(
    filterCommentsByScore: json['filter_comments_by_score'] != null ? bool.tryParse('${json['filter_comments_by_score']}', caseSensitive: false) ?? false : null,
    scoreFilteringThreshold: json['score_filtering_threshold'] != null ? int.tryParse('${json['score_filtering_threshold']}') ?? 0 : null,
    ruleForTitle: json['rule_for_title'] != null ? (json['rule_for_title'] as List? ?? []).map((e) => BlockRule.fromJson(e as Map<String, dynamic>)).toList() : null,
    ruleForUploader: json['rule_for_uploader'] != null ? (json['rule_for_uploader'] as List? ?? []).map((e) => BlockRule.fromJson(e as Map<String, dynamic>)).toList() : null,
    ruleForCommentator: json['rule_for_commentator'] != null ? (json['rule_for_commentator'] as List? ?? []).map((e) => BlockRule.fromJson(e as Map<String, dynamic>)).toList() : null,
    ruleForComment: json['rule_for_comment'] != null ? (json['rule_for_comment'] as List? ?? []).map((e) => BlockRule.fromJson(e as Map<String, dynamic>)).toList() : null
  );
  
  Map<String, dynamic> toJson() => {
    'filter_comments_by_score': filterCommentsByScore,
    'score_filtering_threshold': scoreFilteringThreshold,
    'rule_for_title': ruleForTitle?.map((e) => e.toJson()).toList(),
    'rule_for_uploader': ruleForUploader?.map((e) => e.toJson()).toList(),
    'rule_for_commentator': ruleForCommentator?.map((e) => e.toJson()).toList(),
    'rule_for_comment': ruleForComment?.map((e) => e.toJson()).toList()
  };

  BlockConfig clone() => BlockConfig(
    filterCommentsByScore: filterCommentsByScore,
    scoreFilteringThreshold: scoreFilteringThreshold,
    ruleForTitle: ruleForTitle?.map((e) => e.clone()).toList(),
    ruleForUploader: ruleForUploader?.map((e) => e.clone()).toList(),
    ruleForCommentator: ruleForCommentator?.map((e) => e.clone()).toList(),
    ruleForComment: ruleForComment?.map((e) => e.clone()).toList()
  );


  BlockConfig copyWith({
    Optional<bool?>? filterCommentsByScore,
    Optional<int?>? scoreFilteringThreshold,
    Optional<List<BlockRule>?>? ruleForTitle,
    Optional<List<BlockRule>?>? ruleForUploader,
    Optional<List<BlockRule>?>? ruleForCommentator,
    Optional<List<BlockRule>?>? ruleForComment
  }) => BlockConfig(
    filterCommentsByScore: checkOptional(filterCommentsByScore, () => this.filterCommentsByScore),
    scoreFilteringThreshold: checkOptional(scoreFilteringThreshold, () => this.scoreFilteringThreshold),
    ruleForTitle: checkOptional(ruleForTitle, () => this.ruleForTitle),
    ruleForUploader: checkOptional(ruleForUploader, () => this.ruleForUploader),
    ruleForCommentator: checkOptional(ruleForCommentator, () => this.ruleForCommentator),
    ruleForComment: checkOptional(ruleForComment, () => this.ruleForComment),
  );

  @override
  bool operator ==(Object other) => identical(this, other)
    || other is BlockConfig && filterCommentsByScore == other.filterCommentsByScore && scoreFilteringThreshold == other.scoreFilteringThreshold && ruleForTitle == other.ruleForTitle && ruleForUploader == other.ruleForUploader && ruleForCommentator == other.ruleForCommentator && ruleForComment == other.ruleForComment;

  @override
  int get hashCode => filterCommentsByScore.hashCode ^ scoreFilteringThreshold.hashCode ^ ruleForTitle.hashCode ^ ruleForUploader.hashCode ^ ruleForCommentator.hashCode ^ ruleForComment.hashCode;
}
