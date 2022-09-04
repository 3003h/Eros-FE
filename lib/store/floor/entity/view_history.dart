import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:floor/floor.dart';
import 'package:json_annotation/json_annotation.dart';

part 'view_history.g.dart';

@CopyWith()
@Entity(tableName: 'ViewHistory', primaryKeys: ['gid'])
@JsonSerializable()
class ViewHistory {
  ViewHistory({
    required this.gid,
    required this.lastViewTime,
    required this.galleryProviderText,
  });

  factory ViewHistory.fromJson(Map<String, dynamic> json) =>
      _$ViewHistoryFromJson(json);

  Map<String, dynamic> toJson() => _$ViewHistoryToJson(this);

  final int gid;
  final int lastViewTime;
  final String galleryProviderText;

  @override
  String toString() {
    return 'ViewHistory{gid: $gid, lastViewTime: $lastViewTime, galleryProviderText: $galleryProviderText}';
  }
}
