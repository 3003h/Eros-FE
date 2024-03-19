import 'package:flutter/foundation.dart';
import 'package:quiver/core.dart';

import 'index.dart';

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
    name: json['name'].toString(),
    time: json['time'].toString(),
    score: json['score'].toString(),
    vote: json['vote'] != null ? int.tryParse('${json['vote']}') ?? 0 : null,
    id: json['id']?.toString(),
    memberId: json['memberId']?.toString(),
    canEdit: json['canEdit'] != null ? bool.tryParse('${json['canEdit']}', caseSensitive: false) ?? false : null,
    canVote: json['canVote'] != null ? bool.tryParse('${json['canVote']}', caseSensitive: false) ?? false : null,
    showTranslate: json['showTranslate'] != null ? bool.tryParse('${json['showTranslate']}', caseSensitive: false) ?? false : null,
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
    Optional<int?>? vote,
    Optional<String?>? id,
    Optional<String?>? memberId,
    Optional<bool?>? canEdit,
    Optional<bool?>? canVote,
    Optional<bool?>? showTranslate,
    Optional<List<String>?>? scoreDetails,
    Optional<dynamic?>? element,
    Optional<dynamic?>? translatedElement,
    Optional<List<String>?>? textList,
    Optional<List<String>?>? translatedTextList
  }) => GalleryComment(
    name: name ?? this.name,
    time: time ?? this.time,
    score: score ?? this.score,
    vote: checkOptional(vote, () => this.vote),
    id: checkOptional(id, () => this.id),
    memberId: checkOptional(memberId, () => this.memberId),
    canEdit: checkOptional(canEdit, () => this.canEdit),
    canVote: checkOptional(canVote, () => this.canVote),
    showTranslate: checkOptional(showTranslate, () => this.showTranslate),
    scoreDetails: checkOptional(scoreDetails, () => this.scoreDetails),
    element: checkOptional(element, () => this.element),
    translatedElement: checkOptional(translatedElement, () => this.translatedElement),
    textList: checkOptional(textList, () => this.textList),
    translatedTextList: checkOptional(translatedTextList, () => this.translatedTextList),
  );

  @override
  bool operator ==(Object other) => identical(this, other)
    || other is GalleryComment && name == other.name && time == other.time && score == other.score && vote == other.vote && id == other.id && memberId == other.memberId && canEdit == other.canEdit && canVote == other.canVote && showTranslate == other.showTranslate && scoreDetails == other.scoreDetails && element == other.element && translatedElement == other.translatedElement && textList == other.textList && translatedTextList == other.translatedTextList;

  @override
  int get hashCode => name.hashCode ^ time.hashCode ^ score.hashCode ^ vote.hashCode ^ id.hashCode ^ memberId.hashCode ^ canEdit.hashCode ^ canVote.hashCode ^ showTranslate.hashCode ^ scoreDetails.hashCode ^ element.hashCode ^ translatedElement.hashCode ^ textList.hashCode ^ translatedTextList.hashCode;
}
