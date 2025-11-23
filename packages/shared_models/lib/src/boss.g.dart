// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'boss.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Boss _$BossFromJson(Map<String, dynamic> json) => Boss(
  id: json['id'] as String,
  name: json['name'] as String,
  type: Boss._typeFromJson(json['type'] as String),
  iconUrl: json['iconUrl'] as String,
  uniqueItems: (json['uniqueItems'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$BossToJson(Boss instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'type': Boss._typeToJson(instance.type),
  'iconUrl': instance.iconUrl,
  'uniqueItems': instance.uniqueItems,
};
