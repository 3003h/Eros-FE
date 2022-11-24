import 'package:flutter/foundation.dart';


@immutable
class GalleryComment {
  
  const GalleryComment({
    required this.name,
    required this.time,
    required this.score,
    this.vote,
    this.id,
    this.memberId,
    this.canEdit,
    this.canVote,
    this.showTranslate,
    this.scoreDetails,
    this.rawContent,
    this.translatedContent,
    this.text,
    this.translatedText,
  });

  final String name;
  final String time;
  final String score;
  final int? vote;
  final String? id;
  final String? memberId;
  final bool? canEdit;
  final bool? canVote;
  final bool? showTranslate;
  final List<String>? scoreDetails;
  final String? rawContent;
  final String? translatedContent;
  final String? text;
  final String? translatedText;

  factory GalleryComment.fromJson(Map<String,dynamic> json) => GalleryComment(
    name: json['name'] as String,
    time: json['time'] as String,
    score: json['score'] as String,
    vote: json['vote'] != null ? json['vote'] as int : null,
    id: json['id'] != null ? json['id'] as String : null,
    memberId: json['memberId'] != null ? json['memberId'] as String : null,
    canEdit: json['canEdit'] != null ? json['canEdit'] as bool : null,
    canVote: json['canVote'] != null ? json['canVote'] as bool : null,
    showTranslate: json['showTranslate'] != null ? json['showTranslate'] as bool : null,
    scoreDetails: json['scoreDetails'] != null ? (json['scoreDetails'] as List? ?? []).map((e) => e as String).toList() : null,
    rawContent: json['rawContent'] != null ? json['rawContent'] as String : null,
    translatedContent: json['translatedContent'] != null ? json['translatedContent'] as String : null,
    text: json['text'] != null ? json['text'] as String : null,
    translatedText: json['translatedText'] != null ? json['translatedText'] as String : null
  );
  
  Map<String, dynamic> toJson() => {
    'name': name,
    'time': time,
    'score': score,
    'vote': vote,
    'id': id,
    'memberId': memberId,
    'canEdit': canEdit,
    'canVote': canVote,
    'showTranslate': showTranslate,
    'scoreDetails': scoreDetails?.map((e) => e.toString()).toList(),
    'rawContent': rawContent,
    'translatedContent': translatedContent,
    'text': text,
    'translatedText': translatedText
  };

  GalleryComment clone() => GalleryComment(
    name: name,
    time: time,
    score: score,
    vote: vote,
    id: id,
    memberId: memberId,
    canEdit: canEdit,
    canVote: canVote,
    showTranslate: showTranslate,
    scoreDetails: scoreDetails?.toList(),
    rawContent: rawContent,
    translatedContent: translatedContent,
    text: text,
    translatedText: translatedText
  );

    
  GalleryComment copyWith({
    String? name,
    String? time,
    String? score,
    int? vote,
    String? id,
    String? memberId,
    bool? canEdit,
    bool? canVote,
    bool? showTranslate,
    List<String>? scoreDetails,
    String? rawContent,
    String? translatedContent,
    String? text,
    String? translatedText
  }) => GalleryComment(
    name: name ?? this.name,
    time: time ?? this.time,
    score: score ?? this.score,
    vote: vote ?? this.vote,
    id: id ?? this.id,
    memberId: memberId ?? this.memberId,
    canEdit: canEdit ?? this.canEdit,
    canVote: canVote ?? this.canVote,
    showTranslate: showTranslate ?? this.showTranslate,
    scoreDetails: scoreDetails ?? this.scoreDetails,
    rawContent: rawContent ?? this.rawContent,
    translatedContent: translatedContent ?? this.translatedContent,
    text: text ?? this.text,
    translatedText: translatedText ?? this.translatedText,
  );  

  @override
  bool operator ==(Object other) => identical(this, other) 
    || other is GalleryComment && name == other.name && time == other.time && score == other.score && vote == other.vote && id == other.id && memberId == other.memberId && canEdit == other.canEdit && canVote == other.canVote && showTranslate == other.showTranslate && scoreDetails == other.scoreDetails && rawContent == other.rawContent && translatedContent == other.translatedContent && text == other.text && translatedText == other.translatedText;

  @override
  int get hashCode => name.hashCode ^ time.hashCode ^ score.hashCode ^ vote.hashCode ^ id.hashCode ^ memberId.hashCode ^ canEdit.hashCode ^ canVote.hashCode ^ showTranslate.hashCode ^ scoreDetails.hashCode ^ rawContent.hashCode ^ translatedContent.hashCode ^ text.hashCode ^ translatedText.hashCode;
}
