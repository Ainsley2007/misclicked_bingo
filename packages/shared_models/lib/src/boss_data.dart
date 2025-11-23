import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'boss_type.dart';

part 'boss_data.g.dart';

@JsonSerializable()
class BossData extends Equatable {
  final String name;
  @JsonKey(fromJson: _typeFromJson, toJson: _typeToJson)
  final BossType type;
  final String icon;
  final List<String> uniques;

  const BossData({
    required this.name,
    required this.type,
    required this.icon,
    this.uniques = const [],
  });

  static BossType _typeFromJson(String json) => BossType.fromString(json);
  static String _typeToJson(BossType type) => type.value;

  factory BossData.fromJson(Map<String, dynamic> json) =>
      _$BossDataFromJson(json);
  Map<String, dynamic> toJson() => _$BossDataToJson(this);

  @override
  List<Object?> get props => [name, type, icon, uniques];
}
