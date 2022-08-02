import 'package:flutter/foundation.dart';
import 'gallery_comment_span.dart';

@immutable
class GalleryComment {
  
  const GalleryComment({
    required this.name,
    required this.time,
    required this.span,
    required this.score,
    this.vote,
    this.id,
    this.menberId,
    this.canEdit,
    this.canVote,
    this.showTranslate,
    this.scoreDetails,
  });

  final String name;
  final String time;
  final List<GalleryCommentSpan> span;
  final String score;
  final int? vote;
  final String? id;
  final String? menberId;
  final bool? canEdit;
  final bool? canVote;
  final bool? showTranslate;
  final List<String>? scoreDetails;

  factory GalleryComment.fromJson(Map<String,dynamic> json) => GalleryComment(
    name: json['name'] as String,
    time: json['time'] as String,
    span: (json['span'] as List? ?? []).map((e) => GalleryCommentSpan.fromJson(e as Map<String, dynamic>)).toList(),
    score: json['score'] as String,
    vote: json['vote'] != null ? json['vote'] as int : null,
    id: json['id'] != null ? json['id'] as String : null,
    menberId: json['menberId'] != null ? json['menberId'] as String : null,
    canEdit: json['canEdit'] != null ? json['canEdit'] as bool : null,
    canVote: json['canVote'] != null ? json['canVote'] as bool : null,
    showTranslate: json['showTranslate'] != null ? json['showTranslate'] as bool : null,
    scoreDetails: json['scoreDetails'] != null ? (json['scoreDetails'] as List? ?? []).map((e) => e as String).toList() : null
  );
  
  Map<String, dynamic> toJson() => {
    'name': name,
    'time': time,
    'span': span.map((e) => e.toJson()).toList(),
    'score': score,
    'vote': vote,
    'id': id,
    'menberId': menberId,
    'canEdit': canEdit,
    'canVote': canVote,
    'showTranslate': showTranslate,
    'scoreDetails': scoreDetails?.map((e) => e.toString()).toList()
  };

  GalleryComment clone() => GalleryComment(
    name: name,
    time: time,
    span: span.map((e) => e.clone()).toList(),
    score: score,
    vote: vote,
    id: id,
    menberId: menberId,
    canEdit: canEdit,
    canVote: canVote,
    showTranslate: showTranslate,
    scoreDetails: scoreDetails?.toList()
  );

    
  GalleryComment copyWith({
    String? name,
    String? time,
    List<GalleryCommentSpan>? span,
    String? score,
    int? vote,
    String? id,
    String? menberId,
    bool? canEdit,
    bool? canVote,
    bool? showTranslate,
    List<String>? scoreDetails
  }) => GalleryComment(
    name: name ?? this.name,
    time: time ?? this.time,
    span: span ?? this.span,
    score: score ?? this.score,
    vote: vote ?? this.vote,
    id: id ?? this.id,
    menberId: menberId ?? this.menberId,
    canEdit: canEdit ?? this.canEdit,
    canVote: canVote ?? this.canVote,
    showTranslate: showTranslate ?? this.showTranslate,
    scoreDetails: scoreDetails ?? this.scoreDetails,
  );  

  @override
  bool operator ==(Object other) => identical(this, other) 
    || other is GalleryComment && name == other.name && time == other.time && span == other.span && score == other.score && vote == other.vote && id == other.id && menberId == other.menberId && canEdit == other.canEdit && canVote == other.canVote && showTranslate == other.showTranslate && scoreDetails == other.scoreDetails;

  @override
  int get hashCode => name.hashCode ^ time.hashCode ^ span.hashCode ^ score.hashCode ^ vote.hashCode ^ id.hashCode ^ menberId.hashCode ^ canEdit.hashCode ^ canVote.hashCode ^ showTranslate.hashCode ^ scoreDetails.hashCode;
}
