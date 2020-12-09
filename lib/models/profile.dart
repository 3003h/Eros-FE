import 'package:json_annotation/json_annotation.dart';
import 'user.dart';
import 'cacheConfig.dart';
import 'ehConfig.dart';
import 'galleryItem.dart';
import 'localFav.dart';
import 'advanceSearch.dart';
import 'dnsConfig.dart';
import 'downloadConfig.dart';

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
  LocalFav localFav;
  bool enableAdvanceSearch;
  AdvanceSearch advanceSearch;
  DnsConfig dnsConfig;
  DownloadConfig downloadConfig;

  factory Profile.fromJson(Map<String,dynamic> json) => _$ProfileFromJson(json);
  Map<String, dynamic> toJson() => _$ProfileToJson(this);
}
