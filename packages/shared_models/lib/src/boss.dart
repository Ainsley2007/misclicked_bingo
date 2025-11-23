import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import 'boss_type.dart';

part 'boss.g.dart';

@JsonSerializable()
class Boss extends Equatable {
  final String id;
  final String name;
  @JsonKey(fromJson: _typeFromJson, toJson: _typeToJson)
  final BossType type;
  final String iconUrl;
  final List<String> uniqueItems;

  const Boss({
    required this.id,
    required this.name,
    required this.type,
    required this.iconUrl,
    required this.uniqueItems,
  });

  static BossType _typeFromJson(String json) => BossType.fromString(json);
  static String _typeToJson(BossType type) => type.value;

  factory Boss.fromJson(Map<String, dynamic> json) => _$BossFromJson(json);
  Map<String, dynamic> toJson() => _$BossToJson(this);

  @override
  List<Object?> get props => [id, name, type, iconUrl, uniqueItems];
}
