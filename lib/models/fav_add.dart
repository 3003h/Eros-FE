import 'package:flutter/foundation.dart';
import 'package:quiver/core.dart';

import 'index.dart';

@immutable
class FavAdd {

  const FavAdd({
    required this.favcats,
    this.selectFavcat,
    this.favNote,
    required this.maxNoteSlots,
    required this.usedNoteSlots,
  });

  final List<Favcat> favcats;
  final String? selectFavcat;
  final String? favNote;
  final String maxNoteSlots;
  final String usedNoteSlots;

  factory FavAdd.fromJson(Map<String,dynamic> json) => FavAdd(
    favcats: (json['favcats'] as List? ?? []).map((e) => Favcat.fromJson(e as Map<String, dynamic>)).toList(),
    selectFavcat: json['selectFavcat']?.toString(),
    favNote: json['favNote']?.toString(),
    maxNoteSlots: json['maxNoteSlots'].toString(),
    usedNoteSlots: json['usedNoteSlots'].toString()
  );
  
  Map<String, dynamic> toJson() => {
    'favcats': favcats.map((e) => e.toJson()).toList(),
    'selectFavcat': selectFavcat,
    'favNote': favNote,
    'maxNoteSlots': maxNoteSlots,
    'usedNoteSlots': usedNoteSlots
  };

  FavAdd clone() => FavAdd(
    favcats: favcats.map((e) => e.clone()).toList(),
    selectFavcat: selectFavcat,
    favNote: favNote,
    maxNoteSlots: maxNoteSlots,
    usedNoteSlots: usedNoteSlots
  );


  FavAdd copyWith({
    List<Favcat>? favcats,
    Optional<String?>? selectFavcat,
    Optional<String?>? favNote,
    String? maxNoteSlots,
    String? usedNoteSlots
  }) => FavAdd(
    favcats: favcats ?? this.favcats,
    selectFavcat: checkOptional(selectFavcat, () => this.selectFavcat),
    favNote: checkOptional(favNote, () => this.favNote),
    maxNoteSlots: maxNoteSlots ?? this.maxNoteSlots,
    usedNoteSlots: usedNoteSlots ?? this.usedNoteSlots,
  );

  @override
  bool operator ==(Object other) => identical(this, other)
    || other is FavAdd && favcats == other.favcats && selectFavcat == other.selectFavcat && favNote == other.favNote && maxNoteSlots == other.maxNoteSlots && usedNoteSlots == other.usedNoteSlots;

  @override
  int get hashCode => favcats.hashCode ^ selectFavcat.hashCode ^ favNote.hashCode ^ maxNoteSlots.hashCode ^ usedNoteSlots.hashCode;
}
