// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'boss_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BossData _$BossDataFromJson(Map<String, dynamic> json) => BossData(
  name: json['name'] as String,
  type: BossData._typeFromJson(json['type'] as String),
  icon: json['icon'] as String,
  uniques:
      (json['uniques'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$BossDataToJson(BossData instance) => <String, dynamic>{
  'name': instance.name,
  'type': BossData._typeToJson(instance.type),
  'icon': instance.icon,
  'uniques': instance.uniques,
};
