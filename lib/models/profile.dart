import 'package:json_annotation/json_annotation.dart';

import 'cacheConfig.dart';
import 'ehConfig.dart';
import 'galleryItem.dart';
import 'user.dart';

part 'profile.g.dart';

@JsonSerializable()
class Profile {
  Profile();

  User user;
  CacheConfig cache;
  EhConfig ehConfig;
  String lastLogin;
  String locale;
  String theme;
  List<String> searchText;
  List<GalleryItem> history;
  List<GalleryItem> localFav;

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileToJson(this);
}
