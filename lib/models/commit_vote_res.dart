import 'package:flutter/foundation.dart';
import 'package:quiver/core.dart';

import 'index.dart';

@immutable
class CommitVoteRes {

  const CommitVoteRes({
    this.commentId,
    this.commentScore,
    this.commentVote,
  });

  final int? commentId;
  final int? commentScore;
  final int? commentVote;

  factory CommitVoteRes.fromJson(Map<String,dynamic> json) => CommitVoteRes(
    commentId: json['comment_id'] != null ? json['comment_id'] as int : null,
    commentScore: json['comment_score'] != null ? json['comment_score'] as int : null,
    commentVote: json['comment_vote'] != null ? json['comment_vote'] as int : null
  );
  
  Map<String, dynamic> toJson() => {
    'comment_id': commentId,
    'comment_score': commentScore,
    'comment_vote': commentVote
  };

  CommitVoteRes clone() => CommitVoteRes(
    commentId: commentId,
    commentScore: commentScore,
    commentVote: commentVote
  );


  CommitVoteRes copyWith({
    Optional<int?>? commentId,
    Optional<int?>? commentScore,
    Optional<int?>? commentVote
  }) => CommitVoteRes(
    commentId: checkOptional(commentId, () => this.commentId),
    commentScore: checkOptional(commentScore, () => this.commentScore),
    commentVote: checkOptional(commentVote, () => this.commentVote),
  );

  @override
  bool operator ==(Object other) => identical(this, other)
    || other is CommitVoteRes && commentId == other.commentId && commentScore == other.commentScore && commentVote == other.commentVote;

  @override
  int get hashCode => commentId.hashCode ^ commentScore.hashCode ^ commentVote.hashCode;
}
