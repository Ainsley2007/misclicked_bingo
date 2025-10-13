// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_team.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Game _$GameFromJson(Map<String, dynamic> json) => Game(
  id: json['id'] as String,
  code: json['code'] as String,
  name: json['name'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$GameToJson(Game instance) => <String, dynamic>{
  'id': instance.id,
  'code': instance.code,
  'name': instance.name,
  'createdAt': instance.createdAt.toIso8601String(),
};

Team _$TeamFromJson(Map<String, dynamic> json) => Team(
  id: json['id'] as String,
  gameId: json['gameId'] as String,
  name: json['name'] as String,
  captainUserId: json['captainUserId'] as String,
);

Map<String, dynamic> _$TeamToJson(Team instance) => <String, dynamic>{
  'id': instance.id,
  'gameId': instance.gameId,
  'name': instance.name,
  'captainUserId': instance.captainUserId,
};
