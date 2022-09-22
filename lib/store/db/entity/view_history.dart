import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:isar/isar.dart';
import 'package:json_annotation/json_annotation.dart';

part 'view_history.g.dart';

@CopyWith()
@JsonSerializable()
@Collection()
class ViewHistory {
  ViewHistory({
    required this.gid,
    required this.lastViewTime,
    required this.galleryProviderText,
  });

  factory ViewHistory.fromJson(Map<String, dynamic> json) =>
      _$ViewHistoryFromJson(json);

  Map<String, dynamic> toJson() => _$ViewHistoryToJson(this);

  @Index(unique: true)
  @Id()
  final int gid;
  @Index()
  final int lastViewTime;
  final String galleryProviderText;

  @override
  String toString() {
    return 'ViewHistory{gid: $gid, lastViewTime: $lastViewTime, galleryProviderText: $galleryProviderText}';
  }
}
