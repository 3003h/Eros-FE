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
    this.element,
    this.translatedElement,
    this.textList,
    this.translatedTextList,
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
  final dynamic? element;
  final dynamic? translatedElement;
  final List<String>? textList;
  final List<String>? translatedTextList;

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
    textList: json['textList'] != null ? (json['textList'] as List? ?? []).map((e) => e as String).toList() : null,
    translatedTextList: json['translatedTextList'] != null ? (json['translatedTextList'] as List? ?? []).map((e) => e as String).toList() : null
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
    'textList': textList?.map((e) => e.toString()).toList(),
    'translatedTextList': translatedTextList?.map((e) => e.toString()).toList()
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
    element: element,
    translatedElement: translatedElement,
    textList: textList?.toList(),
    translatedTextList: translatedTextList?.toList()
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
    dynamic? element,
    dynamic? translatedElement,
    List<String>? textList,
    List<String>? translatedTextList
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
    element: element ?? this.element,
    translatedElement: translatedElement ?? this.translatedElement,
    textList: textList ?? this.textList,
    translatedTextList: translatedTextList ?? this.translatedTextList,
  );  

  @override
  bool operator ==(Object other) => identical(this, other) 
    || other is GalleryComment && name == other.name && time == other.time && score == other.score && vote == other.vote && id == other.id && memberId == other.memberId && canEdit == other.canEdit && canVote == other.canVote && showTranslate == other.showTranslate && scoreDetails == other.scoreDetails && element == other.element && translatedElement == other.translatedElement && textList == other.textList && translatedTextList == other.translatedTextList;

  @override
  int get hashCode => name.hashCode ^ time.hashCode ^ score.hashCode ^ vote.hashCode ^ id.hashCode ^ memberId.hashCode ^ canEdit.hashCode ^ canVote.hashCode ^ showTranslate.hashCode ^ scoreDetails.hashCode ^ element.hashCode ^ translatedElement.hashCode ^ textList.hashCode ^ translatedTextList.hashCode;
}
